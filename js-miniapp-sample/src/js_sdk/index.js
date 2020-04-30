import Bowser from 'bowser';
import { v4 as uuidv4 } from 'uuid';

export const getUUIDFromMobileSdk = () => {
  // $FlowFixMe
  return uuidv4();
};

export const isMobile = () => {
  const parser = Bowser.getParser(window.navigator.userAgent);
  return parser.getPlatform().type === 'mobile';
};
