import { setUUID } from '../actions';
import { SET_UUID } from '../types';

describe('uuid actions', () => {
  test('should create a set_uuid action with unique uuid', () => {
    const dispatch = jest.fn();
    setUUID()(dispatch);
    expect(dispatch).toBeCalledWith({
      type: SET_UUID,
      payload: expect.any(String),
    });
  });
});
