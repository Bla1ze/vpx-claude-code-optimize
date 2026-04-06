Option Explicit

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs in order to run this table, available in the vp10 package"
On Error Goto 0

LoadVPM "01530000","sega.vbs",3.1

'********************************************
'**     Game Specific Code Starts Here     **
'********************************************
Const UseSolenoids=2,UseSync=1Const SSolenoidOn="SolOn",SSolenoidOff="SolOff",SFlipperOn="fx_FlipperUp",SFlipperOff="fx_FlipperDown",SCoin="Coin3"Sub Table1_KeyDown(ByVal KeyCode)	If KeyCode=KeyUpperLeft Then Controller.Switch(1)=1	If KeyCode=KeyUpperRight Then Controller.Switch(8)=1	If KeyCode=PlungerKey Then Controller.Switch(53)=1	If vpmKeyDown(KeyCode) Then Exit SubEnd SubSub Table1_KeyUp(ByVal KeyCode)	If KeyCode=KeyUpperLeft Then Controller.Switch(1)=0	If KeyCode=KeyUpperRight Then Controller.Switch(8)=0	If KeyCode=PlungerKey Then Controller.Switch(53)=0	If vpmKeyUp(KeyCode) Then Exit SubEnd Sub
'**************************************
'**     Bind Events To Solenoids     **
'**************************************
SolCallback(1)="SolTrough"SolCallback(2)="vpmSolAutoPlunger Plunger,0,"SolCallback(3)="bsTRVUK.SolOut"SolCallback(4)="bsBRVUK.SolOut"SolCallback(6)="bsCVUK.SolOut"SolCallback(9)="vpmSolSound ""fx_Bumper"","SolCallback(10)="vpmSolSound ""fx_Bumper"","SolCallback(11)="vpmSolSound ""fx_Bumper"","SolCallback(12)="vpmSolSound ""fx_Bumper"","SolCallback(13)="vpmSolSound ""fx_Bumper"","SolCallback(14)="mDMag.MagnetOn="SolCallback(sLLFlipper)="vpmSolFlipper LeftFlipper,Nothing,"SolCallback(sLRFlipper)="vpmSolFlipper RightFlipper,Nothing,"SolCallback(17)="SolSpinWheelsMotor"SolCallback(18)="vpmSolSound ""Sling"","SolCallback(19)="vpmSolSound ""Sling"","SolCallback(20)="SolRobot"'FLASHERSSolCallback(25)="vpmFlasher Array(F1A,F1B,F1C,F1D),"'25'F1=Red*4SolCallback(26)="vpmFlasher Array(F2A,F2B,F2C,F2D),"'26'F2=Yellow*4SolCallback(27)="vpmFlasher Array(F3A,F3B,F3C,F3D),"'27'F3=Green*4'28'F4=WARNing*4'29'F5=warnING*4'SolCallback(30)="vpmFlasher Array(Light6,Light7,Light8),"'31'F7=Pops*2'32'F8=Ramp*2

'*********************Flashers
Sub Sol25(Enabled)
	If Enabled Then
F1A.State=LightStateOn
F1B.State=LightStateOn
F1C.State=LightStateOn
F1D.State=LightStateOn
Else
F1A.State=LightStateOff
F1B.State=LightStateOff
F1C.State=LightStateOff
F1D.State=LightStateOff
End If
End Sub

Sub Sol26(Enabled)
	If Enabled Then
F2A.State=LightStateOn
F2B.State=LightStateOn
F2C.State=LightStateOn
F2D.State=LightStateOn
Else
F2A.State=LightStateOff
F2B.State=LightStateOff
F2C.State=LightStateOff
F2D.State=LightStateOff
End If
End Sub

Sub Sol27(Enabled)
	If Enabled Then
