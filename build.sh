#!/bin/sh

 # Copyright � 2016,  Sultan Qasim Khan <sultanqasim@gmail.com> 		      
 # Copyright � 2016,  Varun Chitre  <varun.chitre15@gmail.com>	
 # Edited by axxx007xxxz
 #
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it

BUILD_START=$(date +"%s")
nocol='\033[0m'
blue='\033[0;34m'
brown='\033[0;33m'
cyan='\033[0;36m'
green='\033[0;32m'
lightblue='\033[1;34m'
red='\033[0;31m'
echo "${blue}Setting up${nocol}"
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=$(xdg-user-dir)/tools/ubertc-arm-eabi-4.9/bin/arm-eabi-
export KBUILD_BUILD_USER="axxx007xxxz"
export KBUILD_BUILD_HOST="peppermint"
kernelname="Test"
kernelversion="1"
echo
echo "${blue}Cleaning${nocol}"
make clean
rm -f arch/arm/boot/dts/*.dtb
rm -f arch/arm/boot/dt.img
rm -fr tmp
mkdir tmp
rm -f flash/tools/zImage
rm -f flash/tools/dt.img
rm -fr flash/system/*
rm -f ${kernelname}_v${kernelversion}.zip
echo
echo
echo "${lightblue}Compiling ${kernelname} Kernel${nocol}"
echo
echo "${blue}Initializing defconfig${nocol}"
make test-lux_defconfig
echo
echo "${blue}Building kernel${nocol}"
make -j4 zImage
make -j4 dtbs
tools/dtbToolCM -o arch/arm/boot/dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/dts/
echo
echo "${blue}Building modules${nocol}"
make -j4 modules
echo
echo "${blue}Making flashable zip${nocol}"
mkdir tmp/modules
make -j4 modules_install INSTALL_MOD_PATH=tmp/modules INSTALL_MOD_STRIP=1
mkdir -p tmp/flash/system/lib/modules/pronto
find tmp/modules -name '*.ko' -type f -exec cp '{}' tmp/flash/system/lib/modules/ \;
mv tmp/flash/system/lib/modules/wlan.ko tmp/flash/system/lib/modules/pronto/pronto_wlan.ko
mkdir tmp/flash/tools
mv arch/arm/boot/zImage tmp/flash/tools/
mv arch/arm/boot/dt.img tmp/flash/tools/
cp tmp/flash/tools/* flash/tools/
cp -r tmp/flash/system/* flash/system/
cd flash/
zip -qr ../${kernelname}_v${kernelversion}.zip * -x .gitignore
cd ../
echo
echo
echo
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo "$(tput bold)${cyan}Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds!${nocol}$(tput sgr0)"
