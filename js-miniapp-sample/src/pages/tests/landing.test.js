import React from 'react';

import '@testing-library/jest-dom';

import {
  renderWithRedux,
  wrapRouter,
  screen,
  wrapTheme,
} from '../../tests/test-utils';

import Landing from '../landing';

test('Landing text is rendered', () => {
  renderWithRedux(wrapRouter(wrapTheme(<Landing />)));
  expect(screen.getByText('Demo Mini App JS SDK')).toBeInTheDocument();
});
