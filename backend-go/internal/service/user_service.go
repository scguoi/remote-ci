package service

import (
	"context"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/scguoi/remote-ci/backend-go/internal/common"
	"github.com/scguoi/remote-ci/backend-go/internal/dao"
)

// UserService defines the user service interface
// Corresponds to UserService in the Java project
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

// userServiceImpl implements the UserService interface
// Corresponds to UserServiceImpl in the Java project
type userServiceImpl struct {
	userDAO dao.UserDAO
}

// NewUserService creates a new UserService instance
func NewUserService(userDAO dao.UserDAO) UserService {
	return &userServiceImpl{
		userDAO: userDAO,
	}
}

// CreateUser creates a new user
func (s *userServiceImpl) CreateUser(
	ctx context.Context,
	req *common.CreateUserRequest,
	createdBy *string,
) (*common.UserResponse, error) {
	// Validate username uniqueness
	exists, err := s.userDAO.ExistsByUsername(ctx, req.Username, nil)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, common.NewUsernameExistsError(req.Username)
	}

	// Validate email uniqueness
	exists, err = s.userDAO.ExistsByEmail(ctx, req.Email, nil)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, common.NewEmailExistsError(req.Email)
	}

	// Hash password
	passwordHash, err := s.hashPassword(req.Password)
	if err != nil {
		return nil, common.NewInternalError("Failed to hash password", err)
	}

	// Create user entity
	now := time.Now()
	user := &common.User{
		Username:     req.Username,
		Email:        req.Email,
		FullName:     req.FullName,
		PasswordHash: passwordHash,
		PhoneNumber:  req.PhoneNumber,
		IsActive:     true, // Default to active
		CreatedAt:    now,
		UpdatedAt:    now,
		CreatedBy:    createdBy,
		UpdatedBy:    createdBy,
	}

	// Save user
	err = s.userDAO.Create(ctx, user)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// GetUserByID retrieves a user by ID
func (s *userServiceImpl) GetUserByID(ctx context.Context, id int64) (*common.UserResponse, error) {
	user, err := s.userDAO.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// GetUserByUsername retrieves a user by username
func (s *userServiceImpl) GetUserByUsername(ctx context.Context, username string) (*common.UserResponse, error) {
	user, err := s.userDAO.GetByUsername(ctx, username)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// GetUserByEmail retrieves a user by email
func (s *userServiceImpl) GetUserByEmail(ctx context.Context, email string) (*common.UserResponse, error) {
	user, err := s.userDAO.GetByEmail(ctx, email)
	if err != nil {
		return nil, err
	}

	return user.ToResponse(), nil
}

// UpdateUser updates an existing user
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

// DeleteUser soft deletes a user
func (s *userServiceImpl) DeleteUser(ctx context.Context, id int64, version int) error {
	return s.userDAO.Delete(ctx, id, version)
}

// ListUsers retrieves a paginated list of users
func (s *userServiceImpl) ListUsers(
	ctx context.Context,
	filter *common.UserFilter,
) (*common.PagedResponse[*common.UserResponse], error) {
	// Set default pagination parameters
	if filter.Size <= 0 {
		filter.Size = 10
	}
	if filter.Size > 100 {
		filter.Size = 100
	}
	if filter.Page < 0 {
		filter.Page = 0
	}

	// Get data
	users, total, err := s.userDAO.List(ctx, filter)
	if err != nil {
		return nil, err
	}

	// Convert to response format
	responses := make([]*common.UserResponse, len(users))
	for i, user := range users {
		responses[i] = user.ToResponse()
	}

	// Calculate pagination info
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

// CheckUsernameExists checks if a username exists
func (s *userServiceImpl) CheckUsernameExists(ctx context.Context, username string, excludeID *int64) (bool, error) {
	return s.userDAO.ExistsByUsername(ctx, username, excludeID)
}

// CheckEmailExists checks if an email exists
func (s *userServiceImpl) CheckEmailExists(ctx context.Context, email string, excludeID *int64) (bool, error) {
	return s.userDAO.ExistsByEmail(ctx, email, excludeID)
}

// hashPassword encrypts a password
func (s *userServiceImpl) hashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(bytes), nil
}

// VerifyPassword verifies a password (for login authentication)
func (s *userServiceImpl) VerifyPassword(hashedPassword, password string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
}