F3A.State=LightStateOn
F3B.State=LightStateOn
F3C.State=LightStateOn
F3D.State=LightStateOn
Else
F3A.State=LightStateOff
F3B.State=LightStateOff
F3C.State=LightStateOff
F3D.State=LightStateOff
End If
End Sub
'*****************************
    Sub SolRobot(Enabled)	If Enabled Then		Robot1.TimerEnabled=1		Robot1_Timer	Else		Robot1.TimerEnabled=0	End IfEnd SubSub Robot1_Timer	If Robot2.IsDropped Then		Robot1.IsDropped=1		Robot2.IsDropped=0	Else		Robot2.IsDropped=1		Robot1.IsDropped=0	End IfEnd SubSub SolTrough(Enabled)	If Enabled Then		If bsTrough.Balls Then			vpmTimer.PulseSw 15			bsTrough.ExitSol_On		End If	End IfEnd Sub
'********************************************
'**     Init The Table, Start VPinMAME     **
'********************************************
 Dim bsTrough,bsCVUK,bsTRVUK,bsBRVUK,mTLMag,mTRMag,mDMag,X,TtableSub Table1_Init
    Robot2.IsDropped=1
'*********************FlasherF
F1A.State=LightStateOff
F1B.State=LightStateOff
F1C.State=LightStateOff
F1D.State=LightStateOff
F2A.State=LightStateOff
F2B.State=LightStateOff
F2C.State=LightStateOff
F2D.State=LightStateOff
F3A.State=LightStateOff
F3B.State=LightStateOff
F3C.State=LightStateOff
F3D.State=LightStateOff
'*****************************

	Plunger.PullBack
    On Error Resume Next
	With Controller
	.GameName="lostspc"
	.SplashInfoLine=""
	.HandleKeyboard=0
	.ShowTitle=0
	.ShowDMDOnly=1
    .HandleMechanics=0
	.ShowFrame=0
		If Table1.ShowDT = false then
			'Scoretext.Visible = false
			.Hidden = 0
		End If

		If Table1.ShowDT = true then
		'Scoretext.Visible = false
			.Hidden = 0
		End If
	End With
	Controller.Run
	If Err Then MsgBox Err.Description
		On Error Goto 0

    PinMAMETimer.Interval=PinMAMEInterval:PinMAMETimer.Enabled=1
	vpmNudge.TiltSwitch=56:vpmNudge.Sensitivity=5:vpmNudge.TiltObj=Array(S36,S37,S38,S39,S40,LeftSlingshot,RightSlingshot)
RealTime.Enabled = 1
	Set bsTrough=New cvpmBallStack	bsTrough.InitSw 0,14,13,12,11,0,0,0	bsTrough.InitKick BallRelease,95,5	bsTrough.Balls=4	bsTrough.InitExitSnd"BallRel","SolOn"	Set bsCVUK=New cvpmBallStack	bsCVUK.InitSw 0,46,0,0,0,0,0,0	bsCVUK.InitKick CenterHole,160,8	bsCVUK.InitExitSnd SoundFX("fx_kicker", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)

	Set bsTRVUK=New cvpmBallStack	bsTRVUK.InitSw 0,47,0,0,0,0,0,0	bsTRVUK.InitKick TRVExit,280,20	bsTRVUK.InitExitSnd SoundFX("fx_kicker", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)	Set bsBRVUK=New cvpmBallStack	bsBRVUK.InitSw 0,48,0,0,0,0,0,0	bsBRVUK.InitKick BRVExit,300,20	bsBRVUK.InitExitSnd SoundFX("fx_kicker", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)	Set mTLMag=New cvpmMagnet	mTLMag.InitMagnet Magnet1,200	mTLMag.Solenoid=5	mTLMag.GrabCenter=1	mTLMag.CreateEvents"mTLMag"	Set mTRMag=New cvpmMagnet	mTRMag.InitMagnet Magnet2,50	mTRMag.Solenoid=7	mTRMag.GrabCenter=1	mTRMag.CreateEvents"mTRMag"	Set mDMag=New cvpmMagnet	mDMag.InitMagnet Magnet3,20	mDMag.GrabCenter=1    Set Ttable = New cvpmTurntable
	Ttable.InitTurntable TT, 35
	Ttable.SpinDown = 10
	Ttable.CreateEvents "Ttable"
	vpmMapLights AllLights
	InitTexturePairs
End Sub


