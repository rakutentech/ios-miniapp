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
}));

const UriSchemes = () => {
  const classes = useStyles();

  function onDownloadFile(url, fileName) {
    fetch(url, { method: 'GET' })
      .then((response) => response.blob())
      .then((blob) => {
        var fileReader = new window.FileReader();
        fileReader.readAsDataURL(blob);
        fileReader.onloadend = () => {
          var a = document.createElement('a');
          a.href = fileReader.result;
          a.download = fileName;
          document.body && document.body.appendChild(a);
          a.click();
          a.remove();
        };
      });
  }

  return (
    <div className={classes.scrollable}>
      <GreyCard className={classes.card}>
        <CardContent className={classes.content}>
          Download Files via XHR
        </CardContent>
        <CardActions className={classes.actions}>
          <Button
            variant="contained"
            color="primary"
            onClick={() =>
              // $FlowFixMe
              onDownloadFile(require('../assets/images/panda.png'), 'panda.png')
            }
          >
            Download Image
          </Button>
        </CardActions>

        <CardActions className={classes.actions}>
          <Button
            variant="contained"
            color="primary"
            onClick={() =>
              // $FlowFixMe
              onDownloadFile(require('../assets/sample.zip'), 'sample.zip')
            }
          >
            Download ZIP
          </Button>
        </CardActions>

        <CardActions className={classes.actions}>
          <Button
            variant="contained"
            color="primary"
            onClick={() =>
              // $FlowFixMe
              onDownloadFile(require('../assets/sample.mp3'), 'sample.mp3')
            }
          >
            Download MP3
          </Button>
        </CardActions>
      </GreyCard>
    </div>
  );
};

export default UriSchemes;
