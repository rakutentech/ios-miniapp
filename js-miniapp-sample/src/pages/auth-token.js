import React, { Fragment, useReducer, useState } from 'react';

import {
  Button,
  CircularProgress,
  FormGroup,
  Typography,
  CardContent,
  ListItemText,
  FormControl,
  TextField,
} from '@material-ui/core';
import { red, green } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';
import clsx from 'clsx';
import {
  CustomPermission,
  CustomPermissionResult,
  CustomPermissionName,
  CustomPermissionStatus,
  AccessTokenData,
} from 'js-miniapp-sdk';
import { connect } from 'react-redux';

import GreyCard from '../components/GreyCard';
import { displayDate } from '../js_sdk';
import { requestCustomPermissions } from '../services/permissions/actions';
import { requestAccessToken } from '../services/user/actions';

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
  red: {
    color: red[500],
  },
}));

const initialState = {
  isLoading: false,
  isError: false,
  hasRequestedPermissions: false,
  error: null,
};

const dataFetchReducer = (state, action) => {
  switch (action.type) {
    case 'FETCH_INIT':
      return {
        ...state,
        isLoading: true,
        isError: false,
        hasRequestedPermissions: false,
        error: null,
      };
    case 'FETCH_SUCCESS':
      return {
        ...state,
        isLoading: false,
        isError: false,
        hasRequestedPermissions: true,
        error: null,
      };
    case 'FETCH_FAILURE':
      return {
        ...state,
        isLoading: false,
        isError: true,
        error: action.miniAppError.message,
      };
    default:
      throw new Error();
  }
};

type AuthTokenProps = {
  permissions: CustomPermissionName[],
  accessToken: AccessTokenData,
  getAccessToken: (audience: string, scopes: string[]) => Promise<string>,
  requestPermissions: (
    permissions: CustomPermission[]
  ) => Promise<CustomPermissionResult[]>,
};

function AuthToken(props: AuthTokenProps) {
  const [state, dispatch] = useReducer(dataFetchReducer, initialState);
  const classes = useStyles();
  const [scope, setScope] = useState({
    audience: 'rae',
    scopes: ['idinfo_read_openid', 'memberinfo_read_point'],
  });
  const buttonClassname = clsx({
    [classes.buttonFailure]: state.isError,
    [classes.buttonSuccess]: !state.isError,
  });
  const onAudienceChange = (event) => {
    setScope({ ...scope, audience: event.target.value });
  };
  const onScopesChange = (event) => {
    setScope({ ...scope, scopes: event.target.value.split(', ') });
  };

  function requestAccessTokenPermission() {
    const permissionsList = [
      {
        name: CustomPermissionName.ACCESS_TOKEN,
        description:
          'We would like to get the Access token details to share with this Mini app',
      },
    ];

    props
      .requestPermissions(permissionsList)
      .then((permissions) =>
        permissions
          .filter(
            (permission) => permission.status === CustomPermissionStatus.ALLOWED
          )
          .map((permission) => permission.name)
      )
      .then((permissions) =>
        Promise.all([
          hasPermission(CustomPermissionName.ACCESS_TOKEN, permissions)
            ? props.getAccessToken(scope.audience, scope.scopes)
            : null,
        ])
      )
      .then(() => dispatch({ type: 'FETCH_SUCCESS' }))
      .catch((miniAppError) => {
        console.error(miniAppError);
        dispatch({ type: 'FETCH_FAILURE', miniAppError });
      });
  }

  function hasPermission(permission, permissionList: ?(string[])) {
    permissionList = permissionList || props.permissions || [];
    return permissionList.indexOf(permission) > -1;
  }

  function handleClick(e) {
    if (!state.isLoading) {
      e.preventDefault();
      dispatch({ type: 'FETCH_INIT' });
      requestAccessTokenPermission();
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

  function AccessToken() {
    const hasDeniedPermission =
      state.hasRequestedPermissions &&
      !hasPermission(CustomPermissionName.ACCESS_TOKEN);

    return hasDeniedPermission ? (
      <ListItemText
        primary="Access Token permission is denied by the user."
        className={classes.red}
      />
    ) : null;
  }

  return (
    <GreyCard height="auto">
      <CardContent>
        <FormGroup column="true" classes={{ root: classes.rootFormGroup }}>
          <Fragment>
            <FormControl className={classes.formControl}>
              <TextField
                id="audience"
                label="Audience"
                className={classes.fields}
                onChange={onAudienceChange}
                value={scope.audience}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <TextField
                id="scopes"
                label="Scopes"
                className={classes.fields}
                onChange={onScopesChange}
                value={scope.scopes.join(', ')}
              />
            </FormControl>
          </Fragment>
          {ButtonWrapper()}
          {!state.isLoading && !state.isError && props.accessToken && (
            <Typography variant="body1" className={classes.success}>
              Token: {props.accessToken.token}
            </Typography>
          )}
          {!state.isLoading && !state.isError && props.accessToken && (
            <Typography variant="body1" className={classes.success}>
              Valid until: {displayDate(props.accessToken.validUntil)}
            </Typography>
          )}
          {!state.isLoading && state.isError && (
            <Typography variant="body1" className={classes.red}>
              {state.error}
            </Typography>
          )}
          <div>{AccessToken()}</div>
        </FormGroup>
      </CardContent>
    </GreyCard>
  );
}

const mapStateToProps = (state) => {
  return {
    permissions: state.permissions,
    accessToken: state.user.accessToken,
    error: state.error,
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    getAccessToken: (audience: string, scopes: string[]) =>
      dispatch(requestAccessToken(audience, scopes)),
    requestPermissions: (permissions) =>
      dispatch(requestCustomPermissions(permissions)),
  };
};

export { AuthToken };
export default connect(mapStateToProps, mapDispatchToProps)(AuthToken);
