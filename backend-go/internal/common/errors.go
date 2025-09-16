package common

import (
	"fmt"
	"net/http"
)

// ErrorCode represents application error codes
// Corresponds to ErrorCodes constants class in the Java project
type ErrorCode string

const (
	// System errors
	ErrCodeInternal     ErrorCode = "INTERNAL_ERROR"
	ErrCodeValidation   ErrorCode = "VALIDATION_ERROR"
	ErrCodeUnauthorized ErrorCode = "UNAUTHORIZED"
	ErrCodeForbidden    ErrorCode = "FORBIDDEN"

	// User-related errors
	ErrCodeUserNotFound       ErrorCode = "USER_NOT_FOUND"
	ErrCodeUserExists         ErrorCode = "USER_ALREADY_EXISTS"
	ErrCodeUsernameExists     ErrorCode = "USERNAME_ALREADY_EXISTS"
	ErrCodeEmailExists        ErrorCode = "EMAIL_ALREADY_EXISTS"
	ErrCodeUserInactive       ErrorCode = "USER_INACTIVE"
	ErrCodeVersionMismatch    ErrorCode = "VERSION_MISMATCH"
	ErrCodeInvalidCredentials ErrorCode = "INVALID_CREDENTIALS"

	// Database errors
	ErrCodeDatabaseConnection ErrorCode = "DATABASE_CONNECTION_ERROR"
	ErrCodeDatabaseQuery      ErrorCode = "DATABASE_QUERY_ERROR"
)

// AppError represents an application error with code and HTTP status
type AppError struct {
	Code       ErrorCode `json:"code"`
	Message    string    `json:"message"`
	HTTPStatus int       `json:"-"`
	Cause      error     `json:"-"`
}

// Error implements the error interface
func (e *AppError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("%s: %s (caused by: %v)", e.Code, e.Message, e.Cause)
	}
	return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// Unwrap supports error chaining
func (e *AppError) Unwrap() error {
	return e.Cause
}

// NewAppError creates a new application error
func NewAppError(code ErrorCode, message string, httpStatus int, cause error) *AppError {
	return &AppError{
		Code:       code,
		Message:    message,
		HTTPStatus: httpStatus,
		Cause:      cause,
	}
}

// Predefined error factory functions

// NewUserNotFoundError creates a user not found error
func NewUserNotFoundError(identifier string) *AppError {
	return NewAppError(
		ErrCodeUserNotFound,
		fmt.Sprintf("User with identifier '%s' not found", identifier),
		http.StatusNotFound,
		nil,
	)
}

// NewUserExistsError creates a user already exists error
func NewUserExistsError(field, value string) *AppError {
	return NewAppError(
		ErrCodeUserExists,
		fmt.Sprintf("User with %s '%s' already exists", field, value),
		http.StatusConflict,
		nil,
	)
}

// NewUsernameExistsError creates a username already exists error
func NewUsernameExistsError(username string) *AppError {
	return NewAppError(
		ErrCodeUsernameExists,
		fmt.Sprintf("Username '%s' is already taken", username),
		http.StatusConflict,
		nil,
	)
}

// NewEmailExistsError creates an email already exists error
func NewEmailExistsError(email string) *AppError {
	return NewAppError(
		ErrCodeEmailExists,
		fmt.Sprintf("Email '%s' is already registered", email),
		http.StatusConflict,
		nil,
	)
}

// NewVersionMismatchError creates a version mismatch error (optimistic locking)
func NewVersionMismatchError() *AppError {
	return NewAppError(
		ErrCodeVersionMismatch,
		"Resource has been modified by another process. Please refresh and try again",
		http.StatusConflict,
		nil,
	)
}

// NewValidationError creates a validation error
func NewValidationError(message string, cause error) *AppError {
	return NewAppError(
		ErrCodeValidation,
		message,
		http.StatusBadRequest,
		cause,
	)
}

// NewInternalError creates an internal server error
func NewInternalError(message string, cause error) *AppError {
	return NewAppError(
		ErrCodeInternal,
		message,
		http.StatusInternalServerError,
		cause,
	)
}

// NewDatabaseError creates a database error
func NewDatabaseError(message string, cause error) *AppError {
	return NewAppError(
		ErrCodeDatabaseQuery,
		message,
		http.StatusInternalServerError,
		cause,
	)
}

// IsUserNotFound checks if error is a user not found error
func IsUserNotFound(err error) bool {
	if appErr, ok := err.(*AppError); ok {
		return appErr.Code == ErrCodeUserNotFound
	}
	return false
}

// IsUserExists checks if error is a user already exists error
func IsUserExists(err error) bool {
	if appErr, ok := err.(*AppError); ok {
		return appErr.Code == ErrCodeUserExists ||
			appErr.Code == ErrCodeUsernameExists ||
			appErr.Code == ErrCodeEmailExists
	}
	return false
}

// IsVersionMismatch checks if error is a version mismatch error
func IsVersionMismatch(err error) bool {
	if appErr, ok := err.(*AppError); ok {
		return appErr.Code == ErrCodeVersionMismatch
	}
	return false
}
