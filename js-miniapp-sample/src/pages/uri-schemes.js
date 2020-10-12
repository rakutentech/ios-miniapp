// @flow
import React from 'react';

import {
  Button,
  CardContent,
  CardActions,
  makeStyles,
} from '@material-ui/core';

import GreyCard from '../components/GreyCard';

const useStyles = makeStyles((theme) => ({
  card: {
    height: 'auto',
  },
  content: {
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
    paddingBottom: 0,
  },
  actions: {
    justifyContent: 'center',
    paddingBottom: 16,
  },
}));

const UriSchemes = () => {
  const classes = useStyles();
  return (
    <GreyCard className={classes.card}>
      <CardContent className={classes.content}>tel: scheme</CardContent>
      <CardActions className={classes.actions}>
        <Button variant="contained" color="primary" href="tel:+1-123-456-7890">
          +1-123-456-7890
        </Button>
      </CardActions>

      <CardContent className={classes.content}>tel:// scheme</CardContent>
      <CardActions className={classes.actions}>
        <Button
          variant="contained"
          color="primary"
          href="tel://+1-123-456-7890"
        >
          +1-123-456-7890
        </Button>
      </CardActions>

      <CardContent className={classes.content}>External Webview</CardContent>
      <CardActions className={classes.actions}>
        <Button
          variant="contained"
          color="primary"
          href="https://htmlpreview.github.io/?https://raw.githubusercontent.com/rakutentech/js-miniapp/master/js-miniapp-sample/external-webview/index.html"
        >
          Open
        </Button>
      </CardActions>
    </GreyCard>
  );
};

export default UriSchemes;
