// @flow
import React from 'react';
import ReactPlayerLoader from '@brightcove/react-player-loader';
import MiniApp from 'js-miniapp-sdk';
import { ScreenOrientation } from 'js-miniapp-sdk';

const onSuccess = function (success) {
  console.log(success.ref);

  success.ref.on('fullscreenchange', (event) => {
    if (success.ref.isFullscreen()) {
      MiniApp.setScreenOrientation(ScreenOrientation.LOCK_LANDSCAPE)
        .then((success) => {
          console.log(success);
        })
        .catch((error) => {
          console.error(error);
        });
    } else {
      MiniApp.setScreenOrientation(ScreenOrientation.LOCK_RELEASE)
        .then((success) => {
          console.log(success);
        })
        .catch((error) => {
          console.error(error);
        });
    }
  });
};

const Media = () => {
  return (
    <ReactPlayerLoader
      accountId="1752604059001"
      videoId="5819230967001"
      onSuccess={onSuccess}
    ></ReactPlayerLoader>
  );
};

export default Media;
