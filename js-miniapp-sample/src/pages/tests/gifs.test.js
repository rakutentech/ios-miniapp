import React from 'react';

import { render, cleanup } from '@testing-library/react';

import { wrapTheme } from '../../tests/test-utils';
import GifComponent from '../gifs';

describe('Gif', () => {
  afterEach(cleanup);
  test("gif's & webp are rendered", () => {
    const { container } = render(wrapTheme(<GifComponent />));
    const images = Array.from(container.querySelectorAll('img'));
    expect(images.length).toBe(3);
    expect(images.filter((it) => it.src.includes('gif')).length).toBe(2);
    expect(images.filter((it) => it.src.includes('webp')).length).toBe(1);
  });
});
