import {
  LoginCredentials,
  ValidationErrors,
  validateLoginForm,
  simulateLogin,
  LocalStorageHelper,
} from './utils/helpers.js';

/**
 * Login form management class
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
   * Initialize event listeners
   */
  private initializeEventListeners(): void {
    // Form submission event
    this.form.addEventListener('submit', this.handleSubmit.bind(this));

    // Real-time validation event
    this.usernameInput.addEventListener(
      'blur',
      this.validateUsernameField.bind(this)
    );
    this.passwordInput.addEventListener(
      'blur',
      this.validatePasswordField.bind(this)
    );

    // Clear error state on input
    this.usernameInput.addEventListener('input', () =>
      this.clearFieldError('username')
    );
    this.passwordInput.addEventListener('input', () =>
      this.clearFieldError('password')
    );

    // Remember me checkbox event
    this.rememberMeInput.addEventListener(
      'change',
      this.handleRememberMeChange.bind(this)
    );
  }

  /**
   * Load remembered username
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
   * Handle form submission
   */
  private async handleSubmit(event: Event): Promise<void> {
    event.preventDefault();

    const credentials: LoginCredentials = {
      username: this.usernameInput.value.trim(),
      password: this.passwordInput.value,
      rememberMe: this.rememberMeInput.checked,
    };

    // Validate form
    const errors = validateLoginForm(credentials);
    this.displayErrors(errors);

    // If there are validation errors, don't submit form
    if (Object.keys(errors).length > 0) {
      this.focusFirstErrorField(errors);
      return;
    }

    // Start login process
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
      this.handleLoginFailure(
        'An error occurred during login, please try again later'
      );
      console.error('Login error:', error);
    } finally {
      this.setLoadingState(false);
    }
  }

  /**
   * Validate username field
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
   * Validate password field
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
   * Display field error
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
   * Clear field error state
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
   * Display all validation errors
   */
  private displayErrors(errors: ValidationErrors): void {
    this.displayFieldError('username', errors.username);
    this.displayFieldError('password', errors.password);
  }

  /**
   * Focus on first error field
   */
  private focusFirstErrorField(errors: ValidationErrors): void {
    if (errors.username) {
      this.usernameInput.focus();
    } else if (errors.password) {
      this.passwordInput.focus();
    }
  }

  /**
   * Set loading state
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
   * Handle login success
   */
  private handleLoginSuccess(
    credentials: LoginCredentials,
    message: string
  ): void {
    // Handle remember me functionality
    if (credentials.rememberMe) {
      LocalStorageHelper.setRememberMe(credentials.username);
    } else {
      LocalStorageHelper.clearRememberMe();
    }

    this.showStatus(message, 'success');

    // Clear password field
    this.passwordInput.value = '';

    // In real application, should redirect to main page here
    setTimeout(() => {
      this.showStatus(
        'Login successful! Redirecting to main page...',
        'success'
      );
    }, 1000);
  }

  /**
   * Handle login failure
   */
  private handleLoginFailure(message: string): void {
    this.showStatus(message, 'error');
    this.passwordInput.focus();
    this.passwordInput.select();
  }

  /**
   * Display status message
   */
  private showStatus(message: string, type: 'success' | 'error'): void {
    this.loginStatus.textContent = message;
    this.loginStatus.className = `login-status ${type}`;
    this.loginStatus.style.display = 'block';
  }

  /**
   * Hide status message
   */
  private hideStatus(): void {
    this.loginStatus.style.display = 'none';
    this.loginStatus.textContent = '';
    this.loginStatus.className = 'login-status';
  }

  /**
   * Handle remember me checkbox change
   */
  private handleRememberMeChange(): void {
    if (!this.rememberMeInput.checked) {
      LocalStorageHelper.clearRememberMe();
    }
  }
}

/**
 * Initialize login form after DOM loads
 */
document.addEventListener('DOMContentLoaded', () => {
  try {
    new LoginForm();
    console.log('Login form initialized successfully');

    // Display test account info in development mode
    if (
      typeof window !== 'undefined' &&
      window.location.hostname === 'localhost'
    ) {
      console.log('Test accounts:');
      console.log('1. Username: admin, Password: admin123');
      console.log('2. Username: user, Password: user123');
      console.log('3. Username: testuser, Password: test123');
    }
  } catch (error) {
    console.error('Login form initialization failed:', error);

    // Display error message to user
    const errorElement = document.createElement('div');
    errorElement.className = 'login-status error';
    errorElement.style.display = 'block';
    errorElement.style.position = 'fixed';
    errorElement.style.top = '20px';
    errorElement.style.left = '50%';
    errorElement.style.transform = 'translateX(-50%)';
    errorElement.style.zIndex = '9999';
    errorElement.textContent =
      'Page initialization failed, please refresh and try again';
    document.body.appendChild(errorElement);
  }
});
