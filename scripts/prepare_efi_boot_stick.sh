#!/bin/bash
#title           :prepare_efi_boot_stick.sh
#description     :This script will create the folder structure for and download a UEFI shell
#                 in the path of your choosing.
#author          :rapha
#date            :20220913
#version         :0.1
#usage           :bash prepare_efi_boot_stick.sh

if ! command -v wget &> /dev/null
then
    echo "This script depends on 'wget', but it does not seem to be installed. Exiting..."
    exit
fi

echo -e "This script downloads a UEFI shell from the https://github.com/tianocore/edk2 project"
echo -e "and create the proper directory structure in the path of your choosing."
echo -e "This is useful if there is no built-in UEFI shell (e.g. for security reasons) included"
echo -e "in the BIOS and a instead a USB stick with a UEFI shell to boot from needs to be prepared.\n"
echo -e "Please enter the root path of the USB stick or any folder to put the UEFI folders and shell.\n"
read -p "Path [/tmp]:" path
path=${path:-/tmp}

echo -e "\nThis will create the following files and folder structure:"
echo -e " $path/efi/"
echo -e " └── boot"
echo -e "     ├── bootia32.efi"
echo -e "     └── BOOTX64.efi"
echo -e "Any existing folders and files with the same name will be overwritten.\n"

while true; do
read -p "Do you want to proceed? (y/n) " yn
case $yn in
        [yY] ) break;;
        [nN] ) echo Exiting...;
                exit;;
        * ) echo Invalid response;;
esac
done

echo -e "\nCreating folder structure in $path and downloading UEFI shell into it..."
echo -e "Any existing folders and files with the same name will be overwritten\n\n"

mkdir -p $path/efi/boot
cd $path/efi/boot
wget -O BOOTX64.efi https://github.com/tianocore/edk2/raw/UDK2018/ShellBinPkg/UefiShell/X64/Shell.efi
wget -O bootia32.efi https://github.com/tianocore/edk2/raw/UDK2018/ShellBinPkg/UefiShell/Ia32/Shell.efi

echo -e "\n\nFolder structure with UEFI shell in $path was created successfully.\n"
echo -e "If you did not enter the path to the root folder of the USB stick, please"
echo -e "move the \"efi\" folder to the root of the USB stick. Afterwards you should"
echo -e "be able to boot into the UEFI shell on the USB stick.\n"
echo -e "Next include any other files like BIOS updates in the USB stick, attach the"
echo -e "USB stick to a system running UEFI enabled BIOS and boot into the USB stick."
