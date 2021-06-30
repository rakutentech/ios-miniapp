import React, { useReducer } from 'react';

import {
  Avatar,
  Button,
  CardHeader,
  CircularProgress,
  FormGroup,
  Typography,
  CardContent,
  CardActions,
  List,
  ListItem,
  ListItemAvatar,
  ListItemText,
  TextField,
  Paper,
} from '@material-ui/core';
import { red, green } from '@material-ui/core/colors';
import { makeStyles } from '@material-ui/core/styles';
import clsx from 'clsx';
import {
  CustomPermission,
  CustomPermissionResult,
  CustomPermissionName,
  CustomPermissionStatus,
  Contact,
  Points,
} from 'js-miniapp-sdk';
import { connect } from 'react-redux';

import GreyCard from '../components/GreyCard';
import { requestCustomPermissions } from '../services/permissions/actions';
import {
  requestContactList,
  requestProfilePhoto,
  requestUserName,
  requestPoints,
} from '../services/user/actions';

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
  formInput: {
    width: '90%',
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
    width: '100%',
    paddingBottom: 10,
    marginBottom: 20,
    '&:last-child': {
      marginBottom: 0,
    },
  },
  profilePhoto: {
    height: 100,
    width: 100,
    marginBottom: 20,
  },
  contactsList: {
    maxHeight: 125,
    overflow: 'auto',
  },
  red: {
    color: red[500],
  },
}));

export const initialState = {
  isLoading: false,
  isError: false,
  hasRequestedPermissions: false,
  isPointsLoading: false,
  isPointsError: false,
  hasRequestedPointPermissions: false,
};

type State = {
  isLoading: ?boolean,
  isError: ?boolean,
  hasRequestedPermissions: boolean,
  isPointsLoading: ?boolean,
  isPointsError: ?boolean,
  hasRequestedPointPermissions: boolean,
};

type Action = {
  type: string,
};

export const dataFetchReducer = (state: State, action: Action) => {
  switch (action.type) {
    case 'FETCH_INIT':
      return {
        ...state,
        isLoading: true,
        isError: false,
        hasRequestedPermissions: false,
      };
    case 'FETCH_SUCCESS':
      return {
        ...state,
        isLoading: false,
        isError: false,
        hasRequestedPermissions: true,
      };
    case 'FETCH_FAILURE':
      return {
        ...initialState,
        isLoading: false,
        isError: true,
      };

    case 'POINTS_FETCH_INIT':
      return {
        ...state,
        isPointsLoading: true,
        isPointsError: false,
        hasRequestedPointPermissions: false,
      };
    case 'POINTS_FETCH_SUCCESS':
      return {
        ...state,
        isPointsLoading: false,
        isPointsError: false,
        hasRequestedPointPermissions: true,
      };
    case 'POINTS_FETCH_FAILURE':
      return {
        ...initialState,
        isPointsLoading: false,
        isError: true,
      };

    default:
      throw Error('Unknown action type');
  }
};

type UserDetailsProps = {
  permissions: CustomPermissionName[],
  userName: string,
  profilePhoto: string,
  contactList: Contact[],
  points: Points,
  getUserName: () => Promise<string>,
  getProfilePhoto: () => Promise<string>,
  getContacts: () => Promise<Contact[]>,
  getPoints: () => Promise<Points>,
  requestPermissions: (
    permissions: CustomPermission[]
  ) => Promise<CustomPermissionResult[]>,
};

