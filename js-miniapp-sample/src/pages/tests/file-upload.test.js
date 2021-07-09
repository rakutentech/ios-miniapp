import React from 'react';

import '@testing-library/jest-dom';

import { renderWithRedux, screen, wrapTheme } from '../../tests/test-utils';
import FileUpload from './../file-upload';

describe('home', () => {
  beforeEach(() => {
    renderWithRedux(wrapTheme(<FileUpload />));
  });

  test('should load home page without drawer on pc', () => {
    expect(screen.getByTestId('file-table')).toBeInTheDocument();
  });
});
