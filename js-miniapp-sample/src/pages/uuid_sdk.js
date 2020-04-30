import React from 'react';

import {
  Button,
  Card,
  CardContent,
  CardActions,
  makeStyles,
} from '@material-ui/core';
import { connect } from 'react-redux';

import { setUUID } from '../services/uuid/actions';
import NOT_AVILABLE_GIF from './../assets/images/not_available.gif';

const useStyles = makeStyles((theme) => ({
  root: {
    background: theme.color.secondary,
    height: 300,
    maxWidth: 500,
    width: '95%',
  },
  content: {
    height: '50%',
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
  },
  uuidNotFound: {
    width: 200,
  },
}));

type UUIDProps = {
  uuid: string,
  getSdkId: Function,
};

const UuidFetcher = (props: UUIDProps) => {
  const classes = useStyles();
  return (
    <Card className={classes.root}>
      <CardContent className={classes.content}>
        {props.uuid ?? (
          <img
            className={classes.uuidNotFound}
            src={NOT_AVILABLE_GIF}
            alt="Not Available"
          />
        )}
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
      </CardActions>
    </Card>
  );
};

const mapStateToProps = (state, props) => {
  return {
    ...props,
    uuid: state.uuid.uuid,
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    getSdkId: () => dispatch(setUUID()),
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(UuidFetcher);
