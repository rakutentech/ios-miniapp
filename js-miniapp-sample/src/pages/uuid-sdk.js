import React, { useState } from 'react';

import {
  Button,
  CardContent,
  CardActions,
  makeStyles,
  Snackbar,
} from '@material-ui/core';
import { connect } from 'react-redux';

import GreyCard from '../components/GreyCard';
import { setUUID } from '../services/uuid/actions';

const useStyles = makeStyles((theme) => ({
  content: {
    height: '50%',
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
    wordBreak: 'break-word',
  },
  actions: {
    justifyContent: 'center',
  },
  uuidNotFound: {
    width: 200,
  },
}));

type UUIDProps = {
  uuid: string,
  uuidError: string,
  getSdkId: Function,
};

const UuidFetcher = (props: UUIDProps) => {
  const classes = useStyles();
  const [copyStatus, setCopyStatus] = useState({
    success: false,
    error: false,
  });

  function copyToClipboard() {
    if (props.uuid === undefined) {
      return;
    }
    if (!navigator.clipboard) {
      fallbackCopyMethod(props.uuid);
      return;
    }
    navigator.clipboard.writeText(props.uuid).then(
      function () {
        setCopyStatus({ success: true, error: false });
      },
      function (err) {
        setCopyStatus({ success: false, error: true });
      }
    );
  }

  function fallbackCopyMethod(text) {
    var textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.top = '0';
    textArea.style.left = '0';
    textArea.style.position = 'fixed';
    document.body !== null && document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    try {
      document.execCommand('copy');
      setCopyStatus({ success: true, error: false });
    } catch (err) {
      setCopyStatus({ success: false, error: true });
    }
    document.body !== null && document.body.removeChild(textArea);
  }

  return (
    <GreyCard>
      <CardContent className={classes.content}>
        {props.uuid ?? props.uuidError ?? 'Not Available'}
      </CardContent>
      <CardActions className={classes.actions}>
        <Button
          data-testid="get-unique-id"
          variant="contained"
          color="primary"
          fullWidth
          onClick={props.getSdkId}
        >
          GET UNIQUE ID
        </Button>
        <Button
          disabled={!props.uuid}
          data-testid="clipboard-copy"
          variant="contained"
          color="primary"
          onClick={copyToClipboard}
        >
          Copy
        </Button>
        <Snackbar
          open={copyStatus.success}
          autoHideDuration={3000}
          onClose={() => {
            setCopyStatus({ success: false, error: false });
          }}
          message="Unique ID copied !!"
        />
        <Snackbar
          open={copyStatus.error}
          autoHideDuration={3000}
          onClose={() => {
            setCopyStatus({ success: false, error: false });
          }}
          message="Failed to copy!"
        />
      </CardActions>
    </GreyCard>
  );
};

const mapStateToProps = (state, props) => {
  return {
    ...props,
    uuid: state.uuid.uuid,
    uuidError: state.uuid.uuidError,
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    getSdkId: () => dispatch(setUUID()),
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(UuidFetcher);
