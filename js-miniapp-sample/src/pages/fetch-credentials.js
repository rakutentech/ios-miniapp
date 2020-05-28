import React, { useReducer, useState } from 'react';

import {
  Button,
  Switch,
  CircularProgress,
  FormGroup,
  Grid,
  Typography,
  CardContent,
} from '@material-ui/core';
import { red, green } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';
import axios from 'axios';
import clsx from 'clsx';

import GreyCard from '../components/GreyCard';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    position: 'relative',
    marginTop: 20,
  },
  buttonSuccess: {
    backgroundColor: green[500],
    '&:hover': {
      backgroundColor: green[700],
    },
  },
  buttonFailure: {
    backgroundColor: red[500],
    '&:hover': {
      backgroundColor: red[700],
    },
  },
  buttonProgress: {
    position: 'absolute',
    top: 'calc(50% - 10px)',
    left: 'calc(50% - 10px)',
  },
  error: {
    color: red[500],
    marginTop: 20,
  },
  success: {
    color: green[500],
    marginTop: 20,
    wordBreak: 'break-all',
    textAlign: 'center',
  },
  rootFormGroup: {
    alignItems: 'center',
  },
}));

type CredentialsState = {
  isLoading: boolean,
  isError: boolean,
  response: any,
};

type DataFetchAction = {
  type: string,
  payload?: any,
};

export const initialState = {
  isLoading: false,
  isError: false,
  response: null,
};

export const dataFetchReducer = (
  state: CredentialsState,
  action: DataFetchAction
) => {
  switch (action.type) {
    case 'FETCH_INIT':
      return {
        ...state,
        isLoading: true,
        isError: false,
        response: null,
      };
    case 'FETCH_SUCCESS':
      return {
        ...state,
        isLoading: false,
        isError: false,
        response: action.payload,
      };
    case 'FETCH_FAILURE':
      return {
        ...state,
        isLoading: false,
        isError: true,
      };
    default:
      throw new Error();
  }
};

function FetchCredentials() {
  const [state, dispatch] = useReducer(dataFetchReducer, initialState);
  const classes = useStyles();

  const buttonClassname = clsx({
    [classes.buttonFailure]: state.isError,
    [classes.buttonSuccess]: state.response,
  });

  const [switchState, setSwitchState] = useState(true);

  function requestToken() {
    // Hardcoded API values to test
    const API = switchState
      ? 'http://www.mocky.io/v2/5e9406873100006c005e2d00'
      : 'http://www.mocky.io/v2/5e9801a93500005000c47d35';
    axios
      .get(API)
      .then((response) => {
        dispatch({ type: 'FETCH_SUCCESS', payload: response.data });
      })
      .catch((error) => {
        dispatch({ type: 'FETCH_FAILURE' });
      });
  }

  function handleClick(e) {
    if (!state.isLoading) {
      e.preventDefault();
      dispatch({ type: 'FETCH_INIT' });
      requestToken();
    }
  }

  function SwitchToggle() {
    return (
      <Typography component="div">
        <Grid component="label" container alignItems="center" spacing={1}>
          <Grid item>Success</Grid>
          <Grid item>
            <Switch
              color="primary"
              checked={switchState}
              onChange={() => setSwitchState(!switchState)}
              name="switchState"
              data-testid="authSwitch"
            />
          </Grid>
          <Grid item>Failure</Grid>
        </Grid>
      </Typography>
    );
  }

  function ButtonWrapper() {
    return (
      <div className={classes.wrapper}>
        <Button
          onClick={handleClick}
          variant="contained"
          color="primary"
          className={buttonClassname}
          disabled={state.isLoading}
          data-testid="authButton"
        >
          Authentication
        </Button>
        {state.isLoading && (
          <CircularProgress size={20} className={classes.buttonProgress} />
        )}
      </div>
    );
  }

  return (
    <GreyCard height="auto">
      <CardContent>
        <FormGroup column="true" classes={{ root: classes.rootFormGroup }}>
          <Typography variant="body2" align="center">
            Please note that we use a <strong>mocked API</strong> in this
            example (
            <a href="http://www.mocky.io/v2/5e9801a93500005000c47d35">
              Success
            </a>{' '}
            &{' '}
            <a href="http://www.mocky.io/v2/5e9406873100006c005e2d00">
              Failure
            </a>
            )
          </Typography>
          {SwitchToggle()}
          {ButtonWrapper()}
          {state.isError && (
            <Typography variant="body1" className={classes.error}>
              Error fetching credentials
            </Typography>
          )}
          {state.response && (
            <Typography variant="body1" className={classes.success}>
              {JSON.stringify(state.response)}
            </Typography>
          )}
        </FormGroup>
      </CardContent>
    </GreyCard>
  );
}

export default FetchCredentials;
