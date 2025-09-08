/**
 * 工具函数测试
 */

import {
  validateUsername,
  validatePassword,
  validateLoginForm,
  simulateLogin,
  LocalStorageHelper,
  LoginCredentials,
} from '../utils/helpers';

describe('validateUsername', () => {
  test('应该拒绝空用户名', () => {
    expect(validateUsername('')).toBe('请输入用户名');
    expect(validateUsername('   ')).toBe('请输入用户名');
  });

  test('应该拒绝过短的用户名', () => {
    expect(validateUsername('ab')).toBe('用户名至少需要3个字符');
  });

  test('应该拒绝过长的用户名', () => {
    const longUsername = 'a'.repeat(21);
    expect(validateUsername(longUsername)).toBe('用户名不能超过20个字符');
  });

  test('应该拒绝包含无效字符的用户名', () => {
    expect(validateUsername('user@name')).toBe(
      '用户名只能包含字母、数字、下划线和中文字符'
    );
    expect(validateUsername('user name')).toBe(
      '用户名只能包含字母、数字、下划线和中文字符'
    );
    expect(validateUsername('user-name')).toBe(
      '用户名只能包含字母、数字、下划线和中文字符'
    );
  });

  test('应该接受有效的用户名', () => {
    expect(validateUsername('admin')).toBe('');
    expect(validateUsername('user123')).toBe('');
    expect(validateUsername('test_user')).toBe('');
    expect(validateUsername('测试用户')).toBe('');
    expect(validateUsername('user_测试123')).toBe('');
  });
});

describe('validatePassword', () => {
  test('应该拒绝空密码', () => {
    expect(validatePassword('')).toBe('请输入密码');
  });

  test('应该拒绝过短的密码', () => {
    expect(validatePassword('123')).toBe('密码至少需要6个字符');
  });

  test('应该拒绝过长的密码', () => {
    const longPassword = 'a'.repeat(51);
    expect(validatePassword(longPassword)).toBe('密码不能超过50个字符');
  });

  test('应该拒绝不包含字母的密码', () => {
    expect(validatePassword('123456')).toBe(
      '密码必须包含至少一个字母和一个数字'
    );
  });

  test('应该拒绝不包含数字的密码', () => {
    expect(validatePassword('abcdef')).toBe(
      '密码必须包含至少一个字母和一个数字'
    );
  });

  test('应该接受有效的密码', () => {
    expect(validatePassword('admin123')).toBe('');
    expect(validatePassword('Test123')).toBe('');
    expect(validatePassword('a1b2c3')).toBe('');
    expect(validatePassword('MyPassword1')).toBe('');
  });
});

describe('validateLoginForm', () => {
  const validCredentials: LoginCredentials = {
    username: 'admin',
    password: 'admin123',
    rememberMe: false,
  };

  test('应该验证有效的登录信息', () => {
    const errors = validateLoginForm(validCredentials);
    expect(errors).toEqual({});
  });

  test('应该返回用户名错误', () => {
    const invalidCredentials = { ...validCredentials, username: 'ab' };
    const errors = validateLoginForm(invalidCredentials);
    expect(errors.username).toBe('用户名至少需要3个字符');
    expect(errors.password).toBeUndefined();
  });

  test('应该返回密码错误', () => {
    const invalidCredentials = { ...validCredentials, password: '123' };
    const errors = validateLoginForm(invalidCredentials);
    expect(errors.password).toBe('密码至少需要6个字符');
    expect(errors.username).toBeUndefined();
  });

  test('应该返回多个错误', () => {
    const invalidCredentials = {
      ...validCredentials,
      username: '',
      password: '123',
    };
    const errors = validateLoginForm(invalidCredentials);
    expect(errors.username).toBe('请输入用户名');
    expect(errors.password).toBe('密码至少需要6个字符');
  });
});

describe('simulateLogin', () => {
  test('应该成功登录有效用户', async () => {
    const credentials: LoginCredentials = {
      username: 'admin',
      password: 'admin123',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(true);
    expect(result.message).toBe('登录成功！');
    expect(result.user).toBeDefined();
    expect(result.user?.name).toBe('admin');
    expect(result.user?.role).toBe('admin');
  });

  test('应该成功登录中文用户名', async () => {
    const credentials: LoginCredentials = {
      username: '测试用户',
      password: 'test123',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(true);
    expect(result.user?.name).toBe('测试用户');
    expect(result.user?.role).toBe('user');
  });

  test('应该拒绝无效用户', async () => {
    const credentials: LoginCredentials = {
      username: 'invalid',
      password: 'wrong123',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(false);
    expect(result.message).toBe('用户名或密码错误');
    expect(result.user).toBeUndefined();
  });

  test('应该拒绝错误密码', async () => {
    const credentials: LoginCredentials = {
      username: 'admin',
      password: 'wrongpassword',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(false);
    expect(result.message).toBe('用户名或密码错误');
  });

  test('登录应该有延迟', async () => {
    const startTime = Date.now();
    const credentials: LoginCredentials = {
      username: 'admin',
      password: 'admin123',
      rememberMe: false,
    };

    await simulateLogin(credentials);
    const endTime = Date.now();
    const duration = endTime - startTime;

    // 应该至少有1000ms的延迟（允许一些误差）
    expect(duration).toBeGreaterThanOrEqual(900);
  });
});

describe('LocalStorageHelper', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  test('应该保存和获取记住的用户名', () => {
    LocalStorageHelper.setRememberMe('testuser');
    expect(LocalStorageHelper.getRememberedUsername()).toBe('testuser');
    expect(localStorage.setItem).toHaveBeenCalledWith(
      'rememberedUsername',
      'testuser'
    );
  });

  test('应该返回空字符串如果没有记住的用户名', () => {
    expect(LocalStorageHelper.getRememberedUsername()).toBe('');
  });

  test('应该清除记住的用户名', () => {
    LocalStorageHelper.setRememberMe('testuser');
    LocalStorageHelper.clearRememberMe();
    expect(LocalStorageHelper.getRememberedUsername()).toBe('');
    expect(localStorage.removeItem).toHaveBeenCalledWith('rememberedUsername');
  });

  test('应该处理localStorage错误', () => {
    // 模拟localStorage错误
    const mockSetItem = jest.fn(() => {
      throw new Error('Storage error');
    });
    Object.defineProperty(window, 'localStorage', {
      value: {
        setItem: mockSetItem,
        getItem: jest.fn(() => {
          throw new Error('Storage error');
        }),
        removeItem: jest.fn(() => {
          throw new Error('Storage error');
        }),
      },
    });

    // 这些调用不应该抛出错误
    expect(() => LocalStorageHelper.setRememberMe('test')).not.toThrow();
    expect(() => LocalStorageHelper.getRememberedUsername()).not.toThrow();
    expect(() => LocalStorageHelper.clearRememberMe()).not.toThrow();

    // 应该返回默认值
    expect(LocalStorageHelper.getRememberedUsername()).toBe('');
  });
});
