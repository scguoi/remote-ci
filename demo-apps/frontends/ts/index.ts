import { processData, handleData } from './src/utils/helpers.js';

/**
 * Main function
 */
function main(): void {
  console.log('Hello World from TypeScript Frontend!');

  const greeting: string = '欢迎使用TypeScript前端项目';
  console.log(greeting);

  // Test utility functions
  const testData: string | null = 'test data';
  const processedData: string = processData(testData);
  console.log('Processed data:', processedData);

  const genericData: number = 42;
  const handledData: number = handleData(genericData);
  console.log('Handled data:', handledData);
}

// Execute main function
main();
