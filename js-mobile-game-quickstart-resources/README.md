# appTitle
Created with https://github.com/ivobos/ivobos-quickstarts/js-mobile-game-quickstart.sh

# Prepare Dev Environment
Install nodejs and yarn.
* [https://nodejs.org](https://nodejs.org)
* [https://yarnpkg.com](https://yarnpkg.com) 

That should be enough for a local browser dev. 

# Local browser dev loop
Develop on a local browser
```bash
yarn install
yarn start
```
Open browser location [http://localhost:8080/](http://localhost:8080/)

# Release
```bash
yarn run release
```
This will prompt for new version number, update versions in various files, create a 
version tag and push this to git. 