set GICallback = GetRef("UpdateGI")
Sub UpdateGI(no, Enabled)
	If Enabled Then
		dim xx
		For each xx in GI:xx.State = 1:	Next
        PlaySound "fx_relay"
		PFMESH.image = "Playfield-on"
		Plastics.image = "Plastics-on"
		Ramps.image = "Ramps-on"
		Apron.image = "Playfield-elements-on"
		CabinateSides.image = "Playfield-elements-on"
		Screws.image = "Playfield-elements-on"
		Metalwalls.image = "Playfield-elements-on"
		DrSmith.image = "DrSmith-on"
		Will.image = "Will-on"
		spindisk.image = "SpinDisk-on"
		Primitive006.image = "Toys-on"
		CharBottom.image = "Toys-on"
		Rocks.image = "Rocks-on"
		Chartop.image = "Rocks-on"
		Posts.image = "Playfield-elements-on"
		Jupitor2.image = "Toys-on"
		Cap01.image = "Playfield-elements-off"
		Cap02.image = "Playfield-elements-off"
		Cap03.image = "Playfield-elements-off"
		Cap04.image = "Playfield-elements-off"
		Cap05.image = "Playfield-elements-off"
		sw17.image = "GreenTarget-on"
		sw18.image = "GreenTarget-on"
		sw19.image = "GreenTarget-on"
		sw25.image = "RedTarget-on"
		sw26.image = "RedTarget-on"
		sw27.image = "RedTarget-on"
		sw33.image = "YellowTarget-on"
		sw34.image = "YellowTarget-on"
		sw35.image = "YellowTarget-on"

		

	Else For each xx in GI:xx.State = 0: Next
        PlaySound "fx_relay"
		PFMESH.image = "Playfield-off"
		Plastics.image = "Plastics-off"
		Ramps.image = "Ramps-off"
		Apron.image = "Playfield-elements-off"
		CabinateSides.image = "Playfield-elements-off"
		Screws.image = "Playfield-elements-off"
		Metalwalls.image = "Playfield-elements-off"
		DrSmith.image = "DrSmith-off"
		Will.image = "Will-off"
		spindisk.image = "SpinDisk-off"
		Primitive006.image = "Toys-off"
		Rocks.image = "Rocks-off"
		Chartop.image = "Rocks-off"
		CharBottom.image = "Toys-off"
		Posts.image = "Playfield-elements-off"
		Jupitor2.image = "Toys-off"
		Cap01.image = "Playfield-elements-off-off"
		Cap02.image = "Playfield-elements-off-off"
		Cap03.image = "Playfield-elements-off-off"
		Cap04.image = "Playfield-elements-off-off"
		Cap05.image = "Playfield-elements-off-off"
		sw17.image = "GreenTarget-off"
		sw18.image = "GreenTarget-off"
		sw19.image = "GreenTarget-off"
		sw25.image = "RedTarget-off"
		sw26.image = "RedTarget-off"
		sw27.image = "RedTarget-off"
		sw33.image = "YellowTarget-off"
		sw34.image = "YellowTarget-off"
		sw35.image = "YellowTarget-off"

	End If
End Sub



' --- Stand-up Target Animation (unified) ---
' Pre-built rotation frames: step 1-5 = animate, step 6 = reset to 0
Dim TargetFrames : TargetFrames = Array(0, 5, 10, 5, 2, 1, 0)

' Shared step counters for all 9 targets
Dim TargetSteps(8) ' index 0-8 for targets 17,18,19,25,26,27,33,34,35

' Shared animation handler — called by all 9 target timers
Sub AnimateTarget(idx, swObj, tmrObj)
    Dim s : s = TargetSteps(idx)
    If s >= 1 And s <= 5 Then
        swObj.RotZ = TargetFrames(s)
    ElseIf s = 6 Then
        swObj.RotZ = 0
        tmrObj.Enabled = False
    End If
    TargetSteps(idx) = s + 1
End Sub

Sub Target17Timer_Timer() : AnimateTarget 0, sw17, Target17Timer : End Sub
Sub Target18Timer_Timer() : AnimateTarget 1, sw18, Target18Timer : End Sub
Sub Target19Timer_Timer() : AnimateTarget 2, sw19, Target19Timer : End Sub




