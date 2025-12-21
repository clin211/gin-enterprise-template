package user

import (
	"context"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"github.com/clin211/gin-enterprise-template/internal/pkg/known"
	v1 "github.com/clin211/gin-enterprise-template/pkg/api/apiserver/v1"
	"github.com/mojocn/base64Captcha"
)

// GetCaptcha 获取图形验证码
func (b *userBiz) GetCaptcha(ctx context.Context, rq *v1.GetCaptchaRequest) (*v1.GetCaptchaResponse, error) {
	// 固定配置：数字验证码，长度4，宽度120，高度64
	driver := &base64Captcha.DriverDigit{
		Height:   64,
		Width:    120,
		Length:   4,
		MaxSkew:  0.7,
		DotCount: 80,
	}

	// 创建验证码存储，直接使用 b.redis
	store := &CaptchaStore{biz: b}

	// 创建验证码
	captcha := base64Captcha.NewCaptcha(driver, store)

	// 生成验证码
	id, b64s, answer, err := captcha.Generate()
	if err != nil {
		slog.Error("Failed to generate captcha", "error", err)
		return nil, fmt.Errorf("failed to generate captcha: %w", err)
	}

	slog.Info("Generated captcha", "captchaID", id, "answer", answer)

	response := &v1.GetCaptchaResponse{
		CaptchaID:    id,
		CaptchaImage: b64s,
	}

	return response, nil
}

// VerifyCaptcha 验证验证码
func (b *userBiz) VerifyCaptcha(ctx context.Context, captchaID, verifyCode string) error {
	if captchaID == "" || verifyCode == "" {
		return fmt.Errorf("captchaID and verifyCode cannot be empty")
	}

	// 使用已注入的 Redis 验证验证码
	key := known.CaptchaKeyPrefix + captchaID

	// 获取存储的验证码
	val, err := b.redis.Get(ctx, key).Result()
	if err != nil {
		slog.ErrorContext(ctx, "Failed to get captcha from Redis", "captchaID", captchaID, "error", err)
		return fmt.Errorf("验证码不存在或已过期")
	}

	// 验证验证码（不区分大小写）
	if !strings.EqualFold(val, verifyCode) {
		slog.ErrorContext(ctx, "Invalid captcha", "captchaID", captchaID, "provided", verifyCode, "expected", val)
		return fmt.Errorf("验证码错误")
	}

	// 验证成功后删除验证码
	if err := b.redis.Del(ctx, key).Err(); err != nil {
		slog.WarnContext(ctx, "Failed to delete captcha after verification", "captchaID", captchaID, "error", err)
	}

	return nil
}

// CaptchaStore 实现 base64Captcha.Store 接口
type CaptchaStore struct {
	biz *userBiz
}

// Set 设置验证码到 Redis
func (cs *CaptchaStore) Set(id string, value string) error {
	if cs.biz.redis == nil {
		return fmt.Errorf("redis client is nil")
	}

	// 验证码过期时间：5分钟
	key := known.CaptchaKeyPrefix + id
	return cs.biz.redis.Set(context.Background(), key, value, 5*time.Minute).Err()
}

// Get 从 Redis 获取验证码
func (cs *CaptchaStore) Get(id string, clear bool) string {
	if cs.biz.redis == nil {
		return ""
	}

	key := known.CaptchaKeyPrefix + id

	// 获取验证码
	val, err := cs.biz.redis.Get(context.Background(), key).Result()
	if err != nil {
		return ""
	}

	// 如果需要清除，则删除验证码
	if clear {
		cs.biz.redis.Del(context.Background(), key)
	}

	return val
}

// Verify 验证验证码
func (cs *CaptchaStore) Verify(id, answer string, clear bool) bool {
	value := cs.Get(id, clear)
	return strings.EqualFold(value, answer) // 不区分大小写比较
}
