package common

import (
	"database/sql/driver"
	"time"
)

// User represents a user in the system
// 对应Java项目的User实体类
type User struct {
	ID           int64     `json:"id"                     db:"id"`
	Username     string    `json:"username"               db:"username"      validate:"required,min=3,max=50"`
	Email        string    `json:"email"                  db:"email"         validate:"required,email"`
	FullName     string    `json:"full_name"              db:"full_name"     validate:"required,min=1,max=100"`
	PasswordHash string    `json:"-"                      db:"password_hash"` // 不在JSON中暴露
	PhoneNumber  *string   `json:"phone_number,omitempty" db:"phone_number"`
	IsActive     bool      `json:"is_active"              db:"is_active"`
	CreatedAt    time.Time `json:"created_at"             db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"             db:"updated_at"`
	CreatedBy    *string   `json:"created_by,omitempty"   db:"created_by"`
	UpdatedBy    *string   `json:"updated_by,omitempty"   db:"updated_by"`
	Version      int       `json:"version"                db:"version"` // 乐观锁版本号
}

// CreateUserRequest 创建用户请求
// 对应Java项目的CreateUserRequest DTO
type CreateUserRequest struct {
	Username    string  `json:"username"               validate:"required,min=3,max=50"`
	Email       string  `json:"email"                  validate:"required,email"`
	FullName    string  `json:"full_name"              validate:"required,min=1,max=100"`
	Password    string  `json:"password"               validate:"required,min=6,max=100"`
	PhoneNumber *string `json:"phone_number,omitempty" validate:"omitempty,min=10,max=20"`
}

// UpdateUserRequest 更新用户请求
// 对应Java项目的UpdateUserRequest DTO
type UpdateUserRequest struct {
	Email       *string `json:"email,omitempty"        validate:"omitempty,email"`
	FullName    *string `json:"full_name,omitempty"    validate:"omitempty,min=1,max=100"`
	PhoneNumber *string `json:"phone_number,omitempty" validate:"omitempty,min=10,max=20"`
	IsActive    *bool   `json:"is_active,omitempty"`
	Version     int     `json:"version"                validate:"required"` // 乐观锁必需
}

// UserResponse 用户响应
// 对应Java项目的UserResponse DTO
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

// ApiResponse 统一API响应格式
// 对应Java项目的ApiResponse
type ApiResponse[T any] struct {
	Success   bool   `json:"success"`
	Message   string `json:"message"`
	Data      T      `json:"data,omitempty"`
	Error     string `json:"error,omitempty"`
	Timestamp string `json:"timestamp"`
}

// PagedResponse 分页响应
type PagedResponse[T any] struct {
	Content       []T   `json:"content"`
	Page          int   `json:"page"`
	Size          int   `json:"size"`
	TotalElements int64 `json:"total_elements"`
	TotalPages    int   `json:"total_pages"`
	First         bool  `json:"first"`
	Last          bool  `json:"last"`
}

// UserFilter 用户查询过滤条件
type UserFilter struct {
	Username *string `json:"username,omitempty"  form:"username"`
	Email    *string `json:"email,omitempty"     form:"email"`
	IsActive *bool   `json:"is_active,omitempty" form:"is_active"`
	Page     int     `json:"page"                form:"page"      validate:"min=0"`
	Size     int     `json:"size"                form:"size"      validate:"min=1,max=100"`
}

// Value 实现 driver.Valuer 接口，用于数据库存储
func (u User) Value() (driver.Value, error) {
	return u.ID, nil
}

// ToResponse 将User转换为UserResponse
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
