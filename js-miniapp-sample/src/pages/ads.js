import React, { useReducer, useState } from 'react';
import MiniApp from 'js-miniapp-sdk';

import {
  Button,
  CardActions,
  CardContent,
  CircularProgress,
  Paper,
  TextField,
  Typography,
  makeStyles,
} from '@material-ui/core';
import GreyCard from '../components/GreyCard';

const useStyles = makeStyles((theme) => ({
  content: {
    height: 'auto',
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    color: theme.color.primary,
    fontWeight: 'bold',
  },
  paper: {
    paddingBottom: 10,
    marginBottom: 20,
    '&:first-child': {
      marginTop: 20,
    },
  },
  actions: {
    justifyContent: 'center',
  },
  error: {
    marginTop: 10,
  },
  textfield: {
    backgroundColor: '#ffffff',
  },
}));

type State = {
  isLoading: ?boolean,
  isError: ?boolean,
};

export const initialState = {
  isLoading: false,
  isError: false,
};

// $FlowFixMe
export const dataFetchReducer = (state: State, action: Action) => {
  switch (action.type) {
    case 'LOADING':
      return {
        ...state,
        isLoading: true,
        isError: false,
      };
    case 'SUCCESS':
      return {
        ...state,
        isLoading: false,
        isError: false,
        reward: action.rewardItem,
      };
    case 'FAILURE':
      return {
        ...initialState,
        isLoading: false,
        isError: true,
      };
    default:
      throw Error('Unknown action type');
  }
};

function Ads() {
  const [interstitialState, interstitialDispatch] = useReducer(
    dataFetchReducer,
    initialState
  );
  const [rewardState, rewardDispatch] = useReducer(
    dataFetchReducer,
    initialState
  );
  const [interstitialAdId, setInterstitialAdId] = useState(
    'ca-app-pub-3940256099942544/1033173712'
  );
  const [rewardAdId, setRewardAdId] = useState(
    'ca-app-pub-3940256099942544/5224354917'
  );
  const classes = useStyles();

  const handleInterstitialSuccess = (loadSuccess) => {
    console.log(loadSuccess);
    interstitialDispatch({ type: 'SUCCESS' });
  };
  const handleInterstitialFailure = (error) => {
    interstitialDispatch({ type: 'FAILURE' });
    console.error(error);
  };
  const loadInterstitialAd = () => {
    interstitialDispatch({ type: 'LOADING' });
    MiniApp.loadInterstitialAd(interstitialAdId)
      .then(handleInterstitialSuccess)
      .catch(handleInterstitialFailure);
  };
  const displayInterstitialAd = () => {
    interstitialDispatch({ type: 'LOADING' });
    MiniApp.showInterstitialAd(interstitialAdId)
      .then(handleInterstitialSuccess)
      .catch(handleInterstitialFailure);
  };

  const handleRewardFailure = (error) => {
    rewardDispatch({ type: 'FAILURE' });
    console.error(error);
  };
  const loadRewardAd = () => {
    rewardDispatch({ type: 'LOADING' });
    MiniApp.loadRewardedAd(rewardAdId)
      .then((loadSuccess) => {
        console.log(loadSuccess);
        rewardDispatch({ type: 'SUCCESS' });
      })
      .catch(handleRewardFailure);
  };
  const displayRewardAd = () => {
    rewardDispatch({ type: 'LOADING' });
    MiniApp.showRewardedAd(rewardAdId)
      .then((reward) => {
        rewardDispatch({ type: 'SUCCESS', rewardItem: reward });
      })
      .catch(handleRewardFailure);
  };

  return (
    <GreyCard className={classes.content}>
      {(interstitialState.isLoading || rewardState.isLoading) && (
        <CircularProgress size={20} className={classes.buttonProgress} />
      )}

      <Paper className={classes.paper}>
        <CardContent className={classes.content}>
          <TextField
            type="text"
            label="Interstitial Ad Id"
            className={classes.textfield}
            value={interstitialAdId}
            onChange={(e) => setInterstitialAdId(e.currentTarget.value)}
            variant="outlined"
            color="primary"
            inputProps={{
              'data-testid': 'input-field',
            }}
          />
        </CardContent>
        <CardActions className={classes.actions}>
          <Button
            color="primary"
            className={classes.button}
            onClick={loadInterstitialAd}
            disabled={interstitialState.isLoading}
            variant="contained"
          >
            Load Interstitial
          </Button>
        </CardActions>
        <CardActions className={classes.actions}>
          <Button
            color="primary"
            className={classes.button}
            onClick={displayInterstitialAd}
            disabled={interstitialState.isLoading}
            variant="contained"
          >
            Show Interstitial
          </Button>
        </CardActions>
      </Paper>

      <Paper className={classes.paper}>
        <CardContent className={classes.content}>
          <TextField
            type="text"
            label="Rewarded Ad Id"
            className={classes.textfield}
            value={rewardAdId}
            onChange={(e) => setRewardAdId(e.currentTarget.value)}
            variant="outlined"
            color="primary"
            inputProps={{
              'data-testid': 'input-field',
            }}
          />
        </CardContent>
        <CardActions className={classes.actions}>
          <Button
            color="primary"
            className={classes.button}
            onClick={loadRewardAd}
            disabled={rewardState.isLoading}
            variant="contained"
          >
            Load Reward
          </Button>
        </CardActions>
        <CardActions className={classes.actions}>
          <Button
            color="primary"
            className={classes.button}
            onClick={displayRewardAd}
            disabled={rewardState.isLoading}
            variant="contained"
          >
            Show Reward
          </Button>
        </CardActions>
      </Paper>

      {!rewardState.isError &&
        !rewardState.isLoading &&
        rewardState.reward != null && (
          // $FlowFixMe
          <Typography>Rewarded point: {rewardState.reward.amount}</Typography>
        )}
      {(interstitialState.isError || rewardState.isError) && (
        <Typography className={classes.error}>Error display ads</Typography>
      )}
    </GreyCard>
  );
}

export default Ads;
