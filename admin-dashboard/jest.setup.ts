import '@testing-library/jest-dom';

const originalConsoleError = console.error;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
console.error = (...args: any[]) => {
  if (
    typeof args[0] === 'string' &&
    (args[0].includes('Warning: ReactDOM.render is no longer supported in React 18.') ||
     args[0].includes('Warning: useLayoutEffect does nothing on the server') ||
     args[0].includes('The above error occurred in the <TestComponent> component:') ||
     args[0].includes('Error: Test error') ||
     args[0].includes('ErrorBoundary caught an error:') ||
     args[0].includes('The above error occurred in the') ||
     args[0].includes('React will try to recreate this component tree from scratch using the error boundary you provided')
    )
  ) {
    return;
  }
  originalConsoleError(...args);
};
