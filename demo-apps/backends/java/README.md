# 用户管理系统 (User Management System)

## 📋 项目概述

这是一个基于**Spring Boot 3.x + MyBatis + MySQL**的现代化多模块用户管理系统，采用领域驱动设计，具备完整的代码质量保证体系和企业级开发规范。

### 🎯 核心特性

- 🏗️ **多模块架构**：清晰分离业务层级，便于维护和扩展
- 🔐 **完整用户管理**：用户增删改查、状态管理、数据验证
- 💾 **MySQL + MyBatis**：高性能数据访问，支持乐观锁并发控制
- 🔄 **Flyway数据库迁移**：版本化schema管理，支持多环境部署
- 🌐 **RESTful API**：统一响应格式，完善错误处理机制
- ✅ **代码质量保证**：Spotless格式化 + Checkstyle + PMD静态分析
- 📊 **生产就绪**：集成Actuator监控，多环境配置支持

## 🏗️ 项目架构

```
backend-java/
├── pom.xml                    # 父级POM，依赖管理
├── config/                    # 代码质量工具配置目录
│   ├── checkstyle.xml         # Checkstyle代码风格配置
│   ├── pmd-ruleset.xml        # PMD静态分析规则
│   └── spotbugs-exclude.xml   # SpotBugs排除规则
├── user-common/              # 公共模块
│   ├── entity/               # 实体类 (User)
│   ├── dto/                  # 数据传输对象
│   └── constants/            # 常量定义
├── user-dao/                 # 数据访问层
│   └── UserMapper.java       # MyBatis映射器
├── user-service/             # 业务逻辑层
│   ├── UserService.java      # 服务接口
│   └── impl/UserServiceImpl.java # 服务实现
└── user-web/                 # Web层
    ├── controller/           # REST控制器
    ├── UserManagementApplication.java # 启动类
    └── resources/            # 配置和数据库脚本
        ├── application.yml   # 应用配置
        └── db/migration/     # Flyway迁移脚本
```

### 📦 模块说明

| 模块 | 职责 | 主要内容 |
|------|------|----------|
| `user-common` | 公共组件 | 实体类、DTO、常量、异常定义 |
| `user-dao` | 数据访问层 | MyBatis Mapper接口和动态SQL |
| `user-service` | 业务逻辑层 | 业务服务接口和实现类 |
| `user-web` | Web表示层 | REST API控制器、配置文件 |

## 🚀 技术栈

### 🔧 核心框架
- **Spring Boot 3.1.5** - 应用框架和自动配置
- **Spring Web** - REST API和MVC支持
- **MyBatis 3.0.2** - 持久层框架和SQL映射
- **MySQL 8.0.33** - 关系型数据库
- **HikariCP** - 高性能数据库连接池
- **Flyway 9.22.3** - 数据库版本管理和迁移

### 🛠️ 开发工具
- **Lombok** - 减少样板代码，提升开发效率
- **MapStruct 1.5.5** - 类型安全的Bean映射
- **Jakarta Validation** - JSR-303数据验证
- **Jackson** - JSON序列化和反序列化

### ✅ 代码质量工具
- **Spotless 2.43.0** - Google Java Format代码格式化
- **Checkstyle 10.12.4** - 代码风格一致性检查 (`config/checkstyle.xml`)
- **PMD 6.55.0** - 静态代码分析和最佳实践检查 (`config/pmd-ruleset.xml`)
- **SpotBugs 4.8.2** - Bug模式检测和安全漏洞扫描 (`config/spotbugs-exclude.xml`)

## 📝 核心功能

### REST API接口

| HTTP方法 | 路径 | 功能 | 描述 |
|---------|------|------|------|
| POST | `/api/v1/users` | 创建用户 | 创建新用户账户 |
| GET | `/api/v1/users/{id}` | 查询用户 | 根据ID查询用户 |
| GET | `/api/v1/users/username/{username}` | 查询用户 | 根据用户名查询 |
| GET | `/api/v1/users` | 用户列表 | 分页查询用户列表 |
| PUT | `/api/v1/users/{id}` | 更新用户 | 更新用户信息 |
| DELETE | `/api/v1/users/{id}?version={version}` | 删除用户 | 软删除用户（停用） |
| GET | `/api/v1/users/check-username/{username}` | 检查用户名 | 验证用户名是否存在 |
| GET | `/api/v1/users/check-email?email={email}` | 检查邮箱 | 验证邮箱是否存在 |

### 数据模型

**User实体字段**:
- `id` - 主键ID
- `username` - 用户名（唯一）
- `email` - 邮箱地址（唯一）
- `fullName` - 真实姓名
- `passwordHash` - 密码哈希
- `phoneNumber` - 手机号码
- `isActive` - 账户状态
- `createdAt/updatedAt` - 时间戳
- `createdBy/updatedBy` - 审计字段
- `version` - 乐观锁版本号

## 🚀 快速开始

### 📋 环境要求

- **JDK 17+** 
- **Maven 3.8+**
- **MySQL 8.0+**
- **IDE**: IntelliJ IDEA / Eclipse / VS Code

### 🔧 安装和配置

