# Ivo's Quickstarts
Start your game coding in minutes.

## Description
Put the fun back into game development by not having to configure standard development tooling for each new project. Simply run the quickstart script, answer a few questions, and a custom JavaScript mobile game project will be created 
for you. The poject is based on Apache Cordova which supports both iOS and Android development. The build environment uses webpack to package the source code and manage hot deployment, and saves time by not needing to fiddle with 
babel configuration, icons, splashcreens and other non-game specific timewasters.

## Installation
Clone the ivobos-quickstarts repository with
```
git clone https://github.com/ivobos/ivobos-quickstarts.git
```
Other tools that you will need on your system include
- yarn 
- cordova
- xmlstarlet
- jq
- cordova-icon
- cordova-splash

## Usage

Run the quickstart
```
./ivobos-quickstarts/bin/js-mobile-game-quickstart.sh
```
Answer some questions
```
Enter project name: testproj
Ready to create project testproj
Path:         /Users/ibosticky/src/ivobos-quickstarts/ivobos-testproj
Package id:   net.aptive.testproj
Description:  testproj description
App title:    testproj
Author:       Ivo Bosticky
Author email: ivobos@gmail.com
Auther site:  http://aptive.net
Do you wish to continue? [Y/n]
```
Your custom project will be created
```
...
Project testproj created successfully
Your project location is /Users/ibosticky/src/ivobos-quickstarts/ivobos-testproj
Run local development with 'yarn start'
Build iOS with 'yarn run ios'
Build Android with 'yarn run android'
```

## Contributing
To contribute you can use a local dev loop by running
```
yarn start
```
This will run the quickstart for a project called 'ivobos-testproj'. After the build is
complete any file changes will trigger a re-run.








