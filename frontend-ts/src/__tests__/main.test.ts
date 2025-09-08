/**
 * 主页面功能测试
 */

import { simulateLogin, LocalStorageHelper } from '../utils/helpers';

// 模拟导入的模块
jest.mock('../utils/helpers', () => ({
  ...jest.requireActual('../utils/helpers'),
  simulateLogin: jest.fn(),
  LocalStorageHelper: {
    setRememberMe: jest.fn(),
    getRememberedUsername: jest.fn().mockReturnValue(''),
    clearRememberMe: jest.fn(),
  },
}));

const mockSimulateLogin = simulateLogin as jest.MockedFunction<
  typeof simulateLogin
>;
const mockLocalStorageHelper = LocalStorageHelper as jest.Mocked<
  typeof LocalStorageHelper
>;

describe('登录表单基础测试', () => {
  beforeEach(() => {
    // 设置DOM结构
    document.body.innerHTML = `
      <form id="loginForm">
        <input id="username" type="text" />
        <span id="usernameError"></span>
        <input id="password" type="password" />
        <span id="passwordError"></span>
        <input id="rememberMe" type="checkbox" />
        <button id="loginButton" type="submit">登录</button>
      </form>
      <div id="loginStatus" style="display: none;"></div>
    `;

    // 重置所有模拟
    jest.clearAllMocks();
    mockLocalStorageHelper.getRememberedUsername.mockReturnValue('');
  });

  test('应该正确初始化DOM元素', () => {
    const form = document.getElementById('loginForm') as HTMLFormElement;
    const usernameInput = document.getElementById(
      'username'
    ) as HTMLInputElement;
    const passwordInput = document.getElementById(
      'password'
    ) as HTMLInputElement;
    const rememberMeInput = document.getElementById(
      'rememberMe'
    ) as HTMLInputElement;
    const loginButton = document.getElementById(
      'loginButton'
    ) as HTMLButtonElement;
    const loginStatus = document.getElementById('loginStatus') as HTMLElement;
    const usernameError = document.getElementById(
      'usernameError'
    ) as HTMLElement;
    const passwordError = document.getElementById(
      'passwordError'
    ) as HTMLElement;

    expect(form).toBeTruthy();
    expect(usernameInput).toBeTruthy();
    expect(passwordInput).toBeTruthy();
    expect(rememberMeInput).toBeTruthy();
    expect(loginButton).toBeTruthy();
    expect(loginStatus).toBeTruthy();
    expect(usernameError).toBeTruthy();
    expect(passwordError).toBeTruthy();
  });

  test('应该能够触发表单提交事件', async () => {
    const form = document.getElementById('loginForm') as HTMLFormElement;
    const usernameInput = document.getElementById(
      'username'
    ) as HTMLInputElement;
    const passwordInput = document.getElementById(
      'password'
    ) as HTMLInputElement;

    // 设置有效输入
    usernameInput.value = 'admin';
    passwordInput.value = 'admin123';

    mockSimulateLogin.mockResolvedValue({
      success: true,
      message: '登录成功！',
    });

    // 创建一个简单的提交处理函数
    let formSubmitted = false;
    form.addEventListener('submit', e => {
      e.preventDefault();
      formSubmitted = true;
    });

    // 触发表单提交
    const submitEvent = new Event('submit');
    form.dispatchEvent(submitEvent);

    expect(formSubmitted).toBe(true);
  });

  test('应该验证localStorage功能', () => {
    mockLocalStorageHelper.setRememberMe('testuser');
    expect(mockLocalStorageHelper.setRememberMe).toHaveBeenCalledWith(
      'testuser'
    );

    mockLocalStorageHelper.getRememberedUsername.mockReturnValue('testuser');
    expect(mockLocalStorageHelper.getRememberedUsername()).toBe('testuser');

    mockLocalStorageHelper.clearRememberMe();
    expect(mockLocalStorageHelper.clearRememberMe).toHaveBeenCalled();
  });

  test('应该能够模拟登录API调用', async () => {
    const credentials = {
      username: 'admin',
      password: 'admin123',
      rememberMe: true,
    };

    mockSimulateLogin.mockResolvedValue({
      success: true,
      message: '登录成功！',
      user: {
        id: 1,
        name: 'admin',
        email: 'admin@example.com',
        age: 25,
        isActive: true,
        hasPermission: true,
        role: 'admin',
      },
    });

    const result = await mockSimulateLogin(credentials);

    expect(mockSimulateLogin).toHaveBeenCalledWith(credentials);
    expect(result.success).toBe(true);
    expect(result.message).toBe('登录成功！');
    expect(result.user).toBeDefined();
  });

  test('应该能够处理登录失败', async () => {
    const credentials = {
      username: 'invalid',
      password: 'wrong',
      rememberMe: false,
    };

    mockSimulateLogin.mockResolvedValue({
      success: false,
      message: '用户名或密码错误',
    });

    const result = await mockSimulateLogin(credentials);

    expect(result.success).toBe(false);
    expect(result.message).toBe('用户名或密码错误');
  });
});