Sub Target25Timer_Timer() : AnimateTarget 3, sw25, Target25Timer : End Sub
Sub Target26Timer_Timer() : AnimateTarget 4, sw26, Target26Timer : End Sub
Sub Target27Timer_Timer() : AnimateTarget 5, sw27, Target27Timer : End Sub
Sub Target33Timer_Timer() : AnimateTarget 6, sw33, Target33Timer : End Sub
Sub Target34Timer_Timer() : AnimateTarget 7, sw34, Target34Timer : End Sub
Sub Target35Timer_Timer() : AnimateTarget 8, sw35, Target35Timer : End Sub





' --- Texture-update light/primitive pairs (data-driven) ---
Dim TexLights(5), TexPrims(5), TexOnImgs(5), TexOffImgs(5), TexLastState(5)
Const TexPairCount = 6

Sub InitTexturePairs()
    Dim i
    Set TexLights(0) = Light029 : Set TexPrims(0) = Cap01 : TexOnImgs(0) = "Playfield-elements-on" : TexOffImgs(0) = "Playfield-elements-off"
    Set TexLights(1) = Light030 : Set TexPrims(1) = Cap02 : TexOnImgs(1) = "Playfield-elements-on" : TexOffImgs(1) = "Playfield-elements-off"
    Set TexLights(2) = Light031 : Set TexPrims(2) = Cap03 : TexOnImgs(2) = "Playfield-elements-on" : TexOffImgs(2) = "Playfield-elements-off"
    Set TexLights(3) = Light032 : Set TexPrims(3) = Cap04 : TexOnImgs(3) = "Playfield-elements-on" : TexOffImgs(3) = "Playfield-elements-off"
    Set TexLights(4) = Light033 : Set TexPrims(4) = Cap05 : TexOnImgs(4) = "Playfield-elements-on" : TexOffImgs(4) = "Playfield-elements-off"
    Set TexLights(5) = L15      : Set TexPrims(5) = ShipLight : TexOnImgs(5) = "Rocks-on" : TexOffImgs(5) = "Rocks-off"
    For i = 0 To 5 : TexLastState(i) = -1 : Next
End Sub

Sub TextureUpdateTimer_Timer()
    Dim i, st
    For i = 0 To 5
        st = TexLights(i).State
        If st <> TexLastState(i) Then
            If st = 1 Then TexPrims(i).image = TexOnImgs(i) Else TexPrims(i).image = TexOffImgs(i)
            TexLastState(i) = st
        End If
    Next
End Sub





'*********
' Switches
'*********

' Slings
Dim LStep, RStep

Sub LeftSlingShot_Slingshot
    PlaySoundAt SoundFX("fx_slingshot", DOFContactors), Lemk
    LeftSling4.Visible = 1
    Lemk.RotX = 26
    LStep = 0
    vpmTimer.PulseSw 59
    LeftSlingShot.TimerEnabled = 1
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 1:LeftSling4.Visible = 0:LeftSLing3.Visible = 1:Lemk.RotX = 14
        Case 2:LeftSLing3.Visible = 0:LeftSLing2.Visible = 1:Lemk.RotX = 2
        Case 3:LeftSLing2.Visible = 0:Lemk.RotX = -20:LeftSlingShot.TimerEnabled = 0
    End Select
    LStep = LStep + 1
End Sub

Sub RightSlingShot_Slingshot
    PlaySoundAt SoundFX("fx_slingshot", DOFContactors), Remk
    RightSling4.Visible = 1
    Remk.RotX = 26
    RStep = 0
    vpmTimer.PulseSw 62
    RightSlingShot.TimerEnabled = 1
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 1:RightSLing4.Visible = 0:RightSLing3.Visible = 1:Remk.RotX = 14
        Case 2:RightSLing3.Visible = 0:RightSLing2.Visible = 1:Remk.RotX = 2
        Case 3:RightSLing2.Visible = 0:Remk.RotX = -20:RightSlingShot.TimerEnabled = 0
    End Select
    RStep = RStep + 1
End Sub




'********************  Spinning Discs Animation Timer ****************************
Dim SpinnerMotorOff, SpinnerStep, ss

Sub SolSpinWheelsMotor(enabled)
	If enabled Then
		Ttable.MotorOn = True
		SpinnerStep = 10

		SpinnerMotorOff = False
		SpinnerTimer.Interval = 10
		SpinnerTimer.enabled = True
	Else
		SpinnerMotorOff = True
		Ttable.MotorOn = False
	end If
