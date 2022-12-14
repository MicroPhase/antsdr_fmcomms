# antsdr_fmcomms
This repo contains the kernel boot file for fmcomms compatible image for antsdr devices.

If you are using vivado 2019.1 you can switch to [tag_2019_r2](https://github.com/MicroPhase/antsdr_fmcomms/tree/2019_r2) for build information.

- Step 1
  
  Download the prebuild image from ADI [Kuiper_2021_r1](https://swdownloads.analog.com/cse/kuiper/image_2022-08-04-ADI-Kuiper-full.zip).
  This is the prebuild image, if you want to build the rootfs from source, you can find information from [adi-kuiper-gen](https://github.com/analogdevicesinc/adi-kuiper-gen).

- Step 2 
  
  Burn the image into a SD card. You can use dd command or win32diskmanager.
  ```bash
  dd if=/path/to/your/kuiper_image.img of=/dev/sdb bs=2M
  ```
  There will be a BOOT partition and rootfs partition once the sd card image is burned into the sd card.

- Step 3
  
  Now you can build the kernel boot files for antsdr devices.
    - Install build requirements
    ```bash
        sudo apt-get install git build-essential fakeroot libncurses5-dev libssl-dev ccache 
        sudo apt-get install dfu-util u-boot-tools device-tree-compiler mtools
        sudo apt-get install bc python cpio zip unzip rsync file wget 
        sudo apt-get install libtinfo5 device-tree-compiler bison flex u-boot-tools
        sudo apt-get purge gcc-arm-linux-gnueabihf
        sudo apt-get remove libfdt-de
    ```

    - Get source code and setup bash
    ```bash
        git clone --recursive https://github.com/MicroPhase/antsdr_fmcomms.git
        export CROSS_COMPILE=arm-linux-gnueabihf- 
        export PATH=$PATH:/opt/Xilinx/Vitis/2021.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin
        export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2021.1/settings64.sh
    ``` 

    - Choose your devices
    We support antsdr_e200 and antsdr_e310 currently, you should decide one to build the boot files.
    ```bash
        export TARGET=antsdre200 #(for antsdr_e200)
    ```    
    or
    ```bash
        export TARGET=antsdre310 #(for antsdr_e310)
    ``` 

    - Build the kernel boot file
    ```bash
        make
    ```     

- Step 4 
  
  now you can copy the **BOOT.bin**, **devicetree.dtb**, **uImage** into the the BOOT partition of SD card.
  Then you can insert the SD card into the slot of the device.

## Related links
[antsdr-fw](https://github.com/MicroPhase/antsdr-fw-patch)
[antsdr_uhd](https://github.com/MicroPhase/antsdr_uhd)