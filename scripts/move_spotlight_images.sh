#!/bin/bash
cd /c/Users/Buildmaster/AppData/Local/Packages/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy/LocalState/Assets
cp * /d/Spotlight/
cd /d/Spotlight/
for i in $(ls); do mv $i $i.jpg; done
