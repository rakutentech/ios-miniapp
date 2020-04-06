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
- `yarn sdk build`
- `yarn sdk fix`
- `yarn sdk test`
