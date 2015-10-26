#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=assets\AlarmOnACDisconnect.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <FontConstants.au3>
#include <TrayConstants.au3>
#include <StaticConstants.au3>
#include <WinAPISys.au3>
#include <WinAPI.au3>
#include <Sound.au3>
#include <_AudioEndpointVolume.au3>

If $CmdLine[0] = 1 Then
	If $CmdLine[1] = "Exit" Then
		ProcessClose("AlarmOnACDisconnect.exe")
	Else
		MsgBox($MB_SYSTEMMODAL, "Error", "Incorrect argument: " & $CmdLine[1])
	EndIf

	Exit
Endif

Const $maxVolume = 100	; from 0 to 100
Const $intervalCheckingTime = 500	; milliseconds
Const $alarmSoundFile = "assets/alarm.mp3"
Const $disarmSoundFile = "assets/disarm.mp3"
Const $sTrayIcon = "assets/AlarmOnACDisconnect.ico"

Global $gui, $iWidth, $iHeight, $msgCtrlID
Global $isActive=False, $isArmed=False, $isBlinkOn=False
Global $alarmSound, $alarmSoundLength=Null
Global $preVolume = _GetMasterVolumeLevelScalar()

DrawGui()
AdlibRegister("CheckAlarm", $intervalCheckingTime)
TrayMenu()

Func CheckAlarm()
	Local $ACPowerStatus = GetACPowerStatus()

	If $isActive Then
		If $ACPowerStatus="Online" Then
			Pause()	; Pause the alarm if AC power is reconnected
			GUICtrlSetData($msgCtrlID, "Armed")
		Else
			SetMaximumVolume()
			Return
		EndIf
	EndIf

	If $isArmed=False And $ACPowerStatus="Online" Then
		$isArmed=True
		GUICtrlSetData($msgCtrlID, "Armed")
	ElseIf $isArmed=True And $ACPowerStatus="Offline" Then
		Alarm()
	EndIf
EndFunc

Func Alarm()
	$isActive = True
	GUICtrlSetData($msgCtrlID, "> !!! ALARM !!! <")
	AdlibRegister("BlinkWindow", 500)

	$alarmSound = OpenASound(@WorkingDir & "\" & $alarmSoundFile)
	$alarmSoundLength = _SoundLength($alarmSound, 2)
	If $alarmSoundLength > 0 Then
		SoundAlarm()
		AdlibRegister("SoundAlarm", $alarmSoundLength)
	Endif
EndFunc

Func Pause()
	$isActive = False
	StopSoundAlarm()
	StopBlinkWindow()
	ResetVolume()
EndFunc

Func BlinkWindow()
	Local $guiBgColor, $msgCtrlColor

	If $isBlinkOn Then
		$guiBgColor = "0x000000"
		$msgCtrlColor = "0xFF0000"
	Else
		$guiBgColor = "0x000000"
		$msgCtrlColor = "0x000000"
	EndIf

	$isBlinkOn = Not $isBlinkOn

	GuiSetBkColor($guiBgColor)
	GUICtrlSetColor($msgCtrlID, $msgCtrlColor)
EndFunc

Func StopBlinkWindow()
	AdlibUnRegister("BlinkWindow")
	$isBlinkOn = False
	GuiSetBkColor("0x000000")
	GUICtrlSetColor($msgCtrlID, "0xFF0000")
EndFunc

Func OpenASound($filename)
	$aSound = _SoundOpen($filename)
	If @error = 2 Then
		MsgBox($MB_SYSTEMMODAL, "Error", "The file does not exist" & $filename)
		Exit
	ElseIf @extended <> 0 Then
		Local $iExtended = @extended ; Assign because @extended will be set after DllStructCreate().
		Local $tText = DllStructCreate("char[128]")
		DllCall("winmm.dll", "short", "mciGetErrorStringA", "str", $iExtended, "struct*", $tText, "int", 128)
		MsgBox($MB_SYSTEMMODAL, "Error", "The open failed." & @CRLF & "Error Number: " & $iExtended & @CRLF & "Error Description: " & DllStructGetData($tText, 1) & @CRLF & "Please Note: The sound may still play correctly.")
	EndIf

	Return $aSound
EndFunc

Func SoundALarm()
	_SoundPlay($alarmSound)
EndFunc

Func StopSoundAlarm()
	AdlibUnRegister("SoundAlarm")
	_SoundStop($alarmSound)
	_SoundClose($alarmSound)
EndFunc

Func SetMaximumVolume()
	Send("{VOLUME_UP}")	; Send VOLUME_UP key to prevent user from muting the speaker
	_SetMasterVolumeLevelScalar(100)
EndFunc

Func ResetVolume()
	_SetMasterVolumeLevelScalar($preVolume)
EndFunc

Func DisarmAndExit()
	StopSoundAlarm()
	StopBlinkWindow()
	AdlibUnRegister("CheckAlarm")
	ResetVolume()
	Exit
EndFunc

Func GetACPowerStatus()
	Local $status
	Local $aData = _WinAPI_GetSystemPowerStatus()
	If @error Then Return
	Switch $aData[0]
		Case 0
			$status = "Offline"
		Case 1
			$status = "Online"
		Case Else
			$status = 'Unknown'
	EndSwitch
	Return $status
EndFunc

Func DrawGui()
	Local $tRECT = _WinAPI_GetWorkArea()
	Local $X = DllStructGetData($tRECT, 'Left')
	Local $Y = DllStructGetData($tRECT, 'Top')
	$iWidth = DllStructGetData($tRECT, 'Right') - $X
	$iHeight = DllStructGetData($tRECT, 'Bottom') - $Y

	$gui = GuiCreate("", $iWidth, $iHeight, $X, $Y, $WS_POPUP)
	GuiSetState(@SW_SHOW)
	WinSetOnTop($gui, "", 1)
	GuiSetBkColor("0x000000")
	WinSetTrans($gui, '', 180)

	$msgCtrlID = GUICtrlCreateLabel('AC power: ' &GetACPowerStatus(), -1, $iHeight/2-100, $iWidth, $iHeight, $SS_CENTER)
	GUICtrlSetFont($msgCtrlID, 60, $FW_NORMAL,  $GUI_FONTNORMAL, "Consolas")
	GUICtrlSetColor($msgCtrlID, "0xFF0000")
EndFunc

Func TrayMenu()
	Opt("TrayMenuMode", 3)	; The default tray menu items will not be shown and items are not checked when selected.
	TraySetIcon($sTrayIcon)
    TraySetState($TRAY_ICONSTATE_SHOW)

	Local $idAbout = TrayCreateItem("About")
    TrayCreateItem("") ; Create a separator line.

    Local $idExit = TrayCreateItem("Exit")

    While 1
        Switch TrayGetMsg()
            Case $idAbout
                MsgBox($MB_SYSTEMMODAL, "", "Alarm On AC Disconnect" & @CRLF & @CRLF & _
                        "Version: 0.1.0" & @CRLF & _
                        "Created by Ha Ho <http://www.hoducha.com>")
			Case $idExit
				DisarmAndExit()
                ExitLoop
        EndSwitch
    WEnd
EndFunc