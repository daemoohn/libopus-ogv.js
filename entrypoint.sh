#!/bin/bash

## getting the source code
git clone https://gitlab.xiph.org/xiph/opus.git

## get version tag
cd opus
version=`git describe --tags`
cd ..

## verify if this specific version has already been uploaded to bintray
bintray_response=`curl -u$1:$2 https://api.bintray.com/packages/daemoohn/libopus-ogv.js/libopus-ogv.js/versions/$version`
if [[ $bintray_response != *"Version '$version' was not found"* ]]; then
  echo "libopus version $version is already present on bintray!"
  exit 1
fi

## configureOpus.sh
cd opus
if [ ! -f configure ]; then
  # generate configuration script
  # disable running configure automatically
  sed -i.bak 's/$srcdir\/configure/#/' autogen.sh
  ./autogen.sh
  
  # disable oggxpack_writealign test
  sed -i.bak 's/$ac_cv_func_oggpack_writealign/yes/' configure
fi
cd ..

## compileOpusJs.sh
dir=`pwd`

# set up the build directory
mkdir -p build
cd build

mkdir -p js
cd js

mkdir -p root
mkdir -p libopus
cd libopus

# finally, run configuration script
emconfigure ../../../opus/configure \
  --disable-asm \
  --disable-intrinsics \
  --disable-doc \
  --disable-extra-programs \
  --prefix="$dir/build/js/root" \
  --disable-shared \
  CFLAGS="-O3" || exit 1

# compile libopus
emmake make -j4 || exit 1
emmake make install || exit 1

cd $dir/build/js/root

## upload to bintray
zip -r $dir/libopus-ogv.js.zip . 
curl -T $dir/libopus-ogv.js.zip -u$1:$2 https://api.bintray.com/content/daemoohn/libopus-ogv.js/libopus-ogv.js/$version/libopus-ogv.js.zip?publish=1