**1. 克隆项目**
```bash
git clone <repository-url>
cd remote-ci/backend-java
```

**2. 数据库设置**
```sql
-- 创建数据库
CREATE DATABASE user_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE user_db_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;  
CREATE DATABASE user_db_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户（可选）
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON user_db*.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;
```

**3. 配置文件修改**
```yaml
# user-web/src/main/resources/application.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/user_db?useSSL=false&serverTimezone=UTC
    username: root  # 修改为你的数据库用户名
    password: password  # 修改为你的数据库密码
```

**4. 构建和启动**
```bash
# 🚀 使用Makefile（推荐）
make setup          # 一次性环境设置
make build          # 构建项目
make run            # 启动应用

# 📦 传统Maven方式
mvn clean install -DskipTests
mvn spring-boot:run -pl user-web

# 🏺 JAR包启动
java -jar user-web/target/user-web-1.0.0.jar
```

应用将在 `http://localhost:8080` 启动

## 🔧 配置说明

### 数据库配置
在 `user-web/src/main/resources/application.yml` 中配置数据库连接：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/user_db
    username: root
    password: your_password
```

### 环境配置
支持多环境配置：
- `dev` - 开发环境
- `test` - 测试环境  
- `prod` - 生产环境

启动时指定环境：
```bash
java -jar user-web-1.0.0.jar --spring.profiles.active=dev
```

## 📊 API测试示例

### 创建用户
```bash
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "full_name": "新用户",
    "password": "password123",
    "phone_number": "+8613800138000"
  }'
```

### 查询用户列表
```bash
curl "http://localhost:8080/api/v1/users?page=0&size=10&isActive=true"
```

### 更新用户
```bash
curl -X PUT http://localhost:8080/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "email": "updated@example.com",
    "full_name": "更新的用户名",
    "version": 1
  }'
```

## 🧪 测试数据

系统预置了以下测试用户（密码均为 `password123`）：
- `admin` - 系统管理员
- `testuser1` - 测试用户一
- `testuser2` - 测试用户二
- `inactiveuser` - 禁用用户（用于测试）

### 🔍 验证安装

```bash
# 健康检查
curl http://localhost:8080/actuator/health

# 获取用户列表
curl http://localhost:8080/api/v1/users

# 创建新用户
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com", 
    "fullName": "Test User",
    "phoneNumber": "13800138000"
  }'
```

## 🛠️ 开发指南

### 📝 代码质量检查

项目集成了完整的代码质量工具链，确保代码规范和质量。所有配置文件统一放在 `config/` 目录下：

```bash
# 代码格式化（Google Java Format）
mvn spotless:apply

# 格式化检查
mvn spotless:check

# 代码风格检查（使用 config/checkstyle.xml）
mvn checkstyle:check

# PMD静态分析（使用 config/pmd-ruleset.xml）
mvn pmd:check

# SpotBugs安全检查（使用 config/spotbugs-exclude.xml）
# 注意：需要先编译才能运行
mvn clean compile spotbugs:check

# 运行所有代码质量检查
mvn clean compile spotless:check checkstyle:check

# 或使用质量检查profile（暂时跳过PMD）
mvn -Pcode-quality verify
```

#### 🛠️ 代码质量工具配置说明

| 工具 | 配置文件 | 功能说明 |
|------|---------|----------|
| **Spotless** | 内置Google Java Format | 自动格式化代码，保持一致的代码风格 |
| **Checkstyle** | `config/checkstyle.xml` | 检查代码风格规范，如命名、缩进、注释等 |
| **PMD** | `config/pmd-ruleset.xml` | 静态分析，检测代码异味和最佳实践违反 |
| **SpotBugs** | `config/spotbugs-exclude.xml` | 检测潜在bug和安全漏洞，排除误报 |

## 🛠️ 本地CI/CD工具链

项目包含完整的Makefile本地CI/CD工具链，提供高效的开发工作流：

### 🚀 快速开始命令

```bash
# 查看所有可用命令
make help

# 项目信息
make info

# 环境检查
make check-env

# 一次性设置
make setup

# 快速构建
make build

# 启动应用
make run
```

### ✅ 代码质量命令

```bash
# 自动格式化代码
make format

# 快速质量检查（格式+风格）
make check-quick

# 完整质量检查（包括SpotBugs）
make check

# 提交前检查
make pre-commit

# CI构建流程
make ci-build
```

### 🧪 测试和构建命令

```bash
# 快速构建（跳过测试）
make build-fast

# 运行测试
make test

# 清理和重建
make clean build

# 发布准备
make release-prepare
```

### 🗄️ 数据库命令

```bash
# 查看迁移状态
make db-info

# 执行数据库迁移
make db-migrate

# 修复迁移问题
make db-repair
```

### 🔧 开发辅助命令

```bash
# 开发模式启动（热重载）
make run-dev

# 健康检查
make health

# API测试
make api-test

# 查看依赖
make deps

# 端口检查
make port-check
```

### 🧪 测试和构建

```bash
# 运行所有测试
mvn test

# 运行特定模块测试
mvn test -pl user-service

