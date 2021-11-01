// @flow
import React, { useState } from 'react';

import {
  Button,
  CardContent,
  CardActions,
  makeStyles,
} from '@material-ui/core';

import GreyCard from '../components/GreyCard';
import { connect } from 'react-redux';
import { requestCustomPermissions } from '../services/permissions/actions';
import {
  CustomPermission,
  CustomPermissionResult,
  CustomPermissionName,
  CustomPermissionStatus,
} from 'js-miniapp-sdk';

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
  actions: {
    justifyContent: 'center',
    paddingBottom: 16,
  },
  content: {
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
    paddingBottom: 0,
  },
  info: {
    fontSize: 16,
    lineBreak: 'anywhere',
    wordBreak: 'break-all',
    color: theme.color.primary,
    marginTop: 0,
    paddingBottom: 10,
  },
}));

type FileDownloadProps = {
  permissions: CustomPermissionName[],
  requestPermissions: (
    permissions: CustomPermission[]
  ) => Promise<CustomPermissionResult[]>,
};

const FileDownload = (props: FileDownloadProps) => {
  const classes = useStyles();
  let [isPermissionGranted, setIsPermissionGranted] = useState(false);

  function requestDownloadAttachmentPermission(url, fileName) {
    const permissionsList = [
      {
        name: CustomPermissionName.FILE_DOWNLOAD,
        description: 'We would like to get the permission to download files.',
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
          hasPermission(CustomPermissionName.FILE_DOWNLOAD, permissions)
            ? startFileDownload(url, fileName)
            : setIsPermissionGranted(false),
        ])
      )
      .catch((miniAppError) => {
        console.error(miniAppError);
      });
  }

  function hasPermission(permission, permissionList: ?(string[])) {
    permissionList = permissionList || props.permissions || [];
    return permissionList.indexOf(permission) > -1;
  }

  function onDownloadFile(url, fileName) {
    requestDownloadAttachmentPermission(url, fileName);
  }

  function startFileDownload(url, fileName) {
    setIsPermissionGranted(true);
    fetch(url, { method: 'GET' })
      .then((response) => response.blob())
      .then((blob) => {
        var fileReader = new window.FileReader();
        fileReader.readAsDataURL(blob);
        fileReader.onloadend = () => {
          var a = document.createElement('a');
          a.href = fileReader.result;
          a.download = fileName;
          document.body && document.body.appendChild(a);
          a.click();
          a.remove();
        };
      });
  }

  return (
    <div className={classes.scrollable}>
      <GreyCard className={classes.card}>
        <CardContent className={classes.content}>
          Download Files via XHR
        </CardContent>
        <CardActions className={classes.actions}>
          <Button
            variant="contained"
            color="primary"
            onClick={() =>
              // $FlowFixMe
              onDownloadFile(require('../assets/images/panda.png'), 'panda.png')
            }
          >
            Download Image
          </Button>
        </CardActions>

        <CardActions className={classes.actions}>
          <Button
            variant="contained"
            color="primary"
            onClick={() =>
              // $FlowFixMe
              onDownloadFile(require('../assets/sample.zip'), 'sample.zip')
            }
          >
            Download ZIP
          </Button>
        </CardActions>

        <CardActions className={classes.actions}>
          <Button
            variant="contained"
            color="primary"
            onClick={() =>
              // $FlowFixMe
              onDownloadFile(require('../assets/sample.mp3'), 'sample.mp3')
            }
          >
            Download MP3
          </Button>
        </CardActions>
        <div className={classes.info}>
          <p>
            {!isPermissionGranted && '"FILE_DOWNLOAD" permission not granted.'}
          </p>
        </div>
      </GreyCard>
    </div>
  );
};

const mapStateToProps = (state) => {
  return {
    permissions: state.permissions,
  };
};

const mapDispatchToProps = (dispatch) => {
  return {
    requestPermissions: (permissions) =>
      dispatch(requestCustomPermissions(permissions)),
  };
};

export { FileDownload };
export default connect(mapStateToProps, mapDispatchToProps)(FileDownload);
