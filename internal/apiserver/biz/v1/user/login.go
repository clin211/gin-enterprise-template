package user

import (
	"context"
	"log/slog"

	"github.com/clin211/gin-enterprise-template/pkg/authn"
	"github.com/clin211/gin-enterprise-template/pkg/store/where"
	"github.com/clin211/gin-enterprise-template/pkg/token"

	"github.com/clin211/gin-enterprise-template/internal/pkg/errno"
	v1 "github.com/clin211/gin-enterprise-template/pkg/api/apiserver/v1"
)

// Login 实现 UserBiz 接口中的 Login 方法.
func (b *userBiz) Login(ctx context.Context, rq *v1.LoginRequest) (*v1.LoginResponse, error) {
	// 验证验证码
	if err := b.VerifyCaptcha(ctx, rq.GetCaptchaID(), rq.GetVerifyCode()); err != nil {
		slog.ErrorContext(ctx, "Captcha verification failed", "error", err)
		return nil, errno.ErrCaptchaInvalid
	}

	// 获取登录用户的所有信息
	whr := where.F("username", rq.GetUsername())
	userM, err := b.store.User().Get(ctx, whr)
	if err != nil {
		return nil, errno.ErrUserNotFound
	}

	// 对比传入的明文密码和数据库中已加密过的密码是否匹配
	if err := authn.Compare(userM.Password, rq.GetPassword()); err != nil {
		slog.ErrorContext(ctx, "Failed to compare password", "error", err)
		return nil, errno.ErrPasswordInvalid
	}

	// 如果匹配成功，说明登录成功，签发 token 并返回
	tokenStr, expireAt, err := token.Sign(userM.UserID)
	if err != nil {
		slog.ErrorContext(ctx, "Failed to sign token", "error", err)
		return nil, errno.ErrSignToken
	}

	return &v1.LoginResponse{Token: tokenStr, ExpireAt: expireAt.Unix()}, nil
}
