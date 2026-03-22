'*********************************************************************
'1995 Williams DIRTY HARRY
'*********************************************************************
'*********************************************************************
'Pinball Machine designed by Barry Oursler
'*********************************************************************
'*********************************************************************
'recreated for Visual Pinball by Knorr
'*********************************************************************
'*********************************************************************
'I would like to give my sincere thanks to
'Mfuegemann, Freneticamnesic, Toxie and the VPdevs, Clark Kent and
'Gigalula for always being so friendly, helpful and motivating while
'building this table.
'*********************************************************************


'V2.0
'new Ramps (thanks to flupper!)
'added more Gi
'script clean up by JP (thanks for all the help!)
'reworked enviroment


'V1.9
'added primitive to HQ

'V1.8
'New Plastic/WireRamps
'reworked primitives
'Bug Fixes

'V1.7
'Added controller.vbs
'Bug Fixes

'V1.6
'First Release For VP10.0.0
'CrimeWave Gunfix (only 1 Ball can be in the Gun)
'reduced gun model
'reduced warehouse model (again)
'reduced png for smaller file size
'BallSize is now 52

'V1.5
'Fixed Multiball
'Changed Primitves Rampentry Metals

'V1.4
'Added Global Light for Flasher
'Added Plunger Animation
'Cleaned up RightRamp Primitive
'Added Dropwall to Warehouse so only one Ball can be in
'new Slingshot Plastics Primitives and added Walls for Collision

'V1.3
'Updated Ball Rolling/Collision Script
'small changes with primitives

'V1.2
'Fixed CrimeWave Multiball
'Added Global Lightning (thanks for helping Fren)
'Added missing Lights for BumperCap and BankRobber
'added images for ON/OFF effects
'Changed Sound for Plunger

'V1.1
'Reduced meshes in the warehouse model (almost the half)
'improved lightning for environment (thanks to Fren)
'reduced lightning for the inserts
'reduced size of the playfield.jpg and the warehouse
'minor changes with flashers

'V1.0
'First Release For VP10 Beta

Option Explicit
Randomize

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs in order to run this table, available in the vp10 package"
On Error Goto 0

LoadVPM "01560000", "WPC.VBS", 3.36

'********************
'Standard definitions
'********************

Const cGameName = "dh_lx2"
Const UseSolenoids = 1
Const UseLamps = 1
Const SSolenoidOn = "SolOn"
Const SSolenoidOff = "SolOff"
Const SFlipperOn = "FlipperUp"
Const SFlipperOff = "FlipperDown"
Const SCoin = "Coin5"

Set GiCallback2 = GetRef("UpdateGI")
BSize = 25.5

' Standard Sounds
' Const SSolenoidOn = "Solenoid"
' Const SSolenoidOff = ""
' Const SFlipperOn = "FlipperUp"
' Const SFlipperOff = "FlipperDown"
' Const SCoin = "Coin"

Dim bsTrough, BallInGun, bsSafeHouse, LeftPopper, WareHousePopper, GunPopper, RightMagnet

' --- PRE-CACHED TABLE DIMENSIONS (eliminates 2 COM reads per AudioFade/AudioPan call) ---
Dim tablewidth : tablewidth = table1.width
Dim tableheight : tableheight = table1.height

' --- PRE-BUILT SOUND STRINGS (eliminates string concatenation in RollingTimer) ---
Dim RollStr(6), DropStr(6)
Dim iStr
For iStr = 0 To 6
    RollStr(iStr) = "fx_ballrolling" & iStr
    DropStr(iStr) = "fx_ball_drop" & iStr
Next

' --- HOISTED BALLSHADOW ARRAY (initialized in Table1_Init, eliminates per-tick alloc) ---
Dim BallShadow(5)

' --- PREVIOUS-STATE TRACKING FOR GUARDED WRITES ---
Dim lastSw76 : lastSw76 = -1
Dim lastLfsAngle : lastLfsAngle = -999
Dim lastRfsAngle : lastRfsAngle = -999

Set LampCallback = GetRef("UpdateMultipleLamps")
Set MotorCallback = GetRef("RealTimeUpdates")

'************
' Table init.
'************

