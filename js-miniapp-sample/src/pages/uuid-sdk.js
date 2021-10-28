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
import { CopyToClipboard } from 'react-copy-to-clipboard';

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

  function textCopied(text, result) {
    if (result) {
      setCopyStatus({ success: true, error: false });
    } else {
      setCopyStatus({ success: false, error: true });
    }
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
        <CopyToClipboard
          disabled={!props.uuid}
          text={props.uuid}
          onCopy={textCopied}
        >
          <Button
            disabled={!props.uuid}
            data-testid="clipboard-copy"
            variant="contained"
            color="primary"
          >
            Copy
          </Button>
        </CopyToClipboard>
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
