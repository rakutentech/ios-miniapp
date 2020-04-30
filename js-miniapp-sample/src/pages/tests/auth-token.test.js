import React from 'react';

import { render, cleanup, screen } from '@testing-library/react';

import { wrapTheme } from '../../tests/test-utils';
import AuthToken from '../auth-token';

beforeEach(() => {
  render(wrapTheme(<AuthToken />));
});

afterEach(cleanup);

test('Button is rendered', () => {
  const button = screen.getByTestId('authButton');
  expect(button).toBeInTheDocument();
});

test('Switch is rendered', () => {
  const authSwitch = screen.getByTestId('authSwitch');
  expect(authSwitch).toBeInTheDocument();
});
