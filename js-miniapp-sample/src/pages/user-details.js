import React, { useReducer, useState } from 'react';

import {
  Button,
  CircularProgress,
  FormGroup,
  Typography,
  Card,
  CardContent,
  CardActions,
  TextField,
  Grid,
  Switch,
  Paper,
} from '@material-ui/core';
import { red, green } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';
import axios from 'axios';
import clsx from 'clsx';

const useStyles = makeStyles((theme) => ({
  root: {
    background: theme.color.secondary,
    width: '85vw',
    maxWidth: 500,
  },
  wrapper: {
    position: 'relative',
    marginTop: 10,
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
    marginTop: 10,
  },
  success: {
    color: green[500],
    marginTop: 20,
  },
  rootUserGroup: {
    alignItems: 'center',
  },
  rootOneAppGroup: {
    alignItems: 'center',
    marginTop: 15,
    paddingTop: 85,
  },
  formInput: {
    width: 220,
    marginTop: 10,
  },
  rootCardActions: {
    justifyContent: 'center',
  },
  caseSelector: {
    marginTop: 5,
  },
  button: {
    marginBottom: 15,
  },
  dataFormsWrapper: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  paper: {
    height: 260,
    width: 260,
  },
  paperApp: {
    height: 75,
    width: 260,
    marginBottom: 15,
    marginTop: 15,
    display: 'flex',
    justifyContent: 'center',
  },
}));

export const initialState = {
  isLoading: false,
  isError: false,
  name: '',
  email: '',
  country: '',
  signIn: '',
  appHoster: '',
  response: null,
};

type Payload = {
  name: string,
  email: string,
  country: string,
  signIn: string,
  appHoster: string,
};

type State = {
  isLoading: ?boolean,
  isError: ?boolean,
  name: ?string,
  email: ?string,
  country: ?string,
  signIn: ?string,
  appHoster: ?string,
  response: ?Payload,
};

type Action = {
  type: string,
  payload?: Payload,
};

export const dataFetchReducer = (state: State, action: Action) => {
  switch (action.type) {
    case 'FETCH_INIT':
      return {
        ...state,
        isLoading: true,
        isError: false,
      };
    case 'FETCH_SUCCESS':
      return {
        ...state,
        isLoading: false,
        isError: false,
        name: action.payload?.name,
        email: action.payload?.email,
        country: action.payload?.country,
        signIn: action.payload?.signIn,
        appHoster: action.payload?.appHoster,
        response: action.payload,
      };
    case 'FETCH_FAILURE':
      return {
        ...initialState,
        isLoading: false,
        isError: true,
      };
    default:
      throw Error('Unknown action type');
  }
};

function UserDetails() {
  const [state, dispatch] = useReducer(dataFetchReducer, initialState);
  const classes = useStyles();
  const [switchState, setSwitchState] = useState(true);

  const buttonClassname = clsx({
    [classes.buttonFailure]: state.isError,
    [classes.buttonSuccess]: state.response,
  });

  function requestUserDetails() {
    const mockedAPI = switchState
      ? 'http://www.mocky.io/v2/5e9406873100006c005e2d00'
      : 'http://www.mocky.io/v2/5e95032c31000057bf5e360b';
    axios
      .get(mockedAPI)
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
      requestUserDetails();
    }
  }

  function SwitchToogle() {
    return (
      <Grid
        component="label"
        className={classes.caseSelector}
        container
        justify="center"
        alignItems="center"
        spacing={1}
      >
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
    );
  }

  function DataForms() {
    return (
      <div className={classes.dataFormsWrapper} data-testid="dataFormsWrapper">
        <Paper className={classes.paperApp}>
          <TextField
            disabled={true}
            className={classes.formInput}
            id="input-name"
            error={state.isError}
            label="App hoster"
            value={state.appHoster || ''}
          />
        </Paper>
        <Paper className={classes.paper}>
          <FormGroup column="true" classes={{ root: classes.rootUserGroup }}>
            <TextField
              disabled={true}
              className={classes.formInput}
              id="input-name"
              error={state.isError}
              label="Name"
              value={state.name || ''}
            />
            <TextField
              disabled={true}
              className={classes.formInput}
              id="input-email"
              error={state.isError}
              label="email"
              value={state.email || ''}
            />
            <TextField
              disabled={true}
              className={classes.formInput}
              id="input-country"
              error={state.isError}
              label="Country"
              value={state.country || ''}
            />
            <TextField
              disabled={true}
              className={classes.formInput}
              id="sign-in-date"
              error={state.isError}
              label="Sign-in date"
              value={state.signIn || ''}
            />
          </FormGroup>
        </Paper>
      </div>
    );
  }

  function CardActionsForm() {
    return (
      <FormGroup column="true" className={classes.rootUserGroup}>
        <div className={classes.wrapper}>
          <Button
            onClick={handleClick}
            variant="contained"
            color="primary"
            classes={{ root: classes.button }}
            className={buttonClassname}
            disabled={state.isLoading}
            data-testid="fetchUserButton"
          >
            Fetch User Details
          </Button>
          {state.isLoading && (
            <CircularProgress size={20} className={classes.buttonProgress} />
          )}
        </div>
        {state.isError && (
          <Typography variant="body1" className={classes.error}>
            Error fetching the User Details
          </Typography>
        )}
      </FormGroup>
    );
  }

  return (
    <Card className={classes.root}>
      <CardContent>
        <Typography variant="body2" align="center">
          Please note that we use a <strong>mocked API</strong> in this example
          (<a href="http://www.mocky.io/v2/5e95032c31000057bf5e360b">Success</a>{' '}
          &{' '}
          <a href="http://www.mocky.io/v2/5e9406873100006c005e2d00">Failure</a>)
        </Typography>
        {SwitchToogle()}
        {DataForms()}
      </CardContent>
      <CardActions classes={{ root: classes.rootCardActions }}>
        {CardActionsForm()}
      </CardActions>
    </Card>
  );
}

export default UserDetails;
