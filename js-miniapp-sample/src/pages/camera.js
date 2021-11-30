import React, { useState } from 'react';

import { Card, Grid, Button, makeStyles } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '90%',
    width: '100%',
  },
  grid: {
    display: 'flex',
    height: '20%',
    flexDirection: 'column',
    justifyContent: 'center',
    padding: '20px',
  },
  table: {
    minWidth: '80%',
  },
  content: {
    height: '50%',
    justifyContent: 'space-between',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
  },
  contentSection: {
    height: '30%',
    padding: '10px',
  },
  label: {
    display: 'block',
    fontSize: 12,
    width: '100%',
    color: theme.color.primary,
  },
  imageBox: {
    height: '250px',
    margin: '20px',
  },
  imageBoxContent: {
    height: '250px',
    objectFit: 'contain',
  },
}));

const Camera = () => {
  const classes = useStyles();

  const [image, setImage] = useState(null);
  const [backCamera, setBackCamera] = useState('');

  const setFiles = (e) => {
    const files = e.target.files;
    if (!files && files.length > 0) {
      return;
    }
    setImage(URL.createObjectURL(e.target.files[0]));
  };

  function clear() {
    setImage(null);
    setBackCamera('');
  }

  return (
    <Card className={classes.root}>
      <Card id="imageBox" className={classes.imageBox} hidden={image == null}>
        <img
          id="imageBoxContent"
          alt="CapturedPicture"
          className={classes.imageBoxContent}
          src={image}
        />
      </Card>
      <Grid className={classes.grid} align="center">
        <div className={classes.contentSection}>
          <label className={classes.label}>Pick Image</label>
          <input
            id="cameraBack"
            type="file"
            accept=".jpg,.jpeg,.png,.svg,.gif"
            onChange={setFiles}
            data-testid="file-input-image-back"
            capture="environment"
            value={backCamera}
          />
        </div>
        <div className={classes.contentSection}>
          <Button variant="contained" color="primary" onClick={() => clear()}>
            Clear
          </Button>
        </div>
      </Grid>
    </Card>
  );
};

export { Camera };
export default Camera;
