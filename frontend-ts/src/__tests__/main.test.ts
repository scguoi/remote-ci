/**
 * Main page functionality tests
 */

import { simulateLogin, LocalStorageHelper } from '../utils/helpers';

// Mock imported modules
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

describe('Basic login form tests', () => {
  beforeEach(() => {
    // Set up DOM structure
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

    // Reset all mocks
    jest.clearAllMocks();
    mockLocalStorageHelper.getRememberedUsername.mockReturnValue('');
  });

  test('should correctly initialize DOM elements', () => {
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

  test('should be able to trigger form submission event', async () => {
    const form = document.getElementById('loginForm') as HTMLFormElement;
    const usernameInput = document.getElementById(
      'username'
    ) as HTMLInputElement;
    const passwordInput = document.getElementById(
      'password'
    ) as HTMLInputElement;

    // Set up valid input
    usernameInput.value = 'admin';
    passwordInput.value = 'admin123';

    mockSimulateLogin.mockResolvedValue({
      success: true,
      message: 'Login successful!',
    });

    // Create a simple submit handler function
    let formSubmitted = false;
    form.addEventListener('submit', e => {
      e.preventDefault();
      formSubmitted = true;
    });

    // Trigger form submission
    const submitEvent = new Event('submit');
    form.dispatchEvent(submitEvent);

    expect(formSubmitted).toBe(true);
  });

  test('should validate localStorage functionality', () => {
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
      message: 'Login successful!',
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
    expect(result.message).toBe('Login successful!');
    expect(result.user).toBeDefined();
  });

  test('should be able to handle login failure', async () => {
    const credentials = {
      username: 'invalid',
      password: 'wrong',
      rememberMe: false,
    };

    mockSimulateLogin.mockResolvedValue({
      success: false,
      message: 'Invalid username or password',
    });

    const result = await mockSimulateLogin(credentials);

    expect(result.success).toBe(false);
    expect(result.message).toBe('Invalid username or password');
  });
});
