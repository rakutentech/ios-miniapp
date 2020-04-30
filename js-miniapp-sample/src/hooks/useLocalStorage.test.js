import { renderHook, act } from '@testing-library/react-hooks';

import useLocalStorage from './useLocalStorage';

beforeEach(() => {
  Object.defineProperty(window, 'localStorage', {
    value: {
      getItem: jest.fn(),
      setItem: jest.fn(),
    },
    writable: true,
  });
});

test('should save the initial value to local storage', () => {
  const { result } = renderHook(() => useLocalStorage('test', 'initial-value'));
  expect(result.current[0]).toBe('initial-value');
});

test('should save passed in value to local storage', () => {
  const { result } = renderHook(() => useLocalStorage('test', 'initial-value'));
  act(() => {
    result.current[1]('input-value');
  });
  expect(result.current[0]).toBe('input-value');
});
