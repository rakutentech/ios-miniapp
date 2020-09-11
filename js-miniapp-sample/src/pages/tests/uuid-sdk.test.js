import React from 'react';

import '@testing-library/jest-dom';

import {
  renderWithRedux,
  wrapRouter,
  screen,
  wrapTheme,
} from '../../tests/test-utils';
import UuidFetcher from '../uuid-sdk';

describe('uuid from mobile sdk', () => {
  beforeEach(() => {
    renderWithRedux(wrapRouter(wrapTheme(<UuidFetcher />)));
  });
  test('should load the UUID fetcher container', () => {
    expect(screen.getByText('Not Available')).toBeInTheDocument();
    expect(screen.getByTestId('get-unique-id')).toBeInTheDocument();
  });
});
