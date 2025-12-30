package db

import (
	"fmt"
	"time"

	"database/sql"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// MySQLOptions defines options for mysql database.
type MySQLOptions struct {
	Addr                  string
	Username              string
	Password              string
	Database              string
	MaxIdleConnections    int
	MaxOpenConnections    int
	MaxConnectionLifeTime time.Duration
	// +optional
	Logger logger.Interface
	// +optional
	// Location 指定时区，默认为 Local
	Location string
}

// DSN return DSN from MySQLOptions.
func (o *MySQLOptions) DSN() string {
	loc := o.Location
	if loc == "" {
		loc = "Local"
	}
	return fmt.Sprintf(`%s:%s@tcp(%s)/%s?charset=utf8&parseTime=%t&loc=%s`,
		o.Username,
		o.Password,
		o.Addr,
		o.Database,
		true,
		loc)
}

// NewMySQL create a new gorm db instance with the given options.
func NewMySQL(opts *MySQLOptions) (*gorm.DB, error) {
	// Set default values to ensure all fields in opts are available.
	setMySQLDefaults(opts)

	db, err := gorm.Open(mysql.Open(opts.DSN()), &gorm.Config{
		// PrepareStmt executes the given query in cached statement.
		// This can improve performance.
		PrepareStmt: true,
		Logger:      opts.Logger,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to open mysql: %w", err)
	}

	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get sql.DB: %w", err)
	}

	// SetMaxOpenConns sets the maximum number of open connections to the database.
	sqlDB.SetMaxOpenConns(opts.MaxOpenConnections)

	// SetConnMaxLifetime sets the maximum amount of time a connection may be reused.
	sqlDB.SetConnMaxLifetime(opts.MaxConnectionLifeTime)

	// SetMaxIdleConns sets the maximum number of connections in the idle connection pool.
	sqlDB.SetMaxIdleConns(opts.MaxIdleConnections)

	return db, nil
}

// setMySQLDefaults set available default values for some fields.
func setMySQLDefaults(opts *MySQLOptions) {
	if opts.Addr == "" {
		opts.Addr = "127.0.0.1:3306"
	}
	if opts.MaxIdleConnections == 0 {
		opts.MaxIdleConnections = 100
	}
	if opts.MaxOpenConnections == 0 {
		opts.MaxOpenConnections = 100
	}
	if opts.MaxConnectionLifeTime == 0 {
		opts.MaxConnectionLifeTime = time.Duration(10) * time.Second
	}
	if opts.Logger == nil {
		opts.Logger = logger.Default
	}
	if opts.Location == "" {
		opts.Location = "Local"
	}
}

// MustRawDB 获取底层的 *sql.DB，如果出错则 panic。
// 注意：此函数设计用于程序启动时的配置验证阶段，
// 此时如果发生错误通常表示配置严重错误，程序应该终止。
// 如果需要更安全的错误处理，请使用 db.DB() 方法。
func MustRawDB(db *gorm.DB) *sql.DB {
	raw, err := db.DB()
	if err != nil {
		panic(fmt.Errorf("failed to get raw DB: %w", err))
	}
	return raw
}

// RawDB 获取底层的 *sql.DB，返回错误。
func RawDB(db *gorm.DB) (*sql.DB, error) {
	raw, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get raw DB: %w", err)
	}
	return raw, nil
}
