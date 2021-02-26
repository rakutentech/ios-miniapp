import React from 'react';

import { render, cleanup } from '@testing-library/react';

import { wrapTheme } from '../../tests/test-utils';
import { AuthToken } from '../auth-token';
import { dataFetchReducer, initialState } from '../fetch-credentials';

import '@testing-library/jest-dom/extend-expect';

jest.mock('axios');

afterEach(cleanup);

test('Button is rendered', () => {
  const { getByTestId } = render(wrapTheme(<AuthToken />));
  const button = getByTestId('authButton');
  expect(button).toBeInTheDocument();
});

describe('Test Reducer', () => {
  test('The init action updates state properly', () => {
    expect(initialState.isLoading).toBe(false);
    const newState = dataFetchReducer(initialState, { type: 'FETCH_INIT' });
    expect(newState.isLoading).toBe(true);
  });

  test('The failure action updates state properly', () => {
    expect(initialState.isError).toBe(false);
    const newState = dataFetchReducer(initialState, { type: 'FETCH_FAILURE' });
    expect(newState.isError).toBe(true);
  });

  test('The success action updates state properly', () => {
    const mockData = {
      token: 'TestToken',
    };
    expect(initialState.response).toBe(null);
    const newState = dataFetchReducer(initialState, {
      type: 'FETCH_SUCCESS',
      payload: mockData,
    });
    expect(newState.response).toBe(mockData);
  });
});
