import { SET_CURRENT_PAGE_TITLE } from '../types';
import homeReducer from './../reducers';

describe('home page reducers', () => {
  test('should return the initial state when state not passed as argument', () => {
    expect(homeReducer()).toEqual({
      title: 'POC',
    });
  });

  test('should return the initial state when action not passed as argument', () => {
    expect(homeReducer()).toEqual({
      title: 'POC',
    });
  });

  test('should return the new state when state passed as argument without action', () => {
    const newState = {
      title: 'NEW POC',
    };
    expect(homeReducer(newState)).toEqual(newState);
  });

  test('should change the title', () => {
    const state = {
      title: 'OLD POC',
    };
    const action = {
      type: SET_CURRENT_PAGE_TITLE,
      payload: 'NEW POC',
    };
    expect(homeReducer(state, action)).toEqual({
      title: 'NEW POC',
    });
  });
});
