package options

import (
	"fmt"
	"time"

	"github.com/spf13/pflag"
)

var _ IOptions = (*JWTOptions)(nil)

// JWTOptions 包含与 JWT 认证相关的配置项。
type JWTOptions struct {
	// Secret 是用于签名 JWT 令牌的私钥。
	Secret string `json:"secret" mapstructure:"secret"`
	// AccessExpiration 是访问令牌的过期时间。
	AccessExpiration time.Duration `json:"access-expiration" mapstructure:"access-expiration"`
	// RefreshExpiration 是刷新令牌的过期时间。
	RefreshExpiration time.Duration `json:"refresh-expiration" mapstructure:"refresh-expiration"`

	fullPrefix string
}

// NewJWTOptions 创建带有默认参数的 JWTOptions 对象。
func NewJWTOptions() *JWTOptions {
	return &JWTOptions{
		Secret:            "9NJE1L0b4Vf2UG8IitQgr0lw0odMu0y8",
		AccessExpiration:  2 * time.Hour,
		RefreshExpiration: 168 * time.Hour, // 7 days
	}
}

// Validate 用于解析和验证 JWT 参数。
func (o *JWTOptions) Validate() []error {
	var errs []error

	if o.Secret == "" {
		errs = append(errs, fmt.Errorf("--%s.secret must be specified", o.fullPrefix))
	}
	if len(o.Secret) < 6 {
		errs = append(errs, fmt.Errorf("--%s.secret must be at least 6 characters long", o.fullPrefix))
	}
	if o.AccessExpiration <= 0 {
		errs = append(errs, fmt.Errorf("--%s.access-expiration must be positive", o.fullPrefix))
	}
	if o.RefreshExpiration <= 0 {
		errs = append(errs, fmt.Errorf("--%s.refresh-expiration must be positive", o.fullPrefix))
	}
	if o.RefreshExpiration < o.AccessExpiration {
		errs = append(errs, fmt.Errorf("--%s.refresh-expiration must be greater than or equal to access-expiration", o.fullPrefix))
	}

	return errs
}

// AddFlags 将与 JWT 配置相关的标志添加到指定的 FlagSet。
func (o *JWTOptions) AddFlags(fs *pflag.FlagSet, fullPrefix string) {
	if fs == nil {
		return
	}

	o.fullPrefix = fullPrefix
	fs.StringVar(&o.Secret, fullPrefix+".secret", o.Secret, "Private key used to sign JWT tokens.")
	fs.DurationVar(&o.AccessExpiration, fullPrefix+".access-expiration", o.AccessExpiration, "JWT access token expiration time.")
	fs.DurationVar(&o.RefreshExpiration, fullPrefix+".refresh-expiration", o.RefreshExpiration, "JWT refresh token expiration time.")
}
