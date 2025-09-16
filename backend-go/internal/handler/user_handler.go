package handler

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"

	"github.com/scguoi/remote-ci/backend-go/internal/common"
	"github.com/scguoi/remote-ci/backend-go/internal/service"
)

// UserHandler handles user-related HTTP requests
// Corresponds to UserController in the Java project
type UserHandler struct {
	userService service.UserService
	validator   *validator.Validate
}

// NewUserHandler creates a new UserHandler instance
func NewUserHandler(userService service.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
		validator:   validator.New(),
	}
}

// RegisterRoutes registers all user-related routes
func (h *UserHandler) RegisterRoutes(router *gin.Engine) {
	v1 := router.Group("/api/v1")
	{
		users := v1.Group("/users")
		{
			users.POST("", h.CreateUser)                                  // Create user
			users.GET("/:id", h.GetUser)                                  // Get user by ID
			users.GET("/username/:username", h.GetUserByUsername)         // Get user by username
			users.GET("", h.ListUsers)                                    // Get user list
			users.PUT("/:id", h.UpdateUser)                               // Update user
			users.DELETE("/:id", h.DeleteUser)                            // Delete user
			users.GET("/check-username/:username", h.CheckUsernameExists) // Check username
			users.GET("/check-email", h.CheckEmailExists)                 // Check email
		}
	}
}

// CreateUser creates a new user
// POST /api/v1/users
func (h *UserHandler) CreateUser(c *gin.Context) {
	var req common.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.respondWithError(c, common.NewValidationError("Invalid request body", err))
		return
	}

	// Validate request
	if err := h.validator.Struct(&req); err != nil {
		h.respondWithError(c, common.NewValidationError("Validation failed", err))
		return
	}

	// Get creator information (from auth middleware or request headers)
	createdBy := h.getCurrentUser(c)

	// Call service
	user, err := h.userService.CreateUser(c.Request.Context(), &req, createdBy)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusCreated, "User created successfully", user)
}

// GetUser retrieves a user by ID
// GET /api/v1/users/:id
func (h *UserHandler) GetUser(c *gin.Context) {
	id, err := h.parseIDParam(c, "id")
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	user, err := h.userService.GetUserByID(c.Request.Context(), id)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusOK, "User retrieved successfully", user)
}

// GetUserByUsername retrieves a user by username
// GET /api/v1/users/username/:username
func (h *UserHandler) GetUserByUsername(c *gin.Context) {
	username := c.Param("username")
	if username == "" {
		h.respondWithError(c, common.NewValidationError("Username is required", nil))
		return
	}

	user, err := h.userService.GetUserByUsername(c.Request.Context(), username)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusOK, "User retrieved successfully", user)
}

// ListUsers retrieves a paginated list of users with optional filters
// GET /api/v1/users?page=0&size=10&username=xxx&email=xxx&is_active=true
func (h *UserHandler) ListUsers(c *gin.Context) {
	var filter common.UserFilter

	// Bind query parameters
	if err := c.ShouldBindQuery(&filter); err != nil {
		h.respondWithError(c, common.NewValidationError("Invalid query parameters", err))
		return
	}

	// Validate parameters
	if err := h.validator.Struct(&filter); err != nil {
		h.respondWithError(c, common.NewValidationError("Query parameter validation failed", err))
		return
	}

	// Set default values
	if filter.Size <= 0 {
		filter.Size = 10
	}
	if filter.Page < 0 {
		filter.Page = 0
	}

	users, err := h.userService.ListUsers(c.Request.Context(), &filter)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusOK, "Users retrieved successfully", users)
}

// UpdateUser updates an existing user
// PUT /api/v1/users/:id
func (h *UserHandler) UpdateUser(c *gin.Context) {
	id, err := h.parseIDParam(c, "id")
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	var req common.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.respondWithError(c, common.NewValidationError("Invalid request body", err))
		return
	}

	// Validate request
	if err := h.validator.Struct(&req); err != nil {
		h.respondWithError(c, common.NewValidationError("Validation failed", err))
		return
	}

	// Get updater information
	updatedBy := h.getCurrentUser(c)

	// Call service
	user, err := h.userService.UpdateUser(c.Request.Context(), id, &req, updatedBy)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusOK, "User updated successfully", user)
}

