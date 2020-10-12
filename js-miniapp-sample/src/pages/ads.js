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
  scrollable: {
    overflowY: 'auto',
    width: '100%',
    paddingTop: 20,
    paddingBottom: 20,
  },
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
    width: '80%',
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
    width: '100%',
  },
}));

type State = {
  isLoading: boolean,
  error?: ?string,
  reward?: {
    amount: number,
  },
};

export const initialState = {
  isLoading: false,
  error: null,
};

// $FlowFixMe
export const dataFetchReducer = (state: State, action: Action) => {
  switch (action.type) {
    case 'LOADING':
      return {
        ...state,
        isLoading: true,
        error: null,
      };
    case 'SUCCESS':
      return {
        ...state,
        isLoading: false,
        error: null,
        reward: action.rewardItem,
      };
    case 'FAILURE':
      return {
        ...initialState,
        isLoading: false,
        error: action.error,
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
    interstitialDispatch({ type: 'FAILURE', error });
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
    rewardDispatch({ type: 'FAILURE', error });
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

  const renderLoading = () => (
    <CardContent className={classes.content}>
      <CircularProgress size={20} className={classes.buttonProgress} />
    </CardContent>
  );

  const renderError = (error) => (
    <CardContent className={classes.content}>
      <Typography className={classes.error}>Error: {error}</Typography>
    </CardContent>
  );

  const renderInput = ({ label, value, onChange }) => (
    <CardContent className={classes.content}>
      <TextField
        type="text"
        label={label}
        className={classes.textfield}
        value={value}
        onChange={(e) => onChange.call(e.currentTarget.value)}
        variant="outlined"
        color="primary"
        inputProps={{
          'data-testid': 'input-field',
        }}
      />
    </CardContent>
  );

  const renderButton = ({ text, disabled, onClick }) => (
    <CardActions className={classes.actions}>
      <Button
        color="primary"
        className={classes.button}
        onClick={onClick}
        disabled={disabled}
        variant="contained"
      >
        {text}
      </Button>
    </CardActions>
  );

  return (
    <div class={classes.scrollable}>
      <GreyCard className={classes.content}>
        <Paper className={classes.paper}>
          {interstitialState.isLoading && renderLoading()}
          {interstitialState.error && renderError(interstitialState.error)}

          {renderInput({
            label: 'Interstitial Ad Id',
            value: interstitialAdId,
            onChange: setInterstitialAdId,
          })}
          {renderButton({
            text: 'Load Interstitial',
            disabled: interstitialState.isLoading,
            onClick: loadInterstitialAd,
          })}
          {renderButton({
            text: 'Show Interstitial',
            disabled: interstitialState.isLoading,
            onClick: displayInterstitialAd,
          })}
        </Paper>
        <Paper className={classes.paper}>
          {rewardState.isLoading && renderLoading()}
          {rewardState.error && renderError(rewardState.error)}

          {!rewardState.error &&
            !rewardState.isLoading &&
            rewardState.reward != null && (
              // $FlowFixMe
              <CardContent className={classes.content}>
                <Typography>
                  Rewarded point: {rewardState.reward.amount}
                </Typography>
              </CardContent>
            )}

          {renderInput({
            label: 'Rewarded Ad Id',
            value: rewardAdId,
            onChange: setRewardAdId,
          })}
          {renderButton({
            text: 'Load Reward',
            disabled: rewardState.isLoading,
            onClick: loadRewardAd,
          })}
          {renderButton({
            text: 'Show Reward',
            disabled: rewardState.isLoading,
            onClick: displayRewardAd,
          })}
        </Paper>
      </GreyCard>
    </div>
  );
}

export default Ads;
