import React from 'react';

import { render, cleanup, screen } from '@testing-library/react';

import '@testing-library/jest-dom/extend-expect';
import { wrapTheme } from '../../tests/test-utils';
import UserDetails, { dataFetchReducer, initialState } from '../user-details';

jest.mock('axios');

afterEach(cleanup);

test('renders the elements', () => {
  const { getByTestId } = render(wrapTheme(<UserDetails />));
  expect(getByTestId('authSwitch')).toBeInTheDocument();
  expect(getByTestId('dataFormsWrapper')).toBeInTheDocument();
  expect(getByTestId('fetchUserButton')).toBeInTheDocument();
});

test('On page load all input fields are empty', () => {
  render(wrapTheme(<UserDetails />));
  const hosterInput = screen.getByLabelText('App hoster');
  const nameInput = screen.getByLabelText('Name');
  const emailInput = screen.getByLabelText('email');
  const countryInput = screen.getByLabelText('Country');
  const signInInput = screen.getByLabelText('Sign-in date');
  expect(hosterInput).toBeEmpty();
  expect(nameInput).toBeEmpty();
  expect(emailInput).toBeEmpty();
  expect(countryInput).toBeEmpty();
  expect(signInInput).toBeEmpty();
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

  test('The success action updates state properly', () => {
    const mockData = {
      name: 'Test',
      email: 'test@test.com',
      country: 'Testland',
      signIn: '2020/02/13',
      appHoster: 'OneApp',
    };
    const newState = dataFetchReducer(initialState, {
      type: 'FETCH_SUCCESS',
      payload: mockData,
    });
    expect(newState.isLoading).toBe(false);
    expect(newState.name).toBe('Test');
    expect(newState.email).toBe('test@test.com');
    expect(newState.country).toBe('Testland');
    expect(newState.signIn).toBe('2020/02/13');
    expect(newState.appHoster).toBe('OneApp');
  });
});
