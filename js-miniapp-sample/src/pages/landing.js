import React from 'react';
import MiniApp from 'js-miniapp-sdk';
import { CardContent, makeStyles } from '@material-ui/core';
import GreyCard from '../components/GreyCard';

const useStyles = makeStyles((theme) => ({
  card: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    height: '25%',
    width: '100%',
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'stretch',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
    '& p': {
      lineHeight: 1.5,
    },
  },
  info: {
    fontSize: 16,
    lineBreak: 'anywhere',
    wordBreak: 'break-all',
    marginTop: 0,
  },
}));

const Landing = () => {
  const classes = useStyles();
  return (
    <GreyCard className={classes.card}>
      <CardContent className={classes.content}>
        <p>Demo Mini App JS SDK</p>
        <p className={classes.info}>Platform: {MiniApp.getPlatform()}</p>
        <p className={classes.info}>
          Query Parameters: {window.location.search || 'None'}
        </p>
        <p className={classes.info}>
          URL Fragment: {window.location.hash || 'None'}
        </p>
      </CardContent>
    </GreyCard>
  );
};

export default Landing;
