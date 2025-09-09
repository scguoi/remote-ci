package common

import (
	"fmt"
	"net/http"
)

// ErrorCode 错误代码
// 对应Java项目的ErrorCodes常量类
type ErrorCode string

const (
	// 系统错误
	ErrCodeInternal     ErrorCode = "INTERNAL_ERROR"
	ErrCodeValidation   ErrorCode = "VALIDATION_ERROR"
	ErrCodeUnauthorized ErrorCode = "UNAUTHORIZED"
	ErrCodeForbidden    ErrorCode = "FORBIDDEN"

	// 用户相关错误
	ErrCodeUserNotFound       ErrorCode = "USER_NOT_FOUND"
	ErrCodeUserExists         ErrorCode = "USER_ALREADY_EXISTS"
	ErrCodeUsernameExists     ErrorCode = "USERNAME_ALREADY_EXISTS"
	ErrCodeEmailExists        ErrorCode = "EMAIL_ALREADY_EXISTS"
	ErrCodeUserInactive       ErrorCode = "USER_INACTIVE"
	ErrCodeVersionMismatch    ErrorCode = "VERSION_MISMATCH"
	ErrCodeInvalidCredentials ErrorCode = "INVALID_CREDENTIALS"

	// 数据库错误
	ErrCodeDatabaseConnection ErrorCode = "DATABASE_CONNECTION_ERROR"
	ErrCodeDatabaseQuery      ErrorCode = "DATABASE_QUERY_ERROR"
)

// AppError 应用错误
type AppError struct {
	Code       ErrorCode `json:"code"`
	Message    string    `json:"message"`
	HTTPStatus int       `json:"-"`
	Cause      error     `json:"-"`
}

// Error 实现error接口
func (e *AppError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("%s: %s (caused by: %v)", e.Code, e.Message, e.Cause)
	}
	return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// Unwrap 支持错误链
func (e *AppError) Unwrap() error {
	return e.Cause
}

// NewAppError 创建应用错误
func NewAppError(code ErrorCode, message string, httpStatus int, cause error) *AppError {
	return &AppError{
		Code:       code,
		Message:    message,
		HTTPStatus: httpStatus,
		Cause:      cause,
	}
}

// 预定义错误工厂函数

// NewUserNotFoundError 用户不存在错误
func NewUserNotFoundError(identifier string) *AppError {
	return NewAppError(
		ErrCodeUserNotFound,
		fmt.Sprintf("User with identifier '%s' not found", identifier),
		http.StatusNotFound,
		nil,
	)
}

// NewUserExistsError 用户已存在错误
func NewUserExistsError(field, value string) *AppError {
	return NewAppError(
		ErrCodeUserExists,
		fmt.Sprintf("User with %s '%s' already exists", field, value),
		http.StatusConflict,
		nil,
	)
}

// NewUsernameExistsError 用户名已存在错误
func NewUsernameExistsError(username string) *AppError {
	return NewAppError(
		ErrCodeUsernameExists,
		fmt.Sprintf("Username '%s' is already taken", username),
		http.StatusConflict,
		nil,
	)
}

// NewEmailExistsError 邮箱已存在错误
func NewEmailExistsError(email string) *AppError {
	return NewAppError(
		ErrCodeEmailExists,
		fmt.Sprintf("Email '%s' is already registered", email),
		http.StatusConflict,
		nil,
	)
}

// NewVersionMismatchError 版本不匹配错误（乐观锁）
func NewVersionMismatchError() *AppError {
	return NewAppError(
		ErrCodeVersionMismatch,
		"Resource has been modified by another process. Please refresh and try again",
		http.StatusConflict,
		nil,
	)
}

// NewValidationError 验证错误
func NewValidationError(message string, cause error) *AppError {
	return NewAppError(
		ErrCodeValidation,
		message,
		http.StatusBadRequest,
		cause,
	)
}

// NewInternalError 内部服务器错误
func NewInternalError(message string, cause error) *AppError {
	return NewAppError(
		ErrCodeInternal,
		message,
		http.StatusInternalServerError,
		cause,
	)
}

// NewDatabaseError 数据库错误
func NewDatabaseError(message string, cause error) *AppError {
	return NewAppError(
		ErrCodeDatabaseQuery,
		message,
		http.StatusInternalServerError,
		cause,
	)
}

// IsUserNotFound 检查是否为用户不存在错误
func IsUserNotFound(err error) bool {
	if appErr, ok := err.(*AppError); ok {
		return appErr.Code == ErrCodeUserNotFound
	}
	return false
}

// IsUserExists 检查是否为用户已存在错误
func IsUserExists(err error) bool {
	if appErr, ok := err.(*AppError); ok {
		return appErr.Code == ErrCodeUserExists ||
			appErr.Code == ErrCodeUsernameExists ||
			appErr.Code == ErrCodeEmailExists
	}
	return false
}

// IsVersionMismatch 检查是否为版本不匹配错误
func IsVersionMismatch(err error) bool {
	if appErr, ok := err.(*AppError); ok {
		return appErr.Code == ErrCodeVersionMismatch
	}
	return false
}
