/**
 * Utility function tests
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
  test('should reject empty username', () => {
    expect(validateUsername('')).toBe('Please enter username');
    expect(validateUsername('   ')).toBe('Please enter username');
  });

  test('should reject too short username', () => {
    expect(validateUsername('ab')).toBe(
      'Username must be at least 3 characters'
    );
  });

  test('should reject too long username', () => {
    const longUsername = 'a'.repeat(21);
    expect(validateUsername(longUsername)).toBe(
      'Username cannot exceed 20 characters'
    );
  });

  test('should reject username with invalid characters', () => {
    expect(validateUsername('user@name')).toBe(
      'Username can only contain letters, numbers, underscores and Chinese characters'
    );
    expect(validateUsername('user name')).toBe(
      'Username can only contain letters, numbers, underscores and Chinese characters'
    );
    expect(validateUsername('user-name')).toBe(
      'Username can only contain letters, numbers, underscores and Chinese characters'
    );
  });

  test('should accept valid usernames', () => {
    expect(validateUsername('admin')).toBe('');
    expect(validateUsername('user123')).toBe('');
    expect(validateUsername('test_user')).toBe('');
    expect(validateUsername('testuser')).toBe('');
    expect(validateUsername('user_test123')).toBe('');
  });
});

describe('validatePassword', () => {
  test('should reject empty password', () => {
    expect(validatePassword('')).toBe('Please enter password');
  });

  test('should reject too short password', () => {
    expect(validatePassword('123')).toBe(
      'Password must be at least 6 characters'
    );
  });

  test('should reject too long password', () => {
    const longPassword = 'a'.repeat(51);
    expect(validatePassword(longPassword)).toBe(
      'Password cannot exceed 50 characters'
    );
  });

  test('should reject password without letters', () => {
    expect(validatePassword('123456')).toBe(
      'Password must contain at least one letter and one number'
    );
  });

  test('should reject password without numbers', () => {
    expect(validatePassword('abcdef')).toBe(
      'Password must contain at least one letter and one number'
    );
  });

  test('should accept valid passwords', () => {
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

  test('should validate valid login credentials', () => {
    const errors = validateLoginForm(validCredentials);
    expect(errors).toEqual({});
  });

  test('should return username error', () => {
    const invalidCredentials = { ...validCredentials, username: 'ab' };
    const errors = validateLoginForm(invalidCredentials);
    expect(errors.username).toBe('Username must be at least 3 characters');
    expect(errors.password).toBeUndefined();
  });

  test('should return password error', () => {
    const invalidCredentials = { ...validCredentials, password: '123' };
    const errors = validateLoginForm(invalidCredentials);
    expect(errors.password).toBe('Password must be at least 6 characters');
    expect(errors.username).toBeUndefined();
  });

  test('should return multiple errors', () => {
    const invalidCredentials = {
      ...validCredentials,
      username: '',
      password: '123',
    };
    const errors = validateLoginForm(invalidCredentials);
    expect(errors.username).toBe('Please enter username');
    expect(errors.password).toBe('Password must be at least 6 characters');
  });
});

describe('simulateLogin', () => {
  test('should successfully login valid user', async () => {
    const credentials: LoginCredentials = {
      username: 'admin',
      password: 'admin123',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(true);
    expect(result.message).toBe('Login successful!');
    expect(result.user).toBeDefined();
    expect(result.user?.name).toBe('admin');
    expect(result.user?.role).toBe('admin');
  });

  test('should successfully login Chinese username', async () => {
    const credentials: LoginCredentials = {
      username: 'testuser',
      password: 'test123',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(true);
    expect(result.user?.name).toBe('testuser');
    expect(result.user?.role).toBe('user');
  });

  test('should reject invalid user', async () => {
    const credentials: LoginCredentials = {
      username: 'invalid',
      password: 'wrong123',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(false);
    expect(result.message).toBe('Invalid username or password');
    expect(result.user).toBeUndefined();
  });

  test('should reject wrong password', async () => {
    const credentials: LoginCredentials = {
      username: 'admin',
      password: 'wrongpassword',
      rememberMe: false,
    };

    const result = await simulateLogin(credentials);
    expect(result.success).toBe(false);
    expect(result.message).toBe('Invalid username or password');
  });

  test('login should have delay', async () => {
    const startTime = Date.now();
    const credentials: LoginCredentials = {
      username: 'admin',
      password: 'admin123',
      rememberMe: false,
    };

    await simulateLogin(credentials);
    const endTime = Date.now();
    const duration = endTime - startTime;

    // Should have at least 1000ms delay (allow some tolerance)
    expect(duration).toBeGreaterThanOrEqual(900);
  });
});

describe('LocalStorageHelper', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  test('should save and get remembered username', () => {
    LocalStorageHelper.setRememberMe('testuser');
    expect(LocalStorageHelper.getRememberedUsername()).toBe('testuser');
    expect(localStorage.setItem).toHaveBeenCalledWith(
      'rememberedUsername',
      'testuser'
    );
  });

  test('should return empty string if no remembered username', () => {
    expect(LocalStorageHelper.getRememberedUsername()).toBe('');
  });

  test('should clear remembered username', () => {
    LocalStorageHelper.setRememberMe('testuser');
    LocalStorageHelper.clearRememberMe();
    expect(LocalStorageHelper.getRememberedUsername()).toBe('');
    expect(localStorage.removeItem).toHaveBeenCalledWith('rememberedUsername');
  });

  test('should handle localStorage errors', () => {
    // Mock localStorage error
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

    // These calls should not throw errors
    expect(() => LocalStorageHelper.setRememberMe('test')).not.toThrow();
    expect(() => LocalStorageHelper.getRememberedUsername()).not.toThrow();
    expect(() => LocalStorageHelper.clearRememberMe()).not.toThrow();

    // Should return default value
    expect(LocalStorageHelper.getRememberedUsername()).toBe('');
  });
});
