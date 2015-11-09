#!/bin/bash

sed -n '/<svg/,$p' images/architecture.svg | \
sed 's/font-family=..OpenSans-Semibold../font-weight="600"/g' | \
sed 's/font-family=/illustrator-font-family=/g' | \
sed 's/\>\(histograph\)\/\(.*\)\<\/text/\>\<a xlink:href="https:\/\/github.com\/\1\/\2"\>\1\/\2<\/a\><\/text/g' > _includes/architecture.svg
