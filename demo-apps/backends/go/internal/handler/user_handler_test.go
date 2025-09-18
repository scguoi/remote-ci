package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"

	"github.com/scguoi/remote-ci/backend-go/internal/common"
	"github.com/scguoi/remote-ci/backend-go/internal/service"
)

// mockService implements service.UserService for handler tests.
type mockService struct {
	createResp *common.UserResponse
	createErr  error
}

func (m *mockService) CreateUser(
	_ context.Context,
	_ *common.CreateUserRequest,
	_ *string,
) (*common.UserResponse, error) {
	return m.createResp, m.createErr
}

// Stubs for unused methods in this test.
func (m *mockService) GetUserByID(_ context.Context, _ int64) (*common.UserResponse, error) {
	return nil, nil
}

func (m *mockService) GetUserByUsername(_ context.Context, _ string) (*common.UserResponse, error) {
	return nil, nil
}

func (m *mockService) GetUserByEmail(_ context.Context, _ string) (*common.UserResponse, error) {
	return nil, nil
}

func (m *mockService) UpdateUser(
	_ context.Context,
	_ int64,
	_ *common.UpdateUserRequest,
	_ *string,
) (*common.UserResponse, error) {
	return nil, nil
}
func (m *mockService) DeleteUser(_ context.Context, _ int64, _ int) error { return nil }

func (m *mockService) ListUsers(
	_ context.Context,
	_ *common.UserFilter,
) (*common.PagedResponse[*common.UserResponse], error) {
	return nil, nil
}

func (m *mockService) CheckUsernameExists(_ context.Context, _ string, _ *int64) (bool, error) {
	return false, nil
}

func (m *mockService) CheckEmailExists(_ context.Context, _ string, _ *int64) (bool, error) {
	return false, nil
}

var _ service.UserService = (*mockService)(nil)

func TestCreateUser_Handler_ValidationError(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// Mock service won't be called in validation failure
	svc := &mockService{}
	h := NewUserHandler(svc)
	r := gin.New()
	h.RegisterRoutes(r)

	w := httptest.NewRecorder()
	reqBody := bytes.NewBufferString(`{"username":"","email":"bad","full_name":"","password":"123"}`)
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/users", reqBody)
	req.Header.Set("Content-Type", "application/json")

	r.ServeHTTP(w, req)

	if w.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", w.Code)
	}

	var resp map[string]any
	_ = json.Unmarshal(w.Body.Bytes(), &resp)
	if resp["success"].(bool) {
		t.Fatalf("expected success=false, got true: %s", w.Body.String())
	}
}

func TestCreateUser_Handler_Success(t *testing.T) {
	gin.SetMode(gin.TestMode)

	svc := &mockService{
		createResp: &common.UserResponse{ID: 1, Username: "alice", Email: "a@example.com", FullName: "Alice"},
	}
	h := NewUserHandler(svc)
	r := gin.New()
	h.RegisterRoutes(r)

	w := httptest.NewRecorder()
	reqBody := bytes.NewBufferString(
		`{"username":"alice","email":"a@example.com","full_name":"Alice","password":"secret123"}`,
	)
	req, _ := http.NewRequest(http.MethodPost, "/api/v1/users", reqBody)
	req.Header.Set("Content-Type", "application/json")

	r.ServeHTTP(w, req)

	if w.Code != http.StatusCreated {
		t.Fatalf("expected 201, got %d, body=%s", w.Code, w.Body.String())
	}

	var resp struct {
		Success bool `json:"success"`
		Data    struct {
			Username string `json:"username"`
			Email    string `json:"email"`
		} `json:"data"`
	}

	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("invalid json: %v", err)
	}
	if !resp.Success || resp.Data.Username != "alice" || resp.Data.Email != "a@example.com" {
		t.Fatalf("unexpected body: %s", w.Body.String())
	}
}
