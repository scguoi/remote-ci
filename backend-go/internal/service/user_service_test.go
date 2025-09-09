package service

import (
	"context"
	"testing"

	"github.com/scguoi/remote-ci/backend-go/internal/common"
	"github.com/scguoi/remote-ci/backend-go/internal/dao"
)

// mockUserDAO provides a lightweight, in-memory implementation of dao.UserDAO for tests.
type mockUserDAO struct {
	existsUsername bool
	existsEmail    bool
	createErr      error
	lastCreated    *common.User
}

func (m *mockUserDAO) Create(ctx context.Context, user *common.User) error {
	if m.createErr != nil {
		return m.createErr
	}
	user.ID = 1
	user.Version = 1
	m.lastCreated = user
	return nil
}

func (m *mockUserDAO) GetByID(ctx context.Context, id int64) (*common.User, error) { return nil, nil }
func (m *mockUserDAO) GetByUsername(ctx context.Context, username string) (*common.User, error) {
	return nil, nil
}

func (m *mockUserDAO) GetByEmail(ctx context.Context, email string) (*common.User, error) {
	return nil, nil
}
func (m *mockUserDAO) Update(ctx context.Context, user *common.User) error     { return nil }
func (m *mockUserDAO) Delete(ctx context.Context, id int64, version int) error { return nil }
func (m *mockUserDAO) List(ctx context.Context, filter *common.UserFilter) ([]*common.User, int64, error) {
	return nil, 0, nil
}

func (m *mockUserDAO) ExistsByUsername(ctx context.Context, username string, excludeID *int64) (bool, error) {
	return m.existsUsername, nil
}

func (m *mockUserDAO) ExistsByEmail(ctx context.Context, email string, excludeID *int64) (bool, error) {
	return m.existsEmail, nil
}

var _ dao.UserDAO = (*mockUserDAO)(nil)

func TestCreateUser_Success(t *testing.T) {
	mockDAO := &mockUserDAO{existsUsername: false, existsEmail: false}
	svc := NewUserService(mockDAO)

	req := &common.CreateUserRequest{
		Username: "alice",
		Email:    "alice@example.com",
		FullName: "Alice",
		Password: "secret123",
	}
	createdBy := strPtr("tester")

	resp, err := svc.CreateUser(context.Background(), req, createdBy)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.Username != req.Username || resp.Email != req.Email || resp.FullName != req.FullName {
		t.Fatalf("unexpected response: %+v", resp)
	}
	if mockDAO.lastCreated == nil || mockDAO.lastCreated.PasswordHash == "" {
		t.Fatalf("password was not hashed/set in DAO: %+v", mockDAO.lastCreated)
	}
}

func TestCreateUser_UsernameExists(t *testing.T) {
	mockDAO := &mockUserDAO{existsUsername: true, existsEmail: false}
	svc := NewUserService(mockDAO)

	req := &common.CreateUserRequest{
		Username: "alice",
		Email:    "alice@example.com",
		FullName: "Alice",
		Password: "secret123",
	}

	_, err := svc.CreateUser(context.Background(), req, nil)
	if err == nil {
		t.Fatalf("expected error for existing username, got nil")
	}
	if appErr, ok := err.(*common.AppError); !ok || appErr.Code != common.ErrCodeUsernameExists {
		t.Fatalf("unexpected error type/code: %T, %#v", err, err)
	}
}

func strPtr(s string) *string { return &s }
