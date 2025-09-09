-- V1__Create_users_table.sql
-- Create the main users table with all necessary fields and constraints

-- Create users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户唯一标识',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名，唯一',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱地址，唯一',
    full_name VARCHAR(100) NOT NULL COMMENT '用户真实姓名',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    phone_number VARCHAR(20) COMMENT '手机号码',
    is_active TINYINT(1) DEFAULT 1 NOT NULL COMMENT '账户状态：1-激活，0-禁用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by VARCHAR(50) DEFAULT 'system' COMMENT '创建者',
    updated_by VARCHAR(50) DEFAULT 'system' COMMENT '最后更新者',
    version INT DEFAULT 1 NOT NULL COMMENT '版本号，用于乐观锁'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

-- Create indexes for better query performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Create composite index for common query patterns
CREATE INDEX idx_users_active_created ON users(is_active, created_at);

-- Add table comment for documentation
ALTER TABLE users COMMENT = '用户管理表：存储系统用户的基本信息、认证信息和审计信息';