import React from 'react';
import MiniApp from 'js-miniapp-sdk';

import {
  Button,
  TextField,
  CardContent,
  CardActions,
  makeStyles,
} from '@material-ui/core';

import GreyCard from '../components/GreyCard';

const useStyles = makeStyles((theme) => ({
  content: {
    height: '50%',
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
  },
  actions: {
    justifyContent: 'center',
  },
  textfield: {
    width: '80%',
    maxWidth: 300,
    background: 'white',
    '& input': {
      color: theme.color.primary,
      lineHeight: '1.5em',
      fontSize: '1.2em',
    },
  },
}));

function Share() {
  const classes = useStyles();
  const defaultInputValue = 'This is JS-SDK-Sample.';
  let inputValue = defaultInputValue;

  const handleInput = (e: SyntheticInputEvent<HTMLInputElement>) => {
    e.preventDefault();
    inputValue = e.currentTarget.value;
  };

  const shareContent = () => {
    const info = { content: inputValue }; //see js-miniapp-bridge/types/share-info
    MiniApp.shareInfo(info)
      .then((success) => {
        console.log(success);
      })
      .catch((error) => {
        console.error(error);
      });
  };

  return (
    <GreyCard>
      <CardContent className={classes.content}>
        <TextField
          type="text"
          className={classes.textfield}
          onChange={handleInput}
          placeholder="Content"
          defaultValue={defaultInputValue}
          variant="outlined"
          color="primary"
          multiline="true"
          rowsMax="5"
          inputProps={{
            'data-testid': 'input-field',
          }}
        />
      </CardContent>
      <CardActions className={classes.actions}>
        <Button
          color="primary"
          className={classes.button}
          onClick={shareContent}
          variant="contained"
        >
          Share
        </Button>
      </CardActions>
    </GreyCard>
  );
}

export default Share;
