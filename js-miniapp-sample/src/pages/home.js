import React, { useState, useEffect } from 'react';

import {
  makeStyles,
  Container,
  useTheme,
  useMediaQuery,
} from '@material-ui/core';
import clsx from 'clsx';
import {
  BrowserRouter as Router,
  Route,
  Switch,
  Redirect,
} from 'react-router-dom';

import ToolBar from '../components/ToolBar';
import { navItems } from './../routes';

const DRAWER_WIDTH = '250px';
const DRAWER_SHRINKED_WIDTH = '70px';

const useStyles = makeStyles((theme) => ({
  mainContent: {
    width: '100%',
    height: 'calc(100% - 64px)',
  },
  mainContentMobile: {
    height: 'calc(100% - 56px)',
  },
  wrapperContainer: {
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  drawerClosed: {
    width: '100% !important',
    marginLeft: '0 !important',
  },
  drawerOpen: {
    width: `calc(100% - ${DRAWER_WIDTH})`,
    marginLeft: DRAWER_WIDTH,
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },
  drawerOpenShrink: {
    width: `calc(100% - ${DRAWER_SHRINKED_WIDTH})`,
    marginLeft: DRAWER_SHRINKED_WIDTH,
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },
}));

const Home = (props: any) => {
  const classes = useStyles();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('xs'));
  const [shrink, setShrink] = useState(false);
  const [showDrawer, setShowDrawer] = useState(!isMobile);
  useEffect(() => {
    setShowDrawer(!isMobile);
  }, [isMobile]);
  const onShrinkToggle = (shrinkState) => {
    setShrink(shrinkState);
  };
  const onDrawerToggle = (show) => {
    setShowDrawer(show);
  };
  return (
    <Router>
      <ToolBar
        showDrawer={showDrawer}
        onDrawerToggle={onDrawerToggle}
        onShrinkToggle={onShrinkToggle}
        navItems={navItems}
      ></ToolBar>
      <main
        data-testid="homepage-main-content"
        className={clsx(classes.mainContent, {
          [classes.mainContentMobile]: isMobile,
          [classes.drawerOpen]: !isMobile && showDrawer,
          [classes.drawerClosed]: !isMobile && !showDrawer,
          [classes.drawerOpenShrink]: !isMobile && shrink,
        })}
      >
        <Container className={classes.wrapperContainer}>
          <Switch>
            <Route exact path="/">
              <Redirect to={navItems[0].navLink} />
            </Route>
            {navItems.map((it) => (
              <Route
                key={it.navLink}
                path={it.navLink}
                exact
                component={
                  it.component ??
                  (() => (
                    <div
                      data-testid="nav-routes"
                      style={{ fontSize: '32px', textAlign: 'center' }}
                    >
                      {it.label}
                    </div>
                  ))
                }
              ></Route>
            ))}
            <Route path="*">Page Not Found</Route>
          </Switch>
        </Container>
      </main>
    </Router>
  );
};

export default Home;
