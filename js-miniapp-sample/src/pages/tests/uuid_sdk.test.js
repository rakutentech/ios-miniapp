import React from 'react';

import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import {
  renderWithRedux,
  wrapRouter,
  screen,
  wrapTheme,
} from '../../tests/test-utils';
import UuidFetcher from './../uuid_sdk';

describe('uuid from mobile sdk', () => {
  beforeEach(() => {
    renderWithRedux(wrapRouter(wrapTheme(<UuidFetcher />)));
  });
  test('should load the UUID fetcher container', () => {
    expect(screen.getByText('Not Available')).toBeInTheDocument();
    expect(screen.getByTestId('get-unique-id')).toBeInTheDocument();
  });

  test("should get UUID on 'GET UNIQUE ID' when miniapp not running inside mobile", () => {
    const button = screen.getByTestId('get-unique-id');
    userEvent.click(button);
    expect(screen.getByText('Not Available')).toBeInTheDocument();
  });
});
