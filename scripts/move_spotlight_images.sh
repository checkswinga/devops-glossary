#!/bin/bash
cd /c/Users/aleem/AppData/Local/Packages/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy/LocalState/Assets
cp * /c/Users/aleem/spotlight/
cd /c/Users/aleem/spotlight/
for i in $(ls); do mv $i $i.jpg; done
