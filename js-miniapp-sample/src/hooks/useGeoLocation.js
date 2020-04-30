import { useState } from 'react';

const useGeoLocation = () => {
  const [state, setState] = useState({
    isWatching: false,
  });
  const watch = () => {
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { longitude, latitude } = pos.coords;
        setState({
          isWatching: true,
          location: {
            latitude,
            longitude,
          },
        });
      },
      (error) => console.error(error),
      {
        enableHighAccuracy: true,
      }
    );
  };

  const unwatch = () => {
    setState({
      isWatching: false,
    });
  };

  return [state, watch, unwatch];
};

export default useGeoLocation;
