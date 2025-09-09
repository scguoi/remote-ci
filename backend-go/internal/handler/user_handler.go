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

// UserHandler 用户处理器
// 对应Java项目的UserController
type UserHandler struct {
	userService service.UserService
	validator   *validator.Validate
}

// NewUserHandler 创建UserHandler实例
func NewUserHandler(userService service.UserService) *UserHandler {
	return &UserHandler{
		userService: userService,
		validator:   validator.New(),
	}
}

// RegisterRoutes 注册路由
func (h *UserHandler) RegisterRoutes(router *gin.Engine) {
	v1 := router.Group("/api/v1")
	{
		users := v1.Group("/users")
		{
			users.POST("", h.CreateUser)                                  // 创建用户
			users.GET("/:id", h.GetUser)                                  // 根据ID获取用户
			users.GET("/username/:username", h.GetUserByUsername)         // 根据用户名获取用户
			users.GET("", h.ListUsers)                                    // 获取用户列表
			users.PUT("/:id", h.UpdateUser)                               // 更新用户
			users.DELETE("/:id", h.DeleteUser)                            // 删除用户
			users.GET("/check-username/:username", h.CheckUsernameExists) // 检查用户名
			users.GET("/check-email", h.CheckEmailExists)                 // 检查邮箱
		}
	}
}

// CreateUser 创建用户
// POST /api/v1/users
func (h *UserHandler) CreateUser(c *gin.Context) {
	var req common.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		h.respondWithError(c, common.NewValidationError("Invalid request body", err))
		return
	}

	// 验证请求
	if err := h.validator.Struct(&req); err != nil {
		h.respondWithError(c, common.NewValidationError("Validation failed", err))
		return
	}

	// 获取创建者信息（从认证中间件或请求头）
	createdBy := h.getCurrentUser(c)

	// 调用服务
	user, err := h.userService.CreateUser(c.Request.Context(), &req, createdBy)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusCreated, "User created successfully", user)
}

// GetUser 获取用户
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

// GetUserByUsername 根据用户名获取用户
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

// ListUsers 获取用户列表
// GET /api/v1/users?page=0&size=10&username=xxx&email=xxx&is_active=true
func (h *UserHandler) ListUsers(c *gin.Context) {
	var filter common.UserFilter

	// 绑定查询参数
	if err := c.ShouldBindQuery(&filter); err != nil {
		h.respondWithError(c, common.NewValidationError("Invalid query parameters", err))
		return
	}

	// 验证参数
	if err := h.validator.Struct(&filter); err != nil {
		h.respondWithError(c, common.NewValidationError("Query parameter validation failed", err))
		return
	}

	// 设置默认值
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

// UpdateUser 更新用户
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

	// 验证请求
	if err := h.validator.Struct(&req); err != nil {
		h.respondWithError(c, common.NewValidationError("Validation failed", err))
		return
	}

	// 获取更新者信息
	updatedBy := h.getCurrentUser(c)

	// 调用服务
	user, err := h.userService.UpdateUser(c.Request.Context(), id, &req, updatedBy)
	if err != nil {
		h.respondWithError(c, err)
		return
	}

	h.respondWithSuccess(c, http.StatusOK, "User updated successfully", user)
}

// DeleteUser 删除用户
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

// CheckUsernameExists 检查用户名是否存在
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

// CheckEmailExists 检查邮箱是否存在
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

// 辅助方法

// parseIDParam 解析ID参数
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

// getCurrentUser 获取当前用户（从认证中间件或请求头）
func (h *UserHandler) getCurrentUser(c *gin.Context) *string {
	// 这里可以从JWT token、session或请求头中获取当前用户信息
	// 目前返回固定值，实际项目中需要实现认证中间件
	user := "system"
	return &user
}

// respondWithSuccess 成功响应
func (h *UserHandler) respondWithSuccess(c *gin.Context, statusCode int, message string, data interface{}) {
	response := common.ApiResponse[interface{}]{
		Success:   true,
		Message:   message,
		Data:      data,
		Timestamp: time.Now().Format(time.RFC3339),
	}
	c.JSON(statusCode, response)
}

// respondWithError 错误响应
func (h *UserHandler) respondWithError(c *gin.Context, err error) {
	var statusCode int
	var errorCode common.ErrorCode
	var message string

	// 类型断言，获取应用错误信息
	if appErr, ok := err.(*common.AppError); ok {
		statusCode = appErr.HTTPStatus
		errorCode = appErr.Code
		message = appErr.Message
	} else {
		// 未知错误，返回500
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