Sub Table1_Init
    vpmInit Me
    With Controller
        .GameName = cGameName
        If Err Then MsgBox "Can't start Game " & cGameName & vbNewLine & Err.Description:Exit Sub
        .Games(cGameName).Settings.Value("rol") = 0
        .HandleKeyboard = 0
        .ShowTitle = 0
        .ShowDMDOnly = 1
        .ShowFrame = 0
        .HandleMechanics = 0
        .Hidden = 0
        '.SetDisplayPosition 0, 0, GetPlayerHWnd 'uncomment this line if you don't see the DMD
        On Error Resume Next
        .Run GetPlayerHWnd
        If Err Then MsgBox Err.Description
        On Error Goto 0
        .Switch(22) = 1 'close coin door
        .Switch(24) = 1 'and keep it close
        PinMAMETimer.Interval = PinMAMEInterval
        PinMAMETimer.Enabled = true
        vpmNudge.TiltSwitch = 14
        vpmNudge.Sensitivity = 2
    End With

    Set bsTrough = New cvpmBallStack
    With bsTrough
        .InitSw 0, 32, 33, 34, 35, 0, 0, 0
        .InitKick BallRelease, 90, 10
        .InitExitSnd SoundFX("BallRelease", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)
        .Balls = 4
        .IsTrough = 1
    End With

    Set bsSafeHouse = New cvpmBallStack
    bsSafeHouse.InitSaucer sw73, 73, 167, 22
    bsSafeHouse.InitExitSnd SoundFX("SafeHouseKick", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)
    bsSafeHouse.KickForceVar = 2
    bsSafeHouse.KickAngleVar = 0.8

    Set LeftPopper = New cvpmBallStack
    With LeftPopper
        .InitSw 0, 47, 0, 0, 0, 0, 0, 0
        .InitKick sw47, 180, 15
        .InitExitSnd SoundFX("HeadquarterKick", DOFContactors), "fx_Solenoid"
    End With

    Set WarehousePopper = New cvpmBallStack
    With WarehousePopper
        .InitSw 0, 46, 0, 0, 0, 0, 0, 0
        .InitKick sw46, 2, 10
        .KickZ = 1
        .InitExitSnd SoundFX("WareHouseKick", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)
        .KickBalls = 1
    End With

    Set GunPopper = New cvpmBallStack
    With GunPopper
        .InitSw 0, 45, 0, 0, 0, 0, 0, 0
        .InitKick sw45, 105, 7
        .InitExitSnd SoundFX("GunPopper", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)
    End With

    Set RightMagnet = New cvpmMagnet
    With RightMagnet
        .InitMagnet RMagnet, 100
        .Solenoid = 35
        .GrabCenter = 1
        .CreateEvents "RightMagnet"
    End With

    DiverterOn.isDropped = 1
    DiverterOn2.isDropped = 1
    DiverterOff.isDropped = 0
    Warehousedw.isDropped = 1
    ' Initialize hoisted BallShadow array
    Set BallShadow(0) = BallShadow1
    Set BallShadow(1) = BallShadow2
    Set BallShadow(2) = BallShadow3
    Set BallShadow(3) = BallShadow4
    Set BallShadow(4) = BallShadow5
    Set BallShadow(5) = BallShadow6

    If table1.ShowDT = False then
        Ramp16.WidthTop = 0
        Ramp16.WidthBottom = 0
        Ramp15.WidthTop = 0
        Ramp15.WidthBottom = 0
        Korpus.Size_Y = 1.7
    End if
End Sub

'******
'Trough
'******

Sub SolRelease(Enabled)
    If Enabled Then
        If bsTrough.Balls = 4 Then vpmTimer.PulseSw 31
        If bsTrough.Balls > 0 Then bsTrough.ExitSol_On
    End If
End Sub

Sub Drain_Hit
    PlaySound "Balltruhe", 0, 0.5, 0
    bsTrough.AddBall Me
End Sub

'*********
'Safehouse
'*********

Sub sw73_Hit
    PlaySound "SafeHouseHit"
    bsSafeHouse.AddBall Me
End Sub

'**********
'LeftPopper
'**********

Dim aBall

Sub HQHole_Hit
    PlaySound "HeadquarterHit", 0, 1, AudioPan(ActiveBall)
    Set aBall = ActiveBall:Me.TimerEnabled = 1

    LeftPopper.AddBall 1
End Sub

Sub HQHole_Timer
    Do While aBall.Z > 0
        aBall.Z = aBall.Z -5
        Exit Sub
    Loop
    Me.DestroyBall
    Me.TimerEnabled = 0
End Sub

'*********
'Warehouse
'*********

Sub WarehouseEntry_Hit 'Warehouse
    PlaySound "WareHouseHit"
    WarehousePopper.AddBall Me
    Warehousedw.isDropped = 0
End Sub

Sub Warehousedwtrigger_Hit
    Warehousedw.isDropped = 1
End Sub

'*********
'GunPopper
'*********

Sub TrapDoorKicker_Hit
    PlaySound "HeadquarterHit"
    GunPopper.AddBall Me
End Sub

'************
'TrapDoorRamp
'************

Sub TrapDoorLow(Enabled)
    PlaySound "TrapDoorHigh"
    If Enabled then
        TrapDoorP.RotX = TrapDoorP.RotX + 25
        TrapDoorKicker.Enabled = True
    Else
        TrapDoorP.RotX = TrapDoorP.RotX - 25
        PlaySound "TrapDoorLow"
        TrapDoorKicker.Enabled = False
    End If
End Sub

'*********
'MagnumGun
'*********

Sub SolGunLaunch(Enabled)
    If Enabled AND BallInGun then
        vpmCreateBall GunKick
        GunKick.kick GPos, 50
        PlaySound "GunShot"
        controller.switch(3) = 0
        BallInGun = 0
        BallP.Visible = False
    Else
        Controller.switch(44) = 0
        '		sw44.Enabled = True
        vpmTimer.AddTimer 200, "sw44.Enabled = True'"
    End If
