package common

import (
	"database/sql/driver"
	"time"
)

// User represents a user in the system
// Corresponds to User entity class in the Java project
type User struct {
	ID           int64     `json:"id"                     db:"id"`
	Username     string    `json:"username"               db:"username"      validate:"required,min=3,max=50"`
	Email        string    `json:"email"                  db:"email"         validate:"required,email"`
	FullName     string    `json:"full_name"              db:"full_name"     validate:"required,min=1,max=100"`
	PasswordHash string    `json:"-"                      db:"password_hash"` // Not exposed in JSON
	PhoneNumber  *string   `json:"phone_number,omitempty" db:"phone_number"`
	IsActive     bool      `json:"is_active"              db:"is_active"`
	CreatedAt    time.Time `json:"created_at"             db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"             db:"updated_at"`
	CreatedBy    *string   `json:"created_by,omitempty"   db:"created_by"`
	UpdatedBy    *string   `json:"updated_by,omitempty"   db:"updated_by"`
	Version      int       `json:"version"                db:"version"` // Optimistic locking version number
}

// CreateUserRequest represents a request to create a new user
// Corresponds to CreateUserRequest DTO in the Java project
type CreateUserRequest struct {
	Username    string  `json:"username"               validate:"required,min=3,max=50"`
	Email       string  `json:"email"                  validate:"required,email"`
	FullName    string  `json:"full_name"              validate:"required,min=1,max=100"`
	Password    string  `json:"password"               validate:"required,min=6,max=100"`
	PhoneNumber *string `json:"phone_number,omitempty" validate:"omitempty,min=10,max=20"`
}

// UpdateUserRequest represents a request to update an existing user
// Corresponds to UpdateUserRequest DTO in the Java project
type UpdateUserRequest struct {
	Email       *string `json:"email,omitempty"        validate:"omitempty,email"`
	FullName    *string `json:"full_name,omitempty"    validate:"omitempty,min=1,max=100"`
	PhoneNumber *string `json:"phone_number,omitempty" validate:"omitempty,min=10,max=20"`
	IsActive    *bool   `json:"is_active,omitempty"`
	Version     int     `json:"version"                validate:"required"` // Required for optimistic locking
}

// UserResponse represents a user response data structure
// Corresponds to UserResponse DTO in the Java project
type UserResponse struct {
	ID          int64     `json:"id"`
	Username    string    `json:"username"`
	Email       string    `json:"email"`
	FullName    string    `json:"full_name"`
	PhoneNumber *string   `json:"phone_number,omitempty"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	CreatedBy   *string   `json:"created_by,omitempty"`
	UpdatedBy   *string   `json:"updated_by,omitempty"`
	Version     int       `json:"version"`
}

// ApiResponse represents a unified API response format
// Corresponds to ApiResponse in the Java project
type ApiResponse[T any] struct {
	Success   bool   `json:"success"`
	Message   string `json:"message"`
	Data      T      `json:"data,omitempty"`
	Error     string `json:"error,omitempty"`
	Timestamp string `json:"timestamp"`
}

// PagedResponse represents a paginated response structure
type PagedResponse[T any] struct {
	Content       []T   `json:"content"`
	Page          int   `json:"page"`
	Size          int   `json:"size"`
	TotalElements int64 `json:"total_elements"`
	TotalPages    int   `json:"total_pages"`
	First         bool  `json:"first"`
	Last          bool  `json:"last"`
}

// UserFilter represents filtering criteria for user queries
type UserFilter struct {
	Username *string `json:"username,omitempty"  form:"username"`
	Email    *string `json:"email,omitempty"     form:"email"`
	IsActive *bool   `json:"is_active,omitempty" form:"is_active"`
	Page     int     `json:"page"                form:"page"      validate:"min=0"`
	Size     int     `json:"size"                form:"size"      validate:"min=1,max=100"`
}

// Value implements driver.Valuer interface for database storage
func (u User) Value() (driver.Value, error) {
	return u.ID, nil
}

// ToResponse converts User to UserResponse
func (u *User) ToResponse() *UserResponse {
	return &UserResponse{
		ID:          u.ID,
		Username:    u.Username,
		Email:       u.Email,
		FullName:    u.FullName,
		PhoneNumber: u.PhoneNumber,
		IsActive:    u.IsActive,
		CreatedAt:   u.CreatedAt,
		UpdatedAt:   u.UpdatedAt,
		CreatedBy:   u.CreatedBy,
		UpdatedBy:   u.UpdatedBy,
		Version:     u.Version,
	}
}
