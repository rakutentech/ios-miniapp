import React from 'react';
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
}));

const Landing = () => {
  const classes = useStyles();
  return (
    <GreyCard className={classes.card}>
      <CardContent className={classes.content}>
        <p>This is a Demo App of Mini App JS SDK</p>
      </CardContent>
    </GreyCard>
  );
};

export default Landing;
