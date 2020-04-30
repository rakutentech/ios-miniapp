import '@testing-library/jest-dom';
import React from 'react';

import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

import { wrapTheme } from '../../tests/test-utils';
import WebLocation from './../web_location';

describe('web_location', () => {
  const dummyCoOridinates = {
    latitude: 51.1,
    longitude: 45.3,
  };
  const mockGeolocation = {
    watchPosition: jest.fn(),
    clearWatch: jest.fn(),
    getCurrentPosition: jest.fn().mockImplementation(success =>
      Promise.resolve(
        success({
          coords: dummyCoOridinates,
        })
      )
    ),
  };
  beforeEach(() => {
    render(wrapTheme(<WebLocation />));
    navigator.geolocation = mockGeolocation;
  });

  test('should load web_location component without location details', () => {
    expect(screen.getByText('TURN ON')).toBeInTheDocument();
    expect(screen.getByText('TURN OFF')).toBeInTheDocument();
    expect(screen.queryByTestId('location-container')).not.toBeInTheDocument();
    expect(
      screen.getByTestId('turn-off').className.indexOf('Mui-disabled') >= 0
    ).toBeTruthy();
  });

  test('should fetch display location', () => {
    expect(screen.queryByTestId('location-container')).not.toBeInTheDocument();
    userEvent.click(screen.getByTestId('turn-on'));
    expect(screen.queryByTestId('location-container')).toBeInTheDocument();
    expect(
      screen.getByText(`${dummyCoOridinates.latitude}`)
    ).toBeInTheDocument();
    expect(
      screen.getByText(`${dummyCoOridinates.longitude}`)
    ).toBeInTheDocument();
  });

  test('should turn off geo-location', () => {
    userEvent.click(screen.getByTestId('turn-on'));
    expect(screen.queryByTestId('location-container')).toBeInTheDocument();
    userEvent.click(screen.getByTestId('turn-off'));
    expect(screen.queryByTestId('location-container')).not.toBeInTheDocument();
  });
});
