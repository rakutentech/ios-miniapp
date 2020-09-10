import React from 'react';

import { render, cleanup } from '@testing-library/react';

import '@testing-library/jest-dom/extend-expect';
import { wrapTheme } from '../../tests/test-utils';
import { UserDetails, dataFetchReducer, initialState } from '../user-details';

jest.mock('axios');

afterEach(cleanup);

test('renders the elements', () => {
  const { getByTestId } = render(wrapTheme(<UserDetails />));
  expect(getByTestId('dataFormsWrapper')).toBeInTheDocument();
  expect(getByTestId('fetchUserButton')).toBeInTheDocument();
});

describe('Test Reducer', () => {
  test('The init action updates state properly', () => {
    const newState = dataFetchReducer(initialState, { type: 'FETCH_INIT' });
    expect(newState.isLoading).toBe(true);
  });

  test('The failure action updates state properly', () => {
    const newState = dataFetchReducer(initialState, { type: 'FETCH_FAILURE' });
    expect(newState.isError).toBe(true);
  });
});
