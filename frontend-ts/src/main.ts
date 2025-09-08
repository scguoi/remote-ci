import {
  LoginCredentials,
  ValidationErrors,
  validateLoginForm,
  simulateLogin,
  LocalStorageHelper,
} from './utils/helpers.js';

/**
 * 登录表单管理类
 */
class LoginForm {
  private form: HTMLFormElement;
  private usernameInput: HTMLInputElement;
  private passwordInput: HTMLInputElement;
  private rememberMeInput: HTMLInputElement;
  private loginButton: HTMLButtonElement;
  private loginStatus: HTMLElement;
  private usernameError: HTMLElement;
  private passwordError: HTMLElement;

  constructor() {
    this.form = document.getElementById('loginForm') as HTMLFormElement;
    this.usernameInput = document.getElementById(
      'username'
    ) as HTMLInputElement;
    this.passwordInput = document.getElementById(
      'password'
    ) as HTMLInputElement;
    this.rememberMeInput = document.getElementById(
      'rememberMe'
    ) as HTMLInputElement;
    this.loginButton = document.getElementById(
      'loginButton'
    ) as HTMLButtonElement;
    this.loginStatus = document.getElementById('loginStatus') as HTMLElement;
    this.usernameError = document.getElementById(
      'usernameError'
    ) as HTMLElement;
    this.passwordError = document.getElementById(
      'passwordError'
    ) as HTMLElement;

    this.initializeEventListeners();
    this.loadRememberedUsername();
  }

  /**
   * 初始化事件监听器
   */
  private initializeEventListeners(): void {
    // 表单提交事件
    this.form.addEventListener('submit', this.handleSubmit.bind(this));

    // 实时验证事件
    this.usernameInput.addEventListener(
      'blur',
      this.validateUsernameField.bind(this)
    );
    this.passwordInput.addEventListener(
      'blur',
      this.validatePasswordField.bind(this)
    );

    // 输入时清除错误状态
    this.usernameInput.addEventListener('input', () =>
      this.clearFieldError('username')
    );
    this.passwordInput.addEventListener('input', () =>
      this.clearFieldError('password')
    );

    // 记住我复选框事件
    this.rememberMeInput.addEventListener(
      'change',
      this.handleRememberMeChange.bind(this)
    );
  }

  /**
   * 加载记住的用户名
   */
  private loadRememberedUsername(): void {
    const rememberedUsername = LocalStorageHelper.getRememberedUsername();
    if (rememberedUsername) {
      this.usernameInput.value = rememberedUsername;
      this.rememberMeInput.checked = true;
      this.passwordInput.focus();
    }
  }

  /**
   * 处理表单提交
   */
  private async handleSubmit(event: Event): Promise<void> {
    event.preventDefault();

    const credentials: LoginCredentials = {
      username: this.usernameInput.value.trim(),
      password: this.passwordInput.value,
      rememberMe: this.rememberMeInput.checked,
    };

    // 验证表单
    const errors = validateLoginForm(credentials);
    this.displayErrors(errors);

    // 如果有验证错误，不提交表单
    if (Object.keys(errors).length > 0) {
      this.focusFirstErrorField(errors);
      return;
    }

    // 开始登录流程
    this.setLoadingState(true);
    this.hideStatus();

    try {
      const result = await simulateLogin(credentials);

      if (result.success) {
        this.handleLoginSuccess(credentials, result.message);
      } else {
        this.handleLoginFailure(result.message);
      }
    } catch (error) {
      this.handleLoginFailure('登录过程中发生错误，请稍后重试');
      console.error('登录错误:', error);
    } finally {
      this.setLoadingState(false);
    }
  }

  /**
   * 验证用户名字段
   */
  private validateUsernameField(): void {
    const username = this.usernameInput.value.trim();
    const errors = validateLoginForm({
      username,
      password: this.passwordInput.value,
      rememberMe: this.rememberMeInput.checked,
    });

    this.displayFieldError('username', errors.username);
  }

  /**
   * 验证密码字段
   */
  private validatePasswordField(): void {
    const password = this.passwordInput.value;
    const errors = validateLoginForm({
      username: this.usernameInput.value.trim(),
      password,
      rememberMe: this.rememberMeInput.checked,
    });

    this.displayFieldError('password', errors.password);
  }

