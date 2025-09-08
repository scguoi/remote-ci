# Frontend TypeScript 登录项目

这是一个完整的前端登录项目，使用 TypeScript + Vite 构建，包含完整的表单验证、单元测试和现代化的用户界面。

## 🚀 功能特性

- ✅ **现代化登录界面** - 响应式设计，支持移动端
- ✅ **完整的表单验证** - 实时验证用户名和密码
- ✅ **记住我功能** - 使用 localStorage 保存用户名
- ✅ **加载状态管理** - 登录过程中的视觉反馈
- ✅ **TypeScript支持** - 完整的类型定义和类型安全
- ✅ **单元测试** - 使用 Jest 进行全面测试覆盖
- ✅ **代码质量工具** - ESLint + Prettier 保证代码质量

## 🛠️ 技术栈

- **构建工具**: Vite 5.x
- **语言**: TypeScript 5.x
- **测试框架**: Jest + jsdom
- **代码质量**: ESLint + Prettier
- **样式**: 原生 CSS（现代化设计）

## 📦 安装与使用

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000

### 构建生产版本

```bash
npm run build
```

### 运行测试

```bash
npm test
```

### 代码质量检查

```bash
npm run quality
```

## 🔐 测试账户

项目内置了以下测试账户供开发使用：

| 用户名   | 密码     | 角色     |
| -------- | -------- | -------- |
| admin    | admin123 | 管理员   |
| user     | user123  | 普通用户 |
| 测试用户 | test123  | 普通用户 |

## 📝 验证规则

### 用户名验证

- 必填字段
- 最少3个字符，最多20个字符
- 只能包含字母、数字、下划线和中文字符

### 密码验证

- 必填字段
- 最少6个字符，最多50个字符
- 必须包含至少一个字母和一个数字

## 🏗️ 项目结构

```
src/
├── main.ts              # 主入口文件，包含登录表单逻辑
├── utils/
│   └── helpers.ts       # 工具函数（验证、API模拟等）
├── styles/
│   └── main.css        # 主样式文件
└── __tests__/          # 测试文件
    ├── setup.ts        # 测试环境配置
    ├── helpers.test.ts # 工具函数测试
    └── main.test.ts    # 主要功能测试
```

## ✨ 主要功能

### 登录表单类 (LoginForm)

- 表单验证和错误显示
- 异步登录处理
- 加载状态管理
- 记住我功能
- 错误处理和用户反馈

### 验证工具函数

- `validateUsername()` - 用户名验证
- `validatePassword()` - 密码验证
- `validateLoginForm()` - 完整表单验证
- `simulateLogin()` - 模拟登录API

### 本地存储工具

- `LocalStorageHelper` - 安全的localStorage操作

## 🧪 测试覆盖

项目包含29个测试用例，覆盖：

- ✅ 表单验证逻辑
- ✅ 登录API模拟
- ✅ DOM交互
- ✅ 本地存储功能
- ✅ 错误处理

运行 `npm test` 查看详细测试结果。

## 🎨 界面设计

- **渐变背景** - 现代化视觉效果
- **毛玻璃卡片** - 半透明背景模糊效果
- **响应式布局** - 适配手机、平板、桌面
- **动画效果** - 流畅的交互动画
- **状态反馈** - 清晰的成功/错误提示

## 🔧 开发说明

### 添加新的验证规则

在 `src/utils/helpers.ts` 中修改验证函数：

```typescript
export function validateUsername(username: string): string {
  // 添加自定义验证逻辑
}
```

### 修改登录API

修改 `simulateLogin` 函数连接真实的后端API：

```typescript
export async function simulateLogin(
  credentials: LoginCredentials
): Promise<LoginResult> {
  const response = await fetch('/api/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(credentials),
  });
  return response.json();
}
```

## 📋 TODO

- [ ] 添加忘记密码功能
- [ ] 集成真实的后端API
- [ ] 添加多语言支持
- [ ] 添加主题切换功能
- [ ] 添加社交登录选项

## 🤝 贡献

欢迎提交 Issues 和 Pull Requests！

## 📄 许可证

MIT License
