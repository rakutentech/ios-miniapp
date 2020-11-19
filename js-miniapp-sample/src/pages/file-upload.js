// @flow
import React, { useState } from 'react';

import {
  Card,
  CardContent,
  makeStyles,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableRow,
  TableContainer,
  IconButton,
} from '@material-ui/core';
import DeleteIcon from '@material-ui/icons/Delete';

const useStyles = makeStyles((theme) => ({
  root: {
    height: '90%',
    width: '100%',
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
  uploader: {
    height: '25%',
  },
}));

const FileUploader = () => {
  const classes = useStyles();
  const [rows, setRows] = useState([]);

  const setFile = (e) => {
    if (!e.target.files) {
      return;
    }
    const file = e.target.files[0];
    setRows([...rows, { name: file.name, size: file.size, type: file.type }]);
  };

  const removeFile = (name) => {
    setRows(rows.filter((item) => item.name !== name));
  };

  const numberCommaFormatter = (number) => {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  };

  return (
    <Card className={classes.root}>
      <CardContent className={(classes.content, classes.uploader)}>
        <input type="file" onChange={setFile} data-testid="file-input" />
      </CardContent>
      <CardContent className={classes.content}>
        <TableContainer component={Paper} data-testid="file-table">
          <Table className={classes.table} aria-label="simple table">
            <TableHead>
              <TableRow>
                <TableCell>Name</TableCell>
                <TableCell align="left">Type</TableCell>
                <TableCell align="right">Size(KB)</TableCell>
                <TableCell align="right"></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {rows.map((row) => (
                <TableRow key={row.name}>
                  <TableCell component="th" scope="row">
                    {row.name}
                  </TableCell>
                  <TableCell align="left">{row.type}</TableCell>
                  <TableCell align="right">
                    {numberCommaFormatter(row.size)}
                  </TableCell>
                  <TableCell align="right">
                    <IconButton onClick={() => removeFile(row.name)}>
                      <DeleteIcon />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </CardContent>
    </Card>
  );
};

export default FileUploader;
