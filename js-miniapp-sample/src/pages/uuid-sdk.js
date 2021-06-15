import React from 'react';

import {
  Button,
  CardContent,
  CardActions,
  makeStyles,
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
