package dao

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
	"github.com/scguoi/remote-ci/backend-go/internal/common"
)

// UserDAO user data access object interface
// Corresponds to UserMapper in the Java project
type UserDAO interface {
	Create(ctx context.Context, user *common.User) error
	GetByID(ctx context.Context, id int64) (*common.User, error)
	GetByUsername(ctx context.Context, username string) (*common.User, error)
	GetByEmail(ctx context.Context, email string) (*common.User, error)
	Update(ctx context.Context, user *common.User) error
	Delete(ctx context.Context, id int64, version int) error
	List(ctx context.Context, filter *common.UserFilter) ([]*common.User, int64, error)
	ExistsByUsername(ctx context.Context, username string, excludeID *int64) (bool, error)
	ExistsByEmail(ctx context.Context, email string, excludeID *int64) (bool, error)
}

// userDAOImpl implementation of UserDAO interface
type userDAOImpl struct {
	db *sqlx.DB
}

// NewUserDAO creates a new UserDAO instance
func NewUserDAO(db *sqlx.DB) UserDAO {
	return &userDAOImpl{db: db}
}

// Create inserts a new user into the database
func (d *userDAOImpl) Create(ctx context.Context, user *common.User) error {
	query := `
		INSERT INTO users (
			username, email, full_name, password_hash, phone_number,
			is_active, created_by, updated_by, version
		) VALUES (
			:username, :email, :full_name, :password_hash, :phone_number,
			:is_active, :created_by, :updated_by, 1
		)
	`

	result, err := d.db.NamedExecContext(ctx, query, user)
	if err != nil {
		return common.NewDatabaseError("Failed to create user", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return common.NewDatabaseError("Failed to get user ID after creation", err)
	}

	user.ID = id
	user.Version = 1
	return nil
}

// GetByID retrieves a user by ID
func (d *userDAOImpl) GetByID(ctx context.Context, id int64) (*common.User, error) {
	query := `
		SELECT id, username, email, full_name, password_hash, phone_number,
		       is_active, created_at, updated_at, created_by, updated_by, version
		FROM users 
		WHERE id = ?
	`

	user := &common.User{}
	err := d.db.GetContext(ctx, user, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, common.NewUserNotFoundError(fmt.Sprintf("ID:%d", id))
		}
		return nil, common.NewDatabaseError("Failed to get user by ID", err)
	}

	return user, nil
}

// GetByUsername retrieves a user by username
func (d *userDAOImpl) GetByUsername(ctx context.Context, username string) (*common.User, error) {
	query := `
		SELECT id, username, email, full_name, password_hash, phone_number,
		       is_active, created_at, updated_at, created_by, updated_by, version
		FROM users 
		WHERE username = ?
	`

	user := &common.User{}
	err := d.db.GetContext(ctx, user, query, username)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, common.NewUserNotFoundError(username)
		}
		return nil, common.NewDatabaseError("Failed to get user by username", err)
	}

	return user, nil
}

// GetByEmail retrieves a user by email
func (d *userDAOImpl) GetByEmail(ctx context.Context, email string) (*common.User, error) {
	query := `
		SELECT id, username, email, full_name, password_hash, phone_number,
		       is_active, created_at, updated_at, created_by, updated_by, version
		FROM users 
		WHERE email = ?
	`

	user := &common.User{}
	err := d.db.GetContext(ctx, user, query, email)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, common.NewUserNotFoundError(email)
		}
		return nil, common.NewDatabaseError("Failed to get user by email", err)
	}

	return user, nil
}

