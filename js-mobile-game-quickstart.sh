#!/bin/bash

set -e # exit on command fail
set -o pipefail # exit on command fail in a pipeline
set -u # warn about unused variables
set -E # make sure traps work with set -e

# various paths
scriptPath="`dirname \"$0\"`"
scriptPath="`( cd \"$scriptPath\" && pwd )`"
resourcesPath="$scriptPath/js-mobile-game-quickstart-resources"

# test prerequisite commands are present
set -o xtrace # enable command printing
which cordova
which xmlstarlet

# collect input configuration
set +o xtrace # disable command printing
echo -n "Enter project name: "
read userInput
if [[ -n "$userInput" ]]
then
    projectName=$userInput
fi
projectNameLowercase=`echo $userInput | tr '[:upper:]' '[:lower:]'`
projectDir="$PWD/ivobos-$projectNameLowercase"
projectId=net.aptive.$projectNameLowercase
projectDescription="$projectName description"
appTitle=$projectName
authorName="Ivo Bosticky"
authorEmail="ivobos@gmail.com"
authorWebsite="http://aptive.net"
echo "Ready to create Apache Cordova project"
echo "Path:         $projectDir"
echo "Package id:   $projectId"
echo "Description:  $projectDescription"
echo "App title:    $appTitle"
echo "Author:       $authorName"
echo "Author email: $authorEmail"
echo "Auther site:  $authorWebsite"
echo "Do you wish to continue? [Y/n]"
read -rsn1 answer
if [ "$answer" != "y" -a "$answer" != "Y" -a "$answer" != "" ]; then
    echo "aborted"
    exit
fi

# now create project
set -o xtrace # print commands executed
cordova create $projectDir $projectId $appTitle
cd $projectDir

# update config.xml
xmlstarlet ed -L -N x="http://www.w3.org/ns/widgets" -u "/x:widget/x:description" -v "$projectDescription" config.xml

# update package.json
jq ".description = \"$projectDescription\"" package.json > package.json.new
mv package.json.new package.json
jq ".author = \"$authorName\"" package.json > package.json.new
mv package.json.new package.json
jq "del(.main)" package.json > package.json.new
mv package.json.new package.json

cordova platform add android
cordova platform add ios
# prepare icon
cp "$resourcesPath/icon.png" $projectDir
cordova-icon

# test compile everything
# check build environment pre-requisites
cordova requirements
# build
cordova compile
