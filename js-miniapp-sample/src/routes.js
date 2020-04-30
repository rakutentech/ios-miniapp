import React from 'react';

import ChatIcon from '@material-ui/icons/Chat';
import FingerprintIcon from '@material-ui/icons/Fingerprint';
import LocationOnIcon from '@material-ui/icons/LocationOn';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import PersonIcon from '@material-ui/icons/Person';
import StorageIcon from '@material-ui/icons/Storage';
import VpnKeyIcon from '@material-ui/icons/VpnKey';

import AuthToken from './pages/auth-token';
import TalkToChatBot from './pages/chatbot';
import FetchCredentials from './pages/fetch-credentials';
import LocalStorage from './pages/local-storage';
import UserDetails from './pages/user-details';
import UuidFetcher from './pages/uuid_sdk';
import WebLocation from './pages/web_location';

const navItems = [
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
];

export { navItems };