// Update updates a user with optimistic locking support
func (d *userDAOImpl) Update(ctx context.Context, user *common.User) error {
	query := `
		UPDATE users 
		SET email = :email, full_name = :full_name, phone_number = :phone_number,
		    is_active = :is_active, updated_by = :updated_by, version = version + 1
		WHERE id = :id AND version = :version
	`

	result, err := d.db.NamedExecContext(ctx, query, user)
	if err != nil {
		return common.NewDatabaseError("Failed to update user", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return common.NewDatabaseError("Failed to get affected rows", err)
	}

	if rowsAffected == 0 {
		// Check if user exists
		_, err := d.GetByID(ctx, user.ID)
		if err != nil {
			if common.IsUserNotFound(err) {
				return err
			}
			return common.NewDatabaseError("Failed to verify user existence", err)
		}
		// User exists but version mismatch, indicates optimistic lock conflict
		return common.NewVersionMismatchError()
	}

	user.Version++
	return nil
}

// Delete soft deletes a user by setting is_active to false
func (d *userDAOImpl) Delete(ctx context.Context, id int64, version int) error {
	query := `
		UPDATE users 
		SET is_active = false, version = version + 1
		WHERE id = ? AND version = ?
	`

	result, err := d.db.ExecContext(ctx, query, id, version)
	if err != nil {
		return common.NewDatabaseError("Failed to delete user", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return common.NewDatabaseError("Failed to get affected rows", err)
	}

	if rowsAffected == 0 {
		// Check if user exists
		_, err := d.GetByID(ctx, id)
		if err != nil {
			if common.IsUserNotFound(err) {
				return err
			}
			return common.NewDatabaseError("Failed to verify user existence", err)
		}
		// User exists but version mismatch
		return common.NewVersionMismatchError()
	}

	return nil
}

// List retrieves a paginated list of users with optional filters
func (d *userDAOImpl) List(ctx context.Context, filter *common.UserFilter) ([]*common.User, int64, error) {
	// Build query conditions
	conditions := []string{}
	args := []interface{}{}
	countArgs := []interface{}{}

	if filter.Username != nil {
		conditions = append(conditions, "username LIKE ?")
		searchTerm := "%" + *filter.Username + "%"
		args = append(args, searchTerm)
		countArgs = append(countArgs, searchTerm)
	}

	if filter.Email != nil {
		conditions = append(conditions, "email LIKE ?")
		searchTerm := "%" + *filter.Email + "%"
		args = append(args, searchTerm)
		countArgs = append(countArgs, searchTerm)
	}

	if filter.IsActive != nil {
		conditions = append(conditions, "is_active = ?")
		args = append(args, *filter.IsActive)
		countArgs = append(countArgs, *filter.IsActive)
	}

	whereClause := ""
	if len(conditions) > 0 {
		whereClause = "WHERE " + strings.Join(conditions, " AND ")
	}

	// Get total count
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM users %s", whereClause)
	var total int64
	err := d.db.GetContext(ctx, &total, countQuery, countArgs...)
	if err != nil {
		return nil, 0, common.NewDatabaseError("Failed to count users", err)
	}

	// Get paginated data
	offset := filter.Page * filter.Size
	dataQuery := fmt.Sprintf(`
		SELECT id, username, email, full_name, password_hash, phone_number,
		       is_active, created_at, updated_at, created_by, updated_by, version
		FROM users %s 
		ORDER BY created_at DESC, id DESC
		LIMIT ? OFFSET ?
	`, whereClause)

	args = append(args, filter.Size, offset)

	users := []*common.User{}
	err = d.db.SelectContext(ctx, &users, dataQuery, args...)
	if err != nil {
		return nil, 0, common.NewDatabaseError("Failed to get users list", err)
	}

	return users, total, nil
}

// ExistsByUsername checks if a username exists (optionally excluding a specific ID)
func (d *userDAOImpl) ExistsByUsername(ctx context.Context, username string, excludeID *int64) (bool, error) {
	query := "SELECT COUNT(*) FROM users WHERE username = ?"
	args := []interface{}{username}

	if excludeID != nil {
		query += " AND id != ?"
		args = append(args, *excludeID)
	}

	var count int
	err := d.db.GetContext(ctx, &count, query, args...)
	if err != nil {
		return false, common.NewDatabaseError("Failed to check username existence", err)
	}

	return count > 0, nil
}

// ExistsByEmail checks if an email exists (optionally excluding a specific ID)
func (d *userDAOImpl) ExistsByEmail(ctx context.Context, email string, excludeID *int64) (bool, error) {
	query := "SELECT COUNT(*) FROM users WHERE email = ?"
	args := []interface{}{email}

	if excludeID != nil {
		query += " AND id != ?"
		args = append(args, *excludeID)
	}

	var count int
	err := d.db.GetContext(ctx, &count, query, args...)
	if err != nil {
		return false, common.NewDatabaseError("Failed to check email existence", err)
	}

	return count > 0, nil
}
