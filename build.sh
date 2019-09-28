#!/bin/bash

REPO_URL=https://github.com/ZXMAK/ZXMAK2
BUILD_DIR=.build

CPU=ZXMAK2.Engine.Cpu
CPU_DIR=$BUILD_DIR/src/$CPU

if [ ! -d $BUILD_DIR ]; then
	git clone $REPO_URL $BUILD_DIR
else
	(cd $BUILD_DIR; git checkout -f; git clean -dfx; git pull origin)
fi

rm $BUILD_DIR/src/ZXVM.sln
rm $CPU_DIR/*.csproj
rm -rf $CPU_DIR/Properties
cp $CPU.* $CPU_DIR

(cd $CPU_DIR; dotnet build . -c Release; nuget pack $CPU.nuspec)
