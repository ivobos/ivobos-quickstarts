#!/bin/bash

set -e # exit on command fail
set -o pipefail # exit on command fail in a pipeline
set -u # warn about unused variables
set -E # make sure traps work with set -e

# various paths
scriptPath="`dirname \"$0\"`"
scriptPath="`( cd \"$scriptPath\" && pwd )`"
resourcesPath="$scriptPath/js-mobile-game-quickstart-resources"

echo -n "Enter project name: "
read userInput
if [[ -n "$userInput" ]]
then
    projectName=$userInput
fi
projectNameLowercase=`echo $userInput | tr '[:upper:]' '[:lower:]'`
projectDir="$PWD/ivobos-$projectNameLowercase"
projectId=net.aptive.$projectNameLowercase
appTitle=$projectName
echo "Ready to create Apache Cordova project"
echo "Path:         $projectDir"
echo "Package id:   $projectId"
echo "App title:    $appTitle"

echo "Do you wish to continue? [Y/n]"
read -rsn1 answer
if [ "$answer" != "y" -a "$answer" != "Y" -a "$answer" != "" ]; then
    echo "aborted"
    exit
fi

set -o xtrace # print commands executed

cordova create $projectDir $projectId $appTitle
cd $projectDir
cordova platform add android
cordova platform add osx

# prepare icon
cp "$resourcesPath/icon.png" $projectDir
cordova-icon

