import '@testing-library/jest-dom';
import { act, renderHook } from '@testing-library/react-hooks';

import useGeoLocation from './useGeoLocation';

describe('useGeoLocation', () => {
  let result;
  const dummyCoOridinates = {
    latitude: 51.1,
    longitude: 45.3,
  };
  const mockGeolocation = {
    watchPosition: jest.fn(),
    clearWatch: jest.fn(),
    getCurrentPosition: jest.fn().mockImplementation((success) =>
      Promise.resolve(
        success({
          coords: dummyCoOridinates,
        })
      )
    ),
  };
  beforeEach(() => {
    result = renderHook(() => useGeoLocation()).result;
    navigator.geolocation = mockGeolocation;
  });

  test('should initialize location hook', () => {
    const [state] = result.current;
    expect(state.isWatching).toEqual(false);
    expect(state.location).toBeUndefined();
  });

  test('should watch location coordinates', () => {
    let [state, watch] = result.current;
    act(() => watch());
    [state] = result.current;
    expect(state.isWatching).toEqual(true);
    expect(state.location).toEqual(dummyCoOridinates);
  });

  test('should stop watching location coordinates', () => {
    let [state, watch, unwatch] = result.current;
    act(() => watch());
    [state] = result.current;
    expect(state.isWatching).toEqual(true);
    expect(state.location).toEqual(dummyCoOridinates);
    act(() => unwatch());
    [state] = result.current;
    expect(state.isWatching).toEqual(false);
    expect(state.location).toBeUndefined();
  });
});