End Sub

Sub SolGunMotor(Enabled)
    If Enabled Then
        PlaySound SoundFX("GunMotor", DOFGear)
        GDir = -1
        UpdateGun.Enabled = 1
        Controller.switch(77) = 1
    Else
        UpdateGun.Enabled = 0
        Controller.switch(77) = 0
        StopSound "GunMotor"
    End If
End Sub

Dim GPos, GDir
GPos = -50
GDir = -50
Sub updategun_Timer()
    GPos = GPos + GDir
    If GPos <= -98 Then GDir = 1
    Dim curSw76
    If GPos >= -4 Then curSw76 = 1 Else curSw76 = 0
    If curSw76 <> lastSw76 Then Controller.switch(76) = curSw76 : lastSw76 = curSw76
    If GPos >= -2 Then GDir = -1
    MagnumGun.RotY = GPos
End Sub

Sub sw44_hit()
    sw44.Enabled = False
    PlaySound "BallFallInGun"
    StopSound "WireRamp"
    RightWireStart2.Enabled = True
    Controller.switch(44) = 1
    me.DestroyBall
    BallInGun = 1
    BallP.Visible = True
End Sub

Sub GunLoadHelper_Hit()
    ActiveBall.VelX = -2
End Sub

'******
'Magnet
'******

Sub SolMagnetOn(Enabled)
    If Enabled then
        RightMagnet.MagnetOn = True
    Else
        RightMagnet.MagnetOn = False
    End if
End Sub

'*************
'RightLoopGate
'*************

Sub RightLoopGate(Enabled)
    If Enabled then
        Playsound "gate"
        GateR.open = True
    Else
        GateR.open = False
    End if
End sub

'******
'Plunger
'******

Dim AP

Sub AutoPlunge(Enabled)
    if enabled then
        AP = True
        AutoKicker.Kick 0, 48
        PlaySound SoundFX("Plunger", DOFContactors)
    End if
End Sub

Sub PlungerPTimer()
    if AP = True and PlungerP.TransZ < 45 then PlungerP.TransZ = PlungerP.TransZ + 10
    if AP = False and PlungerP.TransZ > 0 then PlungerP.TransZ = PlungerP.TransZ -10
    if PlungerP.TransZ >= 45 then AP = False
End Sub

'*********
'Solenoids
'*********

SolCallback(1) = "SolRelease"
SolCallback(2) = "AutoPlunge"
SolCallback(3) = "SolGunLaunch"
SolCallback(4) = "WarehousePopper.SolOut"
SolCallback(5) = "GunPopper.SolOut"
SolCallback(7) = "vpmSolSound SoundFX(""Knocker"",DOFKnocker),"
' SolCallback(8) = "TrapDoorHigh"
SolCallback(14) = "LeftPopper.SolOut"
SolCallBack(15) = "vpmSolDiverter diverterR,""DiverterRight"","
SolCallback(16) = "TrapDoorLow"
SolCallBack(20) = "SolGunMotor"
SolCallback(26) = "bsSafeHouse.SolOut"
SolCallback(27) = "SolDiverterHold"
SolCallBack(28) = "RightLoopGate"
SolCallBack(35) = "SolMagnetOn"

'*********
'Flasher
'*********

SolCallback(17) = "Multi117"
SolCallback(18) = "Multi118"
SolCallback(19) = "Multi119"
SolCallback(21) = "Multi121"
SolCallback(22) = "Multi122"
SolCallback(23) = "Multi123"
SolCallback(24) = "Multi124"

'**********
' Keys
'**********

Sub table1_KeyDown(ByVal Keycode)
    If KeyCode = MechanicalTilt Then
        vpmTimer.PulseSw vpmNudge.TiltSwitch
        Exit Sub
    End if

    If keycode = PlungerKey Then Controller.Switch(11) = 1
    If keycode = keyFront Then Controller.Switch(23) = 1
    If vpmKeyDown(keycode) Then Exit Sub
End Sub

Sub table1_KeyUp(ByVal Keycode)
    If vpmKeyUp(keycode) Then Exit Sub
    If keycode = PlungerKey Then Controller.Switch(11) = 0
    If keycode = keyFront Then Controller.Switch(23) = 0
End Sub

'**************
' Flipper Subs
'**************

SolCallback(sLRFlipper) = "SolRFlipper"
SolCallback(sLLFlipper) = "SolLFlipper"

Sub SolLFlipper(Enabled)
    If Enabled Then
        PlaySound SoundFX("FlipperUpLeft", DOFContactors):LeftFlipper.RotateToEnd
    Else
        PlaySound SoundFX("FlipperDown", DOFContactors):LeftFlipper.RotateToStart
    End If
End Sub

Sub SolRFlipper(Enabled)
    If Enabled Then
        PlaySound SoundFX("FlipperUpRightBoth", DOFContactors):RightFlipper.RotateToEnd:RightFlipper1.RotateToEnd
    Else
        PlaySound SoundFX("FlipperDown", DOFContactors):RightFlipper.RotateToStart:RightFlipper1.RotateToStart
    End If
End Sub

