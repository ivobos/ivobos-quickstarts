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
- bitbucket (install with `pip install bitbucket-cli`)
- git

## Usage

Run the quickstart
```
./ivobos-quickstarts/bin/js-mobile-game-quickstart.sh
```
Answer some questions
```
Enter project name (eg. space-travel-mobile): tetris-mobile
Enter application title (eg. Space Travel): Tetris
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








