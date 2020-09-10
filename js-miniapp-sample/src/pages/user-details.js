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
} from 'js-miniapp-sdk';
import { connect } from 'react-redux';

import GreyCard from '../components/GreyCard';
import { requestCustomPermissions } from '../services/permissions/actions';
import {
  requestContactList,
  requestProfilePhoto,
  requestUserName,
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
};

type State = {
  isLoading: ?boolean,
  isError: ?boolean,
  hasRequestedPermissions: boolean,
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
    default:
      throw Error('Unknown action type');
  }
};

type UserDetailsProps = {
  permissions: CustomPermissionName[],
  userName: string,
  profilePhoto: string,
  contactList: string[],
  getUserName: () => Promise<string>,
  getProfilePhoto: () => Promise<string>,
  getContacts: () => Promise<string[]>,
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
      .then((permissions) =>
        permissions
          .filter(
            (permission) => permission.status === CustomPermissionStatus.ALLOWED
          )
          .map((permission) => permission.name)
      )
      .then((permissions) =>
        Promise.all([
          hasPermission(CustomPermissionName.USER_NAME, permissions)
            ? props.getUserName()
            : null,
          hasPermission(CustomPermissionName.PROFILE_PHOTO, permissions)
            ? props.getProfilePhoto()
            : null,
          hasPermission(CustomPermissionName.CONTACT_LIST, permissions)
            ? props.getContacts()
            : null,
        ])
      )
      .then(() => dispatch({ type: 'FETCH_SUCCESS' }))
      .catch((e) => {
        console.error(e);
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
              <ListItem>
                <ListItemAvatar>
                  <Avatar className={classes.contactIcon} />
                </ListItemAvatar>
                <ListItemText primary={contact} />
              </ListItem>
            ))}
        </List>
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
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    getUserName: () => dispatch(requestUserName()),
    getProfilePhoto: () => dispatch(requestProfilePhoto()),
    getContacts: () => dispatch(requestContactList()),
    requestPermissions: (permissions) =>
      dispatch(requestCustomPermissions(permissions)),
  };
};

export { UserDetails };
export default connect(mapStateToProps, mapDispatchToProps)(UserDetails);
