#!/bin/sh
## http://tinsuke.wordpress.com/2011/02/17/how-to-cross-compiling-libraries-for-ios-armv6armv7i386/

#
# Global Settings
#

#IOS_BASE_SDK="6.1"
#IOS_DEPLOY_TGT="5.0"

IOS_BASE_SDK="7.0"
IOS_DEPLOY_TGT="6.1"

# For now we want to point at our preview
#export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export DEVELOPER_DIR="/Applications/Xcode5-DP6.app/Contents/Developer"

#
# Shared Functions
#

unsetenv()
{
	unset DEVROOT SDKROOT CFLAGS MYCFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS MYCPPFLAGS CXXFLAGS CXXFLAGS
}

setenv_all()
{
        
        #export CPP="$DEVROOT/usr/bin/llvm-gcc-4.2 -E $CPPFLAGS"
        #export CXX="$DEVROOT/usr/bin/llvm-g++-4.2"
        #export CXXCPP="$DEVROOT/usr/bin/llvm-cpp-4.2"
        #export CC="$DEVROOT/usr/bin/llvm-gcc-4.2"

        export CPP="$DEVELOPER_DIR/usr/bin/gcc -E $CPPFLAGS"
        export CXX="$DEVELOPER_DIR/usr/bin/g++"
        export CXXCPP="$DEVELOPER_DIR/usr/bin/g++"
        export CC="$DEVELOPER_DIR/usr/bin/gcc"
        export LD=$DEVROOT/usr/bin/ld
        export AR=$DEVROOT/usr/bin/ar
        export AS=$DEVROOT/usr/bin/as
        export NM=$DEVROOT/usr/bin/nm
        export RANLIB=$DEVROOT/usr/bin/ranlib
        export LDFLAGS="-L$SDKROOT/usr/lib/"
 
 	export MYCFLAGS=$CFLAGS
 	export MYCPPFLAGS=$CFLAGS
 	export MYCXXFLAGS=$CFLAGS
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS=$CFLAGS
        
}
 
setenv_arm7()
{
        unsetenv
 
        #export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
        export DEVROOT=/Applications/Xcode5-DP6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
        export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
 
        export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
 
        setenv_all
}

setenv_arm7s()
{
        unsetenv
 
        #export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
        export DEVROOT=/Applications/Xcode5-DP6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
        export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
 
        export CFLAGS="-arch armv7s -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
 
        setenv_all
}
 
setenv_i386()
{
        unsetenv
 
        #export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
        export DEVROOT=/Applications/Xcode5-DP6.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
        export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk
 
        export CFLAGS="-arch i386 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"
 
        setenv_all
        export LD=$DEVELOPER_DIR/usr/bin/ld
        export AR=/Applications/Xcode5-DP6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/ar
        export AS=$DEVELOPER_DIR/usr/bin/as
        export NM=$DEVELOPER_DIR/usr/bin/nm
        export RANLIB=$DEVELOPER_DIR/usr/bin/ranlib
}


#
# iOS
#

unset OUTDIR
OUTDIR="`pwd`/ejdb"

pushd ../vendor/ejdb/tcejdb

rm -rf $OUTDIR/build
mkdir $OUTDIR/build

# armv7
rm -rf $OUTDIR/build/armv7
mkdir $OUTDIR/build/armv7
make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm7
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=$OUTDIR/build/armv7
make
make install

# armv7s
rm -rf $OUTDIR/build/armv7s
mkdir $OUTDIR/build/armv7s
make clean 2> /dev/null
make distclean 2> /dev/null
setenv_arm7s
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=$OUTDIR/build/armv7s
make
make install

# i386
rm -rf $OUTDIR/build/i386
mkdir $OUTDIR/build/i386
make clean 2> /dev/null
make distclean 2> /dev/null
setenv_i386
./configure --enable-shared=no --prefix=$OUTDIR/build/i386
make
make install

popd

pushd ejdb

# Copy includes and man pages
cp -r $OUTDIR/build/armv7/* .

# Fat Binary
rm -rf $OUTDIR/lib/libtcejdb.a
xcrun -sdk iphoneos lipo -arch armv7 $OUTDIR/build/armv7/lib/libtcejdb.a -arch armv7s $OUTDIR/build/armv7s/lib/libtcejdb.a -arch i386 $OUTDIR/build/i386/lib/libtcejdb.a -create -output $OUTDIR/lib/libtcejdb.a

popd
