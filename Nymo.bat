@echo off
title NYMO - Advanced USB Bootable Tool v4.0
setlocal enabledelayedexpansion

:: --- SETUP COLOR (0A = Green Text) ---
color 0A
mode con: cols=80 lines=40
cls

:: --- NYMO TEXT LOGO ---
echo.
echo      #######################################################
echo      #                                                     #
echo      #     N   N  Y   Y  M   M  OOO                        #
echo      #     NN  N   Y Y   MM MM O   O                       #
echo      #     N N N    Y    M M M O   O                       #
echo      #     N  NN    Y    M   M O   O                       #
echo      #     N   N    Y    M   M  OOO                        #
echo      #                                                     #
echo      #            [ Advanced USB Creator v4 ]              #
echo      #                                                     #
echo      #######################################################
echo.

:: CHECK FOR ADMIN
net session >nul 2>&1
if %errorLevel% neq 0 (
    color 0C
    echo.
    echo  [!] ADMINISTRATOR PRIVILEGES REQUIRED
    echo      Please right-click this file and select
    echo      "Run as Administrator"
    echo.
    pause
    exit
)

:MAIN_MENU
cls
color 0A
echo.
echo      =======================================================
echo      #                    MAIN MENU                        #
echo      =======================================================
echo.
echo      [1] Create Bootable USB
echo      [2] Download ISO Images
echo      [3] System Tools (Check USB / Format)
echo      [4] Exit NYMO
echo.
set /p choice="      Select Option: "

if "%choice%"=="1" goto BOOTABLE_SECTION
if "%choice%"=="2" goto DOWNLOAD_SECTION
if "%choice%"=="3" goto TOOLS_SECTION
if "%choice%"=="4" exit
goto MAIN_MENU

:: =============================================
:: SECTION: SYSTEM TOOLS
:: =============================================
:TOOLS_SECTION
cls
echo.
echo      =======================================================
echo      #                 SYSTEM TOOLS                        #
echo      =======================================================
echo.
echo      [1] Check if USB is Bootable (Verification)
echo      [2] Quick Format USB Drive (Wipe Data)
echo      [3] Back to Main Menu
echo.
set /p tool_choice="      Select Option: "

if "%tool_choice%"=="1" goto CHECK_USB
if "%tool_choice%"=="2" goto FORMAT_USB
if "%tool_choice%"=="3" goto MAIN_MENU
goto TOOLS_SECTION

:CHECK_USB
cls
echo.
echo      [CHECK USB BOOTABILITY]
echo      This will check connected drives for boot files...
echo.
powershell -Command "Get-Disk | Where-Object BusType -eq 'USB' | Format-Table Number, FriendlyName, Size, PartitionStyle -AutoSize"
echo.
echo      Checking for boot managers (GRUB/Windows BootMgr)...
for /f "tokens=2 delims==" %%d in ('wmic logicaldisk where "drivetype=2" get deviceid /value') do (
    if exist "%%d:\bootmgr" echo      [FOUND] Windows Boot Manager on %%d
    if exist "%%d:\EFI\BOOT\BOOTX64.EFI" echo      [FOUND] UEFI Bootloader on %%d
    if exist "%%d:\grub.cfg" echo      [FOUND] Linux GRUB on %%d
)
echo.
pause
goto TOOLS_SECTION

:FORMAT_USB
cls
echo.
echo      [QUICK FORMAT USB]
echo      Listing Disks...
(list disk) | diskpart
echo.
set /p fmt_disk="Enter Disk Number to FORMAT (e.g., 1): "
if "%fmt_disk%"=="0" (
    echo Error: Cannot format System Disk 0.
    pause
    goto TOOLS_SECTION
)
echo.
echo      WARNING: All data on Disk %fmt_disk% will be lost!
set /p fmt_conf="Type 'YES' to confirm: "
if /i not "%fmt_conf%"=="YES" goto TOOLS_SECTION

echo Formatting...
(
echo select disk %fmt_disk%
echo clean
echo create partition primary
echo format fs=exfat quick
echo assign
) | diskpart
echo.
echo      Format Complete.
pause
goto TOOLS_SECTION

