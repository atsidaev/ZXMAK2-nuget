#!/bin/bash

REPO_URL=https://github.com/ZXMAK/ZXMAK2
BUILD_DIR=.build

CPU=ZXMAK2.Engine.Cpu
CPU_DIR=$BUILD_DIR/src/$CPU

# Remove old .NET 4.0 files since we switch to .NET Standard
prepare_directory()
{
	rm $1/*.csproj
	rm -rf $1/Properties
}

if [ ! -d $BUILD_DIR ]; then
	git clone $REPO_URL $BUILD_DIR
else
	(cd $BUILD_DIR; git checkout -f; git clean -dfx; git pull origin)
fi


# Build ZXMAK2.Z80Cpu

rm $BUILD_DIR/src/ZXVM.sln
prepare_directory $CPU_DIR
cp $CPU.* $CPU_DIR
 
(cd $CPU_DIR; dotnet build . -c Release; nuget pack $CPU.nuspec) || true


# Build ZXMAK2.Engine

ENGINE=ZXMAK2.Engine
ENGINE_PROJECTS="ZXMAK2.Engine ZXMAK2.Dependency ZXMAK2.Crc ZXMAK2.Host ZXMAK2.Logging ZXMAK2.Model.Disk ZXMAK2.Model.Tape ZXMAK2.Mvvm ZXMAK2.Resources"
ENGINE_BUILD_DIR=$BUILD_DIR/.engine

if [ ! -d $ENGINE_BUILD_DIR ]; then
  mkdir $ENGINE_BUILD_DIR
fi

cp $ENGINE.csproj $ENGINE_BUILD_DIR
cp $ENGINE.nuspec $ENGINE_BUILD_DIR

# Include TimingTool.cs, which we ignored in CPU build
cp $CPU_DIR/Tools/TimingTool.cs $ENGINE_BUILD_DIR

for proj in $ENGINE_PROJECTS
do
  prepare_directory $BUILD_DIR/src/$proj
  mv $BUILD_DIR/src/$proj $ENGINE_BUILD_DIR
done

# Apply patch for "using" directives
(cd $ENGINE_BUILD_DIR; patch -p1 -i ../../$ENGINE.patch)

(cd $ENGINE_BUILD_DIR; dotnet build . -c Release; nuget pack $ENGINE.nuspec)
