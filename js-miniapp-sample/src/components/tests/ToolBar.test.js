import React from 'react';

import StorageIcon from '@material-ui/icons/Storage';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import { act } from 'react-dom/test-utils';

import {
  renderWithRedux,
  wrapRouter,
  screen,
  wrapTheme,
} from './../../tests/test-utils';
import ToolBar from './../ToolBar';

describe('ToolBar', () => {
  const navItems = [
    {
      icon: <StorageIcon />,
      label: 'Local Storage',
      navLink: '/local_storage',
    },
  ];
  test('should load toolbar with drawer icon & title', () => {
    renderWithRedux(wrapRouter(wrapTheme(<ToolBar showDrawer={false} />)));
    expect(screen.getByText('POC')).toBeInTheDocument();
    expect(screen.getByTestId('menu-icon')).toBeInTheDocument();
    expect(screen.queryByTestId('close-icon')).toBeNull();
    expect(screen.queryByTestId('drawer')).toBeNull();
  });

  test('should load toolbar with drawer open', () => {
    renderWithRedux(
      wrapRouter(
        wrapTheme(
          <ToolBar
            showDrawer={true}
            navItems={navItems}
            onDrawerToggle={() => {}}
            onShrinkToggle={() => {}}
          />
        )
      )
    );
    expect(screen.getByText('POC')).toBeInTheDocument();
    expect(screen.queryByTestId('menu-icon')).toBeNull();
    expect(screen.queryByTestId('close-icon')).toBeInTheDocument();
    const navList = screen.getByRole('presentation').querySelectorAll('ul a');
    expect(navList.length).toEqual(1);
  });

  test('should load toolbar with drawer closed', () => {
    renderWithRedux(
      wrapRouter(
        wrapTheme(
          <ToolBar
            showDrawer={false}
            navItems={navItems}
            onDrawerToggle={() => {}}
            onShrinkToggle={() => {}}
          />
        )
      )
    );
    expect(screen.getByText('POC')).toBeInTheDocument();
    expect(screen.queryByTestId('menu-icon')).toBeInTheDocument();
    expect(screen.queryByTestId('close-icon')).toBeNull();
    const navList = screen.getByRole('presentation').querySelectorAll('ul a');
    expect(navList.length).toEqual(0);
  });

  test('should change title when navigation', () => {
    renderWithRedux(
      wrapRouter(
        wrapTheme(
          <ToolBar
            showDrawer={true}
            navItems={navItems}
            onDrawerToggle={() => {}}
            onShrinkToggle={() => {}}
          />
        )
      )
    );
    const navList = screen.getByRole('presentation').querySelectorAll('ul a');
    expect(navList.length).toEqual(1);
    const navLabel = navItems[0].label;
    expect(screen.getAllByText(navLabel).length).toEqual(1);
    act(() => {
      userEvent.click(screen.getByText(navLabel));
    });
    expect(screen.getAllByText(navLabel).length).toEqual(2);
  });
});
