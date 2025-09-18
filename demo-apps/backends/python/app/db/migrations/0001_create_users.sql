-- 创建用户表
-- 对应backend-go中的用户表结构，保持数据库兼容性

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    
    -- 基本信息
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(255) NOT NULL UNIQUE COMMENT '邮箱',
    full_name VARCHAR(100) DEFAULT NULL COMMENT '全名',
    hashed_password VARCHAR(255) NOT NULL COMMENT '加密密码',
    is_active BOOLEAN DEFAULT TRUE COMMENT '是否激活',
    
    -- 审计字段
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by VARCHAR(50) DEFAULT 'system' COMMENT '创建者',
    updated_by VARCHAR(50) DEFAULT 'system' COMMENT '更新者',
    
    -- 乐观锁版本控制
    version INT DEFAULT 1 COMMENT '版本号',
    
    -- 软删除标记
    deleted_at TIMESTAMP NULL DEFAULT NULL COMMENT '删除时间',
    
    -- 索引
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_is_active (is_active),
    INDEX idx_created_at (created_at),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 插入示例数据（可选）
-- INSERT INTO users (username, email, full_name, hashed_password) VALUES
-- ('admin', 'admin@example.com', '系统管理员', '$2b$12$example_hashed_password'),
-- ('test_user', 'test@example.com', '测试用户', '$2b$12$example_hashed_password');