End Sub

Sub SpinnerTimer_Timer()
	If Not(SpinnerMotorOff) Then
		spindisk.ObjRotZ  = ss
		ss = ss + SpinnerStep
	Else
		if SpinnerStep < 0 Then
			SpinnerTimer.enabled = False
		Else
		'slow the rate of spin by decreasing rotation step
			SpinnerStep = SpinnerStep - 0.05
			
			spindisk.ObjRotZ  = ss
			ss = ss + SpinnerStep
		End If
	End If
	if ss > 360 then ss = ss - 360
End Sub


'SWITCHES'--------------------------------------------------------------------------																				'1=Left UK Button																				'2=Coin4																				'3=Coin6																				'4=Coin2																				'5=Coin3																				'6=Coin1																				'7=Coin5																				'8=Right UK Button																				'9=NOT USED																				'10=NOT USEDSub Drain_Hit:bsTrough.AddBall Me:End Sub										'11,12,13,14,15Sub S16_Hit:Controller.Switch(16)=1:End Sub										'16Sub S16_unHit:Controller.Switch(16)=0:End Sub
Sub Target17_Hit()
	vpmTimer.PulseSw 17
    TargetSteps(0) = 1 : Target17Timer.Enabled = True
End Sub

Sub Target18_Hit()
	vpmTimer.PulseSw 18
    TargetSteps(1) = 1 : Target18Timer.Enabled = True
End Sub

Sub Target19_Hit()
    vpmTimer.PulseSw 19
    TargetSteps(2) = 1 : Target19Timer.Enabled = True
End Sub
Sub S20_Hit:Controller.Switch(20)=1:End Sub										'20Sub S20_unHit:Controller.Switch(20)=0:End SubSub S21_Hit:Controller.Switch(21)=1:End Sub										'21Sub S21_unHit:Controller.Switch(21)=0:End Sub																				'22=NOT USED																				'23=NOT USED																				'24=NOT USEDSub Target25_Hit()
    vpmTimer.PulseSw 25
    TargetSteps(3) = 1 : Target25Timer.Enabled = True
End Sub

Sub Target26_Hit()
    vpmTimer.PulseSw 26
    TargetSteps(4) = 1 : Target26Timer.Enabled = True
End Sub
Sub Target27_Hit()
    vpmTimer.PulseSw 27
    TargetSteps(5) = 1 : Target27Timer.Enabled = True
End Sub									'27																				'28=NOT USED																				'29=NOT USEDSub S30_Hit:Controller.Switch(30)=1:End Sub										'30Sub S30_unHit:Controller.Switch(30)=0:End SubSub S31_Hit:Controller.Switch(31)=1:End Sub										'31Sub S31_unHit:Controller.Switch(31)=0:End SubSub S32_Hit:Controller.Switch(32)=1:End Sub										'32Sub S32_unHit:Controller.Switch(32)=0:End Sub
Sub Target33_Hit()
    vpmTimer.PulseSw 33
    TargetSteps(6) = 1 : Target33Timer.Enabled = True
End Sub

Sub Target34_Hit()
    vpmTimer.PulseSw 34
    TargetSteps(7) = 1 : Target34Timer.Enabled = True
End Sub

Sub Target35_Hit()
    vpmTimer.PulseSw 35
    TargetSteps(8) = 1 : Target35Timer.Enabled = True
End Sub	

