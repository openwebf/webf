runexample(){
    ret=$PWD
    cd webf/example && flutter run --release
    cd $ret
}
runexampled(){
    ret=$PWD
    cd webf/example && flutter run
    cd $ret
}
build-linux(){
    npm run build:bridge:linux:release
    cp -f bridge/cmake-build-linux/compile_commands.json .
}
build-linuxd(){
    npm run build:bridge:linux && 
    cp -f bridge/cmake-build-linux/compile_commands.json .
}
echo To initialize the build, using build-linux or build-linuxd:
echo then use runexample for release build, or runexample for debug build

