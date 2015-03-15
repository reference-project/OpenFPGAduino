export HOST:=arm-none-linux-gnueabi
export CPP:="$(HOST)-gcc -E" 
export STRIP:="$(HOST)-strip" 
export OBJCOPY:="$(HOST)-objcopy" 
export AR:="$(HOST)-ar" 
export RANLIB:="$(HOST)-ranlib" 
export LD:="$(HOST)-ld" 
export OBJDUMP:="$(HOST)-objdump" 
export CC:="$(HOST)-gcc" 
export CXX:="$(HOST)-g++" 
export NM:="$(HOST)-nm" 
export AS:="$(HOST)-as"
all:build image
build:
	echo "Build submodule linux";     	
	cd linux; make zImage; cd ..;
	@for module in `ls -l | grep ^d | awk '{ print $$NF }' | sed 's/linux//g'`; do \
	echo "Build submodule "$$module;                                               \
	cd $$module; make; cd .. ;                                                     \
	done
clean:
	@for module in `ls -l | grep ^d | awk '{ print $$NF }'`; do                    \
	echo "Build submodule "$$module;                                               \
	cd $$module; make clean ; cd .. ;                                              \
	done

image:
	#boot partition
	cp -rpf boot/boot.bin sdcard/boot/
	cp -rpf boot/kcmd.txt sdcard/boot/
	cp -rpf linux/arch/arm/boot/zImage sdcard/boot/
	cp -rpf fpga/output/grid.rbf sdcard/boot/
	#linux partition
	cd linux; sudo make INSTALL_MOD_PATH=../rootfs/fs modules_install; cd ..;
	sudo cp -rpf driver/openfpgaduino.ko rootfs/fs/home/
	sudo cp -rpf node/node rootfs/fs/bin/
	sudo cp -rpf ArduinoIDE rootfs/fs/home/
	sudo cp -rpf libAduino/lib/libaduino.a rootfs/fs/home/ArduinoIDE/api/
	sudo cp -rpf libAduino/lib/openfpgaduino.h rootfs/fs/home/ArduinoIDE/api/
	sudo cp -rpf Arduinojs/build/Release/openfpgaduino.node rootfs/fs/home/ArduinoIDE/
	sudo cp -rpf docs/_book rootfs/fs/home/ArduinoIDE/docs
	sudo cp -rpf rootfs/fs/ sdcard/os/