Sub S36_Hit:vpmTimer.PulseSw 36:End Sub											'36Sub S37_Hit:vpmTimer.PulseSw 37:End Sub											'37Sub S38_Hit:vpmTimer.PulseSw 38:End Sub											'38Sub S39_Hit:vpmTimer.PulseSw 39:End Sub											'39Sub S40_Hit:vpmTimer.PulseSw 40:End Sub											'40Sub PopExit_Hit:Me.DestroyBall:vpmTimer.PulseSwitch 41,100,"AddMystery":End Sub	'41																				'42=NOT USED																				'43=NOT USED																				'44=NOT USEDSub RobotEnter_Hit :PlaySound "fx_kicker_enter":Me.DestroyBall:vpmTimer.PulseSwitch 45,100,"AddBRV":Primitive006.z=-40:primitive007.z=-40:Light035.state=2:End Sub	'45=UTrough RobotSub AddBRV(swNo):bsBRVUK.AddBall 0:End SubSub CenterHole_Hit :PlaySound "fx_kicker_enter":bsCVUK.AddBall Me:End Sub										'46Sub AddMystery(swNo):bsCVUK.AddBall 0:End SubSub TRHole_Hit:bsTRVUK.AddBall Me:End Sub										'47																				'48=Bottom Right VUKSub S49_Spin:vpmTimer.PulseSw 49:End Sub										'49Sub S50_Spin:vpmTimer.PulseSw 50:End Sub										'50Sub S51_Hit:Controller.Switch(51)=1:End Sub										'51Sub S51_unHit:Controller.Switch(51)=0:End SubSub S52_Hit:Controller.Switch(52)=1:End Sub										'52Sub S52_unHit:Controller.Switch(52)=0:End Sub																				'53=Launch Button																				'54=Start Button																				'55=Slam Tilt																				'56=Plumb Bob TiltSub S57_Hit:Controller.Switch(57)=1:End Sub										'57Sub S57_unHit:Controller.Switch(57)=0:End SubSub S58_Hit:Controller.Switch(58)=1:End Sub										'58Sub S58_unHit:Controller.Switch(58)=0:End Sub'
'Sub LeftSlingshot_Slingshot:vpmTimer.PulseSw 59:End Sub							'59Sub S60_Hit:Controller.Switch(60)=1:End Sub										'60Sub S60_unHit:Controller.Switch(60)=0:End SubSub S61_Hit:Controller.Switch(61)=1:End Sub										'61Sub S61_unHit:Controller.Switch(61)=0:End Sub'Sub RightSlingshot_Slingshot:vpmTimer.PulseSw 62:End Sub						'62'SUPPORTING ROUTINES'--------------------------------------------------------------------------Sub Magnet3_Hit	mDMag.AddBall ActiveBall	mDMag.AttractBall ActiveBallEnd SubSub Magnet3_unHit	mDMag.RemoveBall ActiveBallEnd SubSub TT_Hit	mTurnTable.AddBall ActiveBall	mTurnTable.AffectBall ActiveBallEnd SubSub TT_unHit	mTurnTable.RemoveBall ActiveBallEnd SubSub UpdateTurnTable(aNewPos,aSpeed,aLastPos)	If aLastPos>-1 And aLastPos<10 Then SpinCounter(ALastPos).IsDropped=1	If aNewPos>-1 And aNewPos<10 Then SpinCounter(aNewPos).IsDropped=0End SubSub Trigger1_Hit:ActiveBall.VelY=.1:ActiveBall.VelX=0:End SubSub Trigger2_Hit:ActiveBall.VelY=1:ActiveBall.VelX=0:End SubSub Trigger3_Hit:ActiveBall.VelY=1:ActiveBall.VelX=0:Primitive006.z=0:primitive007.z=0:Light035.state=0:End Sub

'*******************
' Flipper Subs v3.0
'*******************

Sub SolLFlipper(Enabled)
    If Enabled Then
        PlaySoundAt SoundFX("fx_flipperup", DOFFlippers), LeftFlipper
        LeftFlipper.EOSTorque = 0.75:LeftFlipper.RotateToEnd
    Else
        PlaySoundAt SoundFX("fx_flipperdown", DOFFlippers), LeftFlipper
        LeftFlipper.EOSTorque = 0.1:LeftFlipper.RotateToStart
    End If
End Sub

Sub SolRFlipper(Enabled)
    If Enabled Then
        PlaySoundAt SoundFX("fx_flipperup", DOFFlippers), RightFlipper
        RightFlipper.EOSTorque = 0.75:RightFlipper.RotateToEnd
    Else
        PlaySoundAt SoundFX("fx_flipperdown", DOFFlippers), RightFlipper
        RightFlipper.EOSTorque = 0.1:RightFlipper.RotateToStart
    End If
End Sub

