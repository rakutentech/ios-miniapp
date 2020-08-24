// @flow
import React from 'react';

const Media = () => {
  return (
    <video width="100%" controls>
      <source
        src="https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8"
        type="application/x-mpegURL"
      ></source>
    </video>
  );
};

export default Media;