'*********
' Switches
'*********

Sub sw15_Hit:Controller.Switch(15) = 1:sw15wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'shooterlane'
Sub sw15_UnHit:Controller.Switch(15) = 0:sw15wire.RotX = 0:End Sub
Sub sw16_Hit:Controller.Switch(16) = 1:sw16wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'right outlane'
Sub sw16_UnHit:Controller.Switch(16) = 0:sw16wire.RotX = 0:End Sub
Sub sw17_Hit:Controller.Switch(17) = 1:sw17wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'right inlane'
Sub sw17_UnHit:Controller.Switch(17) = 0:sw17wire.RotX = 0:End Sub
Sub sw26_Hit:Controller.Switch(26) = 1:sw26wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'left outlane'
Sub sw26_UnHit:Controller.Switch(26) = 0:sw26wire.RotX = 0:End Sub
Sub sw25_Hit:Controller.Switch(25) = 1:sw25wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'left inlane'
Sub sw25_UnHit:Controller.Switch(25) = 0:sw25wire.RotX = 0:End Sub
Sub sw71_Hit:Controller.Switch(71) = 1:sw71wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'left loop'
Sub sw71_UnHit:Controller.Switch(71) = 0:sw71wire.RotX = 0:End Sub
Sub sw66_Hit:Controller.Switch(66) = 1:sw66wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'left rollover (bumper)'
Sub sw66_UnHit:Controller.Switch(66) = 0:sw66wire.RotX = 0:End Sub
Sub sw67_Hit:Controller.Switch(67) = 1:sw67wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'middle rollover (bumper)'
Sub sw67_UnHit:Controller.Switch(67) = 0:sw67wire.RotX = 0:End Sub
Sub sw68_Hit:Controller.Switch(68) = 1:sw68wire.RotX = 15:PlaySound "metalhit_thin":End Sub 'right rollover (bumper)'
Sub sw68_UnHit:Controller.Switch(68) = 0:sw68wire.RotX = 0:End Sub
Sub sw42_Hit:Controller.Switch(42) = 1:End Sub                                              'right loop'
Sub sw42_UnHit:Controller.Switch(42) = 0:End Sub

Sub BallDrop1_Hit():StopSound "WireRamp":End Sub
Sub BallDrop2_Hit():PlaySound "BallDrop":End Sub
Sub BallDrop3_Hit():PlaySound "BallDrop":End Sub
Sub ZHelper_Hit():ActiveBall.VelZ = ActiveBall.VelZ -5:End Sub

'*********
' Ramps
'*********

Sub sw41_Hit:vpmTimer.pulseSw 41:End Sub
Sub sw43_Hit:vpmTimer.pulseSw 43:End Sub
Sub sw51_Hit:vpmTimer.pulseSw 51:End Sub
Sub sw38_Hit:vpmTimer.pulseSw 38:End Sub

'RampSounds

Dim SoundBall

Sub MiddleWireStart_Hit
    Set SoundBall = Activeball             'Ball-assignment
    playsound "WireRamp", -1, 0.6, 0, 0.35 '-1 = looping, AudioPanning = -1 bis 1, je nach Position
End Sub

Sub LeftWireStart_Hit
    Set SoundBall = Activeball             'Ball-assignment
    playsound "WireRamp", -1, 0.6, 0, 0.35 '-1 = looping, AudioPanning = -1 bis 1, je nach Position
End Sub

Sub RightWireStart1_Hit
    RightWireStart2.Enabled = False
    Set SoundBall = Activeball             'Ball-assignment
    playsound "WireRamp", -1, 0.6, 0, 0.35 '-1 = looping, AudioPanning = -1 bis 1, je nach Position
End Sub

Sub RightWireStart2_Hit
    Set SoundBall = Activeball             'Ball-assignment
    playsound "WireRamp", -1, 0.6, 0, 0.35 '-1 = looping, AudioPanning = -1 bis 1, je nach Position
End Sub

'***************
' StandupTargets
'***************

