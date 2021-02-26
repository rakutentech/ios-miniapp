import React from 'react';

import { render, cleanup, screen } from '@testing-library/react';

import { wrapTheme } from '../../tests/test-utils';
import { AuthToken } from '../auth-token';
import '@testing-library/jest-dom/extend-expect';

jest.mock('axios');

beforeEach(() => {
  render(wrapTheme(<AuthToken />));
});

afterEach(cleanup);

test('Button is rendered', () => {
  const button = screen.getByTestId('authButton');
  expect(button).toBeInTheDocument();
});
