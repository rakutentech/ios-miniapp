// @flow
import React from 'react';

import { Button, Card, CardContent, makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 300,
    width: '100%',
  },
  content: {
    height: '50%',
    justifyContent: 'space-between',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
  },
}));

const WindowActions = () => {
  const classes = useStyles();
  const onAlert = () => {
    window.alert('This is window alert!');
  };
  const onConfirm = () => {
    window.confirm('This is window confirm!');
  };
  const onPrompt = () => {
    window.prompt('This is window prompt!', 'sure!');
  };
  return (
    <Card className={classes.root}>
      <CardContent className={classes.content}>
        <Button variant="contained" color="primary" onClick={onAlert}>
          Show Window Alert
        </Button>
        <Button variant="contained" color="primary" onClick={onConfirm}>
          Show Window Confirm
        </Button>
        <Button variant="contained" color="primary" onClick={onPrompt}>
          Show Window Prompt
        </Button>
      </CardContent>
    </Card>
  );
};

export default WindowActions;
