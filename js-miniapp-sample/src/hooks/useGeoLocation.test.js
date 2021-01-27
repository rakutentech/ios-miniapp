import '@testing-library/jest-dom';
import { act, renderHook } from '@testing-library/react-hooks';
import MiniApp from 'js-miniapp-sdk';

import useGeoLocation from './useGeoLocation';

describe('useGeoLocation', () => {
  let result;
  const dummyCoordinates = {
    latitude: 51.1,
    longitude: 45.3,
  };
  const mockGeolocation = {
    watchPosition: jest.fn(),
    clearWatch: jest.fn(),
    getCurrentPosition: jest.fn().mockImplementation((success) =>
      Promise.resolve(
        success({
          coords: dummyCoordinates,
        })
      )
    ),
  };
  beforeEach(() => {
    result = renderHook(() => useGeoLocation()).result;
    navigator.geolocation = mockGeolocation;
    MiniApp.requestLocationPermission = jest.fn().mockResolvedValue('');
  });

  test('should initialize location hook', () => {
    const [state] = result.current;
    expect(state.isWatching).toEqual(false);
    expect(state.location).toBeUndefined();
  });

  test('should watch location coordinates when permission granted', async () => {
    MiniApp.requestLocationPermission = jest.fn().mockResolvedValue('');

    let [state, watch] = result.current;
    await act(() => watch());
    [state] = result.current;

    expect(state.isWatching).toEqual(true);
    expect(state.location).toEqual(dummyCoordinates);
  });

  test('should not watch location when permission not granted', async () => {
    MiniApp.requestLocationPermission = jest.fn().mockRejectedValue('');

    let [state, watch] = result.current;
    await act(() => watch());
    [state] = result.current;

    expect(state.isWatching).toEqual(false);
    expect(state.location).not.toEqual(dummyCoordinates);
  });

  test('should stop watching location coordinates', async () => {
    let [state, watch, unwatch] = result.current;
    await act(() => watch());
    [state] = result.current;
    expect(state.isWatching).toEqual(true);
    expect(state.location).toEqual(dummyCoordinates);
    act(() => unwatch());
    [state] = result.current;
    expect(state.isWatching).toEqual(false);
    expect(state.location).toBeUndefined();
  });
});