Sub LeftFlipper_Collide(parm)
    PlaySound "fx_rubber_flipper", 0, parm / 60, pan(ActiveBall), 0.2, 0, 0, 0, AudioFade(ActiveBall)
End Sub

Sub RightFlipper_Collide(parm)
    PlaySound "fx_rubber_flipper", 0, parm / 60, pan(ActiveBall), 0.2, 0, 0, 0, AudioFade(ActiveBall)
End Sub

'************************************
' Diverse Collection Hit Sounds v3.0
'************************************

Sub aMetals_Hit(idx):PlaySoundAtBall "fx_MetalHit":End Sub
Sub aRubber_Bands_Hit(idx):PlaySoundAtBall "fx_rubber_band":End Sub
Sub aRubber_LongBands_Hit(idx):PlaySoundAtBall "fx_rubber_longband":End Sub
Sub aRubber_Posts_Hit(idx):PlaySoundAtBall "fx_rubber_post":End Sub
Sub aRubber_Pins_Hit(idx):PlaySoundAtBall "fx_rubber_pin":End Sub
Sub aRubber_Pegs_Hit(idx):PlaySoundAtBall "fx_rubber_peg":End Sub
Sub aPlastics_Hit(idx):PlaySoundAtBall "fx_PlasticHit":End Sub
Sub aGates_Hit(idx):PlaySoundAtBall "fx_Gate":End Sub
Sub aWoods_Hit(idx):PlaySoundAtBall "fx_Woodhit":End Sub
'Sub aTargets_Hit(idx):PlaySoundAtBall "fx_target":End Sub

'***************************************************************
'             Supporting Ball & Sound Functions v3.0
'  includes random pitch in PlaySoundAt and PlaySoundAtBall
'***************************************************************

Dim TableWidth, TableHeight

TableWidth = Table1.width
TableHeight = Table1.height

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
    Vol = Csng(BallVel(ball) ^2 / 2000)
End Function

Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = ball.x * 2 / TableWidth-1
    If tmp > 0 Then
        Pan = Csng(tmp ^10)
    Else
        Pan = Csng(-((- tmp) ^10))
    End If
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
    BallVel = (SQR((ball.VelX ^2) + (ball.VelY ^2)))
End Function

Function AudioFade(ball) 'only on VPX 10.4 and newer
    Dim tmp
    tmp = ball.y * 2 / TableHeight-1
    If tmp > 0 Then
        AudioFade = Csng(tmp ^10)
    Else
        AudioFade = Csng(-((- tmp) ^10))
    End If
End Function

Sub PlaySoundAt(soundname, tableobj) 'play sound at X and Y position of an object, mostly bumpers, flippers and other fast objects
    PlaySound soundname, 0, 1, Pan(tableobj), 0.1, 0, 0, 0, AudioFade(tableobj)
End Sub

Sub PlaySoundAtBall(soundname) ' play a sound at the ball position, like rubbers, targets, metals, plastics
    PlaySound soundname, 0, Vol(ActiveBall), pan(ActiveBall), 0.4, 0, 0, 0, AudioFade(ActiveBall)
End Sub


'******************
' RealTime Updates
'******************

Sub RealTime_Timer
    RollingUpdate
 '   LeftFlipperTop.RotZ = LeftFlipper.CurrentAngle
'    RightFlipperTop.RotZ = RightFlipper.CurrentAngle
'    hulkbody.objRotZ = body.CurrentAngle
 '   hulkarms.objRotZ = body.CurrentAngle
 '   hulkarms.Rotx = arms.CurrentAngle *2
 '   gateleftp.Rotz = gateleft.CurrentAngle
 '   gateleftp2.Rotz = gateleft2.CurrentAngle
 '   gaterightp.Rotz = gateright.CurrentAngle
End Sub

'***********************************************
'   JP's VP10 Rolling Sounds + Ballshadow v3.0
'   uses a collection of shadows, aBallShadow
'***********************************************

Const tnob = 5 ' total number of balls
Const lob = 0   'number of locked balls
Const maxvel = 42 'max ball velocity
ReDim rolling(tnob)

' Pre-build rolling sound strings at init to avoid per-frame concatenation
Dim BallRollStr(5)
Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
        BallRollStr(i) = "fx_ballrolling" & i
    Next