:: =============================================
:: SECTION: ISO DOWNLOADER
:: =============================================
:DOWNLOAD_SECTION
cls
echo.
echo      =======================================================
echo      #               ISO DOWNLOADER                        #
echo      =======================================================
echo.
echo      --- WINDOWS CLIENT ---
echo      [1] Windows 11
echo      [2] Windows 10
echo      [3] Windows 7 (Archive)
echo      [4] Windows Vista (Archive)
echo.
echo      --- WINDOWS SERVER ---
echo      [5] Windows Server 2022
echo.
echo      --- LINUX (General) ---
echo      [6] Ubuntu 22.04 LTS
echo      [7] Linux Mint 21.3
echo      [8] Zorin OS 17
echo      [9] Fedora 39
echo.
echo      --- LINUX (Advanced) ---
echo      [10] Kali Linux 2024.1
echo      [11] Pop!_OS 22.04
echo      [12] Manjaro 23.1
echo.
echo      --- SERVER / VIRTUALIZATION ---
echo      [13] Proxmox VE 8.1
echo.
echo      [14] Back to Main Menu
echo.
set /p dl_choice="      Select OS to download: "

set "ISO_URL="
set "ISO_NAME="

:: --- WINDOWS ---
if "%dl_choice%"=="1" (
    set "ISO_URL=https://software-download.microsoft.com/download/pr/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
    set "ISO_NAME=Win11_Enterprise_Eval.iso"
)
if "%dl_choice%"=="2" (
    set "ISO_URL=https://software-download.microsoft.com/download/pr/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
    set "ISO_NAME=Win10_Enterprise_Eval.iso"
)
if "%dl_choice%"=="3" (
    set "ISO_URL=https://archive.org/download/win-7-sp1-iso/Win7_Pro_SP1_English_x64.iso"
    set "ISO_NAME=Win7_Pro_SP1_x64.iso"
)
if "%dl_choice%"=="4" (
    set "ISO_URL=https://archive.org/download/vista-sp2-iso/en_windows_vista_business_with_service_pack_2_x64_dvd_x15-36185.iso"
    set "ISO_NAME=Win_Vista_SP2_x64.iso"
)
if "%dl_choice%"=="5" (
    set "ISO_URL=https://software-download.microsoft.com/download/pr/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
    set "ISO_NAME=Win_Server_2022.iso"
)

:: --- LINUX GENERAL ---
if "%dl_choice%"=="6" (
    set "ISO_URL=https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-desktop-amd64.iso"
    set "ISO_NAME=Ubuntu_22.04.iso"
)
if "%dl_choice%"=="7" (
    set "ISO_URL=https://mirrors.edge.kernel.org/linuxmint/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso"
    set "ISO_NAME=LinuxMint_21.3.iso"
)
if "%dl_choice%"=="8" (
    set "ISO_URL=https://downloads.zorin.com/zorin-17/zorin-os-17-core-64bit.iso"
    set "ISO_NAME=Zorin_OS_17.iso"
)
if "%dl_choice%"=="9" (
    set "ISO_URL=https://download.fedoraproject.org/pub/fedora/linux/releases/39/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-39-1.5.iso"
    set "ISO_NAME=Fedora_39.iso"
)

:: --- LINUX ADVANCED ---
if "%dl_choice%"=="10" (
    set "ISO_URL=https://kali.download/base-images/kali-2024.1/kali-linux-2024.1-installer-amd64.iso"
    set "ISO_NAME=Kali_Linux_2024.1.iso"
)
if "%dl_choice%"=="11" (
    set "ISO_URL=https://dl.pop-os.org/22.04/amd64/intel/22/pop-os_22.04_amd64_intel_6.iso"
    set "ISO_NAME=Pop_OS_22.04.iso"
)
if "%dl_choice%"=="12" (
    set "ISO_URL=https://download.manjaro.org/kde/23.1.3/manjaro-kde-23.1.3-240316-linux66.iso"
    set "ISO_NAME=Manjaro_23.1.iso"
)

:: --- SERVER ---
if "%dl_choice%"=="13" (
    set "ISO_URL=https://enterprise.proxmox.com/iso/proxmox-ve_8.1-2.iso"
    set "ISO_NAME=Proxmox_VE_8.1.iso"
)

if "%dl_choice%"=="14" goto MAIN_MENU

:: Validation
if "%ISO_URL%"=="" (
    echo      Invalid selection.
    timeout /t 2 >nul
    goto DOWNLOAD_SECTION
)

echo.
echo      =======================================================
echo       Starting Download: %ISO_NAME%
echo       Please wait...
echo      =======================================================
echo.

