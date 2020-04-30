import { setPageTitle } from '../actions';
import { SET_CURRENT_PAGE_TITLE } from '../types';

describe('home actions', () => {
  test('should create an action to set title', () => {
    const title = 'NEW POC';
    const expectedAction = {
      type: SET_CURRENT_PAGE_TITLE,
      payload: title,
    };
    expect(setPageTitle(title)).toEqual(expectedAction);
  });
});
