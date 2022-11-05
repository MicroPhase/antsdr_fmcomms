VIVADO_VERSION ?= 2019.1
CROSS_COMPILE ?= arm-linux-gnueabihf-

HAVE_CROSS=$(shell which $(CROSS_COMPILE)gcc | wc -l)
ifeq (0, ${HAVE_CROSS})
$(warning *** can not find $(CROSS_COMPILE)gcc in PATH)
$(error please update PATH)
endif

#gives us path/bin/arm-linux-gnueabihf-gcc
TOOLCHAIN = $(shell which $(CROSS_COMPILE)gcc)
#gives us path/bin
TOOLCHAIN2 = $(shell dirname $(TOOLCHAIN))
#gives us path we need
TOOLCHAIN_PATH = $(shell dirname $(TOOLCHAIN2))


NCORES = $(shell grep -c ^processor /proc/cpuinfo)
VIVADO_SETTINGS ?= /opt/Xilinx/Vivado/$(VIVADO_VERSION)/settings64.sh
VSUBDIRS = hdl buildroot linux u-boot

VERSION=$(shell git describe --abbrev=4 --dirty --always --tags)
LATEST_TAG=$(shell git describe --abbrev=0 --tags)
UBOOT_VERSION=$(shell echo -n "ANTSDR " && cd u-boot && git describe --abbrev=0 --dirty --always --tags)
HAVE_VIVADO= $(shell bash -c "source $(VIVADO_SETTINGS) > /dev/null 2>&1 && vivado -version > /dev/null 2>&1 && echo 1 || echo 0")

ifeq (1, ${HAVE_VIVADO})
	VIVADO_INSTALL= $(shell bash -c "source $(VIVADO_SETTINGS) > /dev/null 2>&1 && vivado -version | head -1 | awk '{print $2}'")
	ifeq (, $(findstring $(VIVADO_VERSION), $(VIVADO_INSTALL)))
$(warning *** This repository has only been tested with $(VIVADO_VERSION),)
$(warning *** and you have $(VIVADO_INSTALL))
$(warning *** Please 1] set the path to Vivado $(VIVADO_VERSION) OR)
$(warning ***        2] remove $(VIVADO_INSTALL) from the path OR)
$(error "      3] export VIVADO_VERSION=v20xx.x")
	endif
endif

TARGET ?= ant
SUPPORTED_TARGETS:=pluto sidekiqz2 ant antsdre200

all : build	build/uImage build/devicetree.dtb build/BOOT.bin

build:
	mkdir -p $@

%: build/%
	cp $< $@

.PHONY: build

### u-boot ###

u-boot/u-boot u-boot/tools/mkimage:
	make -C u-boot ARCH=arm zynq_$(TARGET)_defconfig
	make -C u-boot ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) UBOOTVERSION="$(UBOOT_VERSION)"


.PHONY: u-boot/u-boot

build/u-boot.elf: u-boot/u-boot | build
	cp $< $@


### Linux ###

linux/arch/arm/boot/uImage:
	make -C linux ARCH=arm zynq_$(TARGET)_defconfig
	make -C linux -j $(NCORES) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) uImage UIMAGE_LOADADDR=0x8000

.PHONY: linux/arch/arm/boot/uImage


build/uImage: linux/arch/arm/boot/uImage  | build
	cp $< $@

### Device Tree ###
linux/arch/arm/boot/dts/%.dtb: linux/arch/arm/boot/dts/%.dts  linux/arch/arm/boot/dts/zynq-$(TARGET).dtsi
	make -C linux -j $(NCORES) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) $(notdir $@)


build/devicetree.dtb: linux/arch/arm/boot/dts/zynq-$(TARGET).dtb | build
	cp $< $@


build/system_top.hdf:  | build

	bash -c "source $(VIVADO_SETTINGS) && make -C hdl/projects/$(TARGET) && cp hdl/projects/$(TARGET)/$(TARGET).sdk/system_top.hdf $@"
	unzip -l $@ | grep -q ps7_init || cp hdl/projects/$(TARGET)/$(TARGET).srcs/sources_1/bd/system/ip/system_sys_ps7_0/ps7_init* build/

### TODO: Build system_top.hdf from src if dl fails - need 2016.2 for that ...

build/sdk/fsbl/Release/fsbl.elf build/sdk/hw_0/system_top.bit : build/system_top.hdf
	rm -Rf build/sdk
ifeq (1, ${HAVE_VIVADO})
	bash -c "source $(VIVADO_SETTINGS) && xsdk -batch -source scripts/create_fsbl_project.tcl"
else
	mkdir -p build/sdk/hw_0
	unzip -o build/system_top.hdf system_top.bit -d build/sdk/hw_0
endif

build/system_top.bit: build/sdk/hw_0/system_top.bit
	cp $< $@

build/BOOT.bin: build/sdk/fsbl/Release/fsbl.elf build/system_top.bit build/u-boot.elf
	@echo img:{[bootloader] $^ } > build/boot.bif
	bash -c "source $(VIVADO_SETTINGS) && bootgen -image build/boot.bif -w -o $@"

clean-build:
	rm -f $(notdir $(wildcard build/*))
	rm -rf build/*

clean:
	make -C u-boot clean
	make -C linux clean
	make -C hdl clean
	rm -f $(notdir $(wildcard build/*))
	rm -rf build/*

git-update-all:
	git submodule update --recursive --remote

git-pull:
	git pull --recurse-submodules

