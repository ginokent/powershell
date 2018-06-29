@setlocal enableextensions enabledelayedexpansion & set "PATH0=%~f0" & PowerShell.exe -Command "& (Invoke-Expression -Command ('{#' + ((Get-Content '!PATH0:'=''!') -join \"`n\") + '}'))" %* & exit /b !errorlevel!
# 
#   install-virtualbox-5.2.12.bat
#


################
# const
################
Set-Variable -Option constant -name REQUIRED_CPU_ARCHITECTURE -value 'amd64'
Set-Variable -Option constant -name VIRTUALBOX_EXE_PATH       -value 'C:\Program Files\Oracle\VirtualBox\VirtualBox.exe'
Set-Variable -Option constant -name TMP_DIR                   -value "${env:TMP}\InstallVirtualBox.tmp"
Set-Variable -Option constant -name VIRTUALBOX_INSTALLER_URL  -value "http://download.virtualbox.org/virtualbox/5.2.12/VirtualBox-5.2.12-122591-Win.exe"
Set-Variable -Option constant -name WARNING_DISPLAY_TIME      -value 5


################
# variables
################
${virtualbox_archived_installer_exe} = "${TMP_DIR}\$(Split-Path -Leaf ${VIRTUALBOX_INSTALLER_URL})"
${virtualbox_installer_tmp_file} = "${virtualbox_archived_installer_exe}.tmp"

################
# main
################
if (-Not(Test-Path -Path ${TMP_DIR})) {
    mkdir ${TMP_DIR}
}

# Check Administrator
if (-Not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: Run as Administrator."
    Start-Sleep ${WARNING_DISPLAY_TIME} ; exit 1
}

# Check PROCESSOR_ARCHITECTURE
if ("${env:PROCESSOR_ARCHITECTURE}" -ine ${REQUIRED_CPU_ARCHITECTURE})
{
    Write-Warning "$(Get-Date -Format yyyy-MM-ddTHH:mm:sszzz) [ERROR]: `${env:PROCESSOR_ARCHITECTURE}: ${env:PROCESSOR_ARCHITECTURE}"
    Start-Sleep ${WARNING_DISPLAY_TIME} ; exit 1
}

# Download Installer
if (-Not(Test-Path -Path ${virtualbox_archived_installer_exe}))
{
    Invoke-RestMethod -Uri ${VIRTUALBOX_INSTALLER_URL} -OutFile ${virtualbox_installer_tmp_file}
    Move-Item ${virtualbox_installer_tmp_file} ${virtualbox_archived_installer_exe}
}

# Install VirtualBox
if (-Not(Test-Path -Path "${VIRTUALBOXEXE}"))
{
    # Extract package
    Start-Process -FilePath ${virtualbox_archived_installer_exe} -Args "--silent --extract --path ${TMP_DIR}" -PassThru -Wait
    # msiexec.exe: Windows *.msi Package install manager
    [System.String] ${virtualbox_installer_msi} = Resolve-Path "${TMP_DIR}\VirtualBox-*${REQUIRED_CPU_ARCHITECTURE}.msi"
    Start-Process -FilePath msiexec.exe -Args "/i ${virtualbox_installer_msi} /quiet" -PassThru -Wait
    Remove-Item -Recurse ${TMP_DIR}
}

# Start VirtualBox
Start-Process -FilePath "${VIRTUALBOXEXE}" -PassThru

