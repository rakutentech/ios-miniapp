import Bowser from 'bowser';

export const isMobile = () => {
  const parser = Bowser.getParser(window.navigator.userAgent);
  return parser.getPlatform().type === 'mobile';
};
