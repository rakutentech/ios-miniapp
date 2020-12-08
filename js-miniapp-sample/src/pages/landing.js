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
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
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
          Parameters: {window.location.search || 'None'}
        </p>
      </CardContent>
    </GreyCard>
  );
};

export default Landing;
