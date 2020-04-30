import React from 'react';

import { ThemeProvider } from '@material-ui/core';
import { render as rtlRender } from '@testing-library/react';
import { Provider } from 'react-redux';
import { MemoryRouter } from 'react-router-dom';
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

import reducers from './../services/reducers';
import Theme from './../theme';

function render(
  ui: any,
  // $FlowFixMe
  {
    initialState = {},
    store = createStore(reducers, initialState, applyMiddleware(thunk)),
    ...renderOptions
  } = {}
) {
  function Wrapper({ children }) {
    return <Provider store={store}>{children}</Provider>;
  }
  // $FlowFixMe
  return rtlRender(ui, { wrapper: Wrapper, ...renderOptions });
}

function wrapTheme(ui: any) {
  return <ThemeProvider theme={Theme}>{ui}</ThemeProvider>;
}

function wrapRouter(ui: any, props: any) {
  return <MemoryRouter {...props}>{ui}</MemoryRouter>;
}

// re-export everything
export * from '@testing-library/react';

// override render method
export { render as renderWithRedux, wrapRouter, wrapTheme };
