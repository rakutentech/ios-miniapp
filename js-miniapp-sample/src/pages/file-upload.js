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
} from '@material-ui/core';

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

  const setFiles = (e) => {
    const files = e.target.files;
    if (!files) {
      return;
    }

    setRows(
      Array.from(files).map((file) => ({
        name: file.name,
        size: file.size,
        type: file.type,
      }))
    );
  };

  const numberCommaFormatter = (number) => {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  };

  return (
    <Card className={classes.root}>
      <CardContent className={(classes.content, classes.uploader)}>
        <input
          type="file"
          onChange={setFiles}
          data-testid="file-input"
          multiple
        />
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