Sub Standup27_Hit:vpmTimer.pulseSw 27:Standup27p.RotY = Standup27p.RotY -3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup27_Timer:Standup27p.RotY = Standup27p.RotY + 3:Me.TimerEnabled = 0:End Sub
Sub Standup28_Hit:vpmTimer.pulseSw 28:Standup28p.RotY = Standup28p.RotY -3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup28_Timer:Standup28p.RotY = Standup28p.RotY + 3:Me.TimerEnabled = 0:End Sub
Sub Standup58_Hit:vpmTimer.pulseSw 58:Standup58p.RotY = Standup58p.RotY -3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup58_Timer:Standup58p.RotY = Standup58p.RotY + 3:Me.TimerEnabled = 0:End Sub
Sub Standup57_Hit:vpmTimer.pulseSw 57:Standup57p.RotY = Standup57p.RotY -3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup57_Timer:Standup57p.RotY = Standup57p.RotY + 3:Me.TimerEnabled = 0:End Sub
Sub Standup56_Hit:vpmTimer.pulseSw 56:Standup56p.RotY = Standup56p.RotY -3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup56_Timer:Standup56p.RotY = Standup56p.RotY + 3:Me.TimerEnabled = 0:End Sub
Sub Standup54_Hit:vpmTimer.pulseSw 54:Standup54p.RotX = Standup54p.RotX + 3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup54_Timer:Standup54p.RotX = Standup54p.RotX -3:Me.TimerEnabled = 0:End Sub
Sub Standup55_Hit:vpmTimer.pulseSw 55:Standup55p.RotY = Standup55p.RotY -3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup55_Timer:Standup55p.RotY = Standup55p.RotY + 3:Me.TimerEnabled = 0:End Sub
Sub Standup18_Hit:vpmTimer.pulseSw 18:Standup18p.RotY = Standup18p.RotY -3:Playsound SoundFX("target", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Standup18_Timer:Standup18p.RotY = Standup18p.RotY + 3:Me.TimerEnabled = 0:End Sub

'*********
' Bumper
'*********

Sub Bumper63_hit:vpmTimer.pulseSw 63:Playsound SoundFX("BumperLeft", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Bumper63_Timer:Me.Timerenabled = 0:End Sub

Sub Bumper64_hit:vpmTimer.pulseSw 64:Playsound SoundFX("BumperMiddle", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Bumper64_Timer:Me.Timerenabled = 0:End Sub

Sub Bumper65_hit:vpmTimer.pulseSw 65:Playsound SoundFX("BumperRight", DOFContactors):Me.TimerEnabled = 1:End Sub
Sub Bumper65_Timer:Me.Timerenabled = 0:End Sub

'**********Sling Shot Animations
' Rstep and Lstep  are the variables that increment the animation
'****************
Dim RStep, Lstep

Sub RightSlingShot_Slingshot
    PlaySound SoundFX("SlingshotLeft", DOFContactors), 0, 1, 0.05, 0.05
    RSling.Visible = 0
    RSling1.Visible = 1
    sling1.TransZ = -20
    RStep = 0
    RightSlingShot.TimerEnabled = 1
    vpmTimer.PulseSw 62
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 3:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.TransZ = -10
        Case 4:RSLing2.Visible = 0:RSLing.Visible = 1:sling1.TransZ = 0:RightSlingShot.TimerEnabled = 0
    End Select
    RStep = RStep + 1
End Sub

Sub LeftSlingShot_Slingshot
    PlaySound SoundFX("SlingshotRight", DOFContactors), 0, 1, -0.05, 0.05
    LSling.Visible = 0
    LSling1.Visible = 1
    sling2.TransZ = -20
    LStep = 0
    LeftSlingShot.TimerEnabled = 1
    vpmTimer.PulseSw 61
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 3:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.TransZ = -10
        Case 4:LSLing2.Visible = 0:LSLing.Visible = 1:sling2.TransZ = 0:LeftSlingShot.TimerEnabled = 0
    End Select
    LStep = LStep + 1
End Sub

'********
'Diverter
'********

Sub SolDiverterHold(Enabled)
    DiverterOFF.IsDropped = Enabled:DiverterOn.IsDropped = Not Enabled
    DiverterOn2.IsDropped = Not Enabled
    If Enabled then Playsound "DiverterLeft":End if
End Sub

'*********
'Update GI
'*********

Dim xx
Dim gistep
gistep = 1 / 8

Sub UpdateGI(no, step)
    If step = 0 OR step = 7 then exit sub
    Select Case no

        'Bottom String
        Case 4
            For each xx in GIString1:xx.IntensityScale = gistep * step:next
            if step = 1 then Table1.ColorGradeImage = "-70"
            if step = 2 then Table1.ColorGradeImage = "-60"
            if step = 3 then Table1.ColorGradeImage = "-50"
            if step = 4 then Table1.ColorGradeImage = "-40"
            if step = 5 then Table1.ColorGradeImage = "-30"
            if step = 6 then Table1.ColorGradeImage = "-20"
            if step = 7 then Table1.ColorGradeImage = "-10"
            if step = 8 then Table1.ColorGradeImage = "ColorGradeLUT256x16_ConSat"

        'Left String
        Case 1
            For each xx in GIString2:xx.IntensityScale = gistep * step:next

        'Right String
        Case 0
            For each xx in GIString3:xx.IntensityScale = gistep * step:next
    End Select
End Sub

'*************
'  VP Lights
'*************

InitLamps

Sub InitLamps()
    Set Lights(11) = l11
    Set Lights(12) = l12
    Set Lights(13) = l13
    Set Lights(14) = l14
    Set Lights(15) = l15
    Set Lights(16) = l16
    Set Lights(17) = l17
    Set Lights(18) = l18
    Set Lights(21) = l21
    Set Lights(22) = l22
    Set Lights(23) = l23
    Set Lights(24) = l24
    Set Lights(25) = l25
    Set Lights(26) = l26
    Set Lights(27) = l27
    Set Lights(28) = l28
    Set Lights(31) = l31
    Set Lights(32) = l32
    Set Lights(33) = l33
    Set Lights(34) = l34
    Set Lights(35) = l35
    Set Lights(36) = l36
    Set Lights(37) = l37
    Set Lights(38) = l38
    Set Lights(41) = l41
    Set Lights(42) = l42
    Set Lights(43) = l43
    Set Lights(44) = l44
    Set Lights(45) = l45
    Set Lights(46) = l46
    Set Lights(47) = l47
    Set Lights(48) = l48
    Set Lights(51) = l51
    Set Lights(52) = l52
    Set Lights(53) = l53
    Set Lights(54) = l54
    Set Lights(55) = l55
    Set Lights(56) = l56
    Set Lights(57) = l57
    Set Lights(58) = l58
    Set Lights(61) = l61
    Set Lights(62) = l62
    Set Lights(63) = l63
    Set Lights(64) = l64
    Set Lights(65) = l65
    Set Lights(66) = l66
    Set Lights(67) = l67
    Set Lights(68) = l68
    Set Lights(77) = l77
    Set Lights(78) = l78
    Set Lights(81) = l81
    Set Lights(82) = l82
    Set Lights(83) = l83
    Set Lights(84) = l84
    Set Lights(85) = l85
    Set Lights(86) = l86
End Sub

Sub UpdateMultipleLamps
    If l48.state = 1 then bulbyellow.image = "bulbcover1_yellowOn":l84a.state = 1:else bulbyellow.image = "bulbcover1_yellow":l84a.state = 0
    If l47.state = 1 then bulbred.image = "bulbcover1_redOn":else bulbred.image = "bulbcover1_red"
    If l85.state = 1 then domesmall.image = "domesmallredOn":else domesmall.image = "domesmallred"
    If l84.state = 1 then domesmall1.image = "domesmallredOn":else domesmall1.image = "domesmallred"
    If l38.state = 1 then Bankrobber.image = "bankrobbermesh1On":else Bankrobber.image = "bankrobbermesh1"
End Sub

Sub Multi117(Enabled)
    If Enabled Then
        l117a.State = 1
        l117b.state = 1
        l117c.state = 1
        l117d.state = 1
        l117e.state = 1
        Dome1.Image = "dome3_orange_On"
        domesmall2.Image = "domesmallredOn"
    Else
        l117a.State = 0
        l117b.state = 0
        l117c.state = 0
        l117d.state = 0
        l117e.state = 0
        Dome1.Image = "dome3_orange"
        domesmall2.Image = "domesmallred"
    End If
End Sub

Sub Multi118(Enabled)
    If Enabled Then
        l118a.State = 1
        l118b.state = 1
        l118c.state = 1
        l118d.state = 1
        l118e.state = 1
        l118f.state = 1
    Else
        l118a.State = 0
        l118b.state = 0
        l118c.state = 0
        l118d.state = 0
        l118e.state = 0
        l118f.state = 0
    End If
End Sub

Sub Multi119(Enabled)
    If Enabled Then
        l119a.State = 1
        l119b.state = 1
        l119c.state = 1
        l119d.state = 1
        l119e.state = 1
        l119f.state = 1
    Else
        l119a.State = 0
        l119b.state = 0
        l119c.state = 0
        l119d.state = 0
        l119e.state = 0
        l119f.state = 0
    End If
End Sub

Sub Multi122(Enabled)
    If Enabled Then
        l122a.State = 1
        l122b.state = 1
    Else
        l122a.State = 0
        l122b.state = 0
    End If
End Sub

Sub Multi123(Enabled)
    If Enabled Then
        l123a.State = 1
        l123b.state = 1
        l123c.state = 1
        l123d.state = 1
        l123ab.state = 1
        l123ab1.state = 1
        Dome5.Image = "dome3_blue_On"
        Dome3.Image = "dome3_clear_On"        
    Else
        l123a.State = 0
        l123b.state = 0
        l123c.state = 0
        l123d.state = 0
        l123ab.state = 0
        l123ab1.state = 0
        Dome5.Image = "dome3_blue"
        Dome3.Image = "dome3_clear"        
    End If
End Sub

Sub Multi124(Enabled)
    If Enabled Then
        l124a.State = 1
        l124b.state = 1
        l124ab.state = 1
        l124ab1.state = 1
        l124c.state = 1
        l124d.state = 1
        Dome2.Image = "dome3_clear_On"
        Dome4.Image = "dome3_blue_On"        
    Else
        l124a.State = 0
        l124b.state = 0
        l124c.state = 0
        l124d.state = 0
        l124ab.State = 0
        l124ab1.state = 0
        Dome2.Image = "dome3_clear"
        Dome4.Image = "dome3_blue"        
    End If
End Sub

Sub Multi121(Enabled)
    If Enabled Then
        l121a.State = 1
        l121b.state = 1
        l121c.state = 1
    Else
        l121a.State = 0
        l121b.state = 0
        l121c.state = 0
    End If
End Sub

'*********************************************************************
'                 Positional Sound Playback Functions
'*********************************************************************

' Play a sound, depending on the X,Y position of the table element (especially cool for surround speaker setups, otherwise stereo panning only)
' parameters (defaults): loopcount (1), volume (1), randompitch (0), pitch (0), useexisting (0), restart (1))
' Note that this will not work (currently) for walls/slingshots as these do not feature a simple, single X,Y position
Sub PlayXYSound(soundname, tableobj, loopcount, volume, randompitch, pitch, useexisting, restart)
	PlaySound soundname, loopcount, volume, AudioPan(tableobj), randompitch, pitch, useexisting, restart, AudioFade(tableobj)
End Sub

' Similar subroutines that are less complicated to use (e.g. simply use standard parameters for the PlaySound call)
Sub PlaySoundAt(soundname, tableobj)
    PlaySound soundname, 1, 1, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

Sub PlaySoundAtBall(soundname)
    PlaySoundAt soundname, ActiveBall
End Sub


'*********************************************************************
'                     Supporting Ball & Sound Functions
'*********************************************************************

Function AudioFade(tableobj) ' Fades between front and back of the table
	Dim tmp
    tmp = tableobj.y * 2 / tableheight - 1
    If tmp > 0 Then
        Dim t2f : t2f = tmp*tmp : Dim t4f : t4f = t2f*t2f : Dim t8f : t8f = t4f*t4f
        AudioFade = Csng(t8f*t2f)
    Else
        tmp = -tmp
        Dim t2fn : t2fn = tmp*tmp : Dim t4fn : t4fn = t2fn*t2fn : Dim t8fn : t8fn = t4fn*t4fn
        AudioFade = Csng(-(t8fn*t2fn))
    End If
End Function

Function AudioFadeXY(y) ' AudioFade variant accepting pre-cached Y scalar
    Dim tmp
    tmp = y * 2 / tableheight - 1
    If tmp > 0 Then
        Dim t2fy : t2fy = tmp*tmp : Dim t4fy : t4fy = t2fy*t2fy : Dim t8fy : t8fy = t4fy*t4fy
        AudioFadeXY = Csng(t8fy*t2fy)
    Else
        tmp = -tmp
        Dim t2fyn : t2fyn = tmp*tmp : Dim t4fyn : t4fyn = t2fyn*t2fyn : Dim t8fyn : t8fyn = t4fyn*t4fyn
        AudioFadeXY = Csng(-(t8fyn*t2fyn))
    End If
End Function

Function AudioPan(tableobj) ' Calculates the pan for a tableobj based on the X position
    Dim tmp
    tmp = tableobj.x * 2 / tablewidth - 1
    If tmp > 0 Then
        Dim t2p : t2p = tmp*tmp : Dim t4p : t4p = t2p*t2p : Dim t8p : t8p = t4p*t4p
        AudioPan = Csng(t8p*t2p)
    Else
        tmp = -tmp
        Dim t2pn : t2pn = tmp*tmp : Dim t4pn : t4pn = t2pn*t2pn : Dim t8pn : t8pn = t4pn*t4pn
        AudioPan = Csng(-(t8pn*t2pn))
    End If
End Function

Function AudioPanXY(x) ' AudioPan variant accepting pre-cached X scalar
    Dim tmp
    tmp = x * 2 / tablewidth - 1
    If tmp > 0 Then
        Dim t2px : t2px = tmp*tmp : Dim t4px : t4px = t2px*t2px : Dim t8px : t8px = t4px*t4px
        AudioPanXY = Csng(t8px*t2px)
    Else
        tmp = -tmp
        Dim t2pxn : t2pxn = tmp*tmp : Dim t4pxn : t4pxn = t2pxn*t2pxn : Dim t8pxn : t8pxn = t4pxn*t4pxn
        AudioPanXY = Csng(-(t8pxn*t2pxn))
    End If
End Function

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
    Vol = Csng(BallVel(ball) ^2 / 5000)
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
    BallVel = INT(SQR((ball.VelX * ball.VelX) + (ball.VelY * ball.VelY)))
End Function

'*****************************************
'      JP's VP10 Rolling Sounds
'*****************************************

Const tnob = 6 ' total number of balls
ReDim rolling(tnob)
InitRolling

Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
    Next
End Sub

Sub RollingTimer_Timer()
    Dim BOT, b, ub
    BOT = GetBalls
    ub = UBound(BOT)

    ' stop the sound of deleted balls
    For b = ub + 1 to tnob
        rolling(b) = False
        StopSound RollStr(b)
    Next

    ' exit the sub if no balls on the table
    If ub = -1 Then Exit Sub

    ' play the rolling sound for each ball
    Dim bx, by, bz, vx, vy, vz, velSq, vel, volVal, pitchVal, panVal, fadeVal

    For b = 0 to ub
        bx = BOT(b).x : by = BOT(b).y : bz = BOT(b).z
        vx = BOT(b).VelX : vy = BOT(b).VelY : vz = BOT(b).VelZ

        velSq = vx*vx + vy*vy
        vel = INT(SQR(velSq))
        panVal = AudioPanXY(bx)
        fadeVal = AudioFadeXY(by)

      If vel > 1 Then
        rolling(b) = True
        volVal = Csng(velSq / 5000)
        pitchVal = vel * 20
        if bz < 30 Then ' Ball on playfield
          PlaySound RollStr(b), -1, volVal, panVal, 0, pitchVal, 1, 0, fadeVal
        Else ' Ball on raised ramp
          PlaySound RollStr(b), -1, volVal*.5, panVal, 0, pitchVal+50000, 1, 0, fadeVal
        End If
      Else
        If rolling(b) = True Then
          StopSound RollStr(b)
          rolling(b) = False
        End If
      End If
      ' play ball drop sounds
        If vz < -1 and bz < 55 and bz > 27 Then
            PlaySound DropStr(b), 0, ABS(vz)/17, panVal, 0, vel*20, 1, 0, fadeVal
        End If
    Next
End Sub

'**********************
' Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
	PlaySound("fx_collide"), 0, Csng(velocity) ^2 / 2000, AudioPan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub

 '**********************
'Flipper Shadows
'***********************
Sub RealTime_Timer
  Dim curLfs : curLfs = LeftFlipper.CurrentAngle
  Dim curRfs : curRfs = RightFlipper.CurrentAngle
  If curLfs <> lastLfsAngle Then lfs.RotZ = curLfs : lastLfsAngle = curLfs
  If curRfs <> lastRfsAngle Then rfs.RotZ = curRfs : lastRfsAngle = curRfs
  BallShadowUpdate
End Sub


Sub BallShadowUpdate()
    Dim BOT, b, ub
    BOT = GetBalls
    ub = UBound(BOT)
    ' hide shadow of deleted balls
    If ub < (tnob-1) Then
        For b = (ub + 1) to (tnob-1)
            BallShadow(b).visible = 0
        Next
    End If
    ' exit the Sub if no balls on the table
    If ub = -1 Then Exit Sub
    ' render the shadow for each ball
    Dim bx, by, bz
    For b = 0 to ub
        bx = BOT(b).X : by = BOT(b).Y : bz = BOT(b).Z
        BallShadow(b).X = bx
        BallShadow(b).Y = by + 10
        If bz > 20 and bz < 260 Then
            BallShadow(b).visible = 1
        Else
            BallShadow(b).visible = 0
        End If
        If bz > 30 Then
            BallShadow(b).height = bz - 20
            BallShadow(b).opacity = 110
        Else
            BallShadow(b).height = bz - 24
            BallShadow(b).opacity = 90
        End If
    Next
End Sub

'****************************
'     Realtime Updates
' called by the MotorCallBack
'****************************

Sub RealTimeUpdates
    'flippers — cache COM reads into locals
    Dim lfA : lfA = LeftFlipper.CurrentAngle
    Dim rf1A : rf1A = RightFlipper1.CurrentAngle
    Dim rfA : rfA = RightFlipper.CurrentAngle
    LeftFlipperP.RotY = lfA
    RightFlipperP1.RotY = rf1A
    RightFlipperP.RotY = rfA
    ' Plunger update
    PlungerPTimer
    ' ramp gate
    SpinnerP.RotX = Spinner1.currentangle + 95
    ' diverter
    DiverterP.RotY = diverterR.CurrentAngle
End Sub

'******************************
' Diverse Collection Hit Sounds
'******************************

Sub Pins_Hit(idx)
    PlaySound "pinhit_low", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 0, 0
End Sub

Sub Targets_Hit(idx)
    PlaySound SoundFX("target", DOFContactors), 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 0, 0
End Sub

Sub Metals_Thin_Hit(idx)
    PlaySound "metalhit_thin", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Metals_Medium_Hit(idx)
    PlaySound "metalhit_medium", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Metals2_Hit(idx)
    PlaySound "metalhit2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Gates_Hit(idx)
    PlaySound "gate4", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
End Sub

Sub Spinner_Spin
    PlaySound "fx_spinner", 0, .25, 0, 0.25
End Sub

Sub Rubbers_Hit(idx)
    dim finalspeed
    finalspeed = SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
    If finalspeed > 20 then
        PlaySound "fx_rubber2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End if
    If finalspeed >= 6 AND finalspeed <= 20 then
        RandomSoundRubber()
    End If
End Sub

Sub Posts_Hit(idx)
    dim finalspeed
    finalspeed = SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
    If finalspeed > 16 then
        PlaySound "fx_rubber2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End if
    If finalspeed >= 6 AND finalspeed <= 16 then
        RandomSoundRubber()
    End If
End Sub

Sub RandomSoundRubber()
    Select Case Int(Rnd * 3) + 1
        Case 1:PlaySound "rubber_hit_1", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 2:PlaySound "rubber_hit_2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 3:PlaySound "rubber_hit_3", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End Select
End Sub

Sub LeftFlipper_Collide(parm)
    RandomSoundFlipper()
End Sub

Sub RightFlipper_Collide(parm)
    RandomSoundFlipper()
End Sub

Sub RandomSoundFlipper()
    Select Case Int(Rnd * 3) + 1
        Case 1:PlaySound "flip_hit_1", 0, 1, AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 2:PlaySound "flip_hit_2", 0, 1, AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
        Case 3:PlaySound "flip_hit_3", 0, 1, AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0
    End Select
End Sub