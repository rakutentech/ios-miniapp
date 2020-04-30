import type { HomeAction } from './actions';
import { SET_CURRENT_PAGE_TITLE } from './types';

type HomePageState = {
  title: string,
};

const homeState: HomePageState = {
  title: 'POC',
};

export default (
  state: HomePageState = homeState,
  action: HomeAction
): HomePageState => {
  if (action !== undefined && action.type === SET_CURRENT_PAGE_TITLE) {
    return { ...state, title: action.payload };
  }
  return state;
};
