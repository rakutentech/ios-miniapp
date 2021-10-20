import React from 'react';

import { Typography, CardContent, CardMedia, Grid } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';

import GreyCard from '../components/GreyCard';
const useStyles = makeStyles((theme) => ({
  scrollable: {
    overflowY: 'auto',
    width: '100%',
    paddingTop: 20,
    paddingBottom: 20,
  },
  grid: {
    position: 'relative',
    paddingBottom: 15,
  },
  greyCard: {
    marginTop: '1rem',
  },
  typography: {
    marginTop: '1rem',
  },
}));

function GIFComponent() {
  const classes = useStyles();
  const images = [
    {
      label: 'Loop Count: Once',
      iconSrc: require('../assets/images/gif/road.gif'),
      altLabel: 'road',
    },
    {
      label: 'Loop Count: Infinite',
      iconSrc: require('../assets/images/gif/road_infinite.gif'),
      altLabel: 'infinite_road',
    },
    {
      label: 'Loop Count: Infinite (WebP)',
      // $FlowFixMe
      iconSrc: require('../assets/images/webp/road_webp.gif'),
      altLabel: 'infinite_road_webp',
    },
  ];
  return (
    <div className={classes.scrollable}>
      <Grid
        container
        direction="column"
        justify="flex-start"
        alignItems="center"
        className={classes.grid}
      >
        {images.map((it, i) => (
          <React.Fragment item key={i}>
            <GreyCard height="auto" className={`${classes.greyCard}`}>
              <Typography className={`app-typography ${classes.typography}`}>
                {it.label}
              </Typography>
              <CardContent>
                <CardMedia
                  component="img"
                  className={classes.gif}
                  src={it.iconSrc}
                  alt={it.altLabel}
                />
              </CardContent>
            </GreyCard>
          </React.Fragment>
        ))}
      </Grid>
    </div>
  );
}

export default GIFComponent;
