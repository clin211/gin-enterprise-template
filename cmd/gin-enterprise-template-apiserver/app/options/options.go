// nolint: err113
package options

import (
	genericoptions "github.com/clin211/gin-enterprise-template/pkg/options"
	"github.com/spf13/pflag"
	utilerrors "k8s.io/apimachinery/pkg/util/errors"

	"github.com/clin211/gin-enterprise-template/internal/apiserver"
)

// ServerOptions contains the configuration options for the server.
type ServerOptions struct {
	// JWTOptions contains the JWT authentication configuration options.
	JWTOptions *genericoptions.JWTOptions `json:"jwt" mapstructure:"jwt"`
	// TLSOptions contains the TLS configuration options.
	TLSOptions *genericoptions.TLSOptions `json:"tls" mapstructure:"tls"`
	// HTTPOptions contains the HTTP configuration options.
	HTTPOptions *genericoptions.HTTPOptions `json:"http" mapstructure:"http"`
	// PostgreSQLOptions contains the PostgreSQL configuration options.
	PostgreSQLOptions *genericoptions.PostgreSQLOptions `json:"postgresql" mapstructure:"postgresql"`
	// RedisOptions contains the Redis configuration options.
	RedisOptions *genericoptions.RedisOptions `json:"redis" mapstructure:"redis"`
	// OTelOptions used to specify the otel options.
	OTelOptions *genericoptions.OTelOptions `json:"otel" mapstructure:"otel"`
}

// NewServerOptions creates a ServerOptions instance with default values.
func NewServerOptions() *ServerOptions {
	opts := &ServerOptions{
		JWTOptions:        genericoptions.NewJWTOptions(),
		TLSOptions:        genericoptions.NewTLSOptions(),
		HTTPOptions:       genericoptions.NewHTTPOptions(),
		PostgreSQLOptions: genericoptions.NewPostgreSQLOptions(),
		RedisOptions:      genericoptions.NewRedisOptions(),
		OTelOptions:       genericoptions.NewOTelOptions(),
	}
	opts.HTTPOptions.Addr = ":5555"

	return opts
}

// AddFlags binds the options in ServerOptions to command-line flags.
func (o *ServerOptions) AddFlags(fs *pflag.FlagSet) {
	// Add JWT options flags
	o.JWTOptions.AddFlags(fs, "jwt")
	// Add command-line flags for sub-options.
	o.TLSOptions.AddFlags(fs, "tls")
	o.HTTPOptions.AddFlags(fs, "http")
	o.PostgreSQLOptions.AddFlags(fs, "postgresql")
	o.RedisOptions.AddFlags(fs, "redis")
	o.OTelOptions.AddFlags(fs, "otel")
}

// Complete completes all the required options.
func (o *ServerOptions) Complete() error {
	// TODO: Add the completion logic if needed.
	return nil
}

// Validate checks whether the options in ServerOptions are valid.
func (o *ServerOptions) Validate() error {
	errs := []error{}

	// Validate JWT options
	errs = append(errs, o.JWTOptions.Validate()...)
	// Validate sub-options.
	errs = append(errs, o.TLSOptions.Validate()...)
	errs = append(errs, o.HTTPOptions.Validate()...)
	errs = append(errs, o.PostgreSQLOptions.Validate()...)
	errs = append(errs, o.RedisOptions.Validate()...)
	errs = append(errs, o.OTelOptions.Validate()...)

	// Aggregate all errors and return them.
	return utilerrors.NewAggregate(errs)
}

// Config builds an apiserver.Config based on ServerOptions.
func (o *ServerOptions) Config() (*apiserver.Config, error) {
	return &apiserver.Config{
		JWTOptions:        o.JWTOptions,
		TLSOptions:        o.TLSOptions,
		HTTPOptions:       o.HTTPOptions,
		PostgreSQLOptions: o.PostgreSQLOptions,
		RedisOptions:      o.RedisOptions,
	}, nil
}
