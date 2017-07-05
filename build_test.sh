#!/bin/bash
Cur_Dir=$(pwd)
LIB=libs
ZIP=faceSize
target_name=faceSizeForiOS
RESOURCE=resource.bundle
resource_path=/Volumes/data/glassplus/common
IOS_OUT_PATH=$HOME/build/master/out/ios

mkdir $LIB
mkdir $RESOURCE

PROJECT_P=$IOS_OUT_PATH/iOSFaceSizeSample
mkdir $PROJECT_P


#TFaceSDK Trail
cd $Cur_Dir

rm -rf ./libs

mkdir $LIB

cp -rf $resource_path/faceSize/IDCard.png $RESOURCE

cp -rf $resource_path/watermask/origin/watermark.png $RESOURCE

cp -rf $IOS_OUT_PATH/iOSFaceSizeSDK/TRIAL/lib/libfaceSizeForiOS_SDK.a $LIB

cp -rf $IOS_OUT_PATH/iOSFaceSizeSDK/TRIAL/export/* $LIB

xcodebuild -project faceSizeForiOS.xcodeproj -target $target_name

if [ -d ./ipa-build ];then
rm -rf ipa-build
fi

cd ./build
PROJECT_PATH=$PROJECT_P/TRIAL
mkdir $PROJECT_PATH

mkdir -p ipa-build/Payload
cp -r ./Release-iphoneos/*.app ./ipa-build/Payload/
cd ipa-build
zip -r $ZIP.ipa *
mv $ZIP.ipa iOSFaceSizeSample.ipa
cp -f iOSFaceSizeSample.ipa $PROJECT_PATH

cd $Cur_Dir
rm -rf ./Build
#rm -rf ./build.sh
rm -rf ./$ZIP
zip -r $ZIP.zip *
cp -f $ZIP.zip $PROJECT_PATH

rm -rf ./$ZIP.zip


###########################################
cp -rf $IOS_OUT_PATH/iOSFaceSizeSample $IOS_DROP_PATH/
cp -rf $IOS_LOG_PATH/iOSFaceSizeSample.log $IOS_LOG_DROP_PATH
###########################################
