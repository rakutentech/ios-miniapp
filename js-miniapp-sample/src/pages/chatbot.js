import React, { useState, Fragment } from 'react';

import {
  makeStyles,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  CardContent,
  CardActions,
  Button,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
} from '@material-ui/core';
import { connect } from 'react-redux';

import { getBotsList } from '../services/chatbot/actions';
import type { ChatBot } from '../services/chatbot/types';
import GreyCard from '../components/GreyCard';

const useStyles = makeStyles((theme) => ({
  formControl: {
    margin: theme.spacing(1),
    minWidth: '100%',
  },
  fields: {
    color: theme.color.primary,
    '& div': {
      color: theme.color.primary,
    },
  },
  content: {
    height: '50%',
    justifyContent: 'center',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    fontSize: 18,
    fontWeight: 'bold',
  },
  actions: {
    justifyContent: 'center',
  },
  errorMessage: {
    fontSize: 12,
    color: 'indianred',
  },
}));

type ChatBotProps = {
  bots: Array<ChatBot>,
};

const TalkToChatBot = (props: ChatBotProps) => {
  const classes = useStyles();
  const chatbots = props.bots;
  const [chatbot, setChatbot] = useState({
    id: chatbots[0] !== undefined ? chatbots[0].id : -1,
    message: '',
  });
  const [validation, setValidationState] = useState({
    error: false,
    message: '',
  });
  const [chatbotMessage, setChatbotMessage] = useState({ show: false });
  const validate = () => {
    if (
      chatbots.map((it) => it.id).findIndex((it) => it === chatbot.id) === -1
    ) {
      setValidationState({ error: true, message: 'select chatbot' });
      return false;
    } else if (
      chatbot.message === undefined ||
      chatbot.message.trim().length === 0
    ) {
      setValidationState({ error: true, message: 'enter message to chatbot' });
      return false;
    } else {
      setValidationState({ error: false, message: '' });
    }
    return true;
  };
  const handleChange = (event) => {
    setChatbot({ ...chatbot, id: event.target.value });
  };
  const talkToChatbot = () => {
    if (validate()) {
      setChatbotMessage({ show: true });
    }
  };

  const onMessageToChatbotChange = (event) => {
    setChatbot({ ...chatbot, message: event.target.value });
  };

  const onChatbotClose = () => {
    setChatbotMessage({ show: false });
  };
  return (
    <Fragment>
      <GreyCard>
        <CardContent className={classes.content}>
          <FormControl className={classes.formControl}>
            <InputLabel id="chatbotLabel">Chatbot</InputLabel>
            <Select
              labelId="chatbotLabel"
              id="chatbot"
              placeholder="Select Chatbot"
              value={chatbot.id}
              className={classes.fields}
              onChange={handleChange}
            >
              {chatbots.map((c) => (
                <MenuItem key={c.id} value={c.id}>
                  {c.name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          <FormControl className={classes.formControl}>
            <TextField
              id="message"
              label="Message"
              className={classes.fields}
              onChange={onMessageToChatbotChange}
              value={chatbot.message}
              placeholder="Type here..."
              multiline
            />
          </FormControl>
          {validation.error && (
            <div
              data-testid="validation-error"
              className={classes.errorMessage}
            >
              {validation.message}
            </div>
          )}
        </CardContent>
        <CardActions className={classes.actions}>
          <Button
            data-testid="send-message"
            variant="contained"
            color="primary"
            fullWidth
            onClick={talkToChatbot}
          >
            SEND MESSAGE
          </Button>
        </CardActions>
      </GreyCard>

      <Dialog
        data-testid="chatbot-response-dialog"
        open={chatbotMessage.show}
        onClose={onChatbotClose}
        aria-labelledby="max-width-dialog-title"
      >
        <DialogTitle id="max-width-dialog-title">Chatbot Response</DialogTitle>
        <DialogContent>
          <DialogContentText>Hello</DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={onChatbotClose} color="primary">
            Close
          </Button>
        </DialogActions>
      </Dialog>
    </Fragment>
  );
};

const mapStatetoProps = (state, props) => {
  return {
    ...props,
    bots: state.chatbot.bots,
  };
};
const mapDispatchToProps = (dispatch) => {
  return {
    getBots: () => dispatch(getBotsList()),
  };
};

export default connect(mapStatetoProps, mapDispatchToProps)(TalkToChatBot);