End Sub
InitRolling

Sub RollingUpdate()
    Dim BOT, b, ballpitch, ballvol, speedfactorx, speedfactory
    Dim bx, by, bz, bvx, bvy, bvz, bvel, tW2, tH2, panVal, fadeVal, tmp
    BOT = GetBalls
    tW2 = 2 / TableWidth
    tH2 = 2 / TableHeight

    ' stop the sound of deleted balls and hide the shadow
    For b = UBound(BOT) + 1 to tnob
        rolling(b) = False
        StopSound BallRollStr(b)
        aBallShadow(b).Y = 3000
    Next

    ' exit the sub if no balls on the table
    If UBound(BOT) = lob - 1 Then Exit Sub

    ' play the rolling sound for each ball and draw the shadow
    For b = lob to UBound(BOT)
        ' Cache COM properties into locals (single read across VBS/VPX boundary)
        bx = BOT(b).X : by = BOT(b).Y : bz = BOT(b).z
        bvx = BOT(b).VelX : bvy = BOT(b).VelY : bvz = BOT(b).VelZ

        aBallShadow(b).X = bx
        aBallShadow(b).Y = by + 20

        ' Inline BallVel — avoid function call + redundant COM reads
        bvel = SQR(bvx * bvx + bvy * bvy)

        If bvel > 1 Then
            If bz < 30 Then
                ballpitch = bvel * 20
                ballvol = Csng(bvel * bvel / 2000)
            Else
                ballpitch = bvel * 20 + 25000
                ballvol = Csng(bvel * bvel / 200)
            End If
            rolling(b) = True
            ' Inline Pan and AudioFade — avoid function calls + redundant COM reads
            tmp = bx * tW2 - 1
            If tmp > 0 Then panVal = Csng(tmp ^ 10) Else panVal = Csng(-((- tmp) ^ 10))
            tmp = by * tH2 - 1
            If tmp > 0 Then fadeVal = Csng(tmp ^ 10) Else fadeVal = Csng(-((- tmp) ^ 10))
            PlaySound BallRollStr(b), -1, ballvol, panVal, 0, ballpitch, 1, 0, fadeVal
        Else
            If rolling(b) = True Then
                StopSound BallRollStr(b)
                rolling(b) = False
            End If
        End If

        ' rothbauerw's Dropping Sounds
        If bvz < -1 And bz < 55 And bz > 27 Then
            tmp = bx * tW2 - 1
            If tmp > 0 Then panVal = Csng(tmp ^ 10) Else panVal = Csng(-((- tmp) ^ 10))
            tmp = by * tH2 - 1
            If tmp > 0 Then fadeVal = Csng(tmp ^ 10) Else fadeVal = Csng(-((- tmp) ^ 10))
            PlaySound "fx_balldrop", 0, ABS(bvz) / 17, panVal, 0, bvel * 20, 1, 0, fadeVal
        End If

        ' jps ball speed control
        If bvx <> 0 And bvy <> 0 Then
            speedfactorx = ABS(maxvel / bvx)
            speedfactory = ABS(maxvel / bvy)
            If speedfactorx < 1 Then
                BOT(b).VelX = bvx * speedfactorx
                BOT(b).VelY = bvy * speedfactorx
                bvx = bvx * speedfactorx : bvy = bvy * speedfactorx
            End If
            If speedfactory < 1 Then
                BOT(b).VelX = bvx * speedfactory
                BOT(b).VelY = bvy * speedfactory
            End If
        End If
    Next
End Sub

Dim LastLFlipAngle, LastRFlipAngle
LastLFlipAngle = -999 : LastRFlipAngle = -999

Sub flipperTimer_Timer
    Dim la, ra
    la = LeftFlipper.CurrentAngle : ra = RightFlipper.CurrentAngle
    If la <> LastLFlipAngle Then FlipperLSh.RotZ = la : LastLFlipAngle = la
    If ra <> LastRFlipAngle Then FlipperRSh.RotZ = ra : LastRFlipAngle = ra
End Sub

'**********************
' Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
    PlaySound("fx_collide"), 0, Csng(velocity) ^2 / 2000, Pan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub



Sub sw24p006_Hit()
	
End Sub