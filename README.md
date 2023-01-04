# antsdr_fmcomms
This repo contains the kernel boot file for fmcomms compatible image for antsdr devices.

- Step 1
  
  Download the prebuild image from ADI [Kuiper_2019_R2](https://swdownloads.analog.com/cse/kuiper/image_2021-07-28-ADI-Kuiper-full.zip).

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
        git clone -b 2019_r2 --recursive https://github.com/MicroPhase/antsdr_fmcomms.git
        export CROSS_COMPILE=arm-linux-gnueabihf- 
        export PATH=$PATH:/opt/Xilinx/SDK/2019.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin 
        export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2019.1/settings64.sh
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
  
  now you can copy the BOOT.bin, devicetree.dtb, uImage into the the BOOT partition of SD card.
  Then you can insert the SD card into the slot of the device.


