package model

import (
	"github.com/clin211/gin-enterprise-template/pkg/authn"
	"gorm.io/gorm"
)

// BeforeCreate encrypts the plaintext password before creating a database record.
func (m *UserM) BeforeCreate(tx *gorm.DB) error {
	// Encrypt the user password.
	var err error
	m.Password, err = authn.Encrypt(m.Password)
	if err != nil {
		return err
	}

	return nil
}
