; InstallCreatorScript.nsi
;
; This script is used to create the installer using NSIS (Nullsoft Scriptable Install System)
; See more: http://nsis.sourceforge.net/Main_Page

;--------------------------------

!include "MUI2.nsh"

!define MUI_ICON "assets\AlarmOnACDisconnect.ico"

;--------------------------------

; The name of the installer
Name "AlarmOnACDisconnect"

; The file to write
OutFile "AlarmOnACDisconnect_Setup.exe"

; The default installation directory
InstallDir $PROGRAMFILES\AlarmOnACDisconnect

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\AlarmOnACDisconnect" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "AlarmOnACDisconnect (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File "AlarmOnACDisconnect.exe"
  File /r "assets"
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\AlarmOnACDisconnect "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AlarmOnACDisconnect" "DisplayName" "Alarm On AC Disconnect"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AlarmOnACDisconnect" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AlarmOnACDisconnect" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AlarmOnACDisconnect" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\AlarmOnACDisconnect"
  CreateShortcut "$SMPROGRAMS\AlarmOnACDisconnect\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortcut "$SMPROGRAMS\AlarmOnACDisconnect\AlarmOnACDisconnect.lnk" "$INSTDIR\AlarmOnACDisconnect.exe" "" "$INSTDIR\AlarmOnACDisconnect.exe" 0
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AlarmOnACDisconnect.exe"
  DeleteRegKey HKLM SOFTWARE\AlarmOnACDisconnect.exe

  ; Remove files and uninstaller
  Delete $INSTDIR\AlarmOnACDisconnect.exe
  RMDir /r $INSTDIR\assets
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\AlarmOnACDisconnect\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\AlarmOnACDisconnect"
  RMDir "$INSTDIR"

SectionEnd