  /**
   * 显示字段错误
   */
  private displayFieldError(
    field: keyof ValidationErrors,
    error?: string
  ): void {
    const input =
      field === 'username' ? this.usernameInput : this.passwordInput;
    const errorElement =
      field === 'username' ? this.usernameError : this.passwordError;

    if (error) {
      errorElement.textContent = error;
      input.classList.add('error');
      input.classList.remove('success');
    } else {
      errorElement.textContent = '';
      input.classList.remove('error');
      input.classList.add('success');
    }
  }

  /**
   * 清除字段错误状态
   */
  private clearFieldError(field: keyof ValidationErrors): void {
    const input =
      field === 'username' ? this.usernameInput : this.passwordInput;
    const errorElement =
      field === 'username' ? this.usernameError : this.passwordError;

    errorElement.textContent = '';
    input.classList.remove('error', 'success');
  }

  /**
   * 显示所有验证错误
   */
  private displayErrors(errors: ValidationErrors): void {
    this.displayFieldError('username', errors.username);
    this.displayFieldError('password', errors.password);
  }

  /**
   * 焦点定位到第一个错误字段
   */
  private focusFirstErrorField(errors: ValidationErrors): void {
    if (errors.username) {
      this.usernameInput.focus();
    } else if (errors.password) {
      this.passwordInput.focus();
    }
  }

  /**
   * 设置加载状态
   */
  private setLoadingState(isLoading: boolean): void {
    if (isLoading) {
      this.loginButton.classList.add('loading');
      this.loginButton.disabled = true;
    } else {
      this.loginButton.classList.remove('loading');
      this.loginButton.disabled = false;
    }
  }

  /**
   * 处理登录成功
   */
  private handleLoginSuccess(
    credentials: LoginCredentials,
    message: string
  ): void {
    // 处理记住我功能
    if (credentials.rememberMe) {
      LocalStorageHelper.setRememberMe(credentials.username);
    } else {
      LocalStorageHelper.clearRememberMe();
    }

    this.showStatus(message, 'success');

    // 清空密码字段
    this.passwordInput.value = '';

    // 实际应用中，这里应该重定向到主页面
    setTimeout(() => {
      this.showStatus('登录成功！正在跳转到主页面...', 'success');
    }, 1000);
  }

  /**
   * 处理登录失败
   */
  private handleLoginFailure(message: string): void {
    this.showStatus(message, 'error');
    this.passwordInput.focus();
    this.passwordInput.select();
  }

  /**
   * 显示状态消息
   */
  private showStatus(message: string, type: 'success' | 'error'): void {
    this.loginStatus.textContent = message;
    this.loginStatus.className = `login-status ${type}`;
    this.loginStatus.style.display = 'block';
  }

  /**
   * 隐藏状态消息
   */
  private hideStatus(): void {
    this.loginStatus.style.display = 'none';
    this.loginStatus.textContent = '';
    this.loginStatus.className = 'login-status';
  }

  /**
   * 处理记住我复选框变化
   */
  private handleRememberMeChange(): void {
    if (!this.rememberMeInput.checked) {
      LocalStorageHelper.clearRememberMe();
    }
  }
}

/**
 * DOM加载完成后初始化登录表单
 */
document.addEventListener('DOMContentLoaded', () => {
  try {
    new LoginForm();
    console.log('登录表单初始化成功');

    // 开发模式下显示测试账户信息
    if (
      typeof window !== 'undefined' &&
      window.location.hostname === 'localhost'
    ) {
      console.log('测试账户:');
      console.log('1. 用户名: admin, 密码: admin123');
      console.log('2. 用户名: user, 密码: user123');
      console.log('3. 用户名: 测试用户, 密码: test123');
    }
  } catch (error) {
    console.error('登录表单初始化失败:', error);

    // 显示错误消息给用户
    const errorElement = document.createElement('div');
    errorElement.className = 'login-status error';
    errorElement.style.display = 'block';
    errorElement.style.position = 'fixed';
    errorElement.style.top = '20px';
    errorElement.style.left = '50%';
    errorElement.style.transform = 'translateX(-50%)';
    errorElement.style.zIndex = '9999';
    errorElement.textContent = '页面初始化失败，请刷新页面重试';
    document.body.appendChild(errorElement);
  }
});
