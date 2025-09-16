/**
 * Utility function collection
 */

// User type definition
interface User {
  id: number;
  name: string;
  email: string;
  age: number;
  isActive: boolean;
  hasPermission: boolean;
  role: 'admin' | 'moderator' | 'user';
}

// Processed user type
interface ProcessedUser extends User {
  status: string;
}

// Login credentials type
export interface LoginCredentials {
  username: string;
  password: string;
  rememberMe: boolean;
}

// Form validation error type
export interface ValidationErrors {
  username?: string;
  password?: string;
}

// Login result type
export interface LoginResult {
  success: boolean;
  message: string;
  user?: User;
}

/**
 * Process user data
 * @param user User object
 * @returns Processed user object
 */
export function processUserData(user: User): ProcessedUser {
  const status = determineUserStatus(user);
  return { ...user, status };
}

/**
 * Determine user status
 * @param user User object
 * @returns User status string
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
 * Validate if string is valid
 * @param value Value to validate
 * @returns Whether it is a valid string
 */
export function isValidString(value: unknown): value is string {
  return typeof value === 'string' && value.length > 0;
}

/**
 * Validate username
 * @param username Username
 * @returns Validation error message, empty string if no error
 */
export function validateUsername(username: string): string {
  if (!username.trim()) {
    return 'Please enter username';
  }
  if (username.length < 3) {
    return 'Username must be at least 3 characters';
  }
  if (username.length > 20) {
    return 'Username cannot exceed 20 characters';
  }
  if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]+$/.test(username)) {
    return 'Username can only contain letters, numbers, underscores and Chinese characters';
  }
  return '';
}

/**
 * Validate password
 * @param password Password
 * @returns Validation error message, empty string if no error
 */
export function validatePassword(password: string): string {
  if (!password) {
    return 'Please enter password';
  }
  if (password.length < 6) {
    return 'Password must be at least 6 characters';
  }
  if (password.length > 50) {
    return 'Password cannot exceed 50 characters';
  }
  if (!/^(?=.*[a-zA-Z])(?=.*\d)/.test(password)) {
    return 'Password must contain at least one letter and one number';
  }
  return '';
}

/**
 * Validate login form
 * @param credentials Login credentials
 * @returns Validation error object
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
 * Simulate login API call
 * @param credentials Login credentials
 * @returns Promise<LoginResult>
 */
export async function simulateLogin(
  credentials: LoginCredentials
): Promise<LoginResult> {
  // Simulate network delay
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Simulate login logic - simple username password verification
  const validUsers = [
    { username: 'admin', password: 'admin123', role: 'admin' as const },
    { username: 'user', password: 'user123', role: 'user' as const },
    { username: 'testuser', password: 'test123', role: 'user' as const },
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
      message: 'Login successful!',
      user: loginUser,
    };
  }

  return {
    success: false,
    message: 'Invalid username or password',
  };
}

/**
 * Local storage utility - remember me functionality
 */
export const LocalStorageHelper = {
  setRememberMe: (username: string): void => {
    try {
      localStorage.setItem('rememberedUsername', username);
    } catch (error) {
      console.warn('Unable to save remember me setting:', error);
    }
  },

  getRememberedUsername: (): string => {
    try {
      return localStorage.getItem('rememberedUsername') || '';
    } catch (error) {
      console.warn('Unable to get remember me setting:', error);
      return '';
    }
  },

  clearRememberMe: (): void => {
    try {
      localStorage.removeItem('rememberedUsername');
    } catch (error) {
      console.warn('Unable to clear remember me setting:', error);
    }
  },
};

/**
 * Handle potentially null data
 * @param data Potentially null data
 * @returns Processed string
 */
export function processData(data: string | null): string {
  if (isValidString(data)) {
    return data.toUpperCase();
  }
  return '';
}

/**
 * Handle data using optional chaining and nullish coalescing
 * @param data Potentially null data
 * @returns Processed string
 */
export function processDataSafe(data: string | null): string {
  return data?.toUpperCase() ?? '';
}

/**
 * Generic data processing function
 * @param data Generic data
 * @returns Processed data
 */
export function handleData<T>(data: T): T {
  return data;
}

/**
 * Handle data using union types
 * @param data Union type data
 * @returns Processed string
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
