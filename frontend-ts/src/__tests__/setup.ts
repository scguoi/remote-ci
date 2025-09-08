/**
 * Jest 测试环境设置
 */

// 模拟 localStorage
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

// 模拟 console.warn 以避免测试时出现警告
const originalWarn = console.warn;
console.warn = jest.fn();

// 在每个测试前重置所有模拟
beforeEach((): void => {
  localStorageMock.clear();
  jest.clearAllMocks();
});

// 在所有测试结束后恢复 console.warn
afterAll((): void => {
  console.warn = originalWarn;
});
