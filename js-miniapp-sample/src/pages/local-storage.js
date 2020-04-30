import React, { useState } from 'react';

import {
  Button,
  TextField,
  makeStyles,
  Card,
  CardContent,
  CardActions,
} from '@material-ui/core';

import useLocalStorage from '../hooks/useLocalStorage';

const useStyles = makeStyles((theme) => ({
  root: {
    background: theme.color.secondary,
    height: 300,
    maxWidth: 500,
    width: '95%',
  },
  content: {
    height: '25%',
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
  },
  actions: {
    justifyContent: 'center',
    flexDirection: 'column',
  },
  button: {
    marginTop: '20px',
    width: '80%',
    maxWidth: 280,
  },
  textfield: {
    width: '80%',
    maxWidth: 300,
    '& input': {
      color: theme.color.primary,
      lineHeight: '1.5em',
      fontSize: '1.2em',
      background: 'white',
    },
  },
}));

function LocalStorage() {
  const classes = useStyles();
  const [inputValue, setInputValue] = useState('');
  const [storedValue, setStoredValue] = useLocalStorage('input-value', '');

  const handleInput = (e: SyntheticInputEvent<HTMLInputElement>) => {
    e.preventDefault();
    setInputValue(e.currentTarget.value);
  };

  const handleLoad = () => {
    setInputValue(storedValue);
  };

  const handleSave = () => {
    setStoredValue(inputValue);
  };

  return (
    <Card className={classes.root}>
      <CardContent className={classes.content}>
        <TextField
          type="text"
          className={classes.textfield}
          value={inputValue}
          onChange={handleInput}
          variant="outlined"
          color="primary"
          inputProps={{
            'data-testid': 'input-field',
          }}
        />
      </CardContent>
      <CardActions className={classes.actions}>
        <Button
          color="primary"
          className={classes.button}
          onClick={handleLoad}
          variant="contained"
        >
          Load text from Local Storage
        </Button>
        <Button
          color="primary"
          className={classes.button}
          onClick={handleSave}
          variant="contained"
        >
          Save text to Local Storage
        </Button>
      </CardActions>
    </Card>
  );
}

export default LocalStorage;
