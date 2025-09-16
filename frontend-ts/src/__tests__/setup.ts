/**
 * Jest test environment setup
 */

// Mock localStorage
const localStorageMock = ((): Storage => {
  let store: { [key: string]: string } = {};

  return {
    getItem: jest.fn((key: string) => store[key] || null),
    setItem: jest.fn((key: string, value: string): void => {
      store[key] = value.toString();
    }),
    removeItem: jest.fn((key: string): void => {
      delete store[key];
    }),
    clear: jest.fn((): void => {
      store = {};
    }),
    get length(): number {
      return Object.keys(store).length;
    },
    key: jest.fn((index: number) => Object.keys(store)[index] || null),
  };
})();

Object.defineProperty(window, 'localStorage', {
  value: localStorageMock,
});

// Mock console.warn to avoid warnings during tests
const originalWarn = console.warn;
console.warn = jest.fn();

// Reset all mocks before each test
beforeEach((): void => {
  localStorageMock.clear();
  jest.clearAllMocks();
});

// Restore console.warn after all tests
afterAll((): void => {
  console.warn = originalWarn;
});
