import { SET_CURRENT_PAGE_TITLE } from './types';

type SetPageAction = { type: string, payload: string };
type HomeAction = SetPageAction;

const setPageTitle = (title: string): SetPageAction => {
  return {
    type: SET_CURRENT_PAGE_TITLE,
    payload: title,
  };
};

export { setPageTitle };
export type { HomeAction };
