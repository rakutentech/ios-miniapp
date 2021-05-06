// @flow
import React, { useState } from 'react';

import {
  Button,
  CardContent,
  CardActions,
  TextField,
  makeStyles,
} from '@material-ui/core';

import GreyCard from '../components/GreyCard';

const useStyles = makeStyles((theme) => ({
  actions: {
    justifyContent: 'center',
    paddingBottom: 16,
  },
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
  textfield: {
    width: '100%',
  },
}));

const UriSchemes = () => {
  const EXTERNAL_WEBVIEW_URL =
    'https://htmlpreview.github.io/?https://raw.githubusercontent.com/rakutentech/js-miniapp/master/js-miniapp-sample/external-webview/index.html';
  const classes = useStyles();
  const [params, setParams] = useState('?testSendParam=someValue&test2=test2');

  function validateParams(params) {
    if (!params.startsWith('?') || params.indexOf('=') <= -1) {
      return false;
    }

    return true;
  }

  function onOpenExternalWebview() {
    if (params && !validateParams(params)) {
      window.alert(
        'Invalid params. Please input params in the format ?param1=value1&param2=value2'
      );
      return;
    }

    const callbackUrl = `${window.location.protocol}//${window.location.host}/index.html`;
    const paramsWithCallback = params
      .concat(params ? '&' : '?')
      .concat(`callbackUrl=${encodeURIComponent(callbackUrl)}`);

    window.location.href = EXTERNAL_WEBVIEW_URL + paramsWithCallback;
  }

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

      <CardContent className={classes.content}>mailto:</CardContent>
      <CardActions className={classes.actions}>
        <Button
          variant="contained"
          color="primary"
          href="mailto:mail@example.com?cc=ccmail@example.com, ccmail2@example.com, &bcc=bccmail@example.com&subject=Sample subject&body=Sample body."
        >
          Address / cc / bcc / subject / body
        </Button>
      </CardActions>

      <CardContent className={classes.content}>External Webview</CardContent>
      <CardContent className={classes.content}>
        <TextField
          className={classes.textfield}
          onChange={(e) => setParams(e.currentTarget.value)}
          value={params}
          label="Params to pass"
          variant="outlined"
          color="primary"
          inputProps={{
            'data-testid': 'input-field',
          }}
        />
      </CardContent>
      <CardActions className={classes.actions}>
        <Button
          variant="contained"
          color="primary"
          onClick={onOpenExternalWebview}
        >
          Open
        </Button>
      </CardActions>
    </GreyCard>
  );
};

export default UriSchemes;
