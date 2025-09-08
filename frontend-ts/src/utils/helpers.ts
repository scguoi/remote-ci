/**
 * 工具函数集合
 */

// 用户类型定义
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
  isActive: boolean;
  hasPermission: boolean;
  role: 'admin' | 'moderator' | 'user';
}

// 处理后的用户类型
interface ProcessedUser extends User {
  status: string;
}

// 登录凭证类型
export interface LoginCredentials {
  username: string;
  password: string;
  rememberMe: boolean;
}

// 表单验证错误类型
export interface ValidationErrors {
  username?: string;
  password?: string;
}

// 登录结果类型
export interface LoginResult {
  success: boolean;
  message: string;
  user?: User;
}

/**
 * 处理用户数据
 * @param user 用户对象
 * @returns 处理后的用户对象
 */
export function processUserData(user: User): ProcessedUser {
  const status = determineUserStatus(user);
  return { ...user, status };
}

/**
 * 确定用户状态
 * @param user 用户对象
 * @returns 用户状态字符串
 */
function determineUserStatus(user: User): string {
  if (user.age <= 18) return 'underage';
  if (!user.isActive) return 'suspended';
  if (!user.hasPermission) return 'inactive';

  return user.role === 'admin'
    ? 'admin'
    : user.role === 'moderator'
      ? 'moderator'
      : 'user';
}

/**
 * 验证字符串是否有效
 * @param value 要验证的值
 * @returns 是否为有效字符串
 */
export function isValidString(value: unknown): value is string {
  return typeof value === 'string' && value.length > 0;
}

/**
 * 验证用户名
 * @param username 用户名
 * @returns 验证错误信息，无错误返回空字符串
 */
export function validateUsername(username: string): string {
  if (!username.trim()) {
    return '请输入用户名';
  }
  if (username.length < 3) {
    return '用户名至少需要3个字符';
  }
  if (username.length > 20) {
    return '用户名不能超过20个字符';
  }
  if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(username)) {
    return '用户名只能包含字母、数字、下划线和中文字符';
  }
  return '';
}

/**
 * 验证密码
 * @param password 密码
 * @returns 验证错误信息，无错误返回空字符串
 */
export function validatePassword(password: string): string {
  if (!password) {
    return '请输入密码';
  }
  if (password.length < 6) {
    return '密码至少需要6个字符';
  }
  if (password.length > 50) {
    return '密码不能超过50个字符';
  }
  if (!/^(?=.*[a-zA-Z])(?=.*\d)/.test(password)) {
    return '密码必须包含至少一个字母和一个数字';
  }
  return '';
}

/**
 * 验证登录表单
 * @param credentials 登录凭证
 * @returns 验证错误对象
 */
export function validateLoginForm(
  credentials: LoginCredentials
): ValidationErrors {
  const errors: ValidationErrors = {};

  const usernameError = validateUsername(credentials.username);
  if (usernameError) {
    errors.username = usernameError;
  }

  const passwordError = validatePassword(credentials.password);
  if (passwordError) {
    errors.password = passwordError;
  }

  return errors;
}

/**
 * 模拟登录API调用
 * @param credentials 登录凭证
 * @returns Promise<LoginResult>
 */
export async function simulateLogin(
  credentials: LoginCredentials
): Promise<LoginResult> {
  // 模拟网络延迟
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 模拟登录逻辑 - 简单的用户名密码验证
  const validUsers = [
    { username: 'admin', password: 'admin123', role: 'admin' as const },
    { username: 'user', password: 'user123', role: 'user' as const },
    { username: '测试用户', password: 'test123', role: 'user' as const },
  ];

  const user = validUsers.find(
    u =>
      u.username === credentials.username && u.password === credentials.password
  );

  if (user) {
    const loginUser: User = {
      id: Date.now(),
      name: user.username,
      email: `${user.username}@example.com`,
      age: 25,
      isActive: true,
      hasPermission: true,
      role: user.role,
    };

    return {
      success: true,
      message: '登录成功！',
      user: loginUser,
    };
  }

  return {
    success: false,
    message: '用户名或密码错误',
  };
}

/**
 * 本地存储工具 - 记住我功能
 */
export const LocalStorageHelper = {
  setRememberMe: (username: string): void => {
    try {
      localStorage.setItem('rememberedUsername', username);
    } catch (error) {
      console.warn('无法保存记住我设置:', error);
    }
  },

  getRememberedUsername: (): string => {
    try {
      return localStorage.getItem('rememberedUsername') || '';
    } catch (error) {
      console.warn('无法获取记住我设置:', error);
      return '';
    }
  },

  clearRememberMe: (): void => {
    try {
      localStorage.removeItem('rememberedUsername');
    } catch (error) {
      console.warn('无法清除记住我设置:', error);
    }
  },
};

/**
 * 处理可能为null的数据
 * @param data 可能为null的数据
 * @returns 处理后的字符串
 */
export function processData(data: string | null): string {
  if (isValidString(data)) {
    return data.toUpperCase();
  }
  return '';
}

/**
 * 使用可选链和空值合并处理数据
 * @param data 可能为null的数据
 * @returns 处理后的字符串
 */
export function processDataSafe(data: string | null): string {
  return data?.toUpperCase() ?? '';
}

/**
 * 泛型数据处理函数
 * @param data 泛型数据
 * @returns 处理后的数据
 */
export function handleData<T>(data: T): T {
  return data;
}

/**
 * 使用联合类型处理数据
 * @param data 联合类型数据
 * @returns 处理后的字符串
 */
export function handleUnionData(data: string | number | boolean): string {
  if (typeof data === 'string') {
    return data.toUpperCase();
  } else if (typeof data === 'number') {
    return data.toFixed(2);
  } else {
    return data.toString();
  }
}