:: PowerShell Download with Progress Bar
powershell -Command "& { $ProgressPreference = 'Continue'; Invoke-WebRequest -Uri '%ISO_URL%' -OutFile '%ISO_NAME%' -UseBasicParsing }"

if exist "%ISO_NAME%" (
    echo.
    echo      [SUCCESS] Downloaded %ISO_NAME%
    echo.
    pause
    goto BOOTABLE_SECTION
) else (
    echo      Download failed.
    pause
    goto DOWNLOAD_SECTION
)

:: =============================================
:: SECTION: BOOTABLE CREATOR
:: =============================================
:BOOTABLE_SECTION
cls
echo.
echo      =======================================================
echo      #            CREATE BOOTABLE USB                     #
echo      =======================================================
echo.

:: Auto-detect ISO
echo      Scanning current folder for ISO files...
echo.
set "iso_count=0"
for %%f in (*.iso) do (
    set /a iso_count+=1
    echo      [!iso_count!] %%f
    set "iso_!iso_count!=%%f"
)

if %iso_count% gtr 0 (
    echo.
    echo      [M] Manual Path Entry
    set /p iso_sel="      Select ISO by number or type M: "
    
    if /i "%iso_sel%"=="M" (
        set /p ISO_FILE="      Drag and Drop your ISO file here: "
    ) else (
        set "ISO_FILE=!iso_%iso_sel%!"
    )
) else (
    echo      No ISO files found.
    set /p ISO_FILE="      Drag and Drop your ISO file here: "
)

set ISO_FILE=%ISO_FILE:"=%

if not exist "%ISO_FILE%" (
    echo      ERROR: File not found.
    pause
    goto MAIN_MENU
)

echo.
echo      Listing disks...
echo      =======================================================
echo       WARNING: DO NOT SELECT DISK 0
echo                Disk 0 is usually your System Drive.
echo      =======================================================
echo.
(
echo list disk
) | diskpart

echo.
set /p DISK_NUM="      Enter the Disk Number of your USB (e.g., 1): "

:: Safety
if "%DISK_NUM%"=="0" (
    echo.
    echo      [!] CRITICAL ERROR: You selected Disk 0.
    echo          Operation cancelled to prevent system damage.
    pause
    goto MAIN_MENU
)

set /p USB_LETTER="      Enter the Drive Letter to assign (e.g., Z): "

echo.
echo      =======================================================
echo       WARNING: ALL DATA ON DISK %DISK_NUM% WILL BE LOST
echo      =======================================================
set /p CONFIRM="      Type 'YES' to proceed: "
if /i not "%CONFIRM%"=="YES" goto MAIN_MENU

echo.
echo      Formatting Drive...
(
echo select disk %DISK_NUM%
echo clean
echo create partition primary
echo active
echo format fs=exfat quick
echo assign letter=%USB_LETTER%
) | diskpart

if %errorlevel% neq 0 (
    echo      Formatting failed.
    pause
    exit
)

echo.
echo      Mounting ISO and Copying Files...
if not exist "C:\MountISO" mkdir "C:\MountISO"
powershell -Command "Mount-DiskImage -ImagePath '%ISO_FILE%'"
timeout /t 5 >nul

set "MOUNT_LETTER="
for /f "skip=1 tokens=2 delims=: " %%a in ('wmic logicaldisk where "drivetype=5" get deviceid') do set "MOUNT_LETTER=%%a:"

if not defined MOUNT_LETTER (
   for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
       if exist "%%d:\sources\install.wim" set "MOUNT_LETTER=%%d:"
       if exist "%%d:\.disk" set "MOUNT_LETTER=%%d:"
   )
)

if not defined MOUNT_LETTER (
    echo      Could not detect mounted ISO drive.
    pause
    goto MAIN_MENU
)

echo      ISO Mounted at: %MOUNT_LETTER%
echo      Copying files to %USB_LETTER%: ...
echo      (This may take a while...)
robocopy "%MOUNT_LETTER%\" "%USB_LETTER%:\" /E /R:0 /W:0 /MT:8

echo.
echo      Unmounting ISO...
powershell -Command "Dismount-DiskImage -ImagePath '%ISO_FILE%'"

echo.
echo      =======================================================
echo       SUCCESS! NYMO Has Finished.
echo      =======================================================
pause