// DeleteUser deletes a user by ID with version check
// DELETE /api/v1/users/:id?version=1
func (h *UserHandler) DeleteUser(c *gin.Context) {
	id, err := h.parseIDParam(c, "id")
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	versionStr := c.Query("version")
	if versionStr == "" {
		h.respondWithError(c, common.NewValidationError("Version parameter is required", nil))
		return
	}

	version, err := strconv.Atoi(versionStr)
	if err != nil {
		h.respondWithError(c, common.NewValidationError("Invalid version parameter", err))
		return
	}

	err = h.userService.DeleteUser(c.Request.Context(), id, version)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusOK, "User deleted successfully", nil)
}

// CheckUsernameExists checks if a username already exists
// GET /api/v1/users/check-username/:username
func (h *UserHandler) CheckUsernameExists(c *gin.Context) {
	username := c.Param("username")
	if username == "" {
		h.respondWithError(c, common.NewValidationError("Username is required", nil))
		return
	}

	exists, err := h.userService.CheckUsernameExists(c.Request.Context(), username, nil)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	response := map[string]interface{}{
		"username": username,
		"exists":   exists,
	}

	message := "Username is available"
	if exists {
		message = "Username already exists"
	}

	h.respondWithSuccess(c, http.StatusOK, message, response)
}

// CheckEmailExists checks if an email already exists
// GET /api/v1/users/check-email?email=xxx@example.com
func (h *UserHandler) CheckEmailExists(c *gin.Context) {
	email := c.Query("email")
	if email == "" {
		h.respondWithError(c, common.NewValidationError("Email parameter is required", nil))
		return
	}

	exists, err := h.userService.CheckEmailExists(c.Request.Context(), email, nil)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	response := map[string]interface{}{
		"email":  email,
		"exists": exists,
	}

	message := "Email is available"
	if exists {
		message = "Email already exists"
	}

	h.respondWithSuccess(c, http.StatusOK, message, response)
}

// Helper methods

// parseIDParam parses and validates an ID parameter from the URL
func (h *UserHandler) parseIDParam(c *gin.Context, paramName string) (int64, error) {
	idStr := c.Param(paramName)
	if idStr == "" {
		return 0, common.NewValidationError(fmt.Sprintf("%s parameter is required", paramName), nil)
	}

	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		return 0, common.NewValidationError(fmt.Sprintf("Invalid %s parameter", paramName), err)
	}

	if id <= 0 {
		return 0, common.NewValidationError(fmt.Sprintf("%s must be positive", paramName), nil)
	}

	return id, nil
}

// getCurrentUser gets the current user (from auth middleware or request headers)
func (h *UserHandler) getCurrentUser(c *gin.Context) *string {
	// Here we can get current user info from JWT token, session or request headers
	// Currently returns a fixed value, in actual projects need to implement auth middleware
	user := "system"
	return &user
}

// respondWithSuccess sends a successful response
func (h *UserHandler) respondWithSuccess(c *gin.Context, statusCode int, message string, data interface{}) {
	response := common.ApiResponse[interface{}]{
		Success:   true,
		Message:   message,
		Data:      data,
		Timestamp: time.Now().Format(time.RFC3339),
	}
	c.JSON(statusCode, response)
}

// respondWithError sends an error response
func (h *UserHandler) respondWithError(c *gin.Context, err error) {
	var statusCode int
	var errorCode common.ErrorCode
	var message string

	// Type assertion to get application error information
	if appErr, ok := err.(*common.AppError); ok {
		statusCode = appErr.HTTPStatus
		errorCode = appErr.Code
		message = appErr.Message
	} else {
		// Unknown error, return 500
		statusCode = http.StatusInternalServerError
		errorCode = common.ErrCodeInternal
		message = "Internal server error"
	}

	response := common.ApiResponse[interface{}]{
		Success:   false,
		Message:   message,
		Error:     string(errorCode),
		Timestamp: time.Now().Format(time.RFC3339),
	}

	c.JSON(statusCode, response)
}
