import React from 'react';

import { render, screen } from '@testing-library/react';

import Landing from '../landing';
import { wrapTheme } from '../../tests/test-utils';

test('Landing text is rendered', () => {
  render(wrapTheme(<Landing />));
  expect(screen.getByText('Demo Mini App JS SDK')).toBeInTheDocument();
  expect(screen.getByText('Platform: Unknown')).toBeInTheDocument();
});
