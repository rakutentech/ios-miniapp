[![npm version](https://img.shields.io/npm/v/js-miniapp-sdk.svg?style=flat)](https://www.npmjs.com/package/js-miniapp-sdk)
[![CircleCI](https://circleci.com/gh/rakutentech/js-miniapp.svg?style=svg)](https://circleci.com/gh/rakutentech/js-miniapp)
[![codecov](https://codecov.io/gh/rakutentech/js-miniapp/branch/master/graph/badge.svg?token=JG77H8JRSK)](https://codecov.io/gh/rakutentech/js-miniapp)
[![Code Style: Google](https://img.shields.io/badge/code%20style-google-blueviolet.svg)](https://github.com/google/gts)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

# Mini App JavaScript SDK.
Mini App SDK for JavaScript.

This Readme targets the developers of this SDK and the Sample App project. If you wish to use the Mini App JavaScript SDK in your own Mini App, see the [JS SDK Documentation](https://rakutentech.github.io/js-miniapp/) and the [Sample Mini App source code](js-miniapp-sample) instead.

# Setup

This is a mono-repo which uses [Yarn Workspaces](https://classic.yarnpkg.com/en/docs/workspaces/), so you must have Yarn installed. On Mac, run `brew install yarn` to install the global version of yarn.

The repo is split into three packages:

- `js-miniapp-sdk`: the JavaScript SDK which is is implemented by each individual Mini App.
- `js-miniapp-sample`: a sample Mini App which utlizes the MiniApp JavaScript SDK.
- `js-miniapp-bridge`: the JavaScript Bridge which is implemented by the Android and iOS and native SDKs.

## Getting Started

1. Run `yarn install`. 
2. You can now run the NPM scripts for each workspace as follows: `yarn sdk SCRIPT_NAME`, `yarn sample SCRIPT_NAME`, or `yarn bridge SCRIPT_NAME`.

### SDK Scripts
- `yarn sdk check`
- `yarn sdk clean`
- `yarn sdk compile`
- `yarn sdk buildSdk`
- `yarn sdk fix`
- `yarn sdk test`

## Continuous Integration and Deployment

[CircleCI](https://circleci.com/gh/rakutentech/js-miniapp) is used for building and testing the project for every pull request. It is also used for publishing the JavaScript SDK.

### SDK Release

The following describes the steps performed by CI when releasing a new version of the SDK ([js-miniapp-sdk](js-miniapp-sdk)).

1. A Git tag is pushed to repo which is in the format `vX.X.X` and triggers the CI to start.
2. Build project, run tests, linting, etc.
3. Pause for user verification of release.
4. If approved, publish the JS SDK to [NPM](https://www.npmjs.com/package/js-miniapp-sdk).
5. Publish documentation to the [Github Pages site](https://rakutentech.github.io/js-miniapp/docs/1.1/).
6. Publish a release to [Github Releases page](https://github.com/rakutentech/js-miniapp/releases) and attach a JavaScript bundle of the SDK (`miniapp.bundle.js`).

### JavaScript Bridge Deployment

The JavaScript bridge ([js-miniapp-bridge](js-miniapp-bridge)) will be deployed to the [js-bridge-android](tree/js-bridge-android) and [js-bridge-ios](/tree/js-bridge-ios) branches when changes are merged to master. These branches are then imported as Git Submodules in the Android and iOS Mini App SDK repos.


### Sample App Deployment

The sample app ([js-miniapp-sample](js-miniapp-sample)) will be deployed to the [gh-pages](tree/gh-pages) branch when changes are merged to master. This can be viewed [here](https://rakutentech.github.io/js-miniapp/sample).
