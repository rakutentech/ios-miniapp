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
  scrollable: {
    overflowY: 'auto',
    width: '100%',
    paddingTop: 20,
    paddingBottom: 20,
  },
  card: {
    width: '100%',
    height: 'auto',
  },
  actions: {
    justifyContent: 'center',
    paddingBottom: 16,
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

const deepLinkStyle = makeStyles((theme) => ({
  content: {
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
    paddingBottom: 0,
    height: '50px',
  },
  card: {
    width: '100%',
    height: '100px',
  },
  actions: {
    justifyContent: 'center',
    paddingBottom: 16,
  },
}));

const UriSchemes = () => {
  const EXTERNAL_WEBVIEW_URL =
    'https://htmlpreview.github.io/?https://raw.githubusercontent.com/rakutentech/js-miniapp/master/js-miniapp-sample/external-webview/index.html';
  const classes = useStyles();
  const deeplinkClass = deepLinkStyle();

  const [params, setParams] = useState('?testSendParam=someValue&test2=test2');
  const [callbackUrl, setCallbackUrl] = useState(
    `${window.location.protocol}//${window.location.host}/index.html`
  );
  let deeplinkUrl = '';

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

    var url = new URL(EXTERNAL_WEBVIEW_URL + params);

    url.search = url.search
      .concat(url.search ? '&' : '?')
      .concat(`callbackUrl=${encodeURIComponent(callbackUrl)}`);

    window.location.href = url;
  }

  function openDeeplinkURL() {
    window.location.href = deeplinkUrl;
  }

  const handleInput = (e: SyntheticInputEvent<HTMLInputElement>) => {
    e.preventDefault();
    deeplinkUrl = e.currentTarget.value;
  };

  return (
    <div className={classes.scrollable}>
      <GreyCard className={classes.card}>
        <CardContent className={classes.content}>tel: scheme</CardContent>
        <CardActions className={classes.actions}>
          <Button
            variant="contained"
            color="primary"
            href="tel:+1-123-456-7890"
          >
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
        <CardContent className={classes.content}>
          <TextField
            className={classes.textfield}
            onChange={(e) => setCallbackUrl(e.currentTarget.value)}
            value={callbackUrl}
            label="Mini App Return URL"
            variant="outlined"
            color="primary"
            inputProps={{
              'data-testid': 'callback-input-field',
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
      <br />
      <GreyCard className={classes.card}>
        <CardContent className={classes.content}>Deep Link</CardContent>
        <CardContent className={deeplinkClass.content}>
          <TextField
            className={classes.textfield}
            onChange={handleInput}
            label="Deep Link URL"
            variant="outlined"
            color="primary"
            inputProps={{
              'data-testid': 'deeplink-input-field',
            }}
          />
        </CardContent>
        <CardActions className={deeplinkClass.actions}>
          <Button variant="contained" color="primary" onClick={openDeeplinkURL}>
            Open
          </Button>
        </CardActions>
      </GreyCard>
    </div>
  );
};

export default UriSchemes;
