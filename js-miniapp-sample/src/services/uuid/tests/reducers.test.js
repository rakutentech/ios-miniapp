import { UUIDReducer } from '../reducers';
import { SET_UUID } from '../types';

describe('uuid reducers', () => {
  test('should return the initial state when state argument not passed', () => {
    expect(UUIDReducer()).toEqual({ uuid: undefined });
  });

  test('should return the initial state when action argument not passed', () => {
    const state = { uuid: 'dummy uuid' };
    expect(UUIDReducer(state)).toEqual(state);
  });

  test('should set the uuid', () => {
    const uuid = 'b5b02fc3-ec5a-4409-8574-854152fc11c5';
    const state = UUIDReducer(undefined, {
      type: SET_UUID,
      payload: uuid,
    });
    expect(state).toBeDefined();
    expect(state.uuid).toEqual(uuid);
  });
});