function UserDetails(props: UserDetailsProps) {
  const [state, dispatch] = useReducer(dataFetchReducer, initialState);
  const classes = useStyles();

  const buttonClassname = clsx({
    [classes.buttonFailure]: state.isError,
    [classes.buttonSuccess]: !state.isError,
  });

  function requestUserDetails() {
    const permissionsList = [
      {
        name: CustomPermissionName.USER_NAME,
        description:
          'We would like to display your Username on your profile page.',
      },
      {
        name: CustomPermissionName.PROFILE_PHOTO,
        description:
          'We would like to display your Profile Photo on your profile page.',
      },
      {
        name: CustomPermissionName.CONTACT_LIST,
        description: 'We would like to send messages to your contacts.',
      },
    ];

    props
      .requestPermissions(permissionsList)
      .then((permissions) => filterAllowedPermissions(permissions))
      .then((permissions) =>
        Promise.all([
          hasPermission(CustomPermissionName.USER_NAME, permissions)
            ? props.getUserName()
            : null,
          hasPermission(CustomPermissionName.PROFILE_PHOTO, permissions)
            ? props.getProfilePhoto()
            : null,
          props.getContacts(),
        ])
      )
      .then(() => dispatch({ type: 'FETCH_SUCCESS' }))
      .catch((e) => {
        console.error(e);
        dispatch({ type: 'FETCH_FAILURE' });
      });
  }

  function requestPoints() {
    const permissionsList = [
      {
        name: CustomPermissionName.POINTS,
        description:
          'We would like to display your Points on your profile page.',
      },
    ];

    props
      .requestPermissions(permissionsList)
      .then((permissions) => filterAllowedPermissions(permissions))
      .then((permissions) =>
        Promise.all([
          hasPermission(CustomPermissionName.POINTS, permissions)
            ? props.getPoints()
            : null,
        ])
      )
      .then(() => dispatch({ type: 'POINTS_FETCH_SUCCESS' }))
      .catch((e) => {
        console.error(e);
        dispatch({ type: 'POINTS_FETCH_FAILURE' });
      });
  }

  function filterAllowedPermissions(permissions) {
    return permissions
      .filter(
        (permission) => permission.status === CustomPermissionStatus.ALLOWED
      )
      .map((permission) => permission.name);
  }

  function handleClick(e) {
    if (!state.isLoading) {
      e.preventDefault();
      dispatch({ type: 'FETCH_INIT' });
      requestUserDetails();
    }
  }

  function handlePointsClick(e) {
    if (!state.isLoading) {
      e.preventDefault();
      dispatch({ type: 'POINTS_FETCH_INIT' });
      requestPoints();
    }
  }

  function ProfilePhoto() {
    const hasDeniedPermission =
      state.hasRequestedPermissions &&
      !hasPermission(CustomPermissionName.PROFILE_PHOTO);

    return [
      hasDeniedPermission ? (
        <ListItemText
          primary='"Profile Photo" permission not granted.'
          className={classes.red}
          key="avatar-error"
        />
      ) : null,
      <Avatar
        src={props.profilePhoto}
        className={classes.profilePhoto}
        key="avatar"
      />,
    ];
  }

  function UserDetails() {
    const hasDeniedPermission =
      state.hasRequestedPermissions &&
      !hasPermission(CustomPermissionName.USER_NAME);

    return (
      <Paper className={classes.paper}>
        <CardHeader subheader="User Details" />
        <TextField
          variant="outlined"
          disabled={true}
          className={classes.formInput}
          id="input-name"
          error={state.isError || hasDeniedPermission}
          label={'Name'}
          value={
            hasDeniedPermission
              ? '"User Name" permission not granted.'
              : props.userName || ' '
          }
        />
      </Paper>
    );
  }

  function ContactList() {
    const hasDeniedPermision =
      state.hasRequestedPermissions &&
      !hasPermission(CustomPermissionName.CONTACT_LIST);

    return (
      <Paper className={classes.paper}>
        <CardHeader subheader="Contact List" />
        <List className={classes.contactsList}>
          {hasDeniedPermision && (
            <ListItem>
              <ListItemText
                primary='"Contacts" permission not granted.'
                className={classes.red}
              />
            </ListItem>
          )}
          {props.contactList &&
            props.contactList.map((contact) => (
              <ListItem divider>
                <ListItemAvatar>
                  <Avatar className={classes.contactIcon} />
                </ListItemAvatar>
                <ListItemText
                  primary={contact.id}
                  secondary={
                    <React.Fragment>
                      <Typography>
                        {contact.name && contact.name !== '' && (
                          <span>{'Name: ' + contact.name}</span>
                        )}
                      </Typography>
                      <Typography>
                        {contact.email && contact.email !== '' && (
                          <span>{'Email: ' + contact.email}</span>
                        )}
                      </Typography>
                    </React.Fragment>
                  }
                />
              </ListItem>
            ))}
        </List>
      </Paper>
    );
  }

  function PointBalance() {
    const hasDeniedPermission =
      state.hasRequestedPointPermissions &&
      !hasPermission(CustomPermissionName.POINTS);

    return (
      <Paper className={classes.paper}>
        <CardHeader subheader="Points" />
        <TextField
          variant="outlined"
          disabled={true}
          className={classes.formInput}
          id="input-points-standard"
          error={state.isError || hasDeniedPermission}
          label={'Points (Standard)'}
          value={
            hasDeniedPermission
              ? '"Points" permission not granted.'
              : props.points !== undefined &&
                props.points.standard !== undefined
              ? props.points.standard.toString()
              : '-'
          }
        />
        <TextField
          variant="outlined"
          disabled={true}
          className={classes.formInput}
          id="input-points-term"
          error={state.isError || hasDeniedPermission}
          label={'Points (Time-Limited)'}
          value={
            hasDeniedPermission
              ? '"Points" permission not granted.'
              : props.points !== undefined && props.points.term !== undefined
              ? props.points.term.toString()
              : '-'
          }
        />
        <TextField
          variant="outlined"
          disabled={true}
          className={classes.formInput}
          id="input-points-cash"
          error={state.isError || hasDeniedPermission}
          label={'Points (Rakuten Cash)'}
          value={
            hasDeniedPermission
              ? '"Points" permission not granted.'
              : props.points !== undefined && props.points.cash !== undefined
              ? props.points.cash.toString()
              : '-'
          }
        />
      </Paper>
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

  function CardPointActionsForm() {
    return (
      <FormGroup column="true" className={classes.rootUserGroup}>
        <div className={classes.wrapper}>
          <Button
            onClick={handlePointsClick}
            variant="contained"
            color="primary"
            classes={{ root: classes.button }}
            className={buttonClassname}
            disabled={state.isPointsLoading}
            data-testid="fetchPointsButton"
          >
            Fetch Points
          </Button>
          {state.isPointsLoading && (
            <CircularProgress size={20} className={classes.buttonProgress} />
          )}
        </div>
        {state.isPointsError && (
          <Typography variant="body1" className={classes.error}>
            Error fetching the points
          </Typography>
        )}
      </FormGroup>
    );
  }

  function hasPermission(permission, permissionList: ?(string[])) {
    permissionList = permissionList || props.permissions || [];
    return permissionList.indexOf(permission) > -1;
  }

  return (
    <div className={classes.scrollable}>
      <GreyCard className={classes.card}>
        <CardContent>
          <div
            className={classes.dataFormsWrapper}
            data-testid="dataFormsWrapper"
          >
            {ProfilePhoto()}
            {UserDetails()}
            {ContactList()}
          </div>
        </CardContent>
        <CardActions classes={{ root: classes.rootCardActions }}>
          {CardActionsForm()}
        </CardActions>

        <CardContent>
          <div
            className={classes.dataFormsWrapper}
            data-testid="pointDataFormsWrapper"
          >
            {PointBalance()}
          </div>
        </CardContent>
        <CardActions classes={{ root: classes.rootCardActions }}>
          {CardPointActionsForm()}
        </CardActions>
      </GreyCard>
    </div>
  );
}

const mapStateToProps = (state) => {
  return {
    permissions: state.permissions,
    userName: state.user.userName,
    profilePhoto: state.user.profilePhoto,
    contactList: state.user.contactList,
    points: state.user.points,
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    getUserName: () => dispatch(requestUserName()),
    getProfilePhoto: () => dispatch(requestProfilePhoto()),
    getContacts: () => dispatch(requestContactList()),
    getPoints: () => dispatch(requestPoints()),
    requestPermissions: (permissions) =>
      dispatch(requestCustomPermissions(permissions)),
  };
};

export { UserDetails };
export default connect(mapStateToProps, mapDispatchToProps)(UserDetails);
