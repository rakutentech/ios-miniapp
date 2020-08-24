import React from 'react';

import { makeStyles, ThemeProvider } from '@material-ui/core';
import { Provider } from 'react-redux';

import Home from './pages/home';
import store from './services/store';
import Theme from './theme';

const useStyles = makeStyles((theme) => ({
  App: {
    width: '100%',
    textAlign: 'center',
  },
}));

function App() {
  const classes = useStyles();
  return (
    <Provider store={store}>
      <ThemeProvider theme={Theme}>
        <div className={classes.App}>
          <Home />
        </div>
      </ThemeProvider>
    </Provider>
  );
}

export default App;
