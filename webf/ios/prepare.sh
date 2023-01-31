ROOT=$(pwd)/Frameworks
cd $ROOT

if [ -L "webf_bridge.xcframework" ]; then
  rm webf_bridge.xcframework
  ln -s $ROOT/../../../bridge/build/ios/framework/webf_bridge.xcframework
fi

if [ -L "quickjs.xcframework" ]; then
  rm quickjs.xcframework
  ln -s $ROOT/../../../bridge/build/ios/framework/quickjs.xcframework
fi
