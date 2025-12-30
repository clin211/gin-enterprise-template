package options

import (
	"fmt"
	"time"

	"github.com/spf13/pflag"
)

var _ IOptions = (*JWTOptions)(nil)

// JWTOptions contains configuration items related to JWT authentication.
type JWTOptions struct {
	// Secret is the private key used to sign JWT tokens.
	Secret string `json:"secret" mapstructure:"secret"`
	// AccessExpiration is the expiration time for access tokens.
	AccessExpiration time.Duration `json:"access-expiration" mapstructure:"access-expiration"`
	// RefreshExpiration is the expiration time for refresh tokens.
	RefreshExpiration time.Duration `json:"refresh-expiration" mapstructure:"refresh-expiration"`

	fullPrefix string
}

// NewJWTOptions creates a JWTOptions object with default parameters.
func NewJWTOptions() *JWTOptions {
	return &JWTOptions{
		Secret:            "9NJE1L0b4Vf2UG8IitQgr0lw0odMu0y8",
		AccessExpiration:  2 * time.Hour,
		RefreshExpiration: 168 * time.Hour, // 7 days
	}
}

// Validate is used to parse and validate the JWT parameters.
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

// AddFlags adds flags related to JWT configuration to the specified FlagSet.
func (o *JWTOptions) AddFlags(fs *pflag.FlagSet, fullPrefix string) {
	if fs == nil {
		return
	}

	o.fullPrefix = fullPrefix
	fs.StringVar(&o.Secret, fullPrefix+".secret", o.Secret, "Private key used to sign JWT tokens.")
	fs.DurationVar(&o.AccessExpiration, fullPrefix+".access-expiration", o.AccessExpiration, "JWT access token expiration time.")
	fs.DurationVar(&o.RefreshExpiration, fullPrefix+".refresh-expiration", o.RefreshExpiration, "JWT refresh token expiration time.")
}
