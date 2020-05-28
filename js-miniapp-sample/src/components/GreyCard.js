import * as React from 'react';

import { Card, makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    background: theme.color.secondary,
    height: (props) => props.height || 300,
    maxWidth: 500,
    width: '95%',
  },
}));

type CardType = {
  height?: number | string,
  children: React.Node,
  className?: string,
};

const GreyCard = (props: CardType) => {
  const classes = useStyles(props);
  return (
    <Card className={`${classes.root} ${props.className || ''}`}>
      {props.children}
    </Card>
  );
};

export default GreyCard;
