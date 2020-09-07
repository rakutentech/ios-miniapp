// @flow
import React from 'react';
import ReactPlayerLoader from '@brightcove/react-player-loader';

const onSuccess = function (success) {
  console.log(success.ref);
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
