#!/bin/bash
cd ~/Downloads/
cp -p "$1"* /d/Aleem/Wallpapers/
cp -p "$1"* /e/Aleem/Wallpapers/
mv "$1"* /c/Users/Buildmaster/OneDrive/Wallpapers/
cp -p /d/Aleem/temp_spotlight/*.jpg /d/Aleem/Wallpapers/
cp -p /d/Aleem/temp_spotlight/*.jpg /e/Aleem/Wallpapers/
cp -p /d/Aleem/temp_spotlight/*.jpg /c/Users/Buildmaster/OneDrive/Wallpapers/
rm /d/Aleem/temp_spotlight/*.jpg
