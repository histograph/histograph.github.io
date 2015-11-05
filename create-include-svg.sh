#!/bin/bash

# TODO: font-weight: bold
sed -n '/<svg/,$p' images/architecture.svg | \
sed 's/font-family=/illustrator-font-family=/g' | \
sed 's/\>\(histograph\)\/\(.*\)\<\/text/\>\<a xlink:href="https:\/\/github.com\/\1\/\2"\>\1\/\2<\/a\><\/text/g' > _includes/architecture.svg
