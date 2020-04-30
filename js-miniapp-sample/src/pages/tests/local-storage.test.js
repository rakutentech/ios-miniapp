import React from 'react';

import { render, fireEvent, screen } from '@testing-library/react';

import { wrapTheme } from '../../tests/test-utils';
import LocalStorage from '../local-storage';

beforeEach(() => {
  Object.defineProperty(window, 'localStorage', {
    value: {
      getItem: jest.fn(),
      setItem: jest.fn(),
    },
    writable: true,
  });
});

test('should save input value to local storage', () => {
  render(wrapTheme(<LocalStorage />));
  const input = screen.getByTestId('input-field');
  fireEvent.change(input, { target: { value: 'Hello, World!' } });
  fireEvent.click(screen.getByText('Save text to Local Storage'));
  expect(input.value).toBe('Hello, World!');
  expect(window.localStorage.setItem).toHaveBeenCalledTimes(1);
  expect(window.localStorage.setItem).toHaveBeenCalledWith(
    'input-value',
    '"Hello, World!"'
  );
});

test('should load value from local storage', () => {
  window.localStorage.getItem.mockImplementationOnce(
    () => '"some stored value"'
  );
  render(wrapTheme(<LocalStorage />));
  fireEvent.click(screen.getByText('Load text from Local Storage'));
  expect(screen.getByTestId('input-field').value).toBe('some stored value');
});