# 跳过测试构建
mvn clean install -DskipTests

# 生成测试报告
mvn surefire-report:report

# 打包应用
mvn clean package

# 查看依赖树
mvn dependency:tree
```

### 📊 数据库操作

```bash
# 查看Flyway迁移状态
mvn flyway:info -pl user-web

# 执行数据库迁移
mvn flyway:migrate -pl user-web

# 清理数据库（仅开发环境）
mvn flyway:clean -pl user-web -Pdev

# 修复损坏的迁移
mvn flyway:repair -pl user-web
```

### 🌍 多环境支持

```bash
# 开发环境
mvn spring-boot:run -pl user-web -Dspring-boot.run.profiles=dev

# 测试环境
java -jar user-web/target/user-web-1.0.0.jar --spring.profiles.active=test

# 生产环境（使用环境变量）
export DATABASE_URL="jdbc:mysql://prod-db:3306/user_db"
export DATABASE_USERNAME="app_user" 
export DATABASE_PASSWORD="secure_password"
java -jar user-web/target/user-web-1.0.0.jar --spring.profiles.active=prod
```

### 🔧 开发最佳实践

**新增API接口步骤**：
1. 在 `user-common` 模块中定义DTO和实体类
2. 在 `user-dao` 模块中添加MyBatis Mapper方法
3. 在 `user-service` 模块中实现业务逻辑
4. 在 `user-web` 模块中添加REST Controller
5. 运行代码质量检查：`mvn -Pcode-quality verify`

**数据库变更流程**：
1. 在 `user-web/src/main/resources/db/migration/` 创建迁移脚本
2. 命名格式：`V{version}__{description}.sql`（如 `V3__Add_user_status_index.sql`）
3. 测试迁移：`mvn flyway:info -pl user-web`
4. 应用迁移：`mvn flyway:migrate -pl user-web`

## 🚨 故障排除

### ⚠️ 常见问题解决

**Maven依赖解析失败**
```bash
# 清理并重新构建
mvn clean install -DskipTests
```

**数据库连接失败**
- 检查MySQL服务状态：`brew services list | grep mysql`
- 验证数据库连接参数
- 确认数据库和用户权限

**端口占用问题**
```bash
# 查找占用端口的进程
lsof -i :8080
# 终止进程
kill -9 <PID>
```

**Flyway迁移失败**
```bash
# 查看迁移状态
mvn flyway:info -pl user-web
# 修复迁移状态
mvn flyway:repair -pl user-web
```

## 🔒 安全和生产考虑

- ✅ **密码安全**：BCrypt哈希存储，盐值加密
- ✅ **并发控制**：乐观锁防止数据冲突
- ✅ **数据保护**：软删除机制，审计日志
- ✅ **输入验证**：JSR-303验证，防SQL注入
- ✅ **敏感信息**：生产环境敏感数据不记录日志
- ✅ **监控告警**：Actuator健康检查，性能指标

## 📈 监控和运维

### 🩺 健康检查端点
```bash
# 应用整体健康状态
curl http://localhost:8080/actuator/health

# 详细健康信息
curl http://localhost:8080/actuator/health/db

# 应用信息和版本
curl http://localhost:8080/actuator/info

# 性能指标
curl http://localhost:8080/actuator/metrics
```

### 📝 日志管理
- **开发环境**：控制台彩色输出，DEBUG级别
- **测试环境**：文件输出，INFO级别
- **生产环境**：`/var/log/user-management/application.log`，WARN级别
- **日志轮转**：每文件10MB，保留30天

## 💡 推荐IDE配置

### IntelliJ IDEA插件
- **Lombok Plugin** - 支持注解处理
- **MyBatis Plugin** - SQL映射文件支持
- **CheckStyle-IDEA** - 实时代码风格检查
- **PMD Plugin** - 静态分析集成
- **Database Navigator** - 数据库管理

### VS Code扩展
- **Extension Pack for Java** - Java开发套件
- **Spring Boot Extension Pack** - Spring Boot支持
- **MySQL Extension** - 数据库连接管理

## 🤝 贡献指南

### 📋 开发流程
1. **Fork项目** 并创建特性分支
2. **遵循规范** 运行代码质量检查
3. **编写测试** 确保功能正确性
4. **提交PR** 提供清晰的变更说明

### 📏 代码规范
- 遵循 Google Java Style Guide
- 提交前运行：`mvn -Pcode-quality verify`
- 保持测试覆盖率 > 80%
- 使用约定式提交信息格式

```bash
# 提交信息格式示例
feat: 添加用户搜索功能
fix: 修复用户更新时的并发问题
docs: 更新API文档
refactor: 重构用户服务层代码
```

## 🔗 相关资源

- [Spring Boot 官方文档](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [MyBatis 中文文档](https://mybatis.org/mybatis-3/zh/index.html)
- [Flyway 迁移指南](https://flywaydb.org/documentation/)
- [Google Java 风格指南](https://google.github.io/styleguide/javaguide.html)

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](../LICENSE) 文件了解详情

---

**项目维护者**: Claude Code  
**最后更新**: 2024年9月9日  
**版本**: 1.0.0