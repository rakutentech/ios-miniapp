import React from 'react';

import '@testing-library/jest-dom';

import { renderWithRedux, screen, wrapTheme } from '../../tests/test-utils';
import Home from './../home';

describe('home', () => {
  beforeEach(() => {
    renderWithRedux(wrapTheme(<Home />));
  });

  test('should load home page without drawer on pc', () => {
    expect(screen.getByTestId('homepage-main-content')).toBeInTheDocument();
    const drawerToggle = screen.getByTestId('drawer-toggle-button');
    expect(drawerToggle).toBeInTheDocument();
  });
});
