-- V2__Insert_sample_users.sql
-- Insert sample users for testing and development

-- Note: In production, these sample users should be removed
-- Password for all users is 'password123' (hashed with BCrypt)
-- Hash generated with: BCrypt.hashpw("password123", BCrypt.gensalt())

INSERT INTO users (
    username, 
    email, 
    full_name, 
    password_hash, 
    phone_number, 
    is_active, 
    created_by, 
    updated_by
) VALUES 
(
    'admin', 
    'admin@example.com', 
    '系统管理员',
    '$2a$10$X3kRFgJ6VvX3fJ2cWzYjG.9fXsJ8Z3qB1Kz7R2pN4mL6Q8vW1T5sE',  -- password123
    '+8613800138000',
    1,
    'system',
    'system'
),
(
    'testuser1', 
    'testuser1@example.com', 
    '测试用户一',
    '$2a$10$X3kRFgJ6VvX3fJ2cWzYjG.9fXsJ8Z3qB1Kz7R2pN4mL6Q8vW1T5sE',  -- password123
    '+8613800138001',
    1,
    'system',
    'system'
),
(
    'testuser2', 
    'testuser2@example.com', 
    '测试用户二',
    '$2a$10$X3kRFgJ6VvX3fJ2cWzYjG.9fXsJ8Z3qB1Kz7R2pN4mL6Q8vW1T5sE',  -- password123
    '+8613800138002',
    1,
    'system',
    'system'
),
(
    'inactiveuser', 
    'inactive@example.com', 
    '禁用用户',
    '$2a$10$X3kRFgJ6VvX3fJ2cWzYjG.9fXsJ8Z3qB1Kz7R2pN4mL6Q8vW1T5sE',  -- password123
    NULL,
    0,
    'system',
    'system'
);

-- Add comment for this migration
-- This migration adds sample users for development and testing purposes