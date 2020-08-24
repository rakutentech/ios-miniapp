import React from 'react';

import { render, screen } from '@testing-library/react';

import Landing from '../landing';
import { wrapTheme } from '../../tests/test-utils';

test('Landing text is rendered', () => {
  render(wrapTheme(<Landing />));
  expect(
    screen.getByText('This is a Demo App of Mini App JS SDK')
  ).toBeInTheDocument();
});
