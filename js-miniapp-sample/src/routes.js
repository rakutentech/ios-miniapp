import React from 'react';

import ChatIcon from '@material-ui/icons/Chat';
import FingerprintIcon from '@material-ui/icons/Fingerprint';
import HomeIcon from '@material-ui/icons/Home';
import LaptopWindowsIcon from '@material-ui/icons/LaptopWindows';
import LinkIcon from '@material-ui/icons/Link';
import LocationOnIcon from '@material-ui/icons/LocationOn';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import PersonIcon from '@material-ui/icons/Person';
import StorageIcon from '@material-ui/icons/Storage';
import VpnKeyIcon from '@material-ui/icons/VpnKey';
import MediaIcon from '@material-ui/icons/MusicVideo';

import AuthToken from './pages/auth-token';
import TalkToChatBot from './pages/chatbot';
import FetchCredentials from './pages/fetch-credentials';
import Landing from './pages/landing';
import LocalStorage from './pages/local-storage';
import UriSchemes from './pages/uri-schemes';
import UserDetails from './pages/user-details';
import UuidFetcher from './pages/uuid-sdk';
import WebLocation from './pages/web-location';
import WindowActions from './pages/window-actions';
import Media from './pages/media';

const navItems = [
  {
    icon: <HomeIcon />,
    label: 'Home',
    navLink: '/landing',
    component: Landing,
  },
  {
    icon: <StorageIcon />,
    label: 'Local Storage',
    navLink: '/local_storage',
    component: LocalStorage,
  },
  {
    icon: <FingerprintIcon />,
    label: 'Fetch Unique ID from SDK',
    navLink: '/fetch_id',
    component: UuidFetcher,
  },
  {
    icon: <LocationOnIcon />,
    label: 'Device Location',
    navLink: '/device_location',
    component: WebLocation,
  },
  {
    icon: <VpnKeyIcon />,
    label: 'Auth token from Mobile',
    navLink: '/auth_token',
    component: AuthToken,
  },
  {
    icon: <PersonIcon />,
    label: 'Fetch UserDetail',
    navLink: '/user_detail',
    component: UserDetails,
  },
  {
    icon: <ChatIcon />,
    label: 'Message to Chatbot',
    navLink: '/chatbot',
    component: TalkToChatBot,
  },
  {
    icon: <LockOpenIcon />,
    label: 'Fetch Credentials',
    navLink: '/fetch_credentials',
    component: FetchCredentials,
  },
  {
    icon: <LaptopWindowsIcon />,
    label: 'Window Actions',
    navLink: '/window_actions',
    component: WindowActions,
  },
  {
    icon: <LinkIcon />,
    label: 'URI Schemes',
    navLink: '/uri_schemes',
    component: UriSchemes,
  },
  {
    icon: <MediaIcon />,
    label: 'Media',
    navLink: '/media',
    component: Media,
  },
];

export { navItems };
