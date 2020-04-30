import React from 'react';

import { render, screen } from '@testing-library/react';

import App from './App';
import '@testing-library/jest-dom';

describe('App', () => {
  test('should load home page', () => {
    render(<App />);
    expect(screen.getByTestId('homepage-main-content')).toBeInTheDocument();
  });
});
