import React, { useReducer } from 'react';
import MiniApp from 'js-miniapp-sdk';
import { displayDate } from '../js_sdk';

import {
  Button,
  CircularProgress,
  FormGroup,
  Typography,
  CardContent,
} from '@material-ui/core';
import { red, green } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';
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
    textAlign: 'center',
    wordBreak: 'break-all',
  },
  rootFormGroup: {
    alignItems: 'center',
  },
}));

const initialState = {
  isLoading: false,
  isError: false,
  response: null,
};

const dataFetchReducer = (state, action) => {
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
        response: action.tokenData,
      };
    case 'FETCH_FAILURE':
      return {
        ...state,
        isLoading: false,
        isError: true,
        errorMessage: action.errorMessage,
      };
    default:
      throw new Error();
  }
};

function AuthToken() {
  const [state, dispatch] = useReducer(dataFetchReducer, initialState);
  const classes = useStyles();

  const buttonClassname = clsx({
    [classes.buttonFailure]: state.isError,
    [classes.buttonSuccess]: state.response,
  });

  function requestToken() {
    MiniApp.user
      .getAccessToken()
      .then((response) => {
        dispatch({ type: 'FETCH_SUCCESS', tokenData: response });
      })
      .catch((error) => {
        console.error(error);
        dispatch({ type: 'FETCH_FAILURE', errorMessage: error });
      });
  }

  function handleClick(e) {
    if (!state.isLoading) {
      e.preventDefault();
      dispatch({ type: 'FETCH_INIT' });
      requestToken();
    }
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
          {ButtonWrapper()}
          {state.isError && (
            <Typography variant="body1" className={classes.error}>
              {state.errorMessage}
            </Typography>
          )}
          {state.response && (
            <Typography variant="body1" className={classes.success}>
              Token: {state.response.token}
            </Typography>
          )}
          {state.response && (
            <Typography variant="body1" className={classes.success}>
              Valid until: {displayDate(state.response.validUntil)}
            </Typography>
          )}
        </FormGroup>
      </CardContent>
    </GreyCard>
  );
}

export default AuthToken;
