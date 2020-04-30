# js-miniapp-sample

This is the boilerplate for the MiniAppBuild Team.

The project was bootstrapped with [Create React App](https://github.com/facebook/create-react-app).

## Table of contents

- [js-miniapp-sample](#js-miniapp-sample)
  - [Table of contents](#table-of-contents)
  - [Installation](#installation)
  - [Testing](#testing)
  - [Building](#building)
  - [Export Dockerized App Image as TAR](#export-dockerized-app-image-as-tar)
  - [Import Dockerized App Image from TAR](#import-dockerized-app-image-from-tar)
  - [Flow](#flow)
  - [Custom Environment Variables](#custom-environment-variables)
  - [Code Formatting](#code-formatting)
  - [Others](#others)

## Installation

```
git clone git@github.com:rakutentech/js-miniapp.git
cd js-miniapp
yarn install
yarn sample start
```

## Testing

For test just execute:

`yarn sample test`

## Building

To build the app for production:

`yarn sample build`

The building will be inside the `build` folder on `js-miniapp-sample` root.<br />

## Export Dockerized App Image as TAR

to build and package docker image of the production build:

`yarn sample dockerBuild`

The `poc.tar` file will be generated inside `ci/` directory on `js-miniapp-sample` root.<br/>
**Prerequisite**: [Docker](https://docs.docker.com/) LTS

## Import Dockerized App Image from TAR

to unpackage and run a production build on your local computer:

- Copy `js-miniapp-sample/ci/Makefile` to the `poc.tar` file directory and run

```bash
  make run
```

**Note**: to stop the local docker container run `make stop` on `Makefile` directory.

**Prerequisite**: [Docker](https://docs.docker.com/) LTS

## Flow

- We use [Flow](https://flow.org/) as a static type checker in our App.<br/>
- To check the files for type errors: `npm run flow`
- Check Flow integrations for code editors [here](https://flow.org/en/docs/editors/)

## Custom Environment Variables

- Please check to [this document](https://create-react-app.dev/docs/adding-custom-environment-variables/) about Custom Environment Varibles in create-react-app.
- To set **your environment variables** you need to create a file `.env` on the root of your project. This file is on .gitignore, so it'll just be loaded on your machine.
- **All** the environment variables must start with `REACT_APP_` to work.
- To access any variable you must follow this syntax: `process.env.REACT_APP_XXX`
- At this moment we've 3 different files to add environment variables: `.env.development`, `.env.test` and `.env.production`.
- Check this [link](https://create-react-app.dev/docs/adding-custom-environment-variables/#what-other-env-files-can-be-used) to understand the priority on each available npm script.

## Code Formatting

- The following dev-dependencies have been installed for this purpose: `husky, lint-staged, prettier`
- Whenever we make a commit Prettier will format the changed files automatically.
- You might want to integrate Prettier in your favorite editor as well. Please check the [Prettier Editor Integration](https://prettier.io/docs/en/editors.html).

## Others

- You can have a look at the create-react-app repo [here](https://github.com/facebook/create-react-app)
