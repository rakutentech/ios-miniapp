import React, { useState, Fragment } from 'react';

import {
  makeStyles,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
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
import {
  sendMessageToContact,
  sendMessageToContactId,
  sendMessageToMultipleContacts,
} from '../services/message/actions';
import { getMessageTypeList } from '../services/message/actions';
import type { MessageType } from '../services/message/types';
import { pandaLogo } from '../assets/images/base64';

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
  actions: {
    justifyContent: 'center',
  },
  errorMessage: {
    fontSize: 12,
    color: 'indianred',
  },
}));

type MessageTypeProps = {
  messageTypes: Array<MessageType>,
  sendMessageToContact: (
    image: string,
    text: string,
    caption: string,
    action: string
  ) => Promise<string>,
  sendMessageToContactId: (
    contactId: string,
    image: string,
    text: string,
    caption: string,
    action: string
  ) => Promise<string>,
  sendMessageToMultipleContacts: (
    image: string,
    text: string,
    caption: string,
    action: string
  ) => Promise<string>,
};

const Message = (props: MessageTypeProps) => {
  const classes = useStyles();
  const messageTypes = props.messageTypes;
  const [message, setMessage] = useState({
    id: messageTypes[0] !== undefined ? messageTypes[0].id : -1,
    contactId: '',
    image: pandaLogo,
    text: 'Sample text',
    caption: 'Sample caption',
    action: 'https://www.example.com/',
  });
  const [validation, setValidationState] = useState({
    error: false,
    message: '',
  });
  const [messageResponse, setMessageResponse] = useState({
    show: false,
    response: '',
  });
  const validate = () => {
    if (
      messageTypes.map((it) => it.id).findIndex((it) => it === message.id) ===
      -1
    ) {
      setValidationState({ error: true, message: 'select message' });
      return false;
    } else if (message.text === undefined || message.text.trim().length === 0) {
      setValidationState({ error: true, message: 'text cannot be empty' });
      return false;
    } else if (
      message.id === 2 &&
      (message.contactId === undefined || message.contactId.trim().length === 0)
    ) {
      setValidationState({
        error: true,
        message: 'contact id cannot be empty',
      });
      return false;
    } else {
      setValidationState({ error: false, message: '' });
    }
    return true;
  };
  const handleChange = (event) => {
    setMessage({ ...message, id: event.target.value });
  };
  const talkToChatbot = () => {
    if (validate()) {
      if (message.id === 1) {
        props
          .sendMessageToContact(
            message.image.trim() ?? '',
            message.text.trim(),
            message.caption.trim() ?? '',
            message.action.trim() ?? ''
          )
          .then((contactId) => {
            let respMsg = 'Message not sent';
            if (contactId !== null)
              respMsg = 'Message is sent to contact Id: ' + contactId;
            setMessageResponse({
              show: true,
              response: respMsg,
            });
          })
          .catch((e) => {
            setMessageResponse({
              show: true,
              response: e,
            });
          });
      } else if (message.id === 2) {
        props
          .sendMessageToContactId(
            message.contactId.trim(),
            message.image.trim() ?? '',
            message.text.trim(),
            message.caption.trim() ?? '',
            message.action.trim() ?? ''
          )
          .then((contactId) => {
            let respMsg = 'Message not sent';
            if (contactId !== null)
              respMsg = 'Message is sent to contact Id: ' + contactId;
            setMessageResponse({
              show: true,
              response: respMsg,
            });
          })
          .catch((e) => {
            setMessageResponse({
              show: true,
              response: e,
            });
          });
      } else if (message.id === 3) {
        props
          .sendMessageToMultipleContacts(
            message.image.trim() ?? '',
            message.text.trim(),
            message.caption.trim() ?? '',
            message.action.trim() ?? ''
          )
          .then((contactIds) => {
            let respMsg = 'Message not sent';
            if (contactIds !== null)
              respMsg = contactIds.length + ' contacts sent';
            setMessageResponse({
              show: true,
              response: respMsg,
            });
          })
          .catch((e) => {
            setMessageResponse({
              show: true,
              response: e,
            });
          });
      }
    }
  };

  const onContactIdChange = (event) => {
    setMessage({ ...message, contactId: event.target.value });
  };
  const onImageChange = (event) => {
    setMessage({ ...message, image: event.target.value });
  };
  const onTextChange = (event) => {
    setMessage({ ...message, text: event.target.value });
  };
  const onCaptionChange = (event) => {
    setMessage({ ...message, caption: event.target.value });
  };
  const onActionChange = (event) => {
    setMessage({ ...message, action: event.target.value });
  };

  const onChatbotClose = () => {
    setMessageResponse({ show: false, response: '' });
  };
  return (
    <Fragment>
      <FormControl className={classes.formControl}>
        <InputLabel id="chatbotLabel">Send Message Type</InputLabel>
        <Select
          labelId="chatbotLabel"
          id="message"
          placeholder="Select Chatbot"
          value={message.id}
          className={classes.fields}
          onChange={handleChange}
        >
          {messageTypes.map((c) => (
            <MenuItem key={c.id} value={c.id}>
              {c.name}
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      {message.id === 2 && (
        <FormControl className={classes.formControl}>
          <TextField
            id="contactId"
            label="Contact ID"
            className={classes.fields}
            onChange={onContactIdChange}
            placeholder="Input contact id receiving a message"
            value={message.contactId}
          />
        </FormControl>
      )}

      <FormControl className={classes.formControl}>
        <TextField
          id="image"
          label="Image"
          className={classes.fields}
          onChange={onImageChange}
          placeholder="Image url or Base64 string"
          value={message.image}
        />
      </FormControl>
      <FormControl className={classes.formControl}>
        <TextField
          id="text"
          label="Text"
          className={classes.fields}
          onChange={onTextChange}
          value={message.text}
          multiline
          rowsMax="4"
        />
      </FormControl>
      <FormControl className={classes.formControl}>
        <TextField
          id="caption"
          label="Caption"
          className={classes.fields}
          onChange={onCaptionChange}
          value={message.caption}
        />
      </FormControl>
      <FormControl className={classes.formControl}>
        <TextField
          id="action"
          label="Action"
          className={classes.fields}
          onChange={onActionChange}
          value={message.action}
        />
      </FormControl>
      {validation.error && (
        <div data-testid="validation-error" className={classes.errorMessage}>
          {validation.message}
        </div>
      )}
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
      <Dialog
        data-testid="message-response-dialog"
        open={messageResponse.show}
        onClose={onChatbotClose}
        aria-labelledby="max-width-dialog-title"
      >
        <DialogTitle id="max-width-dialog-title">Response</DialogTitle>
        <DialogContent>
          <DialogContentText>{messageResponse.response}</DialogContentText>
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
    messageTypes: state.message.messageTypes,
  };
};
const mapDispatchToProps = (dispatch) => {
  return {
    getBots: () => dispatch(getMessageTypeList()),
    sendMessageToContact: (image, text, caption, action) =>
      dispatch(sendMessageToContact(image, text, caption, action)),
    sendMessageToContactId: (contactId, image, text, caption, action) =>
      dispatch(sendMessageToContactId(contactId, image, text, caption, action)),
    sendMessageToMultipleContacts: (image, text, caption, action) =>
      dispatch(sendMessageToMultipleContacts(image, text, caption, action)),
  };
};

export default connect(mapStatetoProps, mapDispatchToProps)(Message);
