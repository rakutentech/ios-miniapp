# SDK Developer Guide

This guide targets Developers of this SDK. It explains how to build the project and how the CI setup works. In order to setup the environment you need to install [Cocoapods](https://guides.cocoapods.org/using/getting-started.html) and [Fastlane](https://docs.fastlane.tools/getting-started/ios/setup/)

## Table of Contents
---

* [How to Build the Sample App](#build-sample-app)
* [How to Test with the Sample App](#test-sample-app)
* [How to test your SDK integration with Cocoapods](#integrate-sdk-cocoapod)
* [How to generate SDK documentation locally](#generate-sdk-doc)
* [Continuous Integration and Deployment](#continuous-integration)

<a id="build-sample-app"></a>

## How to Build the Sample App
---

First, it is highly recommended to setup some environment variables which are required by the project.

```bash
RMAAPIEndpoint=https://www.example.com
RASProjectId=test-project-id
RASProjectSubscriptionKey=test-subscription-key
```

NOTE: `RASApplicationIdentifier` is deprecated

The Sample App has a dependency on the [public version of the RAnalytics SDK](https://github.com/rakutentech/ios-analytics-framework) and the following environment variables need to be configured before building:

```bash
RAT_ENDPOINT=your-rat-endpoint
RAT_ACCOUNT_IDENTIFIER=your-rat-account-id
RAT_APP_IDENTIFIER=your-rat-app-id
```

Next, run `fastlane updatePods` from the root directory that will trigger a `pod install` and fetch git submodules, then open `MiniApp.xcworkspace`, and you should be able to successfully build the Sample App.

*Note:* You need to define the environment variables before installing the pods because there is a post install script which sets up the project with your environment variables. If you don't want to use environment variables, you can edit the `MiniApp-Secrets.xcconfig` created after a `pod install` in the parent folder of the project,but be aware you will have to update this file after every `pod install`

<a id="test-sample-app"></a>

## How to Test with the Sample App
---

We currently don't provide an API for public use, so you must provide your own API.

<a id="integrate-sdk-cocoapod"></a>

## How to test your SDK integration with Cocoapods
---

If you need to test your SDK fork into your host app before making a pull request, you can use this line into your podfile:

```ruby
  pod 'MiniApp', git: 'https://github.com/<My fork account>/ios-miniapp', branch: 'master', submodules: true
```

<a id="generate-sdk-doc"></a>

## How to generate SDK documentation locally
---

You may want to generate the SDK documentation locally so that you can ensure that the generated docs look correct. 
We use [Jazzy](https://github.com/realm/jazzy) for this, so you can run the following command:

```
bundle exec jazzy
```

The generated docs will be output to a folder named `docs` in the root of this repo.

<a id="continuous-integration"></a>

## Continuous Integration and Deployment
---

Before any deployment, be sure the project will build and run unit tests by running `fastlane ci`.

[BitRise](https://app.bitrise.io/app/bddaf16e1f0fc0d6) is used for building and testing the project for every pull request. It is also used for publishing the SDK and Sample App.

Note that two Sample App are built on CI and then uploaded with symbols to App Center on merge to master or during a release: 
- One build for the iOS Simulator
- One build for iOS Devices (can be triggered manually directly on App Center if needed)

### Merge to Master

The following describes the steps that CI performs when a branch is merged to master.

1. We trigger a build on CI by merging a branch to master.
2. CI builds SDK and Sample App, run tests, linting, etc.
3. CI creates a ZIP file for the iOS Simulator (Staging) build of the Sample App.
    - Publishes build to App Center "Testers" group.
4. CI builds a Sample App (Staging) IPA and publishes build to App Center "Testers" group.

### Release candidate

In order to launch CI job for regression tests, a candidate branch is observed.
As candidate check steps are always the same, a script is available to guide you trough the process:

```bash
./scripts/release-candidate.sh
```

The script can be launched with no parameters, but you can also provide it a version number and branch name:

    Usage: [-v Version] [-b Branch] [-d]

        -v Version      Version to deploy.
        -b Branch       Branch to release. By default 'candidate'
        -d              displays useful data to debug this script
        -a              automatic mode. Requires -v parameter to be 100% without prompt
        -s              silent mode

    For Example: ./release-candidate.sh -v 3.5.0 -b candidate -a

        -h              Help

During the process a branch will be created and your work in progress will be stored in a git stash.
Once the candidate created and pushed, your branch will be checked out again and the stash will be popped.

If the release candidate process is aborted, please switch manually to your working branch and execute a `git stash pop` to retrieve all your uncommitted changes.

The following describes the steps that CI performs when a branch is merged to candidate.

1. We trigger a build on CI by merging a branch to candidate.
2. CI builds SDK and Sample App, run tests, linting, etc.
3. CI creates a ZIP file for the iOS Simulator (Production) build of the Sample App.
    - Publishes build to App Center "Testers" group.
4. CI builds a Sample App (Production) IPA and publishes build to App Center "Testers" group.

### Release

The following describes the steps that CI performs when releasing a new version of the SDK.

1. We trigger a build on CI by pushing a Git tag on `candidate` branch to the repo in the format `vX.X.X`.
2. CI builds SDK and Sample App, run tests, linting, etc.
3. CI publishes the SDK to [Cocoapods](https://cocoapods.org/pods/MiniApp).
4. CI creates ZIP and IPA files for the iOS Simulator and device (Production) builds of the Sample App.
    - Publishes build to App Center "Production" group.
5. CI merges the `candidate` branch into the `prod` branch.
6. CI creates a pull request to merge `candidate` branch to `master` branch.
7. CI publishes documentation to [Github Pages site](https://rakutentech.github.io/ios-miniapp).
