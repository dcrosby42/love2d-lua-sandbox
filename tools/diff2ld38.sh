#!/bin/bash
pushd `dirname ${BASH_SOURCE[0]}` > /dev/null; HERE=`pwd`; popd > /dev/null
cd $HERE

cat2d=$HERE/../cat2d.love
ld38=$HERE/../../shawn42_ld38/smallworld.love/

diff -r $cat2d/ecs $ld38/ecs
diff $cat2d/helpers.lua $ld38/helpers.lua
