package service

import (
	"context"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/scguoi/remote-ci/backend-go/internal/common"
	"github.com/scguoi/remote-ci/backend-go/internal/dao"
)

// UserService 用户服务接口
// 对应Java项目的UserService
type UserService interface {
	CreateUser(ctx context.Context, req *common.CreateUserRequest, createdBy *string) (*common.UserResponse, error)
	GetUserByID(ctx context.Context, id int64) (*common.UserResponse, error)
	GetUserByUsername(ctx context.Context, username string) (*common.UserResponse, error)
	GetUserByEmail(ctx context.Context, email string) (*common.UserResponse, error)
	UpdateUser(
		ctx context.Context,
		id int64,
		req *common.UpdateUserRequest,
		updatedBy *string,
	) (*common.UserResponse, error)
	DeleteUser(ctx context.Context, id int64, version int) error
	ListUsers(ctx context.Context, filter *common.UserFilter) (*common.PagedResponse[*common.UserResponse], error)
	CheckUsernameExists(ctx context.Context, username string, excludeID *int64) (bool, error)
	CheckEmailExists(ctx context.Context, email string, excludeID *int64) (bool, error)
}

// userServiceImpl UserService的实现
// 对应Java项目的UserServiceImpl
type userServiceImpl struct {
	userDAO dao.UserDAO
}

// NewUserService 创建UserService实例
func NewUserService(userDAO dao.UserDAO) UserService {
	return &userServiceImpl{
		userDAO: userDAO,
	}
}

// CreateUser 创建用户
func (s *userServiceImpl) CreateUser(
	ctx context.Context,
	req *common.CreateUserRequest,
	createdBy *string,
) (*common.UserResponse, error) {
	// 验证用户名唯一性
	exists, err := s.userDAO.ExistsByUsername(ctx, req.Username, nil)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, common.NewUsernameExistsError(req.Username)
	}

	// 验证邮箱唯一性
	exists, err = s.userDAO.ExistsByEmail(ctx, req.Email, nil)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, common.NewEmailExistsError(req.Email)
	}

	// 加密密码
	passwordHash, err := s.hashPassword(req.Password)
	if err != nil {
		return nil, common.NewInternalError("Failed to hash password", err)
	}

	// 创建用户实体
	now := time.Now()
	user := &common.User{
		Username:     req.Username,
		Email:        req.Email,
		FullName:     req.FullName,
		PasswordHash: passwordHash,
		PhoneNumber:  req.PhoneNumber,
		IsActive:     true, // 默认激活
		CreatedAt:    now,
		UpdatedAt:    now,
		CreatedBy:    createdBy,
		UpdatedBy:    createdBy,
	}

	// 保存用户
	err = s.userDAO.Create(ctx, user)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// GetUserByID 根据ID获取用户
func (s *userServiceImpl) GetUserByID(ctx context.Context, id int64) (*common.UserResponse, error) {
	user, err := s.userDAO.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// GetUserByUsername 根据用户名获取用户
func (s *userServiceImpl) GetUserByUsername(ctx context.Context, username string) (*common.UserResponse, error) {
	user, err := s.userDAO.GetByUsername(ctx, username)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// GetUserByEmail 根据邮箱获取用户
func (s *userServiceImpl) GetUserByEmail(ctx context.Context, email string) (*common.UserResponse, error) {
	user, err := s.userDAO.GetByEmail(ctx, email)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// UpdateUser 更新用户
func (s *userServiceImpl) UpdateUser(
	ctx context.Context,
	id int64,
	req *common.UpdateUserRequest,
	updatedBy *string,
) (*common.UserResponse, error) {
	user, err := s.userDAO.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if user.Version != req.Version {
		return nil, common.NewVersionMismatchError()
	}

	if err := s.applyEmailUpdate(ctx, id, req, user); err != nil {
		return nil, err
	}

	s.applyFieldUpdates(req, user)
	s.applyAudit(updatedBy, user)

	if err := s.userDAO.Update(ctx, user); err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// applyEmailUpdate checks email uniqueness if requested and applies it to user.
func (s *userServiceImpl) applyEmailUpdate(
	ctx context.Context,
	id int64,
	req *common.UpdateUserRequest,
	user *common.User,
) error {
	if req.Email == nil || *req.Email == user.Email {
		return nil
	}
	exists, err := s.userDAO.ExistsByEmail(ctx, *req.Email, &id)
	if err != nil {
		return err
	}
	if exists {
		return common.NewEmailExistsError(*req.Email)
	}
	user.Email = *req.Email
	return nil
}

// applyFieldUpdates copies allowed mutable fields from request to entity.
func (s *userServiceImpl) applyFieldUpdates(req *common.UpdateUserRequest, user *common.User) {
	if req.FullName != nil {
		user.FullName = *req.FullName
	}
	if req.PhoneNumber != nil {
		user.PhoneNumber = req.PhoneNumber
	}
	if req.IsActive != nil {
		user.IsActive = *req.IsActive
	}
}

// applyAudit updates audit fields and timestamps.
func (s *userServiceImpl) applyAudit(updatedBy *string, user *common.User) {
	user.UpdatedAt = time.Now()
	user.UpdatedBy = updatedBy
}

// DeleteUser 删除用户（软删除）
func (s *userServiceImpl) DeleteUser(ctx context.Context, id int64, version int) error {
	return s.userDAO.Delete(ctx, id, version)
}

// ListUsers 获取用户列表
func (s *userServiceImpl) ListUsers(
	ctx context.Context,
	filter *common.UserFilter,
) (*common.PagedResponse[*common.UserResponse], error) {
	// 设置默认分页参数
	if filter.Size <= 0 {
		filter.Size = 10
	}
	if filter.Size > 100 {
		filter.Size = 100
	}
	if filter.Page < 0 {
		filter.Page = 0
	}

	// 获取数据
	users, total, err := s.userDAO.List(ctx, filter)
	if err != nil {
		return nil, err
	}

	// 转换为响应格式
	responses := make([]*common.UserResponse, len(users))
	for i, user := range users {
		responses[i] = user.ToResponse()
	}

	// 计算分页信息
	totalPages := int((total + int64(filter.Size) - 1) / int64(filter.Size))
	if totalPages == 0 {
		totalPages = 1
	}

	return &common.PagedResponse[*common.UserResponse]{
		Content:       responses,
		Page:          filter.Page,
		Size:          filter.Size,
		TotalElements: total,
		TotalPages:    totalPages,
		First:         filter.Page == 0,
		Last:          filter.Page >= totalPages-1,
	}, nil
}

// CheckUsernameExists 检查用户名是否存在
func (s *userServiceImpl) CheckUsernameExists(ctx context.Context, username string, excludeID *int64) (bool, error) {
	return s.userDAO.ExistsByUsername(ctx, username, excludeID)
}

// CheckEmailExists 检查邮箱是否存在
func (s *userServiceImpl) CheckEmailExists(ctx context.Context, email string, excludeID *int64) (bool, error) {
	return s.userDAO.ExistsByEmail(ctx, email, excludeID)
}

// hashPassword 密码加密
func (s *userServiceImpl) hashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(bytes), nil
}

// VerifyPassword 验证密码（用于登录验证）
func (s *userServiceImpl) VerifyPassword(hashedPassword, password string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
}
