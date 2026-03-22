' ****************************************************************
'                   Total Nuclear Annihilation v1.4
' ****************************************************************
Option Explicit
Randomize

Const Disable_TNA_Message	= 1		'CHANGE THIS TO 1 TO DISABLE THE TNA START UP MESSAGE
' This release comes with the free song from the TNA soundtrack available here: http://www.scottdanesi.com/?page_id=19  
' For the full music experience, you will need to BUY the TNA Album and convert the songs from FLAC format to mp3 format
' with a tool like this:  https://www.freac.org/  Rename all mp3 files to TNA1.mp3 through TNA10.mp3 
' and replace the existing mp3 files. (Scarlet.mp3 is not used)


Const UseUltraDMD			= 1		'0 = Off.  1 = Enable UltraDMD. 2 - Try 2 if enabling UltraDMD crashes (Windows locale setting issue for non-English setting)
Const UseApronDMD			= 0		'0 = Off.  1 = Enable DMD on Apron

Const BallsPerGame			= 3  	'Default: 3 balls
Const ReactorDifficulty 	= 2		'Default: 2 (1-Easy, 2-Med, 3-Hard)
Const ReactorLevelMax 		= 9		'Default: 9 (1-9 Reactors)
Const SongVolume 			= 0.5
Const bFreePlay 			= False	'True = FreePlay.  False = Coins
Const GIcolor 				= "white" 	'Colors:  "white", "blue"

Const BallSaverTime 		= 12   	'Default: 12 seconds
Const DropTargetResetTime 	= 5		'Default: 5 seconds during Multiball Jackpot
Const ReactorPercentLossTime= 3		'Default: After Reactor 3, Reactor Percent drops back down by 1 every 3 seconds
Const ExtraBallAward1 		= 3		'Default: Extra Ball at Reactor 3 Critical stage
Const ExtraBallAward2 		= 6		'Default: Extra Ball at Reactor 6 Critical stage
Const KeepLaneSaves 		= 1		'Default: 1 (Yes. 0=No)
Const AutoPlungeDelay 		= 1.0	'Default: 1.0 seconds
Const LeftScoopStrength		= 50	'Default: 50	adjust stregth of left scoop KickOut
Const RightScoopStrength	= 45	'Default: 45	adjust stregth of right scoop KickOut
Const BallSearchTime		= 20    'Missing Ball search kicks in after xx seconds (Default: 20), if flippers not used and no switch hits
Const AddRightSpinner		= 1		' 0 = Original table has 1 spinner.  1 = If you like more cowbell, I mean more spinner
Const FlipperPhysicsMode	= 1     '1 = VPX Flippers,   2 = NFozzy flipper tweaks
Const Reactor1Music			= 2		'1 = Always play TNA song first then random songs.  2 = Random song from the beginning
Const ResetHighScore		= 0		'0 = Keep Scores.  1 = Reset all high scores.  START TABLE ONCE to reset high scores and then set this back to 0
Const UsePinup				= 0		'NOT IMPLEMENTED YET 0 = Off.  1 = Enable PinUp 
Const UltraDMDUpdateTime	= 5000	'UltraDMD update time (msec).  Increase value if you encounter stutter with UltraDMD on

'============================
'  DOF Events for this table are listed at the bottom of this script
'============================


' ****************************************************************
Const Testmode 				= 0		'Testing only
Const debugGeneral 			= 0		'For debug only
Const debugReactor 			= 0		'For debug only
Const debugMultiball 		= 0 	'For debug only
Const debugGrid 			= 0 	'For debug only
Const debugDestroyRAD 		= 0 	'For debug only
Const debugMysteryAward 	= 0 	'For debug only
Const debugHighScore		= 0 	'For debug only


' Improved directional sounds 2019 October : ' !! NOTE : Table not verified yet !!
' Volume devided by - lower gets higher sound

Const VolDiv = 5000    ' Lower number, louder ballrolling/collition sound
Const VolCol = 10      ' Ball collition divider ( voldiv/volcol )

' The rest of the values are multipliers
'
'  .5 = lower volume
' 1.5 = higher volume
Const VolBump   = 2    ' Bumpers volume.
Const VolRol    = 1    ' Rollovers volume.
Const VolGates  = 1    ' Gates volume.
Const VolMetal  = 1    ' Metals volume.
Const VolRB     = 1    ' Rubber bands volume.
Const VolRH     = 1    ' Rubber hits volume.
Const VolPo     = 1    ' Rubber posts volume.
Const VolPi     = 1    ' Rubber pins volume.
Const VolPlast  = 1    ' Plastics volume.
Const VolTarg   = 1    ' Targets volume.
Const VolWood   = 1    ' Woods volume.
Const VolKick   = 1    ' Kicker volume.
Const VolSpin   = 1.5  ' Spinners volume.
Const VolFlip   = 1    ' Flipper volume.

'============================
'   PinUp Player USER Config 
'============================
Const PuPDMDDriverType		= 0   	' 0=LCD DMD, 1=RealDMD 2=FULLDMD (large/High LCD)
Const useRealDMDScale		= 1    	' 0 or 1 for RealDMD scaling.  Choose which one you prefer.
Const useDMDVideos			= true  ' true or false to use DMD splash videos.
Const pGameName				= "tna" 'pupvideos foldername, probably set to cGameName in realworld



On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs in order to run this table, available in the vp10 package"
On Error Goto 0

Dim UltraDMD
Sub LoadUltraDMD
    Set UltraDMD = CreateObject("UltraDMD.DMDObject")
    UltraDMD.Init
	uDMDScoreTimer.Interval = UltraDMDUpdateTime
	uDMDScoreTimer.Enabled = 1
	uDMDScoreUpdate
End Sub

Sub uDMDScoreTimer_Timer
	uDMDScoreUpdate
End Sub

Sub uDMDScoreUpdate
	If hsbModeActive Then Exit Sub
	If Timer < udmdHoldOffUntil Then Exit Sub
	If UseUltraDMD = 1 Then
		If TestMode = 0 Then
			UltraDMD.DisplayScoreboard00 PlayersPlayingGame, CurrentPlayer, Score(1), Score(2), Score(3), Score(4), "RVal:" & ReactorValue(CurrentPlayer), "Ball " & Balls
		Else
			UltraDMD.DisplayScoreboard00 PlayersPlayingGame, CurrentPlayer, Score(1), Score(2), Score(3), Score(4), "RV:" & ReactorValue(CurrentPlayer) & ":BP:" & BallsOnPlayfield, "Ball " & Balls
		End If
	ElseIf UseUltraDMD = 2 Then
		If TestMode = 0 Then
			UltraDMD.DisplayScoreboard PlayersPlayingGame, CurrentPlayer, Score(1), Score(2), Score(3), Score(4), "RVal:" & ReactorValue(CurrentPlayer), "Ball " & Balls
		Else
			UltraDMD.DisplayScoreboard PlayersPlayingGame, CurrentPlayer, Score(1), Score(2), Score(3), Score(4), "RV:" & ReactorValue(CurrentPlayer) & ":BP:" & BallsOnPlayfield, "Ball " & Balls
		End If
	End If

End Sub


Const cGameName = "tna"
Const BallSize = 50 ' 50 is the normal size

' Load the core.vbs for supporting Subs and functions
LoadCoreVBS

Sub LoadCoreVBS
    On Error Resume Next
    ExecuteGlobal GetTextFile("core.vbs")
    If Err Then MsgBox "Can't open core.vbs"
    On Error Goto 0
End Sub

Sub startB2S(aB2S)
    If B2SOn Then
        Controller.B2SSetData 1, 0
        Controller.B2SSetData 2, 0
        Controller.B2SSetData 3, 0
        Controller.B2SSetData 4, 0
        Controller.B2SSetData 5, 0
        Controller.B2SSetData 6, 0
        Controller.B2SSetData 7, 0
        Controller.B2SSetData 8, 0
        Controller.B2SSetData aB2S, 1
    End If
End Sub

' Define any Constants
Const TableName = "TNA"
Const myVersion = "1.0.0"
Const MaxPlayers = 4
Const MaxMultiplier = 4 'limit to 4x in this game
Const MaxMultiballs = 4  ' max number of balls during multiballs

' Define Global Variables
Dim PlayersPlayingGame
Dim CurrentPlayer
Dim Credits
Dim BonusPoints(4)
Dim BonusHeldPoints(4)
Dim BonusMultiplier(4)
Dim bBonusHeld
Dim BallsRemaining(4)
Dim ExtraBallsAwards(4)
Dim Score(4)
Dim ReactorScore(4)
Dim HighScore(4)
Dim HighScoreName(4)
Dim Tilt
Dim TiltSensitivity
Dim Tilted
Dim TotalGamesPlayed
Dim mBalls2Eject
Dim SkillshotValue
Dim HandsFreeSkillshotInsert
Dim bAutoPlunger
Dim bInstantInfo
Const Quotemode 			= 0

' Define Game Control Variables
Dim LastSwitchHit
Dim BallsOnPlayfield
Dim BallsInLock
Dim BallsInHole

' Define Game Flags
Dim bGameInPlay
Dim bOnTheFirstBall
Dim bBallInPlungerLane
Dim bBallSaverActive
Dim bBallSaverReady
Dim bMultiBallMode
Dim DrainBonusReady
Dim bMusicOn
Dim GIcolorOpposite

'Skillshot
Dim SkillshotReady	'0 = Off, 1 = Start, 2 = Plunged
Dim bSkillshotSelect 'used to select the skillshot you want

Dim bExtraBallWonThisBall
Dim bJustStarted
Dim tablewidth: tablewidth = table1.width
Dim tableheight: tableheight = table1.height
Dim lastLFAngle, lastRFAngle
Dim udmdHoldOffUntil: udmdHoldOffUntil = 0

Dim plungerIM 'used mostly as an autofire plunger
'Dim ttable, cbleft, cbright

' *********************************************************************
'                Visual Pinball Defined Script Events
' *********************************************************************
Sub Table1_Init()
    Dim i

    Randomize
	If UsePinup = 1 Then
		PUPInit
		pDMDStartGame
	End If

    LoadEM
	
	If ResetHighScore = 1 then Reseths

	Spinner2Enable

	If Disable_TNA_Message = 1 Then 
		flasher001.visible = False
	Else
		flasher001.visible = True: 	flasher001.TimerInterval = 15000: 	flasher001.TimerEnabled = True
	End If 
	If TestMode = 1 Then flasher001.visible = True: 	flasher001.TimerInterval = 500: 	flasher001.TimerEnabled = False:  flasher001.TimerEnabled = True

    'Impulse Plunger as autoplunger
    Const IMPowerSetting = 43 ' Plunger Power
    Const IMTime = 1.1        ' Time in seconds for Full Plunge
    Set plungerIM = New cvpmImpulseP
    With plungerIM
        .InitImpulseP swplunger, IMPowerSetting, IMTime
        .Random 1.5
        .InitExitSnd SoundFX("fx_kicker", DOFContactors), SoundFX("fx_solenoid", DOFContactors)
        .CreateEvents "plungerIM"
    End With

	If GIcolor = "blue" Then
		GIColorOpposite = "white"
	Else
		GIColorOpposite = "blue"
	End If

    'load saved values, highscore, names, jackpot
    Loadhs
	If ((bFreePlay = True) Or (Credits > 0)) Then DOF 140, DOFOn
		
    'Init main variables

	' start the UltraDMD
	If UseUltraDMD > 0 Then LoadUltraDMD

    ' initalise the DMD display
    DMD_Init


    ' initialse any other flags
	CoopMode = 0
    bOnTheFirstBall = False
    bBallInPlungerLane = False
    bBallSaverActive = False
    bBallSaverReady = False
    bMultiBallMode = False
    bGameInPlay = False
    bAutoPlunger = False
    bMusicOn = True
    SetBallsOnPlayfield 0
    BallsInLock = 0
    BallsInHole = 0
    LastSwitchHit = ""
    Tilt = 0
    TiltSensitivity = 6
    Tilted = False
    bBonusHeld = False
    bJustStarted = True
    bInstantInfo = False


    'EndOfGame()
	StartRainbow "all"
	PlaySong "tna10.mp3", 2
	ShowTableInfo
	'LightSeqAttract.Play SeqRandom, 40, 1000, 0
	StartAttractMode 1

    ' Misc. VP table objects Initialisation, droptargets, animations...
    VPObjects_Init

    ' Remove the cabinet rails if in FS mode
    If Table1.ShowDT = False then
        lrail.Visible = False
        rrail.Visible = False

    End If
End Sub
Sub flasher001_Timer: Flasher001.visible = False: Flasher001.TimerEnabled = False: End Sub

Dim ComboLoopFlag

Sub SetLastSwitchHit (value)
	Dim comboscore

	'check for combo first
	If (StrComp(value, "swRLoop") = 0) Then
		If ComboLoopFlag > 0 Then 	'check if value is right loop switch

			comboscore = 5000 * (2 ^ ComboLoopFlag)
			If comboscore > 160000 then comboscore = 160000

			AddScore (comboscore)
			'MSGBOX "COMBO " & ComboLoopFlag & "!"
			DOF 160, DOFPulse: DMD "", eNone, Centerline(1, ("COMBO")), eNone, "", eNone, CenterLine(3, FormatScore(comboscore)), eBlinkFast, 800, True, "tna_combo"
			UDMD "  COMBO  ", comboscore, 800
			GiGameImmediate 6, "orange"
		end if

	elseif (StrComp(value, "swLLoop") = 0) AND (StrComp(LastSwitchHit, "swRLoop") = 0) then 'Loop detected
		ComboLoopFlag = ComboLoopFlag + 1
	else
		ComboLoopFlag = 0
	End If
		
	LastSwitchHit = value

	'Reset Ball Search Timer
	If (bGameInPlay AND NOT Tilted AND BallsOnPlayfield > 0) Then
		BallSearchTimer.Enabled = False
		BallSearchTimer.Interval = BallSearchTime * 1000
		BallSearchTimer.Enabled = True
	End If
End Sub

Sub BallSearchTimer_Timer	'only triggered if no switches hit for x seconds

	If (bGameInPlay AND NOT Tilted AND BallsOnPlayfield > 0) Then
		If ((LeftFlipper.CurrentAngle > 90 ) AND (RightFlipper.CurrentAngle < -90)) Then	'If flippers are not up holding a ball
			If bBallInPlungerLane = 0 Then 'If ball not resting in plungerlane

				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BALL SEARCH"), eNone, 2000, True, "tna_leftscoopawardeject"
				UDMD "BALL SEARCH", "Ejecting ball", 2000
				vpmtimer.addtimer 1100, "BallSearchEject '"
			End If
		End If
	End If
End Sub

Sub BallSearchEject
	LeftScoop.Createball
	LeftScoop.Kick 165, LeftScoopStrength, 1.56				
	LeftScoop.Enabled = True
End Sub

'******
' Section; Keys
'******
Dim CoopMode	
Dim kickertest
kickertest = 8
Sub Table1_KeyDown(ByVal Keycode)
    If Keycode = ((AddCreditKey)  AND (bFreePlay = 0))Then
        Credits = Credits + 1
        DOF 140, DOFOn
        If(Tilted = False)Then
			If hsbModeActive = False Then
				DMDFlush
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "CREDITS: " & Credits), eNone, 500, True, "fx_coin"
				UDMD "CREDITS: " & Credits, "", 500
				If NOT bGameInPlay Then ShowTableInfo
			End If
        End If
    End If

'	If ReactorLevel(CurrentPlayer) <= ReactorLevelMax Then
		If keycode = PlungerKey Then
			Plunger.Pullback
			PlaySound "fx_plungerpull"

		End If
'	End If
' ************ DEBUG KEYS Sect  *******
' ************ DEBUG KEYS Sect  *******
	
	If TestMode = 1 Then
		If keycode = 17 Then	'W key
			ByPassGrid
			debug.print "*****SUB:" & "Table1_KeyDown, Testmode:REACTOR READY: GridTargets set"
		End If
		If keycode = 18 Then	'E key
			CheckReactorStart
			debug.print "*****SUB:" & "Table1_KeyDown, Testmode:REACTOR STARTED: CheckReactorStart"
		End If
		If keycode = 19 Then	'R key
			SetReactorPercent 100
			debug.print "*****SUB:" & "Table1_KeyDown, Testmode:REACTOR CRITICAL: SetReactorPercent 100"
		End If
		If keycode = 20 Then	'T key
				DecreaseReactorDestroyCount lD3, lBumperFlash
				DecreaseReactorDestroyCount lD3, lBumperFlash	
				DecreaseReactorDestroyCount lRad1, fRad1
				DecreaseReactorDestroyCount lRad2, fRad2
				DecreaseReactorDestroyCount lRad3, fRad3
				DecreaseReactorDestroyCount lD1, fD1	
				DecreaseReactorDestroyCount lD2, fD2
			debug.print "*****SUB:" & "Table1_KeyDown, Testmode:REACTOR DESTROYED: DecreaseReactorDestroyCount"
		End If
		
		If keycode = 30 Then 'A key
			RotateLaneLightsRight
			Sw1_hit
		End If
		If keycode = 31 Then 'S key
			TargetRAD3_Hit
			TargetRAD2_Hit
			TargetRAD1_Hit
		End If

		If keycode = 33 Then	'F key
			AddBonusMultiplier 1
			debug.print "*****SUB:" & "Table1_KeyDown, Testmode:AddBonusMultiplier 1"
		End If

		If keycode = 34 Then	'G key
			AwardSave 1
			debug.print "*****SUB:" & "Table1_KeyDown, Testmode:AwardSave 1"
		End If
		If keycode = 35 Then	'H key
			TestHitTarget
			debug.print "*****SUB:" & "Table1_KeyDown, Testmode:TestHitTarget"
		End If
	End If
' ************ DEBUG KEYS Sect  *******
' ************ DEBUG KEYS Sect  *******

    If hsbModeActive Then
        EnterHighScoreKey(keycode)
        Exit Sub
    End If

    ' Table specific

    ' Normal flipper action

    If bGameInPlay AND NOT Tilted Then

        If keycode = LeftTiltKey Then Nudge 90, 6:Playsound SoundFX("fx_nudge",0), 0, 1, -0.1, 0.25:CheckTilt
        If keycode = RightTiltKey Then Nudge 270, 6:Playsound SoundFX("fx_nudge",0), 0, 1, 0.1, 0.25:CheckTilt
        If keycode = CenterTiltKey Then Nudge 0, 7:Playsound SoundFX("fx_nudge",0), 0, 1, 1, 0.25:CheckTilt
        If keycode = MechanicalTilt Then Playsound SoundFX("fx_nudge",0),0,1,1,0,25:CheckTilt

		If ReactorLevel(CurrentPlayer) <= ReactorLevelMax Then
			If keycode = LeftFlipperKey Then SolLFlipper 1:InstantInfoTimer.Enabled = False
			If keycode = RightFlipperKey Then SolRFlipper 1:InstantInfoTimer.Enabled = False
		End If

		If keycode = StartGameKey Then
			If((PlayersPlayingGame < MaxPlayers)AND(bOnTheFirstBall = True))Then

				If(bFreePlay = True)Then
					PlayersPlayingGame = PlayersPlayingGame + 1
					If B2SOn Then Controller.B2SSetScorePlayer PlayersPlayingGame, 0
					TotalGamesPlayed = TotalGamesPlayed + 1
					PlaySound "tna_superskillshot"
					DMD "", eNone, "_", eNone, CenterLine(2, PlayersPlayingGame & " PLAYERS"), eBlink, "", eNone, 500, True, ""
					UDMD PlayersPlayingGame & " PLAYERS", "", 500
				Else
					If(Credits > 0)then
						PlayersPlayingGame = PlayersPlayingGame + 1
						If B2SOn Then Controller.B2SSetScorePlayer PlayersPlayingGame, 0
						TotalGamesPlayed = TotalGamesPlayed + 1
						Credits = Credits - 1
						If Credits = 0 Then DOF 140, DOFOff
						PlaySound "tna_superskillshot"
						DMD "", eNone, "_", eNone, CenterLine(2, PlayersPlayingGame & " PLAYERS"), eBlink, "", eNone, 500, True, ""
						UDMD PlayersPlayingGame & " PLAYERS", "", 500
					Else
						' Not Enough Credits to start a game.
						DOF 140, DOFOff
						DMDFlush
						DMD "", eNone, CenterLine(1, "CREDITS " & Credits), eNone, CenterLine(2, "INSERT COIN"), eNone, "", eNone, 500, True, "tna_electricity1"
						UDMD "INSERT COIN", "", 500
					End If
				End If
			End If
		End If
	Else ' If (GameInPlay) Game not started yet

		If keycode = StartGameKey Then
			If(bFreePlay = True)Then
				If(BallsOnPlayfield = 0)Then
					ResetForNewGame()
				End If
			Else
				If(Credits > 0)Then
					If(BallsOnPlayfield = 0)Then
						Credits = Credits - 1
						If Credits = 0 Then DOF 140, DOFOff
						ResetForNewGame()
					End If
				Else
					' Not Enough Credits to start a game.
					DOF 140, DOFOff
					DMDFlush
					DMD "", eNone, CenterLine(1, "CREDITS " & Credits), eNone, CenterLine(2, "INSERT COIN"), eBlink, "", eNone, 500, True, ""
					UDMD "INSERT COIN", "", 500
					PlaySound "tna_electricity1", 0, 1, -0.05, 0.05
					ShowTableInfo
				End If
			End If
		End If
		If keycode = LeftMagnaSave or  keycode = RightMagnaSave Then	
			If CoopMode = 0 Then 
				CoopMode = 1
				DMDFlush
				DMD "", eNone, CenterLine(1, "CO-OP MODE"), eNone, CenterLine(2, "ALL VS MACHINE"), eBlink, "", eNone, 10000, True, "tna_superskillshot"
				UDMD "CO-OP MODE", "ALL VS MACHINE", 10000
			Elseif CoopMode = 1 Then
				CoopMode = 2
				DMDFlush
				DMD "", eNone, CenterLine(1, "CO-OP MODE"), eNone, CenterLine(2, "P1 P3 VS P2 P4"), eBlink, "", eNone, 10000, True, "tna_superskillshot"
				UDMD "CO-OP MODE", "P1 P3 VS P2 P4", 10000
			Else
				CoopMode = 0
				DMDFlush
				DMD "", eNone, CenterLine(1, "NORMAL MODE"), eNone, CenterLine(2, "NO CO-OP"), eBlink, "", eNone, 10000, True, "tna_target"
				UDMD "NORMAL MODE", "NO CO-OP", 10000
			End If
		End If

    End If ' If (GameInPlay)
End Sub


Sub Table1_KeyUp(ByVal keycode)

    If keycode = PlungerKey Then
        Plunger.Fire
		PlaySoundAtVol "fx_plunger", Plunger, 1
    End If

    If hsbModeActive Then
        Exit Sub
    End If

    ' Table specific

    If (bGameInPLay AND NOT Tilted AND (ReactorTNAAchieved(CurrentPlayer) = 0)) Then
        If keycode = LeftFlipperKey Then
            SolLFlipper 0
            InstantInfoTimer.Enabled = False
            If bInstantInfo Then
                bInstantInfo = False
                DMDScoreNow
            End If
        End If
        If keycode = RightFlipperKey Then
            SolRFlipper 0
            InstantInfoTimer.Enabled = False
            If bInstantInfo Then
                bInstantInfo = False
                DMDScoreNow
            End If

        End If
    End If

End Sub

Sub InstantInfoTimer_Timer
    InstantInfoTimer.Enabled = False
    bInstantInfo = True
    Jackpot = 1000000 + Round(Score(CurrentPlayer) / 10, 0)
    DMD "", eNone, CenterLine(1, "INSTANT INFO"), eNone, CenterLine(2, "JACKPOT"), eScrollLeft, CenterLine(3, FormatScore(Jackpot)), eScrollLeft, 800, False, ""
    DMD "", eNone, CenterLine(1, "INSTANT INFO"), eNone, CenterLine(2, "SUPERJACKPOT"), eScrollLeft, CenterLine(3, FormatScore(SuperJackpot)), eScrollLeft, 800, False, ""
    DMD "", eNone, CenterLine(1, "INSTANT INFO"), eNone, CenterLine(2, "BONUS MULTIPLIER"), eScrollLeft, CenterLine(3, BonusMultiplier(CurrentPlayer)), eScrollLeft, 800, False, ""
End Sub

Sub EndFlipperStatus
    If bInstantInfo Then
        bInstantInfo = False
        DMDScoreNow
    End If
End Sub

'*************
' Section; Pause Table
'*************

Sub table1_Paused
End Sub

Sub table1_unPaused
End Sub

Sub table1_Exit
    Savehs
	If B2SOn Then Controller.Stop
End Sub

'********************
' Section; Flippers
'********************

Sub SolLFlipper(Enabled)
    If Enabled Then
        PlaySoundAtVol SoundFXDOF("fxz_flipperupL", 101, DOFOn, DOFFlippers), LeftFlipper, 1
        PlaySoundAtVol SoundFXDOF("fxz_flipperupL", 101, DOFOn, DOFFlippers), LeftFlipper2, 1
		If FlipperPhysicsMode = 1 Then
			LeftFlipper.RotateToEnd
		Else
			LF.Fire 'LeftFlipper.RotateToEnd
		End If
        LeftFlipper2.RotateToEnd
        RotateLaneLightsLeft
    Else
        PlaySoundAtVol SoundFXDOF("fxz_flipperdownL", 101, DOFOff, DOFFlippers), LeftFlipper, 1
        PlaySoundAtVol SoundFXDOF("fxz_flipperdownL", 101, DOFOff, DOFFlippers), LeftFlipper2, 1
        LeftFlipper.RotateToStart
        LeftFlipper2.RotateToStart
    End If
End Sub

Sub SolLFlipper2(Enabled)
    If Enabled Then
        LeftFlipper.RotateToEnd
    Else
        LeftFlipper.RotateToStart
    End If
End Sub

Sub SolRFlipper(Enabled)
    If Enabled Then
        PlaySoundAtVol SoundFXDOF("fxz_flipperupr", 102, DOFOn, DOFFlippers), RightFlipper, 1
		If FlipperPhysicsMode = 1 Then
			RightFlipper.RotateToEnd
		Else
			RF.Fire 'RightFlipper.RotateToEnd
		End If
        RotateLaneLightsRight
    Else
        PlaySoundAtVol SoundFXDOF("fxz_flipperdownr", 102, DOFOff, DOFFlippers), RightFlipper, 1
        RightFlipper.RotateToStart
    End If
End Sub

' flippers hit Sound

Sub LeftFlipper_Collide(parm)
    PlaySoundAtBallVol "flip_hit_1", parm / 10
End Sub

Sub RightFlipper_Collide(parm)
    PlaySoundAtBallVol "flip_hit_1", parm / 10
End Sub

Sub LeftFlipper2_Collide(parm)
    PlaySoundAtBallVol "flip_hit_1", parm / 10
End Sub

Sub RightFlipper2_Collide(parm)
    PlaySoundAtBallVol "flip_hit_1", parm / 10
End Sub


'*****************************
' Section; CORE Targets - Bonus Multiplier
'*****************************
Sub ResetCORE()
	L1.State = 0
	L2.State = 0
	L3.State = 0
	L4.State = 0
End Sub

Sub CheckCORE
	If (L1.State = 1 and L2.State = 1 and L3.State = 1 and L4.State = 1) Then
		ResetCORE

'		'to do lightseq
'		FlashForMs l1, 2000, 100, 0
'		FlashForMs l2, 2000, 100, 0
'		FlashForMs l3, 2000, 100, 0
'		FlashForMs l4, 2000, 100, 0
'		
		AddBonusMultiplier 1
	End If
End Sub

Sub RotateLaneLightsLeft()
    Dim tmp
    tmp = l1.State
    l1.state = l2.State
    l2.State = l3.State
    l3.State = l4.State
    l4.State = tmp

    tmp = la1.State
    la1.state = la2.State
    la2.State = la3.State
    la3.State = la4.State
    la4.State = tmp

    If bSkillshotSelect Then
        SelectSkillshot(1)
	Else
		HandsFreeSkillshotInsert = -1
    End If
End Sub

Sub RotateLaneLightsRight()
    Dim tmp
    tmp = la4.State
    la4.state = la3.State
    la3.State = la2.State
    la2.State = la1.State
    la1.State = tmp

    tmp = l4.State
    l4.state = l3.State
    l3.State = l2.State
    l2.State = l1.State
    l1.State = tmp

    If bSkillshotSelect Then
        SelectSkillshot(2)
	Else
		HandsFreeSkillshotInsert = -1
    End If
End Sub

'*********
' Section; TILT
'*********

'NOTE: The TiltDecreaseTimer Subtracts .01 from the "Tilt" variable every round

Sub CheckTilt                                    'Called when table is nudged
    Tilt = Tilt + TiltSensitivity                'Add to tilt count
    TiltDecreaseTimer.Enabled = True
    If(Tilt > TiltSensitivity)AND(Tilt < 15)Then 'show a warning
        DOF 161, DOFPulse: DMD "", eNone, "_", eNone, CenterLine(2, "DANGER!"), eBlinkFast, "", eNone, 500, True, "tna_tilt"
		UDMD " DANGER! ", "", 500
    End if
    If Tilt > 15 Then 'If more that 15 then TILT the table
        Tilted = True
        'display Tilt
'        DMDFlush
        DOF 162, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "TILT!"), eBlinkFast, 500, False, "tna_tilt"
		UDMD "  TILT!  ", "", 500
        DisableTable True
        TiltRecoveryTimer.Enabled = True 'start the Tilt delay to check for all the balls to be drained
    End If
End Sub

Sub TiltDecreaseTimer_Timer
    ' DecreaseTilt
    If Tilt > 0 Then
        Tilt = Tilt - 0.1
    Else
        TiltDecreaseTimer.Enabled = False
    End If
End Sub

Sub DisableTable(Enabled)
    If Enabled Then
        'turn off GI and turn off all the lights
        GiOff
        'LightSeqTilt.Play SeqAllOff
        'Disable slings, bumpers etc
        LeftFlipper.RotateToStart
        RightFlipper.RotateToStart

        LeftSlingshot.Disabled = 1
        RightSlingshot.Disabled = 1
    Else
        'turn back on GI and the lights
        'GiOn
'        'LightSeqTilt.StopPlay
        LeftSlingshot.Disabled = 0
        RightSlingshot.Disabled = 0
        'clean up the buffer display
        DMDFlush
    End If
End Sub

Sub TiltRecoveryTimer_Timer()
    ' if all the balls have been drained then..
    If(BallsOnPlayfield = 0)Then
        ' do the normal end of ball thing (this doesn't give a bonus if the table is tilted)
        EndOfBall()
        TiltRecoveryTimer.Enabled = False
    End If
' else retry (checks again in another second or so)
End Sub

'********************
' Section; Music
'********************

Dim Song
Song = ""
Dim m_main

Sub StartBackgroundMusic	'Reactor 1 always plays TNA1.mp3
	Dim tmp

	If Reactor1Music = 1 Then 
		tmp = ((ReactorLevel(CurrentPlayer) + RandomSongStart) Mod 8) + 2
		If debugGeneral Then debug.print "StartBackgroundMusic, ReactorState(CurrentPlayer)=" & ReactorState(CurrentPlayer)
		If ReactorState(CurrentPlayer) <> 3 Then 'Critical
			If ReactorLevel(CurrentPlayer) = 1 Then	'If player is on reactor 1, then always play first song 
				m_main = "TNA" & ReactorLevel(CurrentPlayer) & ".mp3"
			Else
				m_main = "TNA" & tmp & ".mp3"
			End If
			PlaySong m_main, 2
		End If
	Else
		StartBackgroundMusicAlt
	End If
End Sub

Sub StartBackgroundMusicAlt	'ramdom songs even for TNA Reactor 1 also
	Dim tmp: tmp = ((ReactorLevel(CurrentPlayer) + RandomSongStart) Mod 9) + 1
	If ReactorState(CurrentPlayer) <> 3 Then m_main = "TNA" & tmp & ".mp3"
	PlaySong m_main, 2
End Sub


'Sub ResumeBackgroundMusic
'	Dim tmp
'
'	tmp = ((ReactorLevel(CurrentPlayer) + RandomSongStart) Mod 8) + 2
'	If debugGeneral Then debug.print "StartBackgroundMusic, ReactorState(CurrentPlayer)=" & ReactorState(CurrentPlayer)
'	If ReactorState(CurrentPlayer) <> 3 Then 'Critical
'		If ReactorLevel(CurrentPlayer) = 1 Then	'If player is on reactor 1, then always play first song 
'			m_main = "TNA" & ReactorLevel(CurrentPlayer) & ".mp3"
'		Else
'			m_main = "TNA" & tmp & ".mp3"
'		End If
'		debug.print m_main
'		PlaySong m_main, 100
'	End If
'End Sub


Sub StopBackgroundMusic
	If debugGeneral Then debug.print "StopBackgroundMusic"
	EndMusic
	Song = ""
End Sub

Dim ReactorCriticalMusicOn
Sub StartReactorCriticalMusic
	If debugGeneral Then debug.print "StartReactorCriticalMusic"
	DOF 178, DOFOn
	If MultiballMusicOn = True and bMultiBallMode = True Then
		'do nothing
	ElseIf ReactorCriticalMusicOn = False Then
		StopBackgroundMusic
		StopMultiballMusic
		playsound "tna_reactorcritical", -1
		ReactorCriticalMusicOn = True
	End If
End Sub

Dim MultiballMusicOn
Sub StartMultiballMusic
	If debugGeneral Then debug.print "StartMultiballMusic"
	If MultiballMusicOn = False Then
		StopBackgroundMusic
		StopReactorCriticalMusic
		playsound "tna_multiballcallout"
		playsound "tna_multiballmusic", -1
		MultiballMusicOn = True
	End If
End Sub

Sub StopReactorCriticalMusic
	If debugGeneral Then debug.print "StopReactorCriticalMusic"
	DOF 178, DOFOff
	stopsound "tna_reactorcritical"
	ReactorCriticalMusicOn = False
End Sub

Sub StopMultiballMusic
	If debugGeneral Then debug.print "StopMultiballMusic"
	stopsound "tna_multiballmusic"
	MultiballMusicOn = False
End Sub

Sub PlaySong(name, ttype)
	If debugGeneral Then debug.print "PlaySong " & name & " " & Song
    If bMusicOn Then
        If ((Song <> name) Or (ttype = 100)) Then
            StopSound Song
			StopBackgroundMusic
            Song = name
				If ttype = 1 Then
							If Song = "m_end" Then
								PlaySound Song, 0, 0.1  'this last number is the volume, from 0 to 1
							Else
								PlaySound Song, -1, 1 'this last number is the volume, from 0 to 1
							End If
				Else
							PlayMusic Song, SongVolume
				End If
        End If
    End If
End Sub

'**********************
' Section; GI effects
' independent routine
' it turns on the gi
' when there is a ball
' in play
'**********************
Const DOFuyellow= 144
Const DOFuwhite = 145
Const DOFublue  = 146
Const DOFured   = 147
Const DOFugreen = 148
Const DOFupurple= 149
Dim UndercabColor : UndercabColor = DOFublue

Dim OldGiState, CurrCol
Dim PrevCol, NextCol, NextPerm
OldGiState = -1   'start witht the Gi off

Sub ChangeGi(col, perm) 'changes the gi color, perm specifies if permanent base gi change (1) or temp change(0)
	If debugGeneral Then debug.print "*****SUB:ChangeGi " & col

	NextCol = col
	NextPerm = perm
	ChangeGiTimer.Interval = 500
	ChangeGITimer.Enabled = True
	
	GIOff
End Sub

Sub ChangeGiTimer_Timer
	If debugGeneral Then debug.print "*****SUB:ChangeGiTimer_Timer " & NextCol
	ChangeGITimer.Enabled = False

	ChangeGiImmediate NextCol, NextPerm
	GiOn
End Sub

Sub ChangeGiImmediate (col, perm) 'Perm=1 then save
	If debugGeneral Then debug.print "*****SUB:ChangeGiImmediate " & col
	If col = "white" Then col = "whitegi"
	
	If (perm = 1) Then
		CurrCol = col
	End If
	
    Dim bulb
    For each bulb in aGILights
        SetLight bulb, col, -1
    Next


	DOF UndercabColor, DOFOff
	If col = "white" Then
		UndercabColor = DOFuwhite
	ElseIf col = "whitegi" Then
		UndercabColor = DOFuwhite
	ElseIf col = "blue" Then
		UndercabColor = DOFublue
	ElseIf col = "red" Then
		UndercabColor = DOFured
	ElseIf col = "green" Then
		UndercabColor = DOFugreen
	ElseIf col = "purple" Then
		UndercabColor = DOFupurple
	ElseIf col = "yellow" Then
		UndercabColor = DOFuyellow
	End If
	DOF UndercabColor, DOFOn

End Sub


'Sub ChangeGiTemp (col)
'	PrevCol = CurrCol
'	ChangeGiImmediate col
'End Sub

Sub PreviousGI
	ChangeGiImmediate CurrCol, 1
End Sub	

Sub GiOn
    DOF UndercabColor, DOFOn
    Dim bulb
    For each bulb in aGiLights
        bulb.State = 1
    Next
End Sub

Sub GiOff
    DOF UndercabColor, DOFOff
    Dim bulb
    For each bulb in aGiLights
        bulb.State = 0
    Next
End Sub



Sub GIReactor (col)
Dim Bulb
    For each bulb in aGIReactorLights
        SetLight bulb, col, -1
    Next
End Sub

Sub GIReactorStarted
	gi9.TimerInterval = 30
	gi9.TimerEnabled = True
End Sub

Sub GIReactorStopped
	gi9.TimerEnabled = False
	gi10.TimerInterval = 2000
	gi10.TimerEnabled = True
	
	'Temp GI change and ramdom lights
	ChangeGIImmediate GIcolorOpposite, 0
	LightSeqGame.Play SeqRandom, 40, , 0
End Sub

Sub GIReactorStoppedImmediate
	gi9.TimerEnabled = False
	ChangeGIImmediate GIcolor, 1
End Sub


Sub Gi10_Timer
	gi10.TimerEnabled = False
	LightSeqGame.StopPlay
	If bMultiBallMode = False Then
		ChangeGI GIcolor, 1
	Else
		ChangeGi "green", 1
	End If
End Sub

Dim GISpinNum
GISpinNum=0
Sub GI9_Timer

	If ReactorState(CurrentPlayer) = 2 Then 	'Reactor Started 'Circle animation
		SetLight aGiReactorLights((GISpinNum)mod 16), GIcolor, -1
		SetLight aGiReactorLights((GISpinNum+1)mod 16), GIcolor, -1
		SetLight aGiReactorLights((GISpinNum+2)mod 16), GIcolor, -1
		SetLight aGiReactorLights((GISpinNum+3)mod 16), GIcolor, -1
		SetLight aGiReactorLights((GISpinNum+4)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+5)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+6)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+7)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+8)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+9)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+10)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+11)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+12)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+13)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+14)mod 16), "red", -1
		SetLight aGiReactorLights((GISpinNum+15)mod 16), "red", -1
	
	ElseIf ReactorState(CurrentPlayer) = 3 Then	'Reactor Critical 'blinking Red GI

'		GiReactorCritical
'		ChangeGiImmediate "red", 1
'		GIGameImmediate 5, "red"
'		GiON

		Gi9.TimerEnabled = False	'stop reactor spin timer
	End If
	GISpinNum = (GISpinNum+1) Mod 16

End Sub

Sub GiReactorOn
	If debugGeneral Then debug.print "*****SUB:GiReactorOn"
    Dim bulb
    For each bulb in aGIReactorLights
        bulb.State = 1
    Next
End Sub

Sub GiReactorOff
	If debugGeneral Then debug.print "*****SUB:GiReactorOff"
    Dim bulb
    For each bulb in aGIReactorLights
        bulb.State = 0
    Next
End Sub

Sub GiReactorCritical		' Turn on beacon
	ChangeGiImmediate "red", 1
	GIGameImmediate 5, "red"
	GiON
End Sub

' GI & light sequence effects
Dim GiReactorNum
Sub GiReactorEffect(n)
	Select case n
		Case 2: 
			GiReactorOff
			GiReactorNum=0
			GiReactorEffectTimer.Interval = 50
		Case 3:
			GiReactorOff
			GiReactorNum = 10
			GiReactorEffectTimer.Interval = 150
		
	End Select
	
	GiReactorEffectTimer.Enabled = True
End Sub

Sub GiReactorEffectTimer_Timer
	Select case GiReactorNum
		Case 0, 2, 4, 6, 8:
			GiReactorOn
		Case 10
			GiReactorOn	
			GiReactorEffectTimer.Enabled = False
		Case Else
			GiReactorOff
	End Select
	GiReactorNum = GiReactorNum  + 1
End Sub


'**** Blink Left GI Sling
Sub GILeftSlingHit
	Dim Bulb
    For each bulb in aGILeftSling
		If ReactorState(CurrentPlayer) = 3 Then
			SetLight bulb, "blue", -1
			'debug.print "blue" & gametime
			
		Else
			SetLight bulb, "red", -1
			'debug.print "red" & gametime
		End If
	Next

	GI3.TimerInterval = 250: GI3.TimerEnabled = True
End Sub

Sub GI3_Timer
	Dim Bulb
	
    For each bulb in aGILeftSling
        SetLight bulb, CurrCol, -1
    Next

	GI3.TimerEnabled = False
End Sub

'**** Blink Right GI Sling
Sub GIRightSlingHit
	Dim Bulb
	
    For each bulb in aGIRightSling
		If ReactorState(CurrentPlayer) <> 3 Then
			SetLight bulb, "red", -1
		Else
			SetLight bulb, "blue", -1
		End If
    Next

	GI1.TimerInterval = 250: GI1.TimerEnabled = True
End Sub

Sub GI1_Timer
	Dim Bulb
	
    For each bulb in aGIRightSling
        SetLight bulb, CurrCol, -1
    Next

	GI1.TimerEnabled = False
End Sub



'Gi - Newer GI effects 
Dim EffectNum
Sub GIGame (num, col)
	GIOff
	EffectNum = num
	NextCol = col
	GIGameTimer.Interval = 250
	GIGameTimer.Enabled = True
End Sub

Sub GIGameTimer_Timer
	GiGameImmediate EffectNum, NextCol
	GIGameTimer.Enabled = False
End Sub

Dim currGIGame
Sub GiGameImmediate (num, col)  'temporary gi animations
	GIOff
	currGIGame = col
	Select Case Num	'yyy
		Case 1 'Skillshot, HFSkillshot, Lane save, Jackpot
			ChangeGIImmediate col, 0
			LightSeqGame.UpdateInterval = 2
			LightSeqGame.Play SeqDownOn, 50, 1
		Case 2	'Scoop Eject
			ChangeGIImmediate col, 0
			LightSeqGame.UpdateInterval = 2
			LightSeqGame.Play SeqDownOff, 50, 1
		Case 3 'Ball Lock part 1`
			ChangeGIImmediate col, 0
			LightSeqMball.UpdateInterval = 13
			LightSeqMball.Play SeqCircleOutOn, 150, 1
		Case 4 'mball
			ChangeGIImmediate col, 0
			GIOn
			LightSeqMball.UpdateInterval = 2
			LightSeqMball.Play SeqDownOff, 30, 5
			'LightSeqMball.Play SeqCircleOutOff, 50, 1
		Case 5	'Reactor Critical
			LightSeqCritical.UpdateInterval = 20
			LightSeqCritical.Play SeqUpOff, 15, 1000
		Case 6	'ComboLoop
			ChangeGIImmediate col, 0
			GIOn
			LightSeqGame.UpdateInterval = 1
			LightSeqGame.Play SeqClockLeftOff, 150, 2
		Case 7  'Reactor Ready Part 1
			ChangeGIImmediate col, 0
			LightSeqReady.UpdateInterval = 3
			LightSeqReady.Play SeqStripe2VertOn, 50, 6
		Case 8 ' Reactor Ready Part 2
			ChangeGIImmediate col, 0
			playsound "tna_leftscoopawardeject"
			LightSeqReady.UpdateInterval = 2
			LightSeqReady.Play SeqDownOn, 30, 3
		Case 9 'Double Jackpot
			ChangeGIImmediate col, 0
			LightSeqGame.UpdateInterval = 2
			LightSeqGame.Play SeqDownOn, 50, 2
		Case 10 'Triple Jackpot
			ChangeGIImmediate col, 0
			LightSeqGame.UpdateInterval = 2
			LightSeqGame.Play SeqDownOn, 50, 3
		Case 11 'Super Jackpot
			ChangeGIImmediate col, 0
			LightSeqGame.UpdateInterval = 2
			LightSeqGame.Play SeqDownOn, 50, 4	
		Case 12 'Lane save
			ChangeGIImmediate col, 0
			LightSeqGame.UpdateInterval = 3
			LightSeqGame.Play SeqDownOn, 100, 1
	End Select	
End Sub


Sub LightSeqReady_PlayDone
	If CurrCol = "green" Then
		GigameImmediate 8, "white"
	Else
		PreviousGI
		LightSeqReady.TimerInterval = 500
		LightSeqReady.TimerEnabled = True
	End If
End Sub

Sub LightSeqReady_Timer
	GiOn
	LightSeqReady.TimerEnabled = False
End Sub


' GI & light sequence effects
Dim GiNum
Sub GiEffect(n)
	Select case n
		Case 2: 	'GI blink 5 times at 100 msec rate
			GiOff
			GiNum=0
			GiEffectTimer.Interval = 50
		Case 3:		'GI Blink 1 time for 100 msec
			GiOff
			GiNum = 10
			GiEffectTimer.Interval = 100	
	End Select
	
	GiEffectTimer.Enabled = True
End Sub

Sub GiEffectTimer_Timer
	Select case GiNum
		Case 0, 2, 4, 6, 8:	'Toggle GI On
			GiOn
		Case 10		'Stop timer
			GiOn	
			GiEffectTimer.Enabled = False
		Case 20,30,40,100,500,1000	'Stop timer
			GiOn	
			GiEffectTimer.Enabled = False
		Case Else	'Toggle GO Off 
			GiOff
	End Select
	GiNum = GiNum  + 1
End Sub



Sub LightEffect(n)

End Sub

' Flasher Effects

Dim FEStep, FEffect
FEStep = 0
FEffect = 0

Sub FlashEffect(n)
    Select case n
        Case 1:FEStep = 0:FEffect = 1:FlashEffectTimer.Enabled = 1 'all blink
        Case 2:FEStep = 0:FEffect = 2:FlashEffectTimer.Enabled = 1 'random
        Case 3:FEStep = 0:FEffect = 3:FlashEffectTimer.Enabled = 1 'upon
        Case 4:FEStep = 0:FEffect = 4:FlashEffectTimer.Enabled = 1 'ordered random :)
    End Select
End Sub

Sub FlashEffectTimer_Timer()
    FEStep = FEStep + 1
	FlashEffectTimer.Enabled = 0
End Sub


Sub ResetInserts
	Dim Obj
	'Reactor Inserts
	For each obj in aInsertsReactor
		SetLight obj, "blue", 0
	Next

	'Bonus Inserts
	For each obj in aInsertsBonus
		SetLight obj, "white", 0
	Next

	SetLight lSpinner, "blue", -1
	SetLight F1, "white", 0
	SetLight F2, "white", 0
	SetLight F3, "white", 0
	SetLight F4, "white", 0
	SetLight F5, "white", 0
	SetLight FD1, "white", 0
	SetLight FD2, "white", 0
	SetLight FRAD1, "white", 0
	SetLight FRAD2, "white", 0
	SetLight FRAD3, "white", 0
End Sub

' *******************************************************************************************************
' Positional Sound Playback Functions by DJRobX and Rothbauerw
' PlaySound sound, 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 0, 1, AudioFade(ActiveBall)
' *******************************************************************************************************

' Play a sound, depending on the X,Y position of the table element (especially cool for surround speaker setups, otherwise stereo panning only)
' parameters (defaults): loopcount (1), volume (1), randompitch (0), pitch (0), useexisting (0), restart (1))
' Note that this will not work (currently) for walls/slingshots as these do not feature a simple, single X,Y position

Sub PlayXYSound(soundname, tableobj, loopcount, volume, randompitch, pitch, useexisting, restart)
  PlaySound soundname, loopcount, volume, AudioPan(tableobj), randompitch, pitch, useexisting, restart, AudioFade(tableobj)
End Sub

' Set position as table object (Use object or light but NOT wall) and Vol to 1

Sub PlaySoundAt(soundname, tableobj)
  PlaySound soundname, 1, 1, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

'Set all as per ball position & speed.

Sub PlaySoundAtBall(soundname)
  PlaySoundAt soundname, ActiveBall
End Sub

'Set position as table object and Vol manually.

Sub PlaySoundAtVol(sound, tableobj, Volume)
  PlaySound sound, 1, Volume, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub

'Set all as per ball position & speed, but Vol Multiplier may be used eg; PlaySoundAtBallVol "sound",3

Sub PlaySoundAtBallVol(sound, VolMult)
  PlaySound sound, 0, Vol(ActiveBall) * VolMult, AudioPan(ActiveBall), 0, Pitch(ActiveBall), 0, 1, AudioFade(ActiveBall)
End Sub

'Set position as bumperX and Vol manually.

Sub PlaySoundAtBumperVol(sound, tableobj, Vol)
  PlaySound sound, 1, Vol, AudioPan(tableobj), 0,0,1, 1, AudioFade(tableobj)
End Sub

Sub PlaySoundAtBOTBallZ(sound, BOT)
    PlaySound sound, 0, ABS(BOT.velz)/17, Pan(BOT), 0, Pitch(BOT), 1, 0, AudioFade(BOT)
End Sub

' play a looping sound at a location with volume
Sub PlayLoopSoundAtVol(sound, tableobj, Vol)
	PlaySound sound, -1, Vol, AudioPan(tableobj), 0, 0, 1, 0, AudioFade(tableobj)
End Sub

' *********************************************************************
' Section; Supporting Ball & Sound Functions
' *********************************************************************

Function RndNum(min, max)
    RndNum = Int(Rnd() * (max-min + 1) ) + min ' Sets a random number between min and max
End Function

Function AudioFade(tableobj) ' Fades between front and back of the table (for surround systems or 2x2 speakers, etc), depending on the Y position on the table. "table1" is the name of the table
	Dim tmp, t2, t4, t8
	On Error Resume Next
	tmp = tableobj.y * 2 / tableheight-1
	If tmp > 7000 Then
		tmp = 7000
	ElseIf tmp < -7000 Then
		tmp = -7000
	End If
	If tmp > 0 Then
		t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioFade = Csng(t8 * t2)
	Else
		tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioFade = Csng(-(t8 * t2))
	End If
End Function

Function AudioFadeXY(ByVal y) ' AudioFade variant accepting pre-cached Y scalar (avoids COM read)
	Dim tmp, t2, t4, t8
	tmp = y * 2 / tableheight-1
	If tmp > 7000 Then
		tmp = 7000
	ElseIf tmp < -7000 Then
		tmp = -7000
	End If
	If tmp > 0 Then
		t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioFadeXY = Csng(t8 * t2)
	Else
		tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioFadeXY = Csng(-(t8 * t2))
	End If
End Function

Function AudioPan(tableobj) ' Calculates the pan for a tableobj based on the X position on the table. "table1" is the name of the table
	Dim tmp, t2, t4, t8
	On Error Resume Next
	tmp = tableobj.x * 2 / tablewidth-1
	If tmp > 7000 Then
		tmp = 7000
	ElseIf tmp < -7000 Then
		tmp = -7000
	End If
	If tmp > 0 Then
		t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioPan = Csng(t8 * t2)
	Else
		tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioPan = Csng(-(t8 * t2))
	End If
End Function

Function AudioPanXY(ByVal x) ' AudioPan variant accepting pre-cached X scalar (avoids COM read)
	Dim tmp, t2, t4, t8
	tmp = x * 2 / tablewidth-1
	If tmp > 7000 Then
		tmp = 7000
	ElseIf tmp < -7000 Then
		tmp = -7000
	End If
	If tmp > 0 Then
		t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioPanXY = Csng(t8 * t2)
	Else
		tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		AudioPanXY = Csng(-(t8 * t2))
	End If
End Function

Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table1" is the name of the table
	Dim tmp, t2, t4, t8
	On Error Resume Next
	tmp = ball.x * 2 / tablewidth-1
	If tmp > 7000 Then
		tmp = 7000
	ElseIf tmp < -7000 Then
		tmp = -7000
	End If
	If tmp > 0 Then
		t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		Pan = Csng(t8 * t2)
	Else
		tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
		Pan = Csng(-(t8 * t2))
	End If
End Function

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
	Dim bv : bv = BallVel(ball)
	Vol = Csng(bv * bv / VolDiv)
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
	BallVel = INT(SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY))
End Function

Function BallVelZ(ball) 'Calculates the ball speed in the -Z
    BallVelZ = INT((ball.VelZ) * -1 )
End Function

Function VolZ(ball) ' Calculates the Volume of the sound based on the ball speed in the Z
	Dim bvz : bvz = BallVelZ(ball)
	VolZ = Csng(bvz * bvz / 200) * 1.2
End Function

'*** Determines if a Points (px,py) is inside a 4 point polygon A-D in Clockwise/CCW order

Function InRect(px,py,ax,ay,bx,by,cx,cy,dx,dy)
  Dim AB, BC, CD, DA
  AB = (bx*py) - (by*px) - (ax*py) + (ay*px) + (ax*by) - (ay*bx)
  BC = (cx*py) - (cy*px) - (bx*py) + (by*px) + (bx*cy) - (by*cx)
  CD = (dx*py) - (dy*px) - (cx*py) + (cy*px) + (cx*dy) - (cy*dx)
  DA = (ax*py) - (ay*px) - (dx*py) + (dy*px) + (dx*ay) - (dy*ax)

  If (AB <= 0 AND BC <=0 AND CD <= 0 AND DA <= 0) Or (AB >= 0 AND BC >=0 AND CD >= 0 AND DA >= 0) Then
    InRect = True
  Else
    InRect = False
  End If
End Function


'*****************************************
' Section; JP's VP10 Rolling Sounds
'*****************************************

Const tnob = 6 ' total number of balls
Const lob = 4   'number of locked balls
ReDim rolling(tnob)
ReDim BallRollStr(tnob)
Dim brsI : For brsI = 0 To tnob : BallRollStr(brsI) = "fx_ballrolling" & brsI : Next
InitRolling

Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
    Next
End Sub

Sub RollingUpdate()
    Dim BOT, b, bx, by, bz, bvx, bvy, bvel
    BOT = GetBalls

    ' stop the sound of deleted balls
    For b = UBound(BOT) + 1 to tnob
        rolling(b) = False
        StopSound BallRollStr(b)
    Next

    ' exit the sub if no balls on the table
    If UBound(BOT) = 3 Then Exit Sub 'there are always 4 balls on this table

    ' play the rolling sound for each ball
    For b = 0 to UBound(BOT)
        bx  = BOT(b).X
        by  = BOT(b).Y
        bz  = BOT(b).Z
        bvx = BOT(b).VelX
        bvy = BOT(b).VelY
        bvel = INT(SQR(bvx * bvx + bvy * bvy))

        If bvel > 2 Then
            rolling(b) = True
            If bz < 30 And bz > 10 Then ' Ball on playfield
                PlaySound BallRollStr(b), -1, Csng(bvel * bvel / VolDiv), AudioPanXY(bx), 0, bvel * 20, 1, 0, AudioFadeXY(by)
            End If
        Else
            If rolling(b) = True Then
                StopSound BallRollStr(b)
                rolling(b) = False
            End If
        End If
    Next
End Sub

'**********************
' Section; Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
	Dim cv : cv = Csng(velocity)
	PlaySound "fx_collide", 0, cv * cv / (VolDiv/VolCol), AudioPan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub

Dim BallShadow
BallShadow = Array(BallShadow1,BallShadow2,BallShadow3,BallShadow4,BallShadow5,BallShadow6)

Sub BallShadow_Timer()
    Dim BOT, b, bx, by, bz
    BOT = GetBalls
    ' hide shadow of deleted balls
    If UBound(BOT)<(tnob-1) Then
        For b = (UBound(BOT) + 1) to (tnob-1)
            BallShadow(b).visible = 0
        Next
    End If
    ' exit the Sub if no balls on the table
    If UBound(BOT) = -1 Then Exit Sub
    ' render the shadow for each ball
    For b = 0 to UBound(BOT)
        bx = BOT(b).X
        by = BOT(b).Y
        bz = BOT(b).Z
        BallShadow(b).X = bx
        BallShadow(b).Y = by + 10
        If bz > 20 And bz < 200 Then
            BallShadow(b).visible = 1
        Else
            BallShadow(b).visible = 0
        End If
        If bz > 30 Then
            BallShadow(b).height = bz - 20
            BallShadow(b).opacity = 80
        Else
            BallShadow(b).height = bz - 24
            BallShadow(b).opacity = 90
        End If
    Next
End Sub

 '**********************
'Flipper Shadows
'***********************
Sub RealTime_Timer
	Dim a
	a = LeftFlipper.CurrentAngle
	If a <> lastLFAngle Then lastLFAngle = a : lfs.RotZ = a
	a = RightFlipper.CurrentAngle
	If a <> lastRFAngle Then lastRFAngle = a : rfs.RotZ = a
End Sub

'******************************
' Section; Diverse Collection Hit Sounds
'******************************

Sub aTargets_Hit(idx):PlaySound "fx_Target_soft", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aBigTargets_Hit(idx):PlaySound "fx_Target", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aMetals_Hit(idx):PlaySound "fx_PlasticHit", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aRubber_Bands_Hit(idx):PlaySound "fx_rubber", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aRubber_Posts_Hit(idx):PlaySound "fx_postrubber", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aRubber_Pins_Hit(idx):PlaySound "fx_postrubber", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aYellowPins_Hit(idx):PlaySound "fx_postrubber", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aPlastics_Hit(idx):PlaySound "fx_PlasticHit", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aGates_Hit(idx):PlaySound "fx_Gate", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aWoods_Hit(idx):PlaySound "fx_Woodhit", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub
Sub aCaptiveWalls_Hit(idx):PlaySound "fx_collide", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall):End Sub


Sub PlayQuote_timer() 'one quote each 2 minutes
    Dim Quote
    Quote = "xxxxxx" & INT(RND * 56) + 1
    PlaySound Quote
End Sub

' Ramp Soundss
Sub RHelp1_Hit()
    StopSound "fx_metalrolling"
    PlaySound "fx_ballrampdrop", 0, 1, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub RHelp2_Hit()
    StopSound "fx_metalrolling"
    PlaySound "fx_ballrampdrop", 0, 1, pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

' *********************************************************************
'                        User Defined Script Events
' *********************************************************************

' Initialise the Table for a new Game
Dim RandomSongStart
Sub ResetForNewGame()
	If debugGeneral Then Debug.print "*****SUB:ResetForNewGame()"

    Dim i

	RandomSongStart = INT(RND * 8)
    bGameInPLay = True

    'resets the score display, and turn off attrack mode
    StopAttractMode
	StopRainbow
    GiOn

    TotalGamesPlayed = TotalGamesPlayed + 1
    CurrentPlayer = 1

	'Resets all the led reels - hack	
	If PlayersPlayingGame > 1 Then
		If B2SOn Then Controller.stop: Controller.Run
		'If B2SOn Then Controller.B2SSetScorePlayer 1, 0
		'If B2SOn Then Controller.B2SSetScorePlayer 2, 0
		'If B2SOn Then Controller.B2SSetScorePlayer 3, 0
		'If B2SOn Then Controller.B2SSetScorePlayer 4, 0
	End If

    PlayersPlayingGame = 1
    bOnTheFirstBall = True
    For i = 1 To MaxPlayers
        Score(i) = 0
		ReactorScore(i) = 0
        BonusPoints(i) = 0
        BonusHeldPoints(i) = 0
        BonusMultiplier(i) = 1
        BallsRemaining(i) = BallsPerGame
        ExtraBallsAwards(i) = 0
    Next
	If B2SOn Then Controller.B2SSetScorePlayer 1, 0


    ' initialise any other flags
    Tilt = 0

    ' initialise Game variables
    Game_Init()


    ' you may wish to start some music, play a sound, do whatever at this point
    ' set up the start delay to handle any Start of Game Attract Sequence
	UDMD "Welcome To", "The Future", 1500
    vpmtimer.addtimer 1500, "FirstBall '"

End Sub

' This is used to delay the start of a game to allow any attract sequence to
' complete.  When it expires it creates a ball for the player to start playing with

Sub FirstBall
	If debugGeneral Then Debug.print "*****SUB:FirstBall()"

    ' reset the table for a new ball
    ResetForNewPlayerBall()
    ' create a new ball in the shooters lane
    CreateNewBall()
End Sub

' (Re-)Initialise the Table for a new ball (either a new ball after the player has
' lost one or we have moved onto the next player (if multiple are playing))

Sub ResetForNewPlayerBall()
	If debugGeneral Then Debug.print "*****SUB:ResetForNewPlayerBall()"

    ' make sure the correct display is upto date
    AddScore 0

    ' set the current players bonus multiplier back down to 1X
    SetBonusMultiplier 1

    ' reset any drop targets, lights, game modes etc..

    BonusPoints(CurrentPlayer) = 0
    bBonusHeld = False
    bExtraBallWonThisBall = False
    ResetNewBallLights()

    'Reset any table specific
    ResetNewBallVariables

    'This is a new ball, so activate the ballsaver
    bBallSaverReady = True

    'and the skillshot
    SkillShotReady = 1

	'and Drain bonus Ready 
	DrainBonusReady = 1

	'ResetModes : drain
	If KeepLaneSaves = 0 Then ResetSAVE
	ResetCORE
	ResetGate
	ResetBonusLights
	ResetSuperSpinner
	StartRAD
	StartMaxTarget
	ResetReactorBonus

	If bLockIsLit = False Then
		DropTargetResetLockIsLit 2
	End If
	
'Change the music ?
End Sub

' Create a new ball on the Playfield

Sub CreateNewBall()
    ' create a ball in the plunger lane kicker.
    BallRelease.CreateSizedball BallSize / 2
    ' There is a (or another) ball on the playfield
    AddBallsOnPlayfield 1

	If debugGeneral Then Debug.print "*****SUB:CreateNewBall, BallCnt = " & " : " & BallsOnPlayfield

    ' kick it out..
    PlaySound SoundFXDOF("fxz_Ballrel", 121, DOFPulse, DOFContactors), 0, 1, 0.1, 0.1, AudioFade(BallRelease)
    BallRelease.Kick 90, 4

	If bMultiBallMode = False and ReactorState(CurrentPlayer) <> 3 Then
		StartBackgroundMusic
	Elseif ReactorState(CurrentPlayer) = 3 Then
		StartReactorCriticalMusic
		GiReactorCritical
	End If


	If bBallSaverSingleUse = 1 then bBallSaverSingleUse = 0 'SAVE mode: Clear single ball save
End Sub

Sub CreateNewBallAfterBallLock()
    ' create a ball in the plunger lane kicker.
    BallRelease.CreateSizedball BallSize / 2

	If debugGeneral Then Debug.print "*****SUB:CreateNewBallAfterBallLock, BallCnt = " & " : " & BallsOnPlayfield

    ' kick it out..
    PlaySound SoundFXDOF("fx_Ballrel", 121, DOFPulse, DOFContactors), 0, 1, 0.1, 0.1, AudioFade(BallRelease)
    BallRelease.Kick 90, 4
    bAutoPlunger = True

End Sub


' Add extra balls to the table with autoplunger
' Use it as AddMultiball 4 to add 4 extra balls to the table

Sub AddMultiball(nballs)
	If debugGeneral Then Debug.print "*****SUB:AddMultiball()"

    mBalls2Eject = mBalls2Eject + nballs
	CreateMultiballTimer.Interval = 1000
    CreateMultiballTimer.Enabled = True
End Sub

' Eject the ball after the delay, AddMultiballDelay
Sub CreateMultiballTimer_Timer()
	If debugGeneral Then Debug.print "*****SUB:CreateMultiballTimer_Timer()"

    ' wait if there is a ball in the plunger lane
    If bBallInPlungerLane Then
'uuuu		debug.print "AAA"
        Exit Sub
    Else
        If BallsOnPlayfield < MaxMultiballs Then
            CreateNewBall()
            mBalls2Eject = mBalls2Eject -1
            If mBalls2Eject = 0 Then 'if there are no more balls to eject then stop the timer
                Me.Enabled = False
            End If
        Else 'the max number of multiballs is reached, so stop the timer
            mBalls2Eject = 0
            Me.Enabled = False
        End If
    End If
End Sub

' The Player has lost his ball (there are no more balls on the playfield).
' Handle any bonus points awarded

Sub EndOfBall()
	Dim AwardPoints1, AwardPoints2, AwardPoints3, TotalBonus, TNABonus
	Dim tmp
	If debugGeneral Then Debug.print "*****SUB:EndOfBall()"

	' TNA bonus 
	' Target bonus  - 1000 * targets * bonus level
	' Unused BallSave bonus - ?  5000 each?
	' Reactor bonus
	' Total bonus
    AwardPoints1 = 0
    AwardPoints2 = 0
    AwardPoints3 = 0
    TotalBonus = 0
	
    ' the first ball has been lost. From this point on no new players can join in
    bOnTheFirstBall = False

	'Stop music
	StopBackgroundMusic
	StopReactorCriticalMusic
    If((BallsRemaining(CurrentPlayer) <= 1) AND (ExtraBallsAwards(CurrentPlayer) = 0)) Then		'If game ends with reactor critical
		GIReactorStoppedImmediate
	End If

	bAutoPlunger = False

    ' only process any of this if the table is not tilted.  (the tilt recovery
    ' mechanism will handle any extra balls or end of game)

    If(Tilted = False)Then

        ' Count the bonus. This table uses several bonus
        'dmdflush

		If(ExtraBallsAwards(CurrentPlayer) <> 0)Then
			'Playsound "tna_standbyandbonus"
			DOF 163, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("STAND BY...")), eBlink, 2000, True, "tna_standbyforextraball"
			UDMD "STAND BY...", "", 2000
			lBonus20cnt = -1
		Elseif ReactorTNAAchieved(CurrentPlayer) = 1 Then 'TNA Achieved
			lBonus20cnt = -2
		Else ' Normal Bouss MOde
			'Playsound "tna_3xbonuswithend"
			lBonus20cnt = 0
		End If
		LightSeqCritical.StopPlay 
		LightSeqBonus.Play SeqRandom, 40, 1, 0
		lBonus20.TimerInterval = 2000
		lBonus20.TimerEnabled = True



        AwardPoints1 = LaneSaveBonusValue * LaneSaveCount(CurrentPlayer)
        AwardPoints2 = TargetBonusValue * BonusPoints(CurrentPlayer) * BonusMultiplier(CurrentPlayer)
        AwardPoints3 = ReactorBonus * BonusMultiplier(CurrentPlayer)
		TotalBonus = (LaneSaveBonusValue * LaneSaveCount(CurrentPlayer)) + (TargetBonusValue * BonusPoints(CurrentPlayer)) + (ReactorBonus * BonusMultiplier(CurrentPlayer))
		AddScore TotalBonus

		DOF 164, DOFPulse 
        DMD "", eNone, CenterLine(1, "PLAYER BONUS"), eNone, CenterLine(2, "UNUSED BALLSAVE"), eNone, CenterLine(3, FormatScore(AwardPoints1)), eBlinkFast, 2000, True, "tna_3xbonuswithend"
		UDMD "BALLSAVE BONUS", AwardPoints1, 2000

        DMD "", eNone, CenterLine(1, "PLAYER BONUS"), eNone, CenterLine(2, "TARGET BONUS"), eNone, CenterLine(3, FormatScore(AwardPoints2)), eBlinkFast, 2000, True, ""
		UDMD "TARGET BONUS", AwardPoints2, 2000
		
        DMD "", eNone, CenterLine(1, "PLAYER BONUS"), eNone, CenterLine(2, "REACTOR BONUS"), eNone, CenterLine(3, FormatScore(AwardPoints3)), eBlinkFast, 2000, True, ""
		UDMD "REACTOR BONUS", AwardPoints3, 2000
		
		DMD "", eNone, CenterLine(1, "PLAYER BONUS"), eNone, CenterLine(2, "TOTAL BONUS"), eNone, CenterLine(3, FormatScore(TotalBonus)), eBlinkFast, 2000, True, ""
		UDMD "TOTAL BONUS", TotalBonus, 2000
		
		' add a bit of a delay to allow for the bonus points to be shown & added up
		If ReactorTNAAchieved(CurrentPlayer) <> 1 Then
			vpmtimer.addtimer 9000, "EndOfBall2 '"
		Else 'TNA achieved!!!! zzz
			TNABonus = ReactorReactorTotalReward(CurrentPlayer)
			'msgbox ReactorReactorTotalReward(CurrentPlayer)
			DMD "", eNone, CenterLine(1, "PLAYER BONUS"), eNone, CenterLine(2, "TNA BONUS"), eNone, CenterLine(3, FormatScore(TNABonus)), eBlinkFast, 4000, True, "tna_totalannihilation"
			UDMD "TNA BONUS", TNABonus, 4000
			AddScore TNABonus
			vpmtimer.addtimer 13000, "EndOfBall2 '"
		End If

	Else
        vpmtimer.addtimer 100, "EndOfBall2 '"
    End If
End Sub


Dim lBonus20cnt
Sub lBonus20_Timer
	Select Case lBonus20cnt
		Case -2
			ChangeGiImmediate "purple", 0
		Case -1
			ChangeGiImmediate "green", 0
		Case 0
			ChangeGiImmediate "yellow", 0
		Case 1
			ChangeGiImmediate "blue", 0
		Case 2
			ChangeGiImmediate "purple", 0
			lBonus20.TimerEnabled = False
			lBonus20.TimerInterval = 3000
			lBonus20.TimerEnabled = True
			
		Case 3
			lBonus20.TimerEnabled = False
			LightSeqBonus.StopPlay
			lBonus20cnt = 0
	End Select

	lBonus20cnt = lBonus20cnt + 1
End Sub

' The Timer which delays the machine to allow any bonus points to be added up
' has expired.  Check to see if there are any extra balls for this player.
' if not, then check to see if this was the last ball (of the CurrentPlayer)
'
Sub EndOfBall2()
	If debugGeneral Then Debug.print "*****SUB:EndOfBall2()"

	'ChangeGi GIcolor, 1

    ' if were tilted, reset the internal tilted flag (this will also
    ' set TiltWarnings back to zero) which is useful if we are changing player LOL
    Tilted = False
    Tilt = 0
    DisableTable False 'enable again bumpers and slingshots

    ' has the player won an extra-ball ? (might be multiple outstanding)
    If(ExtraBallsAwards(CurrentPlayer) <> 0)Then
        ' yep got to give it to them
        ExtraBallsAwards(CurrentPlayer) = ExtraBallsAwards(CurrentPlayer)- 1

        ' if no more EB's then turn off any shoot again light
        If(ExtraBallsAwards(CurrentPlayer) = 0)Then
            'lLightShootAgain.State = 0
			ResetBallSaveDisplay
        End If

        ' You may wish to do a bit of a song AND dance at this point
        DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("SHOOT AGAIN")), eBlink, 1000, True, "tna_shootagain"
		UDMD "SHOOT AGAIN", "", 1000

        ' Create a new ball in the shooters lane
		ResetForNewPlayerBall
        CreateNewBall()

		If ReactorLevel(CurrentPlayer) > LastReactorBeforeDifficultyKicksIn Then	'Enable Reactor Percentage drop logic and only one loop
			fRones.TimerInterval = ReactorPercentLossTime * 1000
			fRones.TimerEnabled = True
			StartReactorRightLoopInserts
		Else 'ReactorLevel(CurrentPlayer) 1 and 2 and e
			StartReactorLoopInserts
		End If

    Else ' no extra balls

        BallsRemaining(CurrentPlayer) = BallsRemaining(CurrentPlayer)- 1

        ' was that the last ball ?
        If(BallsRemaining(CurrentPlayer) <= 0)Then
            ' Submit the CurrentPlayers score to the High Score system
            CheckHighScore()
        ' you may wish to play some music at this point

        Else

            ' not the last ball (for that player)
            ' if multiple players are playing then move onto the next one
            EndOfBallComplete()
        End If
    End If
End Sub

' This function is called when the end of bonus display
' (or high score entry finished) AND it either end the game or
' move onto the next player (or the next ball of the same player)
'
Sub EndOfBallComplete()
    Dim NextPlayer

    If debugGeneral Then debug.print "*****SUB: EndOfBallComplete()"

    ' are there multiple players playing this game ?
    If(PlayersPlayingGame > 1)Then
        ' then move to the next player
        NextPlayer = CurrentPlayer + 1
        ' are we going from the last player back to the first
        ' (ie say from player 4 back to player 1)
        If(NextPlayer > PlayersPlayingGame)Then
            NextPlayer = 1
        End If
    Else
        NextPlayer = CurrentPlayer
    End If

    ' is it the end of the game ? (all balls been lost for all players)
    If((BallsRemaining(CurrentPlayer) <= 0)AND(BallsRemaining(NextPlayer) <= 0))Then
        ' you may wish to do some sort of Point Match free game award here
        ' generally only done when not in free play mode

        ' set the machine into game over mode
        EndOfGame()

    ' you may wish to put a Game Over message on the desktop/backglass

    Else
		' Save any additional Player data
		SavePlayerData

		' Extra Save step for co-op mode.  Copies data to other players
		If CoopMode = 1 Then
			'Copy player data to all Players 
			CopyPlayerData CurrentPlayer, 1
			CopyPlayerData CurrentPlayer, 2
			CopyPlayerData CurrentPlayer, 3
			CopyPlayerData CurrentPlayer, 4
		ElseIf CoopMode = 2 Then
			'Copy score to alternate Players 
			Select Case CurrentPlayer
				Case 1
					CopyPlayerData CurrentPlayer, 3
				Case 2
					CopyPlayerData CurrentPlayer, 4
				Case 3
					CopyPlayerData CurrentPlayer, 1
				Case 4
					CopyPlayerData CurrentPlayer, 2
			End Select
		End If
		
        ' set the next player
        CurrentPlayer = NextPlayer

		' Restore next player data or load default setting for ball 1
		RestorePlayerData

        ' make sure the correct display is up to date
        AddScore 0

        ' reset the playfield for the new player (or new ball)
        ResetForNewPlayerBall()

        ' AND create a new ball
        CreateNewBall()

        ' play a sound if more than 1 player
        If PlayersPlayingGame > 1 Then
            'PlaySound "vo_player" &CurrentPlayer
            DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "PLAYER " &CurrentPlayer), eNone, 800, True, ""
			UDMD "PLAYER " & CurrentPlayer, "", 800
        End If
    End If

    If debugGeneral Then debug.print "Next Player = " & NextPlayer

End Sub

' This function is called at the End of the Game, it should reset all
' Drop targets, AND eject any 'held' balls, start any attract sequences etc..

Sub EndOfGame()
    If debugGeneral Then debug.print "*****SUB:EndOfGame()"

    bGameInPLay = False
	BallSearchTimer.Enabled = False
	CoopMode = 0
    ' just ended your game then play the end of game tune
    If NOT bJustStarted Then
        'PlaySong "m_end", 1
    End If
    bJustStarted = False
    ' ensure that the flippers are down
    SolLFlipper 0
    SolRFlipper 0

    ' terminate all modes - eject locked balls
    ' most of the modes/timers terminate at the end of the ball
    PlayQuote.Enabled = 0

    ' set any lights for the attract mode
    GiOff
	StartRainbow "all"
    StartAttractMode 1

	' you may wish to light any Game Over Light you may have
	'Release any balls left on playfield at end of game
	If bLockIsLit = true then
		SetBallsOnPlayfield	(DropTarget2.UserValue + DropTarget3.UserValue)
	End If
	DropTargetResetLockIsLit 0

End Sub

Dim BallinPlay
Function Balls
    Dim tmp
    tmp = BallsPerGame - BallsRemaining(CurrentPlayer) + 1
    If tmp > BallsPerGame Then
        Balls = BallsPerGame
		BallinPlay = BallsPerGame
    Else
        Balls = tmp
		BallinPlay = tmp
    End If
End Function

' *********************************************************************
'  Section; Drain / Plunger Functions
' *********************************************************************

' lost a ball ;-( check to see how many balls are on the playfield.
' if only one then decrement the remaining count AND test for End of game
' if more than 1 ball (multi-ball) then kill of the ball but don't create
' a new one
'
Sub Drain_Hit()
	DOF 116, DOFPulse
    startB2S(7)
    ' Destroy the ball
    Drain.DestroyBall
    ' Exit Sub ' only for debugging
    AddBallsOnPlayfield -1

	If debugGeneral Then Debug.print "Drain_Hit(), ballcnt=" & BallsOnPlayfield

    ' pretend to knock the ball into the ball storage mech
    PlaySoundAtVol "fxz_drain", Drain, 1
    'if Tilted the end Ball modes
    If Tilted Then
        StopEndOfBallModes
    End If

    ' if there is a game in progress AND it is not Tilted
    If(bGameInPLay = True)AND(Tilted = False)Then

        ' is the ball saver active, 
        If(bBallSaverActive = True) Then

            ' yep, create a new ball in the shooters lane
            ' we use the Addmultiball in case the multiballs are being ejected
            AddMultiball 1
            ' we kick the ball with the autoplunger
            bAutoPlunger = True
            ' you may wish to put something on a display or play a sound at this point
			if (bMultiBallMode = False) Then 
				DOF 165, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BALL SAVED"), eBlinkfast, 800, True, "tna_ballsaved"
				UDMD "BALL SAVED", "", 800
			End If

        Else

			'Check if player used a SAVE to save ball
			'UseSAVE  LastSwitchHit
			If bBallSaverSingleUse = 1 Then
	            ' yep, create a new ball in the shooters lane
				' we use the Addmultiball in case the multiballs are being ejected
				AddMultiball 1
				' we kick the ball with the autoplunger
				bAutoPlunger = True
				' you may wish to put something on a display or play a sound at this point
				'DOF 165, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BALL SAVED"), eBlinkfast, 800, True, "tna_ballsaved"
				Exit Sub
			End If

            ' cancel any multiball if on last ball (ie. lost all other balls)
            If(BallsOnPlayfield = 1)Then
                ' AND in a multi-ball??
                If(bMultiBallMode = True)then
                    ' not in multiball mode any more
                    bMultiBallMode = False
					ResetGate
					EndMultiball
					If ReactorState(CurrentPlayer) = 3 Then
						GiReactorCritical
'						ChangeGiImmediate "red", 1
					Else	
						ChangeGi GIcolor, 1
					end If
                    ' you may wish to change any music over at this point and
                    ' turn off any multiball specific lights
					'DropTargetReset
                End If
            End If

            ' was that the last ball on the playfield
            If(BallsOnPlayfield = 0)Then
                ' End Modes and timers
                'PlaySong "m_wait", 1
                StopEndOfBallModes

				fRones.TimerEnabled = False	'stop reactor decrement timer if running
				ResetReactorLoopInserts
				stopReactorLEDblink

                ChangeGi "red", 0
                ' handle the end of ball (count bonus, change player, high score entry etc..)
				If DrainBonusReady = 1 Then
					DrainBonusReady = 0
					vpmtimer.addtimer 1500, "EndOfBall '"
				End If
            End If
        End If
    End If
End Sub

' The Ball has rolled out of the Plunger Lane and it is pressing down the trigger in the shooters lane
' Check to see if a ball saver mechanism is needed and if so fire it up.

Dim BallRestingInPlungerLane
Sub swPlungerRest_Hit()
    If debugGeneral Then debug.print "*****SUB:swPlungerRest_Hit, Resting"

	Wall348.TimerInterval = AutoPlungeDelay*1000

    ' some sound according to the ball position
    PlaySound "fx_sensor", 0, 1, 0.15, 0.25
    bBallInPlungerLane = True

	If SkillshotReady = 2 Then  'Soft plunge failed.  Cancel Skillshot and Autolaunch
		bAutoPlunger = True
		CheckSkillShot 0
		PlaySound "tna_electricity1", 0, 1, -0.05, 0.05
		Wall348.TimerInterval = 300
		Wall348.TimerEnabled = False
		Wall348.TimerEnabled = True
	End If
	
    ' turn on Launch light is there is one
    LaunchLight.State = 2
    ' kick the ball in play if the bAutoPlunger flag is on
    If bAutoPlunger Then
		If debugGeneral Then debug.print "*****SUB:swPlungerRest_Hit, AutoPlunge"
		Wall348.TimerEnabled = False
		Wall348.TimerEnabled = True


        If mBalls2Eject = 0 Then bAutoPlunger = False

	ElseIf ReactorTNAAchieved(CurrentPlayer) = 1 Then	
		DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "GAME OVER,MAN"), eBlinkfast, 5000, True, "tna_totalannihilation"
		UDMD "CONGRATS!", "GAME OVER MAN", 5000
		If debugGeneral Then debug.print "*****SUB:swPlungerRest_Hit, AutoPlunge"
		Wall348.TimerEnabled = False
		Wall348.TimerEnabled = True

'		LightSeqAutoLaunch.StopPlay
'		LightSeqAutoLaunch.UpdateInterval = 5
'		LightSeqAutoLaunch.Play SeqUpOn, 25, 1
	End If


    'Start the Selection of the skillshot if ready
    If SkillShotReady = 1 Then
        StartSkillshot()
    End If

    ' remember last trigger hit by the ball.
    SetLastSwitchHit "swPlungerRest"

	uDMDScoreUpdate

End Sub

Sub Wall348_Timer
		If debugGeneral Then debug.print "*****SUB:Wall348_Timer, AutoPlunge"

        PlungerIM.AutoFire
		PlaySound SoundFXDOF("fxz_autoplunger",125,DOFPulse,DOFContactors)
        DOF 123, DOFPulse
		Wall348.TimerEnabled = False
		'LightSeqAutoLaunch.StopPlay
		LightSeqAutoLaunch.Play SeqAllOff
		LightSeqAutoLaunch.UpdateInterval = 4
		LightSeqAutoLaunch.Play SeqUpOn, 25, 1

End Sub

' The ball is released from the plunger turn off some flags and check for skillshot

Dim bTimedSkillShot
Sub swPlungerRest_UnHit()
LaunchLight.State = 0
    bBallInPlungerLane = False
    If SkillShotReady  = 1 Then
        SkillShotReady = 2	'Ball plunged
        bSkillShotSelect = False	'Skillshot frozen
		swPlungerRest.TimerInterval = 5000
		swPlungerRest.TimerEnabled = True
		bTimedSkillShot = True
    End If

    If debugGeneral Then debug.print "*****SUB:swPlungerRest_UnHit, Ballcnt: " & BallsOnPlayfield
	'Debug.print "BallsonPlayfieldCheck" & " : " & BallsOnPlayfield

    ' if there is a need for a ball saver, then start off a timer
    ' only start if it is ready, and it is currently not running, else it will reset the time period
	'msgbox bBallSaverReady & ":" & BallSaverTime & ":" & bBallSaverActive
    If(bBallSaverReady = True)AND(BallSaverTime <> 0)And(bBallSaverActive = False) AND (ReactorTNAAchieved(CurrentPlayer) = 0) Then
        EnableBallSaver BallSaverTime
    End If


	JustPlunged = True
	Gate1.TimerEnabled = False
	Gate1.TimerInterval = 2000
	Gate1.TimerEnabled = True

End Sub

Sub swPlungerRest_Timer 'Timed skillshot support
	bTimedSkillShot = False
	swPlungerRest.TimerEnabled = False
End Sub

Sub Gate1_Timer
	JustPlunged = False
	Gate1.TimerEnabled = False
End Sub

'Version of Ballsaver using led display
Dim dbs1, dbs2, dbsdelta, dbstime, dbstens, dbsones, dbsdecimals
Sub EnableBallSaver(seconds)
	seconds = seconds + 0.3  'padding
    'If debugGeneral Then debug.print "*****SUB:EnableBallSaver, seconds=" & seconds
    ' set our game flag
    bBallSaverActive = True
    bBallSaverReady = False
    ' start the timer

	BallSaverTimerExpired.Interval = 1000 * seconds
	BallSaverTimerExpired.Enabled = True

	'Set display to x seconds 
	dbstime = seconds
	dbsdelta = .1
	BallSaverUpdateTimer.Interval = 100

	dbstens = Int(dbstime/10)
	dbsones = Int(dbstime-dbstens*10)
	dbsdecimals = Int((dbstime-dbstens*10-dbsones)*10)

	if dbstime > 10 then
		fBStens.ImageA = Eval(dbstens)
		fBSones.ImageA = Eval(dbsones)
	else
		fBStens.ImageA = Eval (dbsones + 10)
		fBSones.ImageA = Eval(dbsdecimals)
	end if
'	if dbstime > 10 then 
'		dBallSave1.SetValue (dbstens + 1)
'		dBallSave2.SetValue (dbsones + 1)
'	else
'		dBallSave1.SetValue (dbsones + 1+10)
'		dBallSave2.SetValue (dbsdecimals + 1)
'	end if

	dbstime = dbstime - dbsdelta
    BallSaverUpdateTimer.Enabled = True
End Sub

Sub StopBallSaver
    BallSaverUpdateTimer.Enabled = False
	BallSaverTimer2Expired.Enabled = False
	If ExtraBallsAwards(CurrentPlayer) = 0 Then
		ResetBallSaveDisplay
	Else
		SetExtraBallDisplay
	End If
	bBallSaverActive = False
End Sub


' The ball saver timer has expired.  Turn it off AND reset the game flag
'
Sub BallSaverTimerExpired_Timer()
    If debugGeneral Then debug.print "*****SUB:" & "BallSaverTimerExpired_Timer"
    BallSaverTimerExpired.Enabled = False
    BallSaverUpdateTimer.Enabled = False

    ' clear the LED display, give extra 2 second 
	If ExtraBallsAwards(CurrentPlayer) = 0 Then
		ResetBallSaveDisplay
	Else
		SetExtraBallDisplay
	End If
	BallSaverTimer2Expired.Interval = 2000
	BallSaverTimer2Expired.Enabled = True
End Sub

Sub ResetBallSaveDisplay
'	dBallSave1.SetValue 0
'	dBallSave2.SetValue 0
	fBStens.ImageA = "blank"
	fBSones.ImageA = "blank"
End Sub


Sub BallSaverTimer2Expired_Timer()
    If debugGeneral Then debug.print "*****SUB:" & "BallSaverTimer2Expired_Timer"
    BallSaverTimer2Expired.Enabled = False

    ' clear the flag
    bBallSaverActive = False
End Sub

Sub BallSaverUpdateTimer_Timer()
	Dim tmp
    'If debugGeneral Then debug.print "*****SUB:" & "BallSaverUpdateTimer_Timer " & dbstime

	dbstens = Int(dbstime/10)
	dbsones = Int(dbstime-dbstens*10)
	dbsdecimals = Int((dbstime-dbstens*10-dbsones)*10)

	if dbstime > 10 then 
		fBStens.ImageA = Eval(dbstens)
		fBSones.ImageA = Eval(dbsones)
	else
		fBStens.ImageA = Eval (dbsones + 10)
		fBSones.ImageA = Eval(dbsdecimals)
	end if
'	if dbstime > 10 then 
'		'DEBUG.PRINT dbstime & " : " & dbstens & " : " & dbsones & " : " & dbsdecimals
'		dBallSave1.SetValue (dbstens + 1)
'		dBallSave2.SetValue (dbsones + 1)
'	else
'		'DEBUG.PRINT dbstime & " : " & dbstens & " : " & dbsones & " : " & dbsdecimals
'		dBallSave1.SetValue (dbsones + 1+10)
'		dBallSave2.SetValue (dbsdecimals + 1)
'	end if
	dbstime = dbstime - dbsdelta

End Sub

'Version of Ballsaver using light insert
'Sub EnableBallSaver(seconds)
'    If debugGeneral Then debug.print "*****SUB:EnableBallSaver, seconds=" & seconds
'    ' set our game flag
'    bBallSaverActive = True
'    bBallSaverReady = False
'    ' start the timer
'    BallSaverTimerExpired.Interval = 1000 * seconds
'    BallSaverTimerExpired.Enabled = True
'    BallSaverSpeedUpTimer.Interval = 1000 * seconds -(1000 * seconds) / 3
'    BallSaverSpeedUpTimer.Enabled = True
'    ' if you have a ball saver light you might want to turn it on at this point (or make it flash)
'    lLightShootAgain.BlinkInterval = 160
'    lLightShootAgain.State = 2
'End Sub
'
'' The ball saver timer has expired.  Turn it off AND reset the game flag
''
'Sub BallSaverTimerExpired_Timer()
'       If debugGeneral Then debug.print "*****SUB:" & "BallSaverTimerExpired_Timer"
'    BallSaverTimerExpired.Enabled = False
'    ' clear the flag
'    bBallSaverActive = False
'    ' if you have a ball saver light then turn it off at this point
'    lLightShootAgain.State = 0
'End Sub
'
'Sub BallSaverSpeedUpTimer_Timer()
'    If debugGeneral Then debug.print "*****SUB:" & "BallSaverSpeedUpTimer_Timer"
'    BallSaverSpeedUpTimer.Enabled = False
'    ' Speed up the blinking
'    lLightShootAgain.BlinkInterval = 80
'    lLightShootAgain.State = 2
'End Sub
' *********************************************************************
'                      Supporting Score Functions
' *********************************************************************

Dim checkones
Sub AddScore(points)
	Dim xmultiplier
	xMultiplier = BallsOnPlayfield
	If xMultiplier = 0 then xMultiplier = 1

    If(Tilted = False)Then
        ' add the points to the current players score variable
        Score(CurrentPlayer) = Score(CurrentPlayer) + (points * xMultiplier)

        ' update the score displays
        DMDScore
    End if

 If debugGeneral Then debug.print "*****SUB:" & "AddScore(" & points * xMultiplier & "), Total=" & Score(CurrentPlayer) 
' you may wish to check to see if the player has gotten a replay
End Sub


Sub AddScoreForReactor()
	' add the points to the current players score variable
	Score(CurrentPlayer) = Score(CurrentPlayer) + (1)
	ReactorScore(CurrentPlayer) = ReactorScore(CurrentPlayer) + 1

	' update the score displays
	DMDScore

 If debugGeneral Then debug.print "*****SUB:" & "AddScore(1), Total=" & Score(CurrentPlayer) 
End Sub

Sub AddToTotalReactorReward

	Dim xmultiplier, rtmp
	xMultiplier = BallsOnPlayfield
	If xMultiplier = 0 then xMultiplier = 1

	rtmp = ReactorValue(CurrentPlayer) * xMultiplier
	ReactorReactorTotalReward(CurrentPlayer) = ReactorReactorTotalReward(CurrentPlayer) + rtmp

	'msgbox ReactorValue(CurrentPlayer) & ": Multiplier " & xMultiplier & "= " & rtmp & ": Sum = " & ReactorReactorTotalReward(CurrentPlayer) 
End Sub

Sub AddScoreSpecial2(points, points2)	'Increase Score and Reactor value
    If debugGeneral Then debug.print "*****SUB:" & "AddScoreSpecial(" & points & ")"

    If(Tilted = False)Then
        ' add the points to the current players score variable
        'Score(CurrentPlayer) = Score(CurrentPlayer) + points

		If ReactorValue(CurrentPlayer) < ReactorValueMax(CurrentPlayer) Then

			ReactorValue(CurrentPlayer) = ReactorValue(CurrentPlayer) + points2
			If ReactorValue(CurrentPlayer) >= ReactorValueMax(CurrentPlayer) Then
				ReactorValue(CurrentPlayer) = ReactorValueMax(CurrentPlayer)
			End If
			AddReactorBonus points2
			tReactorValue.text = ReactorValue(CurrentPlayer)
		End If

		AddScore(points)

    End if

' you may wish to check to see if the player has gotten a replay
End Sub

Sub AddScoreSpecial(points)	'Increase Score and Reactor value
    If debugGeneral Then debug.print "*****SUB:" & "AddScoreSpecial(" & points & ")"

	AddScoreSpecial2 points, points

End Sub

Sub SetReactorMaxed
	Dim delta
	'Update Reactor value to max
	delta = ReactorValueMax(CurrentPlayer) - ReactorValue(CurrentPlayer)
	ReactorValue(CurrentPlayer) = ReactorValueMax(CurrentPlayer)

	'Update Reactor Bonus Award
	If delta > 0 Then
		AddReactorBonus delta
	End If
End Sub


' Add bonus to the bonuspoints AND update the score board

'Sub AddBonus(points)
'    If debugGeneral Then debug.print "*****SUB:" & "AddBonus(" & points & ")"
'
'    If(Tilted = False)Then
'        ' add the bonus to the current players bonus variable
'        BonusPoints(CurrentPlayer) = BonusPoints(CurrentPlayer) + points
'        ' update the score displays
'        DMDScore
'    End if
'
'' you may wish to check to see if the player has gotten a replay
'End Sub
'
'' Add some points to the current Jackpot.
''
'Sub AddJackpot(points) 'not used in this table
'End Sub



Sub AddBonusMultiplier(n)
    If debugGeneral Then debug.print "*****SUB:" & "AddBonusMultiplier(" & n & ")"

    Dim NewBonusLevel
    ' if not at the maximum bonus level
    if(BonusMultiplier(CurrentPlayer) + n <= MaxMultiplier)then
        ' then add and set the lights
        NewBonusLevel = BonusMultiplier(CurrentPlayer) + n
        SetBonusMultiplier(NewBonusLevel)

    End if
End Sub

' Set the Bonus Multiplier to the specified level AND set any lights accordingly
' There is no bonus multiplier lights in this table
Sub SetBonusMultiplier(Level)
	Dim obj

    If debugGeneral Then debug.print "*****SUB:" & "SetBonusMultiplier(" & Level & ")"
    ' Set the multiplier to the specified level
    BonusMultiplier(CurrentPlayer) = Level
	
	' Update the lights
	Select Case Level:
		Case 1:
			l2X.State = 0
			l3X.State = 0
			l4X.State = 0
		Case 2:
			DOF 166, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BONUS 2X"), eBlinkfast, 1800, True, "tna_bonusmultiplier"
			UDMD "BONUS 2X", "", 1800
			l2X.State = 1
			l3X.State = 0
			l4X.State = 0

			GI37.TimerEnabled = True
			GICoreCount = 0
			For each obj in aGICore
				obj.state = 0
			Next
		Case 3:
			DOF 166, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BONUS 3X"), eBlinkfast, 1800, True, "tna_bonusmultiplier"
			UDMD "BONUS 3X", "", 1800
			l2X.State = 1
			l3X.State = 1
			l4X.State = 0

			GI37.TimerEnabled = True
			GICoreCount = 0
			For each obj in aGICore
				obj.state = 0
			Next
		Case 4:
			DOF 166, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BONUS 4X"), eBlinkfast, 1800, True, "tna_bonusmultiplier"
			UDMD "BONUS 4X", "", 1800
			l2X.State = 1
			l3X.State = 1
			l4X.State = 1

			GI37.TimerEnabled = True
			For each obj in aGICore
				obj.state = 0
			Next
		Case Else:
			l2X.State = 1
			l3X.State = 1
			l4X.State = 1
	End Select


End Sub

Dim GICoreCount,GICoredirection, GICoreSweep
GICoredirection = 1
GI37.TimerInterval=25
Sub GI37_Timer
	Dim obj
	For Each obj in aGICore
		SetLight obj, "orange", 0
	Next

	aGICore((GICoreCount+0) Mod 13).state = 1
	aGICore((GICoreCount+1) Mod 13).state = 1
	aGICore((GICoreCount+2) Mod 13).state = 1
	aGICore((GICoreCount+3) Mod 13).state = 0
	aGICore((GICoreCount+4) Mod 13).state = 0
	aGICore((GICoreCount+5) Mod 13).state = 0
	aGICore((GICoreCount+6) Mod 13).state = 0
	aGICore((GICoreCount+7) Mod 13).state = 0
	aGICore((GICoreCount+8) Mod 13).state = 0
	aGICore((GICoreCount+9) Mod 13).state = 0
	aGICore((GICoreCount+10) Mod 13).state = 0
	aGICore((GICoreCount+11) Mod 13).state = 0
	aGICore((GICoreCount+12) Mod 13).state = 0
	GICoreCount = GICoreCount + GICoredirection
	If GICoreCount = 10 Then
		GICoredirection = -1
		GICoreSweep = GICoreSweep + 1
	ElseIf GICoreCount = 0 Then
		GICoreSweep = GICoreSweep + 1
		GICoredirection = 1
	End If
	
	If GICoreSweep = 6 Then	'Sweep done, return lights to normal
		GI37.TimerEnabled = False
		GICoreDirection = 1
		GICoreCount = 0
		GICoreSweep = 0

		For each obj in aGICore
			obj.state = 1
			SetLight obj, GiColor, 1
		Next

		SetLight l1, "white", 0
		SetLight l2, "white", 0
		SetLight l3, "white", 0
		SetLight l4, "white", 0

	End If

End Sub



Sub AwardExtraBall()
	If CoopMode = 0 Then	
		If NOT bExtraBallWonThisBall Then 'Use if you want to limit to 1 extraball
			DMDFlush
			DOF 167, DOFPulse: DMD "", eNone, "_", eNone, Centerline(2, "EXTRA BALL WON"), eBlink, "", eNone, 1000, True, "tna_extraball"
			UDMD "EXTRA BALL", "AWARDED", 1000
			ExtraBallsAwards(CurrentPlayer) = ExtraBallsAwards(CurrentPlayer) + 1
'			bExtraBallWonThisBall = True

			'Set Insert or Display
			SetExtraBallDisplay
		End If
	End If
End Sub

Sub AwardExtraBallNoCallout()
	If CoopMode = 0 Then	
		If NOT bExtraBallWonThisBall Then 'Use if you want to limit to 1 extraball
			ExtraBallsAwards(CurrentPlayer) = ExtraBallsAwards(CurrentPlayer) + 1
'	       bExtraBallWonThisBall = True

			'Set Insert or Display
			SetExtraBallDisplay
		End If
	End If
End Sub

Sub SetExtraBallDisplay
	fBStens.ImageA = "e"
	fBSones.ImageA = "b"
End Sub

Sub AwardSpecial()
    DMDFlush
    DMD "", eNone, "_", eNone, Centerline(2, "EXTRA GAME WON"), eBlink, "", eNone, 1000, True, SoundFXDOF("fx_knocker", 129, DOFPulse, DOFKnocker)
    UDMD "EXTRA GAME", "AWARDED", 1000
	Credits = Credits + 1
	DOF 123, DOFPulse
    DOF 140, DOFOn
End Sub

Sub AwardJackpot() 'award a normal jackpot, double or triple jackpot
    DMDFlush
    DOF 123, DOFPulse
	DMD "", eNone, Centerline(1, ("JACKPOT")), eNone, "", eNone, CenterLine(3, FormatScore(Jackpot)), eBlinkFast, 1000, True, "tna_jackpot"
    UDMD "JACKPOT", Jackpot, 1000
	AddScore Jackpot
	GIGame 1, "purple"

End Sub

Sub AwardDoubleJackpot() 'in this table the jackpot is always 1 million + 10% of your score
    DMDFlush
    DOF 123, DOFPulse
	DMD "", eNone, Centerline(1, ("DOUBLE JACKPOT")), eNone, "", eNone, CenterLine(3, FormatScore(DoubleJackpot)), eBlinkFast, 1000, True, "tna_doublejackpot"
    UDMD "DBL JACKPOT", DoubleJackpot, 1000
    AddScore DoubleJackpot
	GIGame 9, "purple"
End Sub

Sub AwardTripleJackpot() 'in this table the jackpot is always 1 million + 10% of your score
    DOF 132, DOFPulse
    DMDFlush
    DMD "", eNone, Centerline(1, ("TRIPLE JACKPOT")), eNone, "", eNone, CenterLine(3, FormatScore(TripleJackpot)), eBlinkFast, 1000, True, "tna_triplejackpot"
    UDMD "TRPL JACKPOT", TripleJackpot, 1000
    AddScore TripleJackpot
	GIGame 10, "purple"
End Sub

Sub AwardSuperJackpot()
    DOF 133, DOFPulse
    DMDFlush
    DMD "", eNone, Centerline(1, ("SUPER JACKPOT")), eNone, "", eNone, CenterLine(3, FormatScore(SuperJackpot)), eBlinkFast, 1000, True, "tna_superjackpot"
    UDMD "SUPER JACKPOT", SuperJackpot, 1000
    AddScore SuperJackpot
	GIGame 11, "purple"
End Sub


Sub AwardSkillshot()
    DMDFlush
'	If LaneSaveCount(CurrentPlayer) = 1 Then
		DOF 168, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "SKILLSHOT"), eBlinkfast, 1000, True, "tna_lanesavelevelone"
		UDMD "SKILLSHOT", "LANE SAVE +1", 1000
'	Else
'		DOF 168, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "SKILLSHOT"), eBlinkfast, 1000, True, "tna_lanesaveincreased"
'	End If
    AddScore SkillshotValue
    GiEffect 2

	AwardSAVE 1

End Sub


Sub AwardHandsFreeSkillshot()
    DMDFlush
	DOF 169, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "SKILLSHOT"), eBlinkfast, 1000, True, "tna_superskillshot"
	UDMD "SUPER", "SKILLSHOT", 1000
    AddScore SkillshotValue
    GiEffect 2

	AwardSAVE 1
	SetReactorReady
End Sub



'*****************************
' Section;    Load / Save / Highscore
'*****************************

Sub Reseths
	If debugHighScore Then debug.print "Sub:Reseths"
    Dim x
	x = ""
    If(x <> "")Then HighScore(0) = CDbl(x)Else HighScore(0) = 100000 End If
    If(x <> "")Then HighScoreName(0) = x Else HighScoreName(0) = "TNA" End If
    If(x <> "")then HighScore(1) = CDbl(x)Else HighScore(1) = 100000 End If
    If(x <> "")then HighScoreName(1) = x Else HighScoreName(1) = "TNA" End If
    If(x <> "")then HighScore(2) = CDbl(x)Else HighScore(2) = 100000 End If
    If(x <> "")then HighScoreName(2) = x Else HighScoreName(2) = "TNA" End If
    If(x <> "")then HighScore(3) = CDbl(x)Else HighScore(3) = 100000 End If
    If(x <> "")then HighScoreName(3) = x Else HighScoreName(3) = "TNA" End If
    If(x <> "")then Credits = CInt(x)Else Credits = 0 End If
'    If(x <> "")then TotalGamesPlayed = CInt(x)Else TotalGamesPlayed = 0 End If
	Savehs
End Sub

Sub Loadhs
	If debugHighScore Then debug.print "Sub:Loadhs"
    Dim x
    x = LoadValue(TableName, "HighScore1")
    If(x <> "")Then HighScore(0) = CDbl(x)Else HighScore(0) = 100000 End If
    x = LoadValue(TableName, "HighScore1Name")
    If(x <> "")Then HighScoreName(0) = x Else HighScoreName(0) = "TNA" End If
    x = LoadValue(TableName, "HighScore2")
    If(x <> "")then HighScore(1) = CDbl(x)Else HighScore(1) = 100000 End If
    x = LoadValue(TableName, "HighScore2Name")
    If(x <> "")then HighScoreName(1) = x Else HighScoreName(1) = "TNA" End If
    x = LoadValue(TableName, "HighScore3")
    If(x <> "")then HighScore(2) = CDbl(x)Else HighScore(2) = 100000 End If
    x = LoadValue(TableName, "HighScore3Name")
    If(x <> "")then HighScoreName(2) = x Else HighScoreName(2) = "TNA" End If
    x = LoadValue(TableName, "HighScore4")
    If(x <> "")then HighScore(3) = CDbl(x)Else HighScore(3) = 100000 End If
    x = LoadValue(TableName, "HighScore4Name")
    If(x <> "")then HighScoreName(3) = x Else HighScoreName(3) = "TNA" End If
    x = LoadValue(TableName, "Credits")
    If(x <> "")then Credits = CInt(x)Else Credits = 0 End If
    x = LoadValue(TableName, "TotalGamesPlayed")
    If(x <> "")then TotalGamesPlayed = CInt(x)Else TotalGamesPlayed = 0 End If
End Sub

Sub Savehs
	If debugHighScore Then debug.print "Sub:Savehs"

    SaveValue TableName, "HighScore1", HighScore(0)
    SaveValue TableName, "HighScore1Name", HighScoreName(0)
    SaveValue TableName, "HighScore2", HighScore(1)
    SaveValue TableName, "HighScore2Name", HighScoreName(1)
    SaveValue TableName, "HighScore3", HighScore(2)
    SaveValue TableName, "HighScore3Name", HighScoreName(2)
    SaveValue TableName, "HighScore4", HighScore(3)
    SaveValue TableName, "HighScore4Name", HighScoreName(3)
    SaveValue TableName, "Credits", Credits
    SaveValue TableName, "TotalGamesPlayed", TotalGamesPlayed
End Sub

' ***********************************************************
'  High Score Initals Entry Functions - based on Black's code
' ***********************************************************

Dim hsbModeActive
Dim hsEnteredName
Dim hsEnteredDigits(3)
Dim hsCurrentDigit
Dim hsValidLetters
Dim hsCurrentLetter
Dim hsLetterFlash

Sub CheckHighscore()
	If debugHighScore Then debug.print "Sub:CheckHighscore"

	If CoopMode = 0 Then
		Dim tmp
'		tmp = Score(1)
'		If Score(2) > tmp Then tmp = Score(2)
'		If Score(3) > tmp Then tmp = Score(3)
'		If Score(4) > tmp Then tmp = Score(4)

		tmp = Score(CurrentPlayer)

		If tmp > HighScore(1)Then 'add 1 credit for beating the highscore
			AwardSpecial
		End If

		If tmp > HighScore(3) Then
			HighScore(3) = tmp
			'enter player's name
			HighScoreEntryInit()
		Else
			EndOfBallComplete()
		End If
	Else 'Co op mode running so no high score allowed
		EndOfBallComplete()
	End If
End Sub

Sub HighScoreEntryInit()
	If debugHighScore Then debug.print "Sub:HighScoreEntryInit"
    hsbModeActive = True
    uDMDScoreTimer.Enabled = False
    PlaySound SoundFXDOF("fx_knocker", 129, DOFPulse, DOFKnocker)

    Credits = Credits + 1
	DOF 123, DOFPulse

    hsLetterFlash = 0

    hsEnteredDigits(0) = " "
    hsEnteredDigits(1) = " "
    hsEnteredDigits(2) = " "
    hsCurrentDigit = 0

    hsValidLetters = " ABCDEFGHIJKLMNOPQRSTUVWXYZ'<>*+-/=\^0123456789`" ' ` is back arrow
    hsCurrentLetter = 1
    DMDFlush()
    HighScoreDisplayNameNow()

    HighScoreFlashTimer.Interval = 250
    HighScoreFlashTimer.Enabled = True
End Sub

Sub EnterHighScoreKey(keycode)
	If debugHighScore Then debug.print "Sub:EnterHighScoreKey keycode=" & keycode

    If keycode = LeftFlipperKey Then
        Playsound "fx_Previous"
        hsCurrentLetter = hsCurrentLetter - 1
        if(hsCurrentLetter = 0)then
            hsCurrentLetter = len(hsValidLetters)
        end if
        HighScoreDisplayNameNow()
    End If

    If keycode = RightFlipperKey Then
        Playsound "fx_Next"
        hsCurrentLetter = hsCurrentLetter + 1
        if(hsCurrentLetter > len(hsValidLetters))then
            hsCurrentLetter = 1
        end if
        HighScoreDisplayNameNow()
    End If

    If keycode = StartGameKey Then
        if(mid(hsValidLetters, hsCurrentLetter, 1) <> "`")then
            playsound "fx_Enter"
            hsEnteredDigits(hsCurrentDigit) = mid(hsValidLetters, hsCurrentLetter, 1)
            hsCurrentDigit = hsCurrentDigit + 1
            if(hsCurrentDigit = 3)then
                HighScoreCommitName()
            else
                HighScoreDisplayNameNow()
            end if
        else
            playsound "fx_Esc"
            hsEnteredDigits(hsCurrentDigit) = " "
            if(hsCurrentDigit > 0)then
                hsCurrentDigit = hsCurrentDigit - 1
            end if
            HighScoreDisplayNameNow()
        end if
    end if
End Sub

Sub HighScoreDisplayNameNow()
	If debugHighScore Then debug.print "Sub:HighScoreDisplayNameNow"
    HighScoreFlashTimer.Enabled = False
    hsLetterFlash = 0
    HighScoreDisplayName()
    If UseUltraDMD > 0 Then UltraDMD.CancelRendering
    UDMD Trim(dLine(1)), Trim(dLine(2)), 5000
    HighScoreFlashTimer.Enabled = True
End Sub

Sub HighScoreDisplayName()
	If debugHighScore Then debug.print "Sub:HighScoreDisplayName"
    Dim i
    Dim TempTopStr
    Dim TempBotStr

    TempTopStr = "ENTER INITIALS"
    dLine(1) = CenterLine(1, TempTopStr)
    DMDUpdate 1

    TempBotStr = "    > "
    if(hsCurrentDigit > 0)then TempBotStr = TempBotStr & hsEnteredDigits(0)
    if(hsCurrentDigit > 1)then TempBotStr = TempBotStr & hsEnteredDigits(1)
    if(hsCurrentDigit > 2)then TempBotStr = TempBotStr & hsEnteredDigits(2)

    if(hsCurrentDigit <> 3)then
        if(hsLetterFlash <> 0)then
            TempBotStr = TempBotStr & "_"
        else
            TempBotStr = TempBotStr & mid(hsValidLetters, hsCurrentLetter, 1)
        end if
    end if

    if(hsCurrentDigit < 1)then TempBotStr = TempBotStr & hsEnteredDigits(1)
    if(hsCurrentDigit < 2)then TempBotStr = TempBotStr & hsEnteredDigits(2)

    TempBotStr = TempBotStr & " <    "
    dLine(2) = CenterLine(2, TempBotStr)
    DMDUpdate 2

End Sub

Sub HighScoreFlashTimer_Timer()
	If debugHighScore Then debug.print "Sub:HighScoreFlashTimer_Timer"
    HighScoreFlashTimer.Enabled = False
    hsLetterFlash = hsLetterFlash + 1
    if(hsLetterFlash = 2)then hsLetterFlash = 0
    HighScoreDisplayName()
    If UseUltraDMD > 0 Then UltraDMD.CancelRendering
	UDMD Trim(dLine(1)), Trim(dLine(2)), 5000

    HighScoreFlashTimer.Enabled = True
End Sub

Sub HighScoreCommitName()
	If debugHighScore Then debug.print "Sub:HighScoreCommitName"
    HighScoreFlashTimer.Enabled = False
    'hsbModeActive = False

	DMD "", eNone, "", eNone, "", eNone, "", eNone, 1000, True, ""
	vpmtimer.addtimer 800, "HighscoreDelay '"

    hsEnteredName = hsEnteredDigits(0) & hsEnteredDigits(1) & hsEnteredDigits(2)
    if(hsEnteredName = "   ")then
        hsEnteredName = "YOU"
    end if

    HighScoreName(3) = hsEnteredName
    SortHighscore
    EndOfBallComplete()
End Sub

Sub HighscoreDelay
	hsbModeActive = False
	uDMDScoreTimer.Enabled = True
End Sub

Sub SortHighscore
	If debugHighScore Then debug.print "Sub:SortHighscore"
    Dim tmp, tmp2, i, j
    For i = 0 to 3
        For j = 0 to 2
            If HighScore(j) < HighScore(j + 1)Then
                tmp = HighScore(j + 1)
                tmp2 = HighScoreName(j + 1)
                HighScore(j + 1) = HighScore(j)
                HighScoreName(j + 1) = HighScoreName(j)
                HighScore(j) = tmp
                HighScoreName(j) = tmp2
            End If
        Next
    Next
End Sub

' *****************************************************************************
'   JP's Reduced Display Driver Functions for Slimer (based on script by Black)
' only 5 effects: none, scroll left, scroll right, blink and blinkfast
' 4 Lines, treats all 4 lines as text
' Example format:
' DMD "backgnd", eNone,"text1", eNone,"text2", eNone, "centertext", eNone, 250, True, "sound"
' Short names:
' dq = display queue
' de = display effect
' "_" in a line means: do nothing
' *****************************************************************************
 
Const eNone = 0        ' Instantly displayed
Const eScrollLeft = 1  ' scroll on from the right
Const eScrollRight = 2 ' scroll on from the left
Const eBlink = 3       ' Blink (blinks for 'TimeOn')
Const eBlinkFast = 4   ' Blink (blinks for 'TimeOn') at user specified intervals (fast speed)
Const dqSize = 64

Dim dqHead
Dim dqTail
Dim deSpeed
Dim deBlinkSlowRate
Dim deBlinkFastRate

Dim dCharsPerLine(3)
Dim dLine(3)
Dim deCount(3)
Dim deCountEnd(3)
Dim deBlinkCycle(3)

Dim dqText(3, 64)
Dim dqEffect(3, 64)
Dim dqTimeOn(64)
Dim dqbFlush(64)
Dim dqSound(64)

Sub DMD_Init() 'default/startup values
    Dim i, j
    DMDFlush()
    deSpeed = 20
    deBlinkSlowRate = 5
    deBlinkFastRate = 2
    dCharsPerLine(0) = 3
    dCharsPerLine(1) = 19
    dCharsPerLine(2) = 19
    dCharsPerLine(3) = 13
    For i = 0 to 3
        dLine(i) = Space(dCharsPerLine(i))
        deCount(i) = 0
        deCountEnd(i) = 0
        deBlinkCycle(i) = 0
        dqTimeOn(i) = 0
        dqbFlush(i) = True
        dqSound(i) = ""
    Next
    For i = 0 to 3
        For j = 0 to 64
            dqText(i, j) = ""
            dqEffect(i, j) = eNone
        Next
    Next
    DMD "", eNone, "", eNone, "", eNone, "", eNone, 25, True, ""
End Sub

Sub DMDFlush()
    Dim i
    DMDTimer.Enabled = False
    DMDEffectTimer.Enabled = False
    dqHead = 0
    dqTail = 0
    For i = 0 to 3
        deCount(i) = 0
        deCountEnd(i) = 0
        deBlinkCycle(i) = 0
    Next
	If UseUltraDMD > 0 Then UltraDMD.CancelRendering
End Sub

Sub DMDScoreNow()
    DMDFlush()
    DMDScore()
End Sub

Sub DMDScore()
    Dim tmp0, tmp1, tmp2, tmp3
	Dim CoopScore, i

	If CoopMode = 1 Then	'IF Co-Op mode 1 selected, all players get same score
		CoopScore = Score(CurrentPlayer)
'		For i = 1 To MaxPlayers
'			Score(i) = CoopScore
'		Next	
		Score(1) = (Int(CoopScore / 10) * 10) + ReactorScore(1)
		Score(2) = (Int(CoopScore / 10) * 10) + ReactorScore(2)
		Score(3) = (Int(CoopScore / 10) * 10) + ReactorScore(3)
		Score(4) = (Int(CoopScore / 10) * 10) + ReactorScore(4)

	ElseIf CoopMode = 2 Then	'Player 1,3 share score.  Player 2,4 share score
		Select Case CurrentPlayer
			Case 1
				Score(3) = (Int(Score(1) / 10) * 10) + ReactorScore(3)
			Case 2
				Score(4) = (Int(Score(2) / 10) * 10) + ReactorScore(4)
			Case 3
				Score(1) = (Int(Score(3) / 10) * 10) + ReactorScore(1)
			Case 4
				Score(2) = (Int(Score(4) / 10) * 10) + ReactorScore(2)
		End Select
	End If

    if(dqHead = dqTail)Then
        tmp0 = ""
        tmp1 = FillLine(1, " PLAYER " & CurrentPlayer, FormatScore(Score(CurrentPlayer)))
        tmp2 = FillLine(2, " RVAL:" & FormatScore(ReactorValue(CurrentPlayer)), "BALL" & Balls)
        tmp3 = ""
        DMD tmp0, eNone, tmp1, eNone, tmp2, eNone, tmp3, eNone, 25, True, ""
    End If

	If B2SOn Then
		If CoopMode = 0 Then
			Controller.B2SSetScorePlayer CurrentPlayer, Score(CurrentPlayer)
		Else
			For i = 1 to PlayersPlayingGame
				Controller.B2SSetScorePlayer i, Score(i)
			Next
		End If
	End If

	uDMDScoreUpdate

End Sub


'   DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "CRITICAL"), eBlinkfast, 1800, True, "tna_reactorcriticalvoice
Sub DMD(Text0, Effect0, Text1, Effect1, Text2, Effect2, Text3, Effect3, TimeOn, bFlush, Sound) 'the lines are  background. top line, bottom line, and centerline
    if(dqTail < dqSize)Then
        if(Text0 = "_")Then
            dqEffect(0, dqTail) = eNone
            dqText(0, dqTail) = "_"
        Else
            dqEffect(0, dqTail) = Effect0
            dqText(0, dqTail) = ExpandLine(Text0, 0)
        End If

        if(Text1 = "_")Then
            dqEffect(1, dqTail) = eNone
            dqText(1, dqTail) = "_"
        Else
            dqEffect(1, dqTail) = Effect1
            dqText(1, dqTail) = ExpandLine(Text1, 1)
        End If

        if(Text2 = "_")Then
            dqEffect(2, dqTail) = eNone
            dqText(2, dqTail) = "_"
        Else
            dqEffect(2, dqTail) = Effect2
            dqText(2, dqTail) = ExpandLine(Text2, 2)
        End If

        if(Text3 = "_")Then
            dqEffect(3, dqTail) = eNone
            dqText(3, dqTail) = "_"
        Else
            dqEffect(3, dqTail) = Effect3
            dqText(3, dqTail) = ExpandLine(Text3, 3)
        End If

        dqTimeOn(dqTail) = TimeOn
        dqbFlush(dqTail) = bFlush
        dqSound(dqTail) = Sound
        dqTail = dqTail + 1
        if(dqTail = 1)Then
            DMDHead()
        End If
    End If
End Sub

Sub DMDHead()
    Dim i
    deCount(0) = 0
    deCount(1) = 0
    deCount(2) = 0
    deCount(3) = 0
    DMDEffectTimer.Interval = deSpeed

    For i = 0 to 3
        Select Case dqEffect(i, dqHead)
            Case eNone:deCountEnd(i) = 1
            Case eScrollLeft:deCountEnd(i) = Len(dqText(i, dqHead))
            Case eScrollRight:deCountEnd(i) = Len(dqText(i, dqHead))
            Case eBlink:deCountEnd(i) = int(dqTimeOn(dqHead) / deSpeed)
                deBlinkCycle(i) = 0
            Case eBlinkFast:deCountEnd(i) = int(dqTimeOn(dqHead) / deSpeed)
                deBlinkCycle(i) = 0
        End Select
    Next


		
    if(dqSound(dqHead) <> "")Then
        PlaySound(dqSound(dqHead))
    End If
    DMDEffectTimer.Enabled = True
End Sub

Sub DMDEffectTimer_Timer()
    DMDEffectTimer.Enabled = False
    DMDProcessEffectOn()
End Sub

Sub DMDTimer_Timer()
    Dim Head
    DMDTimer.Enabled = False
    Head = dqHead
    dqHead = dqHead + 1
    if(dqHead = dqTail)Then
        if(dqbFlush(Head) = True)Then
            DMDFlush()
            DMDScore()
        Else
            dqHead = 0
            DMDHead()
        End If
    Else
        DMDHead()
    End If
End Sub

Sub DMDProcessEffectOn()
    Dim i
    Dim BlinkEffect
    Dim Temp

    BlinkEffect = False

    For i = 0 to 3
        if(deCount(i) <> deCountEnd(i))Then
            deCount(i) = deCount(i) + 1

            select case(dqEffect(i, dqHead))
                case eNone:
                    Temp = dqText(i, dqHead)
                case eScrollLeft:
                    Temp = Right(dLine(i), dCharsPerLine(i)- 1)
                    Temp = Temp & Mid(dqText(i, dqHead), deCount(i), 1)
                case eScrollRight:
                    Temp = Mid(dqText(i, dqHead), (dCharsPerLine(i) + 1)- deCount(i), 1)
                    Temp = Temp & Left(dLine(i), dCharsPerLine(i)- 1)
                case eBlink:
                    BlinkEffect = True
                    if((deCount(i)MOD deBlinkSlowRate) = 0)Then
                        deBlinkCycle(i) = deBlinkCycle(i)xor 1
                    End If

                    if(deBlinkCycle(i) = 0)Then
                        Temp = dqText(i, dqHead)
                    Else
                        Temp = Space(dCharsPerLine(i))
                    End If
                case eBlinkFast:
                    BlinkEffect = True
                    if((deCount(i)MOD deBlinkFastRate) = 0)Then
                        deBlinkCycle(i) = deBlinkCycle(i)xor 1
                    End If

                    if(deBlinkCycle(i) = 0)Then
                        Temp = dqText(i, dqHead)
                    Else
                        Temp = Space(dCharsPerLine(i))
                    End If
            End Select

            if(dqText(i, dqHead) <> "_")Then
                dLine(i) = Temp
                DMDUpdate i
            End If
        End If
    Next

    if(deCount(0) = deCountEnd(0))and(deCount(1) = deCountEnd(1))and(deCount(2) = deCountEnd(2))and(deCount(3) = deCountEnd(3))Then

        if(dqTimeOn(dqHead) = 0)Then
            DMDFlush()
        Else
            if(BlinkEffect = True)Then
                DMDTimer.Interval = 10
            Else
                DMDTimer.Interval = dqTimeOn(dqHead)
            End If

            DMDTimer.Enabled = True
        End If
    Else
        DMDEffectTimer.Enabled = True
    End If
End Sub

Function ExpandLine(TempStr, id) 'id is the number of the dmd line
    If TempStr = "" Then
        TempStr = Space(dCharsPerLine(id))
    Else
        if(Len(TempStr) > dCharsPerLine(id))Then
            TempStr = Left(TempStr, dCharsPerLine(id))
        Else
            if(Len(TempStr) < dCharsPerLine(id))Then
                TempStr = TempStr & Space(dCharsPerLine(id)- Len(TempStr))
            End If
        End If
    End If
    ExpandLine = TempStr
End Function

Function FormatScore(ByVal Num) 'it returns a string with commas (as in Black's original font)
    dim i
    dim NumString

    NumString = CStr(abs(Num))

    For i = Len(NumString)-3 to 1 step -3
        if IsNumeric(mid(NumString, i, 1))then
            NumString = left(NumString, i-1) & chr(asc(mid(NumString, i, 1)) + 48) & right(NumString, Len(NumString)- i)
        end if
    Next
    FormatScore = NumString
End function

Function UDMDFormatScore(ByVal Num) 'it returns a string with commas (as in Black's original font)
    dim i
    dim NumString

    NumString = CStr(abs(Num))

    For i = Len(NumString)-3 to 1 step -3
        if IsNumeric(mid(NumString, i, 1))then
            NumString = left(NumString, i-1) & "," & right(NumString, Len(NumString)- i)
        end if
    Next
    UDMDFormatScore = NumString
End function

Function CenterLine(id, aString)
    Dim tmp, tmpStr
    tmp = (dCharsPerLine(id)- Len(aString)) \ 2
    If(tmp + tmp + Len(aString)) < dCharsPerLine(id)Then
        tmpStr = " " & Space(tmp) & aString & Space(tmp)
    Else
        tmpStr = Space(tmp) & aString & Space(tmp)
    End If
    CenterLine = tmpStr
End Function

Function FillLine(id, aString, bString)
    Dim tmp, tmpStr
    tmp = dCharsPerLine(id)- Len(aString)- Len(bString)
    tmpStr = aString & Space(tmp) & bString
    FillLine = tmpStr
End Function

Function RightLine(id, aString)
    Dim tmp, tmpStr
    tmp = dCharsPerLine(id)- Len(aString)
    tmpStr = Space(tmp) & aString
    RightLine = tmpStr
End Function

'*********************
' Section; Update DMD - reels
'*********************
Dim DesktopMode:DesktopMode = Table1.ShowDT

Dim Digits(3)

DMDReels_Init

Sub DMDReels_Init
    If DesktopMode Then
        'Desktop
        Digits(0) = Array(d0, d1, d2)                                                                                    'backdrop
        Digits(1) = Array(d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21)        'upper line
        Digits(2) = Array(d22, d23, d24, d25, d26, d27, d28, d29, d30, d31, d32, d33, d34, d35, d36, d37, d38, d39, d40) 'lower line
        Digits(3) = Array(d41, d42, d43, d44, d45, d46, d47, d48, d49, d50, d51, d52, d53)                               ' center line
        d54.Visible = 0:d55.Visible = 0:d56.Visible = 0
    Else
        'FS
        Digits(0) = Array(d54, d55, d56)                                                                                 'backdrop
        Digits(1) = Array(d57, d58, d59, d60, d61, d62, d63, d64, d65, d66, d67, d68, d69, d70, d71, d72, d73, d74, d75) 'upper line
        Digits(2) = Array(d76, d77, d78, d79, d80, d81, d82, d83, d84, d85, d86, d87, d88, d89, d90, d91, d92, d93, d94) 'lower line
        Digits(3) = Array(d95, d96, d97, d98, d99, d100, d101, d102, d103, d104, d105, d106, d107)
        d0.Visible = 0:d1.Visible = 0:d2.Visible = 0
    End If
End Sub

Sub DMDUpdate(id)
    Dim digit, value

	If UseApronDMD = 1 or DesktopMode or hsbModeActive or ResetHighScore = 1 Then
		For digit = 0 to dCharsPerLine(id)-1
			value = ASC(mid(dLine(id), digit + 1, 1))-32
			Digits(id)(digit).SetValue value
		Next
	End If

End Sub

'****************************************
' Section; Real Time updatess using the GameTimer
'****************************************
'used for all the real time updates

Sub GameTimer_Timer
    RollingUpdate
    ' add any other real time update subs, like gates or diverters
End Sub

'********************************************************************************************
' Only for VPX 10.2 and higher.
' Section; FlashForMs will blink light or a flasher for TotalPeriod(ms) at rate of BlinkPeriod(ms)
' When TotalPeriod done, light or flasher will be set to FinalState value where
' Final State values are:   0=Off, 1=On, 2=Return to previous State
'********************************************************************************************

Sub FlashForMs(MyLight, TotalPeriod, BlinkPeriod, FinalState) 'thanks gtxjoe for the first myVersion

    If TypeName(MyLight) = "Light" Then

        If FinalState = 2 Then
            FinalState = MyLight.State 'Keep the current light state
        End If
        MyLight.BlinkInterval = BlinkPeriod
        MyLight.Duration 2, TotalPeriod, FinalState
    ElseIf TypeName(MyLight) = "Flasher" Then

        Dim steps

        ' Store all blink information
        steps = Int(TotalPeriod / BlinkPeriod + .5) 'Number of ON/OFF steps to perform
        If FinalState = 2 Then                      'Keep the current flasher state
            FinalState = ABS(MyLight.Visible)
        End If
        MyLight.UserValue = steps * 10 + FinalState 'Store # of blinks, and final state

        ' Start blink timer and create timer subroutine
        MyLight.TimerInterval = BlinkPeriod
        MyLight.TimerEnabled = 0
        MyLight.TimerEnabled = 1
        ExecuteGlobal "Sub " & MyLight.Name & "_Timer:" & "Dim tmp, steps, fstate:tmp=me.UserValue:fstate = tmp MOD 10:steps= tmp\10 -1:Me.Visible = steps MOD 2:me.UserValue = steps *10 + fstate:If Steps = 0 then Me.Visible = fstate:Me.TimerEnabled=0:End if:End Sub"
    End If
End Sub

Sub FlashForMsrgb(MyLight, TotalPeriod, BlinkPeriod, FinalState, Red, Green, Blue) 'thanks gtxjoe for the first myVersion

    If TypeName(MyLight) = "Light" Then

        If FinalState = 2 Then
            FinalState = MyLight.State 'Keep the current light state
        End If
        MyLight.BlinkInterval = BlinkPeriod
        MyLight.Duration 2, TotalPeriod, FinalState
    ElseIf TypeName(MyLight) = "Flasher" Then

        Dim steps

        ' Store all blink information
        steps = Int(TotalPeriod / BlinkPeriod + .5) 'Number of ON/OFF steps to perform
        If FinalState = 2 Then                      'Keep the current flasher state
            FinalState = ABS(MyLight.Visible)
        End If
        MyLight.UserValue = steps * 10 + FinalState 'Store # of blinks, and final state

        ' Start blink timer and create timer subroutine
        MyLight.TimerInterval = BlinkPeriod
        MyLight.TimerEnabled = 0
        MyLight.TimerEnabled = 1
        ExecuteGlobal "Sub " & MyLight.Name & "_Timer:" & "Dim tmp, steps, fstate:tmp=me.UserValue:fstate = tmp MOD 10:steps= tmp\10 -1:Me.Visible = steps MOD 2:me.UserValue = steps *10 + fstate:If Steps = 0 then Me.Visible = fstate:Me.TimerEnabled=0:End if:End Sub"
    End If
End Sub
'******************************************
' Section; Change light color - simulate color leds
' changes the light color and state
' colors: red, orange, yellow, green, blue, white
'******************************************

'Sub SetLight(n, col, stat)
Sub SetLight(n, col, stat)
	'SEt Color
    Select Case col
        Case "red"
            n.color = RGB(128, 0, 0)
            n.colorfull = RGB(255, 0, 0)
        Case "orange"
            n.color = RGB(18, 3, 0)
            n.colorfull = RGB(255, 64, 0)
        Case "yellow"
            n.color = RGB(18, 18, 0)
            n.colorfull = RGB(255, 255, 0)
        Case "green"
            n.color = RGB(0, 32, 0)
            n.colorfull = RGB(0, 200, 0)
        Case "blue"
            n.color = RGB(0, 5, 128)
            n.colorfull = RGB(0, 10, 255)
        Case "white"
            n.color = RGB(255, 252, 224)
            n.colorfull = RGB(193, 91, 0)
        Case "whitegi"
            n.color = RGB(0, 0, 0)
            n.colorfull = RGB(225, 225, 225)
        Case "purple"
            n.color = RGB(128, 0, 128)
            n.colorfull = RGB(255, 0, 255)
        Case "amber"
            n.color = RGB(193, 49, 0)
            n.colorfull = RGB(255, 153, 0)
		Case ""
    End Select

	'Set State
    If stat <> -1 Then
        n.State = 0
        n.State = stat
    End If

End Sub

SetLight l10, "", -1

' ********************************
'   Table info & Attract Mode
' ********************************

Sub ShowTableInfo

    If Score(1)Then
		DMD "", eNone, "", eNone, "", eNone, "", eNone, 1000, True, ""
		UDMD "", "", 1000
		'info goes in a loop only stopped by the credits and the startkey
		DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "GAME OVER"), eBlink, 2000, False, "":PuPEvent 50 'game over
		UDMD "GAME OVER", "", 2000
	Else
		DMD "", eNone, "", eNone, "", eNone, CenterLine(3, " "), eBlink, 5000, False, "" 'game over
	END IF

    If Score(1)Then
        DMD "", eNone, CenterLine(1, FormatScore(Score(1))), eNone, CenterLine(2, "PLAYER 1"), eNone, "", eNone, 3000, False, ""
		UDMD "PLAYER 1", Score(1), 3000
    End If
    If Score(2)Then
        DMD "", eNone, CenterLine(1, FormatScore(Score(2))), eNone, CenterLine(2, "PLAYER 2"), eNone, "", eNone, 3000, False, ""
		UDMD "PLAYER 2", Score(2), 3000
	End If
    If Score(3)Then
        DMD "", eNone, CenterLine(1, FormatScore(Score(3))), eNone, CenterLine(2, "PLAYER 3"), eNone, "", eNone, 3000, False, ""
		UDMD "PLAYER 3", Score(3), 3000
	End If
    If Score(4)Then
        DMD "", eNone, CenterLine(1, FormatScore(Score(4))), eNone, CenterLine(2, "PLAYER 4"), eNone, "", eNone, 3000, False, ""
		UDMD "PLAYER 4", Score(4), 3000
    End If
	
    DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "GAME OVER"), eBlink, 2000, False, "" 'game over
	UDMD "GAME OVER", "", 2000
    
	If bFreePlay Then
        DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "FREE PLAY"), eNone, 3000, False, ""
		UDMD "FREE PLAY", "", 3000
    Else
        If Credits > 0 Then
            DMD "", eNone, CenterLine(1, "CREDITS " & Credits), eNone, CenterLine(2, "PRESS START"), eNone, "", eNone, 2000, False, ""
			UDMD "PRESS START", "", 2000
        Else
            DMD "", eNone, CenterLine(1, "CREDITS " & Credits), eNone, CenterLine(2, "INSERT COIN"), eNone, "", eNone, 2000, False, ""
			UDMD "INSERT COIN", "", 2000
        End If
    End If
    DMD "", eNone, "        VPX", eNone, "     PRESENTS", eNone, "", eNone, 2000, False, ""
	UDMD "VPX", "PRESENTS", 2000

    DMD "", eNone, "   TOTAL  NUCLEAR", eNone, "    ANNIHILATION", eNone, "", eNone, 2000, False, ""
	UDMD "TOTAL NUCLEAR", "ANNIHILATION", 2000

    DMD "", eNone, "   TRY CO-OP MODES", eNone, "   PRESS MAGNASAVE", eNone, "", eNone, 2000, False, ""
	UDMD "TRY CO-OP MODES", "USE MAGNASAVE", 2000

'    DMD "", eNone, CenterLine(1, "HIGH SCORES"), eScrollLeft, Space(dCharsPerLine(2)), eScrollLeft, "", eNone, 20, False, ""
'	UDMD "", "", 20

    DMD "", eNone, CenterLine(1, "HIGH SCORES"), eBlinkFast, "", eNone, "", eNone, 2000, False, ""
	UDMD "HIGH SCORES", "", 2000
	
    DMD "", eNone, CenterLine(1, "HIGH SCORE"), eNone, "  1  " &HighScoreName(0) & " " &FormatScore(HighScore(0)), eNone, "", eNone, 2000, False, ""
	UDMD "HIGH SCORE 1", HighScoreName(0) & "  " & HighScore(0), 2000
	
    DMD "", eNone, "_", eNone, "  2  " &HighScoreName(1) & " " &FormatScore(HighScore(1)), eNone, "", eNone, 2000, False, ""
	UDMD "HIGH SCORE 2", HighScoreName(1) & "  " & HighScore(1), 2000

    DMD "", eNone, "_", eNone, "  3  " &HighScoreName(2) & " " &FormatScore(HighScore(2)), eNone, "", eNone, 2000, False, ""
	UDMD "HIGH SCORE 3", HighScoreName(2) & "  " & HighScore(2), 2000

    DMD "", eNone, "_", eNone, "  4  " &HighScoreName(3) & " " &FormatScore(HighScore(3)), eNone, "", eNone, 2000, False, ""
	UDMD "HIGH SCORE 4", HighScoreName(3) & "  " & HighScore(3), 2000

    DMD "", eNone, Space(dCharsPerLine(1)), eNone, Space(dCharsPerLine(2)), eNone, "", eNone, 500, False, ""
	UDMD "", "", 500
End Sub

Sub StartAttractMode(dummy)
	DOF 149, DOFOn
    StartLightSeq
    DMDFlush

	If ResetHighScore = 0 Then
		ShowTableInfo
	Else
		DMD "", eNone, "  HIGH SCORE RESET", eNone, "      EXIT GAME", eNone, "", eNone, 100000, False, ""
		UDMD "HIGH SCORE RESET", "EXIT GAME", 100000
	End If
'''    StartRainbow "arrows"
End Sub

Sub StopAttractMode
	DOF 149, DOFOff
    DMDFlush
	DMD "", eNone, "", eNone, "", eNone, "", eNone, 500, True, ""
	UDMD "", "", 500
    LightSeqAttract.StopPlay
'''    StopRainbow
'StopSong

End Sub

Sub StartLightSeq()
    'lights sequences
    LightSeqAttract.UpdateInterval = 15
    LightSeqAttract.Play SeqCircleInOn, 40, 1

    LightSeqAttract.UpdateInterval = 2
    LightSeqAttract.Play SeqRandom, 40, , 4000
    LightSeqAttract.Play SeqAllOff

    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqCircleOutOn, 25, 4

    LightSeqAttract.UpdateInterval = 4
    LightSeqAttract.Play SeqBlinking, , 5, 150

    LightSeqAttract.UpdateInterval = 4
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.Play SeqUpOn, 25, 1, 500
    LightSeqAttract.UpdateInterval = 4
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.Play SeqUpOn, 25, 1, 500

    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqCircleOutOn, 25, 4

    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqRightOn, 50, 1
    LightSeqAttract.UpdateInterval = 8
    LightSeqAttract.Play SeqLeftOn, 50, 1

    LightSeqAttract.UpdateInterval = 5
    LightSeqAttract.Play SeqStripe2VertOn, 50, 4

    LightSeqAttract.UpdateInterval = 4
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.Play SeqUpOn, 25, 1, 500
    LightSeqAttract.UpdateInterval = 4
    LightSeqAttract.Play SeqDownOn, 25, 1
    LightSeqAttract.Play SeqUpOn, 25, 1, 500

    LightSeqAttract.UpdateInterval = 2
    LightSeqAttract.Play SeqScrewRightOn, 50, 8

    LightSeqAttract.UpdateInterval = 2
    LightSeqAttract.Play SeqBlinking, , 5, 150
'
'
'    LightSeqAttract.Play SeqRandom, 40, , 4000
'    LightSeqAttract.Play SeqAllOff
''    LightSeqAttract.UpdateInterval = 8
''    LightSeqAttract.Play SeqUpOn, 50, 1
'    LightSeqAttract.UpdateInterval = 2
'    LightSeqAttract.Play SeqDownOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqCircleOutOn, 15, 2
'    LightSeqAttract.UpdateInterval = 8
''    LightSeqAttract.Play SeqUpOn, 25, 1
''    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 25, 1
''    LightSeqAttract.UpdateInterval = 8
''    LightSeqAttract.Play SeqUpOn, 25, 1
''    LightSeqAttract.UpdateInterval = 8
''    LightSeqAttract.Play SeqDownOn, 25, 1
''    LightSeqAttract.UpdateInterval = 10
''    LightSeqAttract.Play SeqCircleOutOn, 15, 3
'    LightSeqAttract.UpdateInterval = 5
'    LightSeqAttract.Play SeqRightOn, 50, 1
'    LightSeqAttract.UpdateInterval = 5
'    LightSeqAttract.Play SeqLeftOn, 50, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 50, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 50, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 40, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 40, 1
'    LightSeqAttract.UpdateInterval = 10
'    LightSeqAttract.Play SeqRightOn, 30, 1
'    LightSeqAttract.UpdateInterval = 10
'    LightSeqAttract.Play SeqLeftOn, 30, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 15, 1
'    LightSeqAttract.UpdateInterval = 10
'    LightSeqAttract.Play SeqCircleOutOn, 15, 3
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 25, 1
'    LightSeqAttract.UpdateInterval = 5
'    LightSeqAttract.Play SeqStripe1VertOn, 50, 2
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqCircleOutOn, 15, 2
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqStripe1VertOn, 50, 3
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqCircleOutOn, 15, 2
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqStripe2VertOn, 50, 3
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 25, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqStripe1VertOn, 25, 3
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqStripe2VertOn, 25, 3
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqUpOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqDownOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqRightOn, 15, 1
'    LightSeqAttract.UpdateInterval = 8
'    LightSeqAttract.Play SeqLeftOn, 15, 1
End Sub

Sub LightSeqAttract_PlayDone()
    StartLightSeq()
End Sub

Sub LightSeqTilt_PlayDone()
    'LightSeqTilt.Play SeqAllOff
End Sub

Sub LightSeqGame_PlayDone()
	PreviousGI
	LightSeqGame.TimerInterval = 500
	LightSeqGame.TimerEnabled = True
End Sub

Sub LightSeqGame_Timer
	GiOn
	LightSeqGame.TimerEnabled = False
End Sub

Sub LightSeqMball_PlayDone()
	PreviousGI
	LightSeqMball.TimerInterval = 500
	LightSeqMball.TimerEnabled = True
End Sub

Sub LightSeqMball_Timer
	GiOn
	LightSeqMball.TimerEnabled = False
End Sub

Sub LightSeqSkillshot_PlayDone()
    LightSeqSkillshot.Play SeqAllOff
End Sub

'*************************
' Section; Rainbow Changing Lights
'*************************

Dim RGBStep, RGBFactor, Red, Green, Blue, RainbowLights

Sub StartRainbow(n)
    RainbowLights = n
    RGBStep = 0
    RGBFactor = 10
    Red = 255
    Green = 0
    Blue = 0

    RainbowTimer.Interval = 40
    RainbowTimer.Enabled = 1
End Sub

Sub StopRainbow()
    Dim obj
    RainbowTimer.Enabled = 0
    If RainbowLights = "all" Then
        For each obj in aRGBLightsMinusSome
            SetLight obj, "white", 0
        Next
    ElseIf RainbowLights = "gi" Then
        For each obj in aGiLights
            SetLight obj, "white", 0
        Next
    End If
End Sub

Sub RainbowTimer_Timer 'rainbow led light color changing
    Dim obj
    Select Case RGBStep
        Case 0 'Green
            Green = Green + RGBFactor
            If Green > 255 then
                Green = 255
                RGBStep = 1
            End If
        Case 1 'Red
            Red = Red - RGBFactor
            If Red < 0 then
                Red = 0
                RGBStep = 2
            End If
        Case 2 'Blue
            Blue = Blue + RGBFactor
            If Blue > 255 then
                Blue = 255
                RGBStep = 3
            End If
        Case 3 'Green
            Green = Green - RGBFactor
            If Green < 0 then
                Green = 0
                RGBStep = 4
            End If
        Case 4 'Red
            Red = Red + RGBFactor
            If Red > 255 then
                Red = 255
                RGBStep = 5
            End If
        Case 5 'Blue
            Blue = Blue - RGBFactor
            If Blue < 0 then
                Blue = 0
                RGBStep = 0
            End If
    End Select
    If RainbowLights = "all" Then
        For each obj in aRGBLightsMinusSome
            obj.color = RGB(Red \ 10, Green \ 10, Blue \ 10)
            obj.colorfull = RGB(Red, Green, Blue)
        Next
    ElseIf RainbowLights = "gi" Then
        For each obj in aGiLights
            obj.color = RGB(Red \ 10, Green \ 10, Blue \ 10)
            obj.colorfull = RGB(Red, Green, Blue)
        Next
    End If
End Sub

'***********************************************************************
' *********************************************************************
' Section; Table Specific Script Starts Here
' *********************************************************************
'***********************************************************************

' droptargets, animations, etc
Sub VPObjects_Init

End Sub

' tables variables and modes init
Dim bSuperJackpot
Dim bDoubleSuperJackpot
Dim bTripleSuperJackpot
Dim bJackpot
'Dim bLoopinSupers
Dim SpinnerValue
Dim SpinnerReactorValue
Dim Multiplier2x
Dim Multiplier3x
Dim LaneBonus
Dim BallLockScore

Dim COREScore
Dim InlaneScore
Dim BumperScore
Dim OutlaneScore
Dim LowerSlingshotScore
Dim UpperSlingshotScore
Dim Jackpot
Dim DoubleJackpot
Dim TripleJackpot
Dim SuperJackpot
Dim RADSCore
Dim DESTROYScore
Dim GridTargetScore
Dim TargetScore
Const TargetBonusValue = 1000
Const LaneSaveBonusValue = 10000


Sub Game_Init() 'called at the start of a new game
    Dim i
    bExtraBallWonThisBall = False
    TurnOffPlayfieldLights()

    'Init Variables
    bSkillshotSelect = False
	SkillshotReady = 0
	DropTargetResetLockIsLit 1
	
'****************************
'SubSection; Scoring Values
'***************************
    SpinnerValue = 110
    SpinnerReactorValue = 200

	COREScore = 500
	UpperSlingshotScore = 500
	LowerSlingshotScore = 200
	GridTargetScore = 500
	TargetScore = 500
    SkillshotValue = 1000
	BallLockScore = 20000
	Jackpot = 15000
	DoubleJackpot = 30000
	TripleJackpot = 45000
	SuperJackpot = 75000

	'DropTargetScore

	BumperScore = 500
	InlaneScore = 500
	OutlaneScore = 500
	RADScore = 500
	DESTROYScore = 500	



	'Initialize Player Data
	InitializePlayerData
	
	ResetCORE
	ResetSAVE
	ResetGrid
	ResetReactor
	ResetReactorBonus
	ResetRAD
	ResetMaxTarget
	ResetMysteryAward
	ResetDESTROY
	ResetGate
	ResetBonusLights
	ResetReactorLoopInserts
	ResetBallSaveDisplay
	ResetSuperSpinner
	ResetInserts





    bMultiBallMode = False
    bBonusHeld = False
    Multiplier2x = 1
    Multiplier3x = 1

    
	'Init Delays/Timers
	If Quotemode = 1 Then PlayQuote.Enabled = 1

    'Play some Music
    StartBackgroundMusic

	'GI color
	ChangeGI GIcolor, 1
End Sub

Sub StopEndOfBallModes() 'this sub is called after the last ball is drained

    'If Modes(0)Then StopMode Modes(0) 'a mode is active so stop it
End Sub

Sub ResetNewBallVariables()           'reset variables for a new ball or player
    bSuperJackpot = False
    bDoubleSuperJackpot = False
    bTripleSuperJackpot = False
    bJackpot = False
    LaneBonus = 0
End Sub

Sub ResetNewBallLights() 'turn on or off the needed lights before a new ball is released
End Sub

Sub TurnOffPlayfieldLights()
    Dim a
    For each a in aLights
        a.State = 0
    Next
'''    Bumper1Light.Visible = 0
End Sub


'**************************
' Section; SAVE - Inlanes Outlanes
'**************************
Dim LaneSaveCount(4)
Dim PlayerLa1(4)
Dim PlayerLa2(4)
Dim PlayerLa3(4)
Dim PlayerLa4(4)
Const LaneSaveCountMax = 6
Dim bBallSaverSingleUse

Sub ResetSave() ' ClearSave on end ball or start ball
	LaneSaveCount(CurrentPlayer) = 0

	SetLight la1, "red", 0
	SetLight la2, "red", 0
	SetLight la3, "red", 0
	SetLight la4, "red", 0
	

	ttSaves.text = "S:" & LaneSaveCount(CurrentPlayer)
End Sub

Sub CheckSAVE()
	dim tmp
	tmp = 0

	if la1.state = 1 then tmp = tmp + 1
	if la2.state = 1 then tmp = tmp + 1
	if la3.state = 1 then tmp = tmp + 1
	if la4.state = 1 then tmp = tmp + 1

	If tmp = 3 then	'3 targets lit, earn a SAVE
		AwardSAVE 1
	End If

End Sub

Sub AwardSAVE (value)
	Dim SaveInsertAlreadyLit, savecolor
	SaveInsertAlreadyLit = 0

	LaneSaveCount(CurrentPlayer) = LaneSaveCount(CurrentPlayer) + value
	If LaneSaveCount(CurrentPlayer) > LaneSaveCountMax Then 
		LaneSaveCount(CurrentPlayer) = LaneSaveCountMax
	Else
		If LaneSaveCount(CurrentPlayer) = 1 Then
			DOF 170, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "LANE SAVE " & LaneSaveCount(CurrentPlayer)), eBlinkfast, 1500, True, "tna_lanesavelevelone"
			UDMD "LANE SAVE", "LEVEL 1", 1500
		Else
			DOF 170, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "LANE SAVE " & LaneSaveCount(CurrentPlayer)), eBlinkfast, 1500, True, "tna_lanesaveincreased"
			UDMD "LANE SAVE", "LEVEL " & LaneSaveCount(CurrentPlayer), 1500
		End If
		GIGame 1, "yellow"
	End If
	ttSaves.text = "S:" & LaneSaveCount(CurrentPlayer)


	'Select new Insert color
	SetSaveColor

	'Check if any Save insert already blinking and change color based on Save count (Red, Orange, Yellow,Green, Blue, Purple)
	if la1.state = 2 then 
		SaveInsertAlreadyLit = 1
	elseif la2.state = 2 then 
		SaveInsertAlreadyLit = 1
	elseif la3.state = 2 then 
		SaveInsertAlreadyLit = 1
	elseif la4.state = 2 then 
		SaveInsertAlreadyLit = 1
	end if

	'If First Save awarded, set Flashing save insert
	if SaveInsertAlreadyLit=0 Then
		if la1.state = 0 then 
			la1.state = 2
		elseif la2.state = 0 then 
			la2.state = 2
		elseif la3.state = 0 then 
			la3.state = 2
		elseif la4.state = 0 then 
			la4.state = 2
		end if
	End If

	'Reset the rest of the SAVE inserts
	if la1.state = 1 then 
		la1.state = 0
	end if
	if la2.state = 1 then 
		la2.state = 0
	end if
	if la3.state = 1 then 
		la3.state = 0
	end if
	if la4.state = 1 then
		la4.state = 0
	end if

End Sub


Sub UseSAVE (sw) ' On outlane, check for ballsave condition
	dim savecolor
	dim tmp
	tmp = ""
	if LaneSaveCount(CurrentPlayer) > 0 Then
		'Check if SAVE insert is matching the drain outlane
		if la1.state = 2 then 
			tmp = "swOutlaneL"
		elseif la4.state = 2 then 
			tmp = "swOutlaneR"
		end if 

		'debug.print "Entering usesave " & LaneSaveCount(CurrentPlayer) & " : " & sw & " ; " & tmp

		if (StrComp(sw, tmp) = 0)then 'Ball Saved!

			'debug.print "ballSavesingle!"
			bBallSaverSingleUse = 1
			LaneSaveCount(CurrentPlayer) = LaneSaveCount(CurrentPlayer) - 1

			Playsound "tna_ballsaved"
			DOF 165, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BALL SAVED"), eBlinkfast, 800, True, ""
			UDMD "BALL SAVED", "", 800
			GIGameImmediate 12, "green"


			if LaneSaveCount(CurrentPlayer) <=0 Then ' Turn off Save insert
				LaneSaveCount(CurrentPlayer) = 0
				if la1.state = 2 then 
					la1.state = 0
				elseif la2.state = 2 then 
					la2.state = 0
				elseif la3.state = 2 then 
					la3.state = 0
				elseif la4.state = 2 then 
					la4.state = 0
				end if 
			End If

			'Select new Insert color
			SetSaveColor

		End If
	End If
	ttSaves.text = "S:" & LaneSaveCount(CurrentPlayer)

    DMDScoreNow
End Sub


Sub SetSaveColor
	dim savecolor

	'Select new Insert color
	Select Case LaneSaveCount(CurrentPlayer)
		Case 0:	savecolor = "red"
		Case 1:	savecolor = "red"
		Case 2:	savecolor = "orange"
		Case 3:	savecolor = "yellow"
		Case 4:	savecolor = "green"
		Case 5:	savecolor = "blue"
		Case else:	savecolor = "purple"
	End Select

	'Set insert color
	SetLight la1, savecolor, -1
	SetLight la2, savecolor, -1
	SetLight la3, savecolor, -1
	SetLight la4, savecolor, -1
End Sub

Sub InitLaneSaveData
	Dim i
    For i = 1 To MaxPlayers
		LaneSaveCount(i) = 0
		PlayerLa1(i) = 0	
		PlayerLa2(i) = 0
		PlayerLa3(i) = 0
		PlayerLa4(i) = 0
    Next
End Sub

Sub SaveLaneSaveData
	'LaneSaveCount(i) is already saved
	PlayerLa1(CurrentPlayer) = la1.state	
	PlayerLa2(CurrentPlayer) = la2.state
	PlayerLa3(CurrentPlayer) = la3.state
	PlayerLa4(CurrentPlayer) = la4.state	
End Sub

Sub RestoreLaneSaveData
	la1.state = PlayerLa1(CurrentPlayer)
	la2.state = PlayerLa2(CurrentPlayer)
	la3.state = PlayerLa3(CurrentPlayer)
	la4.state = PlayerLa4(CurrentPlayer)

	SetSaveColor
End Sub

Sub CopyLaneSaveData (p1, p2)
	LaneSaveCount(p2) = LaneSaveCount(p1)
	PlayerLa1(p2) = PlayerLa1(p1)
	PlayerLa2(p2) = PlayerLa2(p1)
	PlayerLa3(p2) = PlayerLa3(p1)
	PlayerLa4(p2) = PlayerLa4(p1)
End Sub

'**************************
' Section; Skillshot
'**************************
Sub StartSkillShot() 'Updates the DMD & lights with the chosen skillshots
    'DMDFlush
    bSkillShotSelect = True
	HandsFreeSkillshotInsert = INT(RND * 4) +1
	
    Select Case HandsFreeSkillshotInsert
		Case 1:
			l1.state = 2
			f1.state = 2
			f2.state = 2
			f3.state = 0
			f4.state = 0
			f5.state = 0
		Case 2:
			l2.state = 2
			f1.state = 0
			f2.state = 2
			f3.state = 2
			f4.state = 0
			f5.state = 0
		Case 3:
			l3.state = 2
			f1.state = 0
			f2.state = 0
			f3.state = 2
			f4.state = 2
			f5.state = 0
		Case 4:
			l4.state = 2
			f1.state = 0
			f2.state = 0
			f3.state = 0
			f4.state = 2
			f5.state = 2
	End Select

End Sub

Sub SelectSkillshot(index)
    If index = 1 Then
        Playsound "fx_Previous"
    End If
    If index = 2 Then
        Playsound "fx_Next"
    End If

	if l1.state = 2 then 
		HandsFreeSkillshotInsert = 1
		f1.state = 0
		f2.state = 0
		f3.state = 0
		f4.state = 0
		f5.state = 0
		f1.state = 2
		f2.state = 2
	elseif l2.state = 2 then 
		HandsFreeSkillshotInsert = 2
		f1.state = 0
		f2.state = 0
		f3.state = 0
		f4.state = 0
		f5.state = 0
		f2.state = 2
		f3.state = 2
	elseif l3.state = 2 then 
		HandsFreeSkillshotInsert = 3
		f1.state = 0
		f2.state = 0
		f3.state = 0
		f4.state = 0
		f5.state = 0
		f3.state = 2
		f4.state = 2
	elseif l4.state = 2 then 
		HandsFreeSkillshotInsert = 4
		f1.state = 0
		f2.state = 0
		f3.state = 0
		f4.state = 0
		f5.state = 0
		f4.state = 2
		f5.state = 2
	end if
End Sub

Sub CheckSkillShot (index) ' reset the skillshot lights & variables
	If (index = HandsFreeSkillshotInsert) AND (ReactorState(CurrentPlayer) = 0) then
		AwardHandsFreeSkillshot
	Else 
		Select Case index
			Case 1:
				if l1.state = 2 then AwardSkillshot
			Case 2:
				if l2.state = 2 then AwardSkillshot
			Case 3:
				if l3.state = 2 then AwardSkillshot
			Case 4:
				if l4.state = 2 then AwardSkillshot
		End Select
	End if 

	if l1.state = 2 then 
		l1.state = 0 
	elseif l2.state = 2 then 
		l2.state = 0 
	elseif l3.state = 2 then 
		l3.state = 0 
	elseif l4.state = 2 then 
		l4.state = 0 
	end if

	f1.state = 0
	f2.state = 0
	f3.state = 0
	f4.state = 0
	f5.state = 0

    SkillShotReady = 0
    bSkillShotSelect = False
	HandsFreeSkillshotInsert = -1

    DMDScoreNow
End Sub



' *********************************************************************
'                        Table Object Hit Events
'
' Any target hit Sub will follow this:
' - play a sound
' - do some physical movement
' - add a score, bonus
' - check some variables/modes this trigger is a member of
' - set the "LastSwicthHit" variable in case it is needed later
' *********************************************************************

' Slingshots has been hit

Dim LStep, RStep

Sub LeftSlingShot_Slingshot
    If Tilted Then Exit Sub
    PlaySound SoundFXDOF("fxz_leftslingshot", 103, DOFPulse, DOFContactors), 0, 1, -0.05, 0.05
	PlaySound "tna_reactorslingloud"
    DOF 104, DOFPulse
    LeftSling4.Visible = 1:LeftSling1.Visible = 0
    Lemk.RotX = 26
    LStep = 0
    LeftSlingShot.TimerEnabled = True
    ' add some points
    AddScore LowerSlingshotScore

    ' add some effect to the table?
	GILeftSlingHit	

	SwitchReactorLoopInserts

    ' remember last trigger hit by the ball
    SetLastSwitchHit "LeftSlingShot"
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 1:LeftSLing4.Visible = 0:LeftSLing3.Visible = 1:Lemk.RotX = 14
        Case 2:LeftSLing3.Visible = 0:LeftSLing2.Visible = 1:Lemk.RotX = 2
        Case 3:LeftSLing2.Visible = 0:LeftSling1.Visible = 1:Lemk.RotX = -10:Gi2.State = 1:LeftSlingShot.TimerEnabled = False
    End Select
    LStep = LStep + 1
End Sub

Sub RightSlingShot_Slingshot
    If Tilted Then Exit Sub
    PlaySound SoundFXDOF("fxz_rightslingshot", 105, DOFPulse, DOFContactors), 0, 1, 0.05, 0.05
	PlaySound "tna_reactorslingloud"
	DOF 106, DOFPulse
    RightSling4.Visible = 1:RightSling1.Visible = 0
    Remk.RotX = 26
    RStep = 0
    RightSlingShot.TimerEnabled = True
    ' add some points
    AddScore LowerSlingshotScore

    ' add some effect to the table?
	GIRightSlingHit

	SwitchReactorLoopInserts

    ' remember last trigger hit by the ball
    SetLastSwitchHit "RightSlingShot"
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 1:RightSLing4.Visible = 0:RightSLing3.Visible = 1:Remk.RotX = 14:
        Case 2:RightSLing3.Visible = 0:RightSLing2.Visible = 1:Remk.RotX = 2:
        Case 3:RightSLing2.Visible = 0:RightSLing1.Visible = 1:Remk.RotX = -10:Gi1.State = 1:RightSlingShot.TimerEnabled = False
    End Select
    RStep = RStep + 1
End Sub




'******************
' Section; Spinner
'******************
Dim SpinCount, SuperSpinnerValue
Sub Spinner1_Spin()
    If Tilted Then Exit Sub
	DOF 112, DOFPulse

	If SuperSpinnerValue = 0 Then
		PlaySound "tna_spinner", 0, 1, -0.1
	Else
		PlaySound "tna_superspin", 0, 1, -0.1
		FlashForMs SpinnerFlasher, 100, 50, 0
	End If


	SpinCount = SpinCount + 1
	ttspin.text = SpinCount
	If SpinCount >= 50 Then
		SetSuperSpinner
	End If

    AddScoreSpecial2 SpinnerValue + SuperSpinnerValue, SpinnerReactorValue
	If SkillShotReady <> 0 Then CheckSkillShot 0

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSpinner
	End If

End Sub

'Decide to remove or keep
Sub Spinner2_Spin()
	if AddRightSpinner = 1 Then
		DOF 113, DOFPulse
		If Tilted Then Exit Sub

		If SuperSpinnerValue = 0 Then
			PlaySound "tna_spinner", 0, 1, -0.1
		Else
			PlaySound "tna_superspin", 0, 1, -0.1
		End If

		' increase super jackpot if light l66 is blinking
		AddScoreSpecial2 SpinnerValue + SuperSpinnerValue, SpinnerReactorValue
		If SkillShotReady <> 0 Then CheckSkillShot 0
	end if
End Sub

Sub Spinner2Enable
	If AddRightSpinner = 0 Then	
		Spinner2.visible = False
		Spinner2bracket.visible = False
	End If
End Sub


Sub SetSuperSpinner
	If SuperSpinnerValue <> 900 Then
		SuperSpinnerValue = 900
		lSpinner.state = 2
		DOF 171, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "SUPER SPINNER"), eBlinkfast, 1800, True, "tna_superspinner"
		UDMD "SUPER", "SPINNER", 1800
	End If
End Sub

Sub ResetSuperSpinner
	SpinCount = 0
	ttspin.text = SpinCount
	SuperSpinnerValue = 0
	lSpinner.state = 0	
End Sub
'*********************
' Section; Inlanes - Outlanes
'*********************
Sub swOutlaneL_Hit()
    PlaySoundAtVol "fx_sensor", ActiveBall, 1
    If Tilted Then Exit Sub
    AddScore OutlaneScore

    ' change some light
	If la1.State = 0 Then 
		la1.State = 1
		PlaySound "tna_toplane"
	End If
    SetLastSwitchHit "swOutlaneL"

	'Check if Lane Save being used
	If(bBallSaverActive = False) Then
		UseSAVE  LastSwitchHit
	Else 'animate lights if ballsave On
		GiGameImmediate 12, "purple"
	End If

	'Check if Lane Save earned
	CheckSAVE
End Sub

Sub swOutlaneR_Hit()
    PlaySoundAtVol "fx_sensor",ActiveBall, 1
    If Tilted Then Exit Sub
    AddScore OutlaneScore

    ' change some light
	If la4.State = 0 Then 
		la4.State = 1
		PlaySound "tna_toplane"
	End If    
	SetLastSwitchHit "swOutlaneR"

	'Check if Lane Save being used
	If(bBallSaverActive = False) Then
		UseSAVE  LastSwitchHit
	Else 'animate lights if ballsave On
		GiGameImmediate 12, "purple"
	End If

	'Check if Lane Save earned
	CheckSAVE
End Sub

Sub swInlaneL_Hit()
    PlaySoundAtVol "fx_sensor", ActiveBall, 1
    If Tilted Then Exit Sub
    AddScore InlaneScore

    ' change some light
	If la2.State = 0 Then 
		la2.State = 1
		PlaySound "tna_toplane"
	End If    

	StartReactorRightLoopInserts

	SetLastSwitchHit "swInlaneL"

	' do some check
	CheckSAVE
End Sub

Sub swInlaneR_Hit()
    PlaySoundAtVol "fx_sensor", ActiveBall, 1
    If Tilted Then Exit Sub
    AddScore InlaneScore

    ' change some light
	If la3.State = 0 Then 
		la3.State = 1
		PlaySound "tna_toplane"
	End If    

	StartReactorLeftLoopInserts

	SetLastSwitchHit "swInlaneR"

	' do some check
	CheckSAVE
End Sub


'*********************
' Section; Top Lanes
'*********************
Sub sw1_Hit()
	DOF 150, DOFPulse
	ResetGate
    PlaySoundAtVol "fx_sensor", ActiveBall, 1
    If Tilted Then Exit Sub

    ' change some light
    SetLastSwitchHit "sw1"
	If SkillShotReady <> 0 Then CheckSkillShot 1
	If L1.state <> 1 then playsound "tna_toplane"

	L1.state = 1

    AddScoreSpecial COREScore

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If

' do some check
	CheckCORE
End Sub

Sub sw2_Hit()
	DOF 151, DOFPulse
	ResetGate
    PlaySoundAtVol "fx_sensor", ActiveBall, 1
    If Tilted Then Exit Sub

    ' change some light
'    FlashForms l5f, 1000, 40, 0:FlashForms l5, 1000, 40, 0
    SetLastSwitchHit "sw2"
	If SkillShotReady <> 0 Then CheckSkillShot 2
	If l2.state <> 1 then playsound "tna_toplane"

	L2.state = 1

    AddScoreSpecial COREScore

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If

' do some check
	CheckCORE
End Sub

Sub sw3_Hit()
	DOF 152, DOFPulse
	ResetGate
    PlaySoundAtVol "fx_sensor", ActiveBall, 1
    If Tilted Then Exit Sub

    ' change some light
'    FlashForms l5f, 1000, 40, 0:FlashForms l5, 1000, 40, 0
    SetLastSwitchHit "sw3"
	If SkillShotReady <> 0 Then CheckSkillShot 3
	If l3.state <> 1 then playsound "tna_toplane"

	L3.state = 1

    AddScoreSpecial COREScore

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If
    ' do some check
	CheckCORE
End Sub

Sub sw4_Hit()
	DOF 153, DOFPulse
	ResetGate
    PlaySoundAtVol "fx_sensor", ActiveBall, 1
    If Tilted Then Exit Sub

    ' change some light
'    FlashForms l6f, 1000, 40, 0:FlashForms l6, 1000, 40, 0
    SetLastSwitchHit "sw4"
	If SkillShotReady <> 0 Then CheckSkillShot 4
	If l4.state <> 1 then playsound "tna_toplane"

	L4.state = 1

    AddScoreSpecial COREScore

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If

    ' do some check
	CheckCORE
End Sub


Sub LeftScoop_Hit()
	Dim MysteryAwarded

    PlaySoundAtVol "fx_kicker_enter", ActiveBall, 1
	LeftScoop.Enabled = False
'	Leftscoop.DestroyBall

    If Tilted Then
        LeftScoopExit
        Exit Sub
    End If

	MysteryAwarded = CollectMysteryAward()

	if MysteryAwarded=0 Then 
		vpmtimer.addtimer 200, "LeftScoopExit '"
	End If

    SetLastSwitchHit "LeftScoop"
End Sub

Sub LeftScoopExit
	CheckReactorStart
	
	GiGameImmediate 2, CurrCol

    PlaySoundAtVol SoundFXDOF("fx_kicker", 122, DOFPulse, DOFContactors), LeftScoop, 1
	PlaySound "tna_leftscoopeject"
    DOF 123, DOFPulse

    leftScoop.Kick 165, LeftScoopStrength, 1.56				
	LeftScoop.Enabled = True
End Sub


Sub LeftScoopAlt_Hit()
	Dim MysteryAwarded

    PlaySoundAtVol "fx_kicker_enter", ActiveBall, 1
	LeftscoopAlt.DestroyBall

    If Tilted Then
        LeftScoopExit
        Exit Sub
    End If

	MysteryAwarded = CollectMysteryAward()

	if MysteryAwarded=0 Then 
		vpmtimer.addtimer 500, "LeftScoopAltExit '"
	End If

	LeftScoopAlt.Enabled = False

    SetLastSwitchHit "LeftScoop"
End Sub

Sub LeftScoopAltExit
	CheckReactorStart
	
	GiGameImmediate 2, CurrCol

    PlaySoundAtVol SoundFXDOF("fx_kicker", 122, DOFPulse, DOFContactors), LeftScoopAlt, 1
	PlaySound "tna_leftscoopeject"
    DOF 123, DOFPulse
	LeftScoopAlt.CreateBall
    LeftScoopAlt.Kick 162.7, 34
	LeftScoopAlt.Enabled = True
End Sub


Sub RightScoop_Hit()
    Dim tmp

    PlaySoundAtVol "fx_kicker_enter", ActiveBall, 1
'	Rightscoop.DestroyBall

    If Tilted Then
		vpmtimer.addtimer 150, "RightScoopExit '"
		Exit Sub
    End If

    vpmtimer.addtimer 500, "RightScoopExit '"
	RightScoop.Enabled = False

	If bMultiBallMode = False Then	'Normal Play
		RightScoopEjected.Enabled = True
		lRScoopEjectUpdate 0
		GiGame 2, "green"
	Else	'Multiball Play
		StartDropTargetResetTimer
		AwardSuperJackpot
			
		'Multiball add
		AddMultiball 1
	End If

	AddBonusLights

    SetLastSwitchHit "RightScoop"
End Sub

Sub RightScoopExit
	'Error check:  If a target is up, need to drop them.  Figure this out in future
'	If (DropTarget1.IsDropped = 0 or DropTarget2.IsDropped = 0 or DropTarget3.IsDropped = 0 or TargetBlocker1.IsDropped = 0 or TargetBlocker2.IsDropped = 0) Then
'		DropTarget1.IsDropped = 1
'		DropTarget2.IsDropped = 1
'		DropTarget3.IsDropped = 1
'		TargetBlocker1.IsDropped = 1
'		TargetBlocker2.IsDropped = 1
'	End If
	If DropTarget1.IsDropped = 0 Then 'Warning:  Ball in scoop with targets up, need to temporarily drop Targets to eject ball 
		MultiballTargetDrop
		vpmtimer.addtimer 800, "MultiballTargetResetImmediate '"
	End If

    PlaySoundAtVol SoundFXDOF("fx_kicker", 122, DOFPulse, DOFContactors), RightScoop, 1
    DOF 123, DOFPulse
    RightScoop.Kick 190, RightScoopStrength, 1.56
	RightScoop.Enabled = True
End Sub

Sub RightScoopEjected_Hit
	DropTargetResetLockIsLit 0
	RightScoopEjected.Enabled = False
End Sub


Sub lRScoopEjectUpdate (val)
	if val = 1 Then		
		lRScoopEject.state = 2	
	Else
		lRScoopEject.state = 0	
	End If
End Sub

''*********************
' Section; Multiball Drop Targets
''*********************
' One Target up to start Normal Play.  Lock Lit
' Multiball when DropTarget 3 hit
' When Multiball started, all targets up, jackpot/super jackpot
' When Multiball ends, 1 target up and scoop needed to light lock
Dim bLockIsLit
Dim MultiballStartScore
Sub StartMultiball
	If debugMultiball Then debug.print "*****SUB:StartMultiball"

	bMultiBallMode = True
	DOF 115, DOFPulse
	MultiballTargetReset
    DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "MULTI-BALL!!!"), eBlinkfast, 1800, True, ""
	UDMD "MULTI-BALL!!", "", 1800
	StartMultiballMusic
	MultiballStartScore = Score(CurrentPlayer)

End Sub

Sub EndMultiball	'Multiball ending
	Dim mballtotal
	
	mballtotal = Score(CurrentPlayer) - MultiballStartScore
	If debugMultiball Then debug.print "*****SUB:EndMultiball"
	ChangeGI GIcolor, 1

    DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "M-BALL TOTAL"), eBlinkfast, 1800, True, ""
	DMD "", eNone, Centerline(1, ("MBALL TOTAL")), eNone, "", eNone, CenterLine(3, FormatScore(mballtotal)), eBlinkFast, 1800, True, ""
	UDMD "MBALL TOTAL", mballtotal, 1800
	
	'Restart music or critical music
	If ReactorState(CurrentPlayer) <> 3 Then 'Not Critical
		StopMultiballMusic
		StartBackgroundMusic
	Else
		StopMultiballMusic
		StartReactorCriticalMusic
	End If
		

	'If all targets down, reset to lock is lit
	If (DropTarget1.IsDropped = 1 and DropTarget2.IsDropped = 1 and DropTarget3.IsDropped = 1) Then
		DropTargetResetLockIsNotLit
	Else
		DropTargetPartialResetLockIsNotLit
	End If

End Sub

Sub DropTargetResetLockIsLit (value)	'Normal Play - Only Target 1 up - Lock is lit
	If debugMultiball Then debug.print "*****SUB:DropTargetResetLockIsLit"

	If bGameInPlay = True then
		bLockIsLit = True
		SetLight lLockIsLit1, "blue", 2
		SetLight lLockIsLit2, "blue", 2
		SetLight lLockIsLit3, "blue", 2
		If value = 0 Then
			DOF 172, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "LOCKS ARE LIT"), eBlinkfast, 1000, True, "tna_lockislit"
			UDMD "LOCKS ARE LIT", "", 1000
		ElseIf value = 1 Then
			lLockIsLit2.TimerInterval = 500
			lLockIsLit2.TimerEnabled = True
		End If
	End If
	lRScoopEjectUpdate 0


	DropTarget1.UserValue = 1
	DropTarget1.IsDropped = 0
	TargetBlocker1.IsDropped = 0 
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), DropTarget1, 1

	DropTarget2.UserValue = 0
	DropTarget2.IsDropped = 1
	TargetBlocker2.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 137, DOFPulse, DOFContactors), DropTarget2, 1

	DropTarget3.UserValue = 0
	DropTarget3.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), DropTarget3, 1
End Sub

Sub lLockIsLit2_Timer
	lLockIsLit2.TimerEnabled = False
	PlaySound "TNAWelcomeFuture":PuPEvent 1
End Sub

Sub DropTargetResetLockIsNotLit	'Normal Play - Only Target 1 up - Lock is NOT lit
	If debugMultiball Then debug.print "*****SUB:DropTargetResetLockIsNotLit"

	bLockIsLit = False
	lLockIsLit1.state = 0
	lLockIsLit2.state = 0
	lLockIsLit3.state = 0

	DropTarget1.UserValue = 1
	DropTarget1.IsDropped = 0
	TargetBlocker1.IsDropped = 1 
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), ActiveBall, 1

	DropTarget2.UserValue = 0
	DropTarget2.IsDropped = 1
	TargetBlocker2.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 137, DOFPulse, DOFContactors), ActiveBall, 1

	DropTarget3.UserValue = 0
	DropTarget3.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), ActiveBall, 1
End Sub


Sub DropTargetPartialResetLockIsNotLit	'Normal Play - Any targets left up - Lock is NOT lit
	If debugMultiball Then debug.print "*****SUB:DropTargetPartialResetLockIsNotLit"

	bLockIsLit = False
	lLockIsLit1.state = 0
	lLockIsLit2.state = 0
	lLockIsLit3.state = 0

	'at a minimum, one target up
	DropTarget1.UserValue = 1
	DropTarget1.IsDropped = 0
	TargetBlocker1.IsDropped = 1 
End Sub

Sub MultiballTargetResetImmediate	'Multiball Play - All targets up
	If debugMultiball Then debug.print "*****SUB:MultiballTargetResetImmediate"
    DropTarget1.TimerInterval = 200
	DropTarget1.TimerEnabled = True

	SetLight lLockIsLit1, "red", 2
	SetLight lLockIsLit2, "red", 2
	SetLight lLockIsLit3, "red", 2
End Sub

Sub MultiballTargetReset	'Multiball Play - All targets up
	If debugMultiball Then debug.print "*****SUB:MultiballTargetReset"
    DropTarget1.TimerInterval = 3000
	DropTarget1.TimerEnabled = True

	SetLight lLockIsLit1, "red", 2
	SetLight lLockIsLit2, "red", 2
	SetLight lLockIsLit3, "red", 2
End Sub
	
Sub MultiballTargetDrop
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), DropTarget1, 1
	DropTarget1.UserValue = 0
	DropTarget1.IsDropped = 1 
	TargetBlocker1.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 137, DOFPulse, DOFContactors), DropTarget2, 1
	DropTarget2.UserValue = 0
	DropTarget2.IsDropped = 1
	TargetBlocker2.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), DropTarget3, 1
	DropTarget3.UserValue = 0
	DropTarget3.IsDropped = 1
End Sub

Sub DropTarget1_Timer	'Multiball Play - All targets up
	If debugMultiball Then debug.print "*****SUB:DropTarget1_Timer"
	DropTarget1.TimerEnabled = False

	bLockIsLit = False

	DropTarget1.UserValue = 1
	DropTarget1.IsDropped = 0
	TargetBlocker1.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), DropTarget1, 1

	DropTarget2.UserValue = 1
	DropTarget2.IsDropped = 0
	TargetBlocker2.IsDropped = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 137, DOFPulse, DOFContactors), DropTarget2, 1

	DropTarget3.UserValue = 1
	DropTarget3.IsDropped = 0
	DropTarget3.HasHitEvent = 1
	PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), DropTarget3, 1
End Sub

Sub DropTargetOpto2_Hit	'Locks ball 1
	If debugMultiball Then debug.print "*****SUB:DropTargetOpto2_Hit"

	If bLockIsLit = True Then	'Normal Play
		If DropTarget2.UserValue = 0 And DropTarget1.UserValue = 1 Then
			If bTimedSkillShot = False Then
				DOF 173, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BALL LOCK 1"), eBlinkfast, 1800, True, "tna_balllock1"	
				UDMD "BALL 1", "LOCKED", 1800
				Addscore BallLockScore
		
			Else
				DOF 173, DOFPulse: DMD "", eNone, "", eNone, CenterLine(2, FormatScore(BallLockScore*2)), eNone, CenterLine(3, "SKILL LOCK"), eBlinkfast, 1800, True, "tna_secretskillshot2"
				UDMD "SKILL LOCK 1", BallLockScore*2, 1800
				Addscore BallLockScore*2
				bTimedSkillShot = False
			End If

			'GIMballFlash
			GIGame 3, "red"
			
			AddBonusLights
			PlaySoundAtVol SoundFXDOF("fx_resetdrop", 137, DOFPulse, DOFContactors), ActiveBall, 1
			DropTarget2.UserValue = 1
			DropTarget2.IsDropped = 0
			TargetBlocker2.IsDropped = 0

			If bGameInPlay Then vpmtimer.addtimer 2500, "CreateNewBallAfterBallLock '"
			
		End If
	End If

    SetLastSwitchHit "DropTargetOpto2"
End Sub


Sub DropTargetOpto3_Hit 'Locks ball 2
	If debugMultiball Then debug.print "*****SUB:DropTargetOpto3_Hit"

	If bLockIsLit = True Then	'Normal Play

		If DropTarget3.UserValue = 0 And DropTarget2.UserValue = 1 Then


			If bTimedSkillShot = False Then
				DOF 173, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "BALL LOCK 2"), eBlinkfast, 1800, True, "tna_balllock2"			
				UDMD "BALL 2", "LOCKED", 1800
				Addscore BallLockScore		
			Else
				DOF 173, DOFPulse: DMD "", eNone, "", eNone, CenterLine(2, FormatScore(BallLockScore*2)), eNone, CenterLine(3, "SKILL LOCK"), eBlinkfast, 1800, True, "tna_secretskillshot2"
				UDMD "SKILL LOCK 2", BallLockScore*2, 1800
				Addscore BallLockScore*2
				bTimedSkillShot = False
			End If

			'GIMballFlash
			GIGame 3, "red"

			AddBonusLights
			PlaySoundAtVol SoundFXDOF("fx_resetdrop", 138, DOFPulse, DOFContactors), ActiveBall, 1
			DropTarget3.UserValue = 1
			DropTarget3.IsDropped = 0
			If bGameInPlay Then vpmtimer.addtimer 2500, "CreateNewBallAfterBallLock '"

		End If
	End If
    SetLastSwitchHit "DropTargetOpto3"
End Sub

Sub DropTarget1_Hit
	If debugMultiball Then debug.print "*****SUB:DropTarget1_Hit"

	AddBonusLights

	If bMultiBallMode = False Then	'Normal Play
		'Addscore DropTargetScore
		If (DropTarget1.UserValue = 1) Then
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), ActiveBall, 1
			PlaySound "tna_toptarget"
			lRScoopEjectUpdate 1
		Else	'Game init reset
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), ActiveBall, 1
		End If
	Else	'Multiball Play
			DropTarget1.UserValue = 0	
			AwardTripleJackpot		
			StartDropTargetResetTimer
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), ActiveBall, 1
	End If
    SetLastSwitchHit "DropTarget1"
End Sub

Sub DropTarget2_Hit
	If debugMultiball Then debug.print "*****SUB:DropTarget2_Hit"

	AddBonusLights

	If bMultiBallMode = False Then	'Normal Play
		'Addscore DropTargetScore
		If (DropTarget2.UserValue = 1) Then
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), ActiveBall, 1
			PlaySound "tna_toptarget"
		Else	'Game init reset
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), ActiveBall, 1
		End If
	Else	'Multiball Play
			DropTarget2.UserValue = 0	
			AwardDoubleJackpot		
			StartDropTargetResetTimer
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), ActiveBall, 1
	End If
    SetLastSwitchHit "DropTarget2"
End Sub

Sub DropTarget3_Hit
	If debugMultiball Then debug.print "*****SUB:DropTarget3_Hit"

	AddBonusLights

	If bMultiBallMode = False Then	'If in Normal Play
		'Addscore DropTargetScore
		If (bLockIsLit = True) Then			'Multiball start
			SetBallsOnPlayfield 3
			bBallSaverReady = True
			bAutoPlunger = True
			EnableBallSaver BallSaverTime
			ChangeGI "green", 1
			vpmtimer.addtimer 10, "StartMultiball '"
			
			'GIMballFlash
			GIGame 4, "green"

			'Drop targets
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), ActiveBall, 1
			DropTarget1.UserValue = 0
			DropTarget1.IsDropped = 1 
			TargetBlocker1.IsDropped = 1
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 137, DOFPulse, DOFContactors), ActiveBall, 1
			DropTarget2.UserValue = 0
			DropTarget2.IsDropped = 1
			TargetBlocker2.IsDropped = 1
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), ActiveBall, 1
			DropTarget3.UserValue = 0
			DropTarget3.IsDropped = 1

		Else	'Game init reset
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), ActiveBall, 1
			PlaySound "tna_toptarget"
		End If
	Else	'Multiball Play
			DropTarget3.UserValue = 0	
			AwardJackpot
			StartDropTargetResetTimer
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 138, DOFPulse, DOFContactors), ActiveBall, 1

	End If
    SetLastSwitchHit "DropTarget3"
End Sub

Sub MultiballOptoCheck_Hit 'During Multiball, raise a drop target after x sec of no target hits
	If debugMultiball Then debug.print "*****SUB:MultiballOptoCheck_Hit"

	If bMultiBallMode = True Then
		If debugMultiball Then debug.print "Calling StartDropTargetResetTimer"
		StartDropTargetResetTimer
	End If
	If (DropTarget1.TimerEnabled = True) Then
		If debugMultiball Then debug.print "Reseting DropTarget1 3 sec timer"
		DropTarget1.TimerEnabled = True
		DropTarget1.TimerInterval = 3000
		DropTarget1.TimerEnabled = True
	End If
End Sub


Sub StartDropTargetResetTimer 'During Multiball, raise a drop target after x sec of no target hits
	If debugMultiball Then debug.print "*****SUB:StartDropTargetResetTimer"

	DropTarget3.TimerEnabled = False
	DropTarget3.TimerInterval = DropTargetResetTime*1000
	DropTarget3.TimerEnabled = True
End Sub

Sub DropTarget3_Timer		'During Multiball, raise a drop target after x sec of no target hits
	If debugMultiball Then debug.print "*****SUB:DropTarget3_Timer"

	If bMultiBallMode = False Then 'Multiball over so stop resetting target
		DropTarget3.TimerEnabled = False
	Else
		If DropTarget1.IsDropped = 1 Then
			DropTarget1.IsDropped = 0
			DropTarget1.UserValue = 1
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), DropTarget1, 1
		ElseIf DropTarget2.IsDropped = 1 Then
			DropTarget2.IsDropped = 0
			DropTarget2.UserValue = 1
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), DropTarget2, 1
		ElseIf DropTarget3.IsDropped = 1 Then
			DropTarget3.IsDropped = 0
			DropTarget3.UserValue = 1
			PlaySoundAtVol SoundFXDOF("fx_droptarget", 136, DOFPulse, DOFContactors), DropTarget3, 1
		End If
	End If
End Sub


'**** MBALL GI ****
Sub GIMballFlash

	Dim bulb

	GIOff
    For each bulb in aGIMballLIghts
        SetLight bulb, "red", 1
    Next
    For each bulb in aGIRightSling
        SetLight bulb, "red", 1
    Next
    For each bulb in aGILeftSling
        SetLight bulb, "red", 1
    Next
	
	GI26.TimerInterval = 2000: GI26.TimerEnabled = True

End Sub

Sub GI26_Timer  'multiball flash
	Dim Bulb
	
    For each bulb in aGIMballLights
        SetLight bulb, CurrCol, -1
    Next
    For each bulb in aGIRightSling
        SetLight bulb, CurrCol, -1
    Next
    For each bulb in aGILeftSling
        SetLight bulb, CurrCol, -1
    Next
	GIOn

	GI26.TimerEnabled = False
	'If bGameInPlay Then CreateNewBallAfterBallLock 'delay cause mball problems
End Sub



''*********************
'' Section; Section; Grid Targets
''*********************
Dim bGridReady

Sub GridTargetx_hit()
	PlaySound SoundFXDOF("", 109, DOFPulse, DOFTargets)
	If debugGrid Then debug.print "*****SUB:" & "GridTargetx_hit"
	Select Case ReactorState(CurrentPlayer)
		Case 0:  'Targeted
			If lx1.State = 2 then 
				SetLight lx1, "green", 1
				SetLight lx2, "blue", 2
				'lx1.state = 1
				'lx2.state = 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 184, DOFPulse
			ElseIf lx2.State = 2 then
				SetLight lx2, "green", 1
				SetLight lx3, "blue", 2
				'lx2.state = 1
				'lx3.state = 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 184, DOFPulse
			ElseIf lx3.State = 2 then
				SetLight lx3, "green", 1
				'lx3.state = 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 184, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 1:	'Ready
			Playsound "tna_targetreject"

		Case 2:	'Started
			If lx1.State = 2 then 
				SetLight lx1, "purple", 1
				SetLight lx2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 187, DOFPulse
			ElseIf lx2.State = 2 then
				SetLight lx2, "purple", 1
				SetLight lx3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 187, DOFPulse
			ElseIf lx3.State = 2 then
				SetLight lx3, "purple", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 187, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 3: 'Critical
			If lx1.State = 2 then 
				SetLight lx1, "purple", 1
				SetLight lx2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 187, DOFPulse
			ElseIf lx2.State = 2 then
				SetLight lx2, "purple", 1
				SetLight lx3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 187, DOFPulse
			ElseIf lx3.State = 2 then
				SetLight lx3, "purple", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 187, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 4: 'Destroyed
	End Select
    SetLastSwitchHit "GridTargetx"
End Sub

Sub GridTargety_hit()
	PlaySound SoundFXDOF("", 109, DOFPulse, DOFTargets)
	If debugGrid Then debug.print "*****SUB:" & "GridTargety_hit"
	Select Case ReactorState(CurrentPlayer)
		Case 0:  'Targeted
			If ly1.State = 2 then 
				SetLight ly1, "green", 1
				SetLight ly2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 185, DOFPulse
			ElseIf ly2.State = 2 then
				SetLight ly2, "green", 1
				SetLight ly3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 185, DOFPulse
			ElseIf ly3.State = 2 then
				SetLight ly3, "green", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 185, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 1:	'Ready
			Playsound "tna_targetreject"
		Case 2:	'Started
			If ly1.State = 2 then 
				SetLight ly1, "purple", 1
				SetLight ly2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 188, DOFPulse
			ElseIf ly2.State = 2 then
				SetLight ly2, "purple", 1
				SetLight ly3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 188, DOFPulse
			ElseIf ly3.State = 2 then
				SetLight ly3, "purple", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 188, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 3: 'Critical
			If ly1.State = 2 then 
				SetLight ly1, "purple", 1
				SetLight ly2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 188, DOFPulse
			ElseIf ly2.State = 2 then
				SetLight ly2, "purple", 1
				SetLight ly3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 188, DOFPulse
			ElseIf ly3.State = 2 then
				SetLight ly3, "purple", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 188, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 4: 'Destroyed

	End Select
    SetLastSwitchHit "GridTargety"
End Sub

Sub GridTargetz_hit()
	PlaySound SoundFXDOF("", 109, DOFPulse, DOFTargets)
	If debugGrid Then debug.print "*****SUB:" & "GridTargetz_hit"
	Select Case ReactorState(CurrentPlayer)
		Case 0:  'Targeted
			If lz1.State = 2 then 
				SetLight lz1, "green", 1
				SetLight lz2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 186, DOFPulse
			ElseIf lz2.State = 2 then
				SetLight lz2, "green", 1
				SetLight lz3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 186, DOFPulse
			ElseIf lz3.State = 2 then
				SetLight lz3, "green", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 186, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 1:	'Ready
			Playsound "tna_targetreject"

		Case 2:	'Started
			If lz1.State = 2 then 
				SetLight lz1, "purple", 1
				SetLight lz2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 189, DOFPulse
			ElseIf lz2.State = 2 then
				SetLight lz2, "purple", 1
				SetLight lz3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 189, DOFPulse
			ElseIf lz3.State = 2 then
				SetLight lz3, "purple", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 189, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 3: 'Critical
			If lz1.State = 2 then 
				SetLight lz1, "purple", 1
				SetLight lz2, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 189, DOFPulse
			ElseIf lz2.State = 2 then
				SetLight lz2, "purple", 1
				SetLight lz3, "blue", 2
				AddScore GridTargetScore
				AddBonusLights2
				DOF 189, DOFPulse
			ElseIf lz3.State = 2 then
				SetLight lz3, "purple", 1
				AddScore GridTargetScore
				AddBonusLights2
				DOF 189, DOFPulse
			Else
				Playsound "tna_targetreject"
			End If
			CheckGrid

		Case 4: 'Destroyed

	End Select
    SetLastSwitchHit "GridTargetz"
End Sub

Dim GridSetup
Sub ResetGrid()
	GridSetup = ReactorLevel(CurrentPlayer) + ReactorDifficulty - 1
	If debugGrid Then debug.print "*****SUB:" & "ResetGrid " & GridSetup
	bGridReady = 0

	Select Case GridSetup:

		Case 1:	'3 targets
			SetLight lx1, "green", 1
			SetLight lx2, "green", 1
			SetLight lx3, "blue", 2

			SetLight ly1, "green", 1
			SetLight ly2, "green", 1
			SetLight ly3, "blue", 2

			SetLight lz1, "green", 1
			SetLight lz2, "green", 1
			SetLight lz3, "blue", 2	
		Case 2:	'4 targets
			SetLight lx1, "green", 1
			SetLight lx2, "blue", 2
			SetLight lx3, "green", 0

			SetLight ly1, "green", 1
			SetLight ly2, "green", 1
			SetLight ly3, "blue", 2

			SetLight lz1, "green", 1
			SetLight lz2, "green", 1
			SetLight lz3, "blue", 2
		Case 3:	'5 targets
			SetLight lx1, "green", 1
			SetLight lx2, "blue", 2
			SetLight lx3, "green", 0

			SetLight ly1, "green", 1
			SetLight ly2, "blue", 2
			SetLight ly3, "green", 0

			SetLight lz1, "green", 1
			SetLight lz2, "green", 1
			SetLight lz3, "blue", 2	
		Case 4:	'6 targets
			SetLight lx1, "green", 1
			SetLight lx2, "blue", 2
			SetLight lx3, "green", 0

			SetLight ly1, "green", 1
			SetLight ly2, "blue", 2
			SetLight ly3, "green", 0

			SetLight lz1, "green", 1
			SetLight lz2, "blue", 2
			SetLight lz3, "green", 0	
		Case 5:	'7 targets
			SetLight lx1, "blue", 2
			SetLight lx2, "green", 0
			SetLight lx3, "green", 0

			SetLight ly1, "green", 1
			SetLight ly2, "blue", 2
			SetLight ly3, "green", 0

			SetLight lz1, "green", 1
			SetLight lz2, "blue", 2
			SetLight lz3, "green", 0
		Case 6:	'8 targets
			SetLight lx1, "blue", 2
			SetLight lx2, "green", 0
			SetLight lx3, "green", 0

			SetLight ly1, "blue", 2
			SetLight ly2, "green", 0
			SetLight ly3, "green", 0

			SetLight lz1, "green", 1
			SetLight lz2, "blue", 2
			SetLight lz3, "green", 0
		Case Else:
			SetLight lx1, "blue", 2
			SetLight lx2, "green", 0
			SetLight lx3, "green", 0

			SetLight ly1, "blue", 2
			SetLight ly2, "green", 0
			SetLight ly3, "green", 0

			SetLight lz1, "blue", 2
			SetLight lz2, "green", 0
			SetLight lz3, "green", 0
	End Select

End Sub

Sub StartGridJackpot()
	If debugGrid Then debug.print "*****SUB:" & "StartGridJackpot"

	'Set Grid Color
    SetLight lx1, "blue", 2
    SetLight lx2, "purple", 0
    SetLight lx3, "purple", 0
    SetLight ly1, "blue", 2
    SetLight ly2, "purple", 0
    SetLight ly3, "purple", 0
    SetLight lz1, "blue", 2
    SetLight lz2, "purple", 0
    SetLight lz3, "purple", 0
'
'	lx1.State = 2
'	lx2.State = 0
'	lx3.State = 0
'
'	ly1.State = 2
'	ly2.State = 0
'	ly3.State = 0
'
'	lz1.State = 2
'	lz2.State = 0
'	lz3.State = 0
End Sub

Dim Playerx1(4)
Dim Playerx2(4)
Dim Playerx3(4)    
Dim Playery1(4)
Dim Playery2(4)
Dim Playery3(4)
Dim Playerz1(4)
Dim Playerz2(4)
Dim Playerz3(4)

Sub InitGridData
	Dim i
    For i = 1 To MaxPlayers
		Playerx1(i) = 0	
		Playerx2(i) = 0
		Playerx3(i) = 0
		Playery1(i) = 0	
		Playery2(i) = 0
		Playery3(i) = 0
		Playerz1(i) = 0	
		Playerz2(i) = 0
		Playerz3(i) = 0
    Next
End Sub

Sub SaveGridData	
	If debugGrid Then debug.print "*****SUB:" & "SaveGridState"
	Playerx1(CurrentPlayer) = lx1.State
	Playerx2(CurrentPlayer) = lx2.State
	Playerx3(CurrentPlayer) = lx3.State
	Playery1(CurrentPlayer) = ly1.State
	Playery2(CurrentPlayer) = ly2.State
	Playery3(CurrentPlayer) = ly3.State
	Playerz1(CurrentPlayer) = lz1.State
	Playerz2(CurrentPlayer) = lz2.State
	Playerz3(CurrentPlayer) = lz3.State
End Sub

Sub RestoreGridData
	
	If ((BallsRemaining(CurrentPlayer) = BallsPerGame) And (CoopMode = 0)) Then	'If first ball for new player
		ResetGrid
	Elseif ((CurrentPlayer = 2) And (BallsRemaining(CurrentPlayer) = BallsPerGame) And (CoopMode = 2)) Then	'If first ball for 2nd player in co-op mode 2
		ResetGrid
	ElseIf ReactorState(CurrentPlayer) >= 2 Then
		SetLightGrid lx1, "purple", Playerx1(CurrentPlayer)
		SetLightGrid lx2, "purple", Playerx2(CurrentPlayer)
		SetLightGrid lx3, "purple", Playerx3(CurrentPlayer)
		SetLightGrid ly1, "purple", Playery1(CurrentPlayer)
		SetLightGrid ly2, "purple", Playery2(CurrentPlayer)
		SetLightGrid ly3, "purple", Playery3(CurrentPlayer)
		SetLightGrid lz1, "purple", Playerz1(CurrentPlayer)
		SetLightGrid lz2, "purple", Playerz2(CurrentPlayer)
		SetLightGrid lz3, "purple", Playerz3(CurrentPlayer)
	Else
		SetLightGrid lx1, "green", Playerx1(CurrentPlayer)
		SetLightGrid lx2, "green", Playerx2(CurrentPlayer)
		SetLightGrid lx3, "green", Playerx3(CurrentPlayer)
		SetLightGrid ly1, "green", Playery1(CurrentPlayer)
		SetLightGrid ly2, "green", Playery2(CurrentPlayer)
		SetLightGrid ly3, "green", Playery3(CurrentPlayer)
		SetLightGrid lz1, "green", Playerz1(CurrentPlayer)
		SetLightGrid lz2, "green", Playerz2(CurrentPlayer)
		SetLightGrid lz3, "green", Playerz3(CurrentPlayer)
	End If

End Sub

Sub CopyGridData (p1, p2)
	If debugGrid Then debug.print "*****SUB:" & "CopyGridData"
	Playerx1(p2) = Playerx1(p1)
	Playerx2(p2) = Playerx2(p1)
	Playerx3(p2) = Playerx3(p1)
	Playery1(p2) = Playery1(p1)
	Playery2(p2) = Playery2(p1)
	Playery3(p2) = Playery3(p1)
	Playerz1(p2) = Playerz1(p1)
	Playerz2(p2) = Playerz2(p1)
	Playerz3(p2) = Playerz3(p1)
End Sub

Sub SetLightGrid (obj, col, state)
	If state = 2 then
		SetLight obj, "blue", state
	Else	
		SetLight obj, col, state
	End If
End Sub

Sub TestHitTarget
	If debugGrid Then debug.print "*****SUB:" & "TestHitTarget"
	GridTargetx_hit
	GridTargetx_hit
	GridTargetx_hit
	GridTargety_hit
	GridTargety_hit
	GridTargety_hit
	GridTargetz_hit
	GridTargetz_hit
	GridTargetz_hit
'	lx1.State = 1
'    lx2.State = 1
'    lx3.State = 1
'    
'    ly1.State = 1
'    ly2.State = 1
'    ly3.State = 1
'    
'    lz1.State = 1
'    lz2.State = 1
'    lz3.State = 1
	CheckGrid
end Sub

Sub CheckGrid

	dim tmp
	tmp = 0
	

	If lx1.State = 1 then tmp = tmp + 1
	If lx2.State = 1 then tmp = tmp + 1
	If lx3.State = 1 then tmp = tmp + 1

	If ly1.State = 1 then tmp = tmp + 1
	If ly2.State = 1 then tmp = tmp + 1
	If ly3.State = 1 then tmp = tmp + 1

	If lz1.State = 1 then tmp = tmp + 1
	If lz2.State = 1 then tmp = tmp + 1
	If lz3.State = 1 then tmp = tmp + 1

	If debugGrid Then debug.print "*****SUB:CheckGrid(), Grid=" & tmp

	If tmp = 9 Then
		If ReactorState(CurrentPlayer) = 0 Then
			SetReactorReady
		ElseIf (ReactorState(CurrentPlayer) = 2) or (ReactorState(CurrentPlayer) = 3) Then
			ReactorJackpot
		End If

		AddBonusLights
	End If
End Sub

Sub ByPassGrid
	If debugGrid Then debug.print "*****SUB:ByPassGrid"
	If ReactorState(CurrentPlayer) = 0 Then
		SetReactorReady
	End If
End Sub

Sub ReactorJackpot
	If debugGrid Then debug.print "*****SUB:" & "ReactorJackpot"

    DOF 175, DOFPulse: DMD "", eNone, Centerline(1, ("REACTOR JKPOT")), eNone, "", eNone, CenterLine(3, FormatScore(.5*ReactorValue(CurrentPlayer))), eBlinkFast, 1000, True, "tna_reactorjackpot"
	UDMD "REACTOR JACKPOT", .5*ReactorValue(CurrentPlayer), 1000
	AddScore (.5*ReactorValue(CurrentPlayer))
	StartGridJackpot
End Sub

Sub ReadyGrid	'Blinking to Left Scoop
	If debugGrid Then debug.print "*****SUB:" & "ReadyGrid"
	SetLight lx1, "", 0
	SetLight lx2, "", 0
	SetLight lx3, "", 0

	SetLight ly1, "", 0
	SetLight ly2, "", 0
	SetLight ly3, "", 0

	SetLight lz1, "", 0
	SetLight lz2, "", 0
	SetLight lz3, "", 0

	SetLight lx3, "blue", 2
	SetLight ly2, "blue", 2
	SetLight lz1, "blue", 2

	bGridReady = 1
End Sub


''*********************
'' Section; Bonus Lights
''*********************

'Bonus light TEST
lbonus1.timerinterval = 500
'lbonus1.timerenabled = 1
Sub lBonus1_timer
	AddBonusLights
End Sub

Sub AddBonusLights2
	playsound "tna_target"
	AddBonusLights
End Sub
	
Sub AddBonusLights
	Dim tmp
'	Dim xmultiplier
'	xMultiplier = BallsOnPlayfield
'	If xMultiplier = 0 then xMultiplier = 1

	BonusPoints(CurrentPlayer) = BonusPoints(CurrentPlayer) + 1    '+ (1 * xMultiplier)

	tmp = BonusPoints(CurrentPlayer) mod 10
	Select Case tmp
		Case 1:
			lBonus1.State = 1
			lBonus2.State = 0
			lBonus3.State = 0
			lBonus4.State = 0
			lBonus5.State = 0
			lBonus6.State = 0
			lBonus7.State = 0
			lBonus8.State = 0
			lBonus9.State = 0
			lBonus0.State= 0
		Case 2:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 0
			lBonus4.State = 0
			lBonus5.State = 0
			lBonus6.State = 0
			lBonus7.State = 0
			lBonus8.State = 0
			lBonus9.State = 0
			lBonus0.State= 0
		Case 3:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 1
			lBonus4.State = 0
			lBonus5.State = 0
			lBonus6.State = 0
			lBonus7.State = 0
			lBonus8.State = 0
			lBonus9.State = 0
			lBonus0.State= 0
		Case 4:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 1
			lBonus4.State = 1
			lBonus5.State = 0
			lBonus6.State = 0
			lBonus7.State = 0
			lBonus8.State = 0
			lBonus9.State = 0
			lBonus0.State= 0
		Case 5:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 1
			lBonus4.State = 1
			lBonus5.State = 1
			lBonus6.State = 0
			lBonus7.State = 0
			lBonus8.State = 0
			lBonus9.State = 0
			lBonus0.State= 0
		Case 6:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 1
			lBonus4.State = 1
			lBonus5.State = 1
			lBonus6.State = 1
			lBonus7.State = 0
			lBonus8.State = 0
			lBonus9.State = 0
			lBonus0.State= 0
		Case 7:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 1
			lBonus4.State = 1
			lBonus5.State = 1
			lBonus6.State = 1
			lBonus7.State = 1
			lBonus8.State = 0
			lBonus9.State = 0
			lBonus0.State= 0
		Case 8:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 1
			lBonus4.State = 1
			lBonus5.State = 1
			lBonus6.State = 1
			lBonus7.State = 1
			lBonus8.State = 1
			lBonus9.State = 0
			lBonus0.State= 0
		Case 9:
			lBonus1.State = 1
			lBonus2.State = 1
			lBonus3.State = 1
			lBonus4.State = 1
			lBonus5.State = 1
			lBonus6.State = 1
			lBonus7.State = 1
			lBonus8.State = 1
			lBonus9.State = 1
			lBonus0.State= 0			
		Case 0:
			If BonusPoints(CurrentPlayer) > 0 Then
				lBonus1.State = 1
				lBonus2.State = 1
				lBonus3.State = 1
				lBonus4.State = 1
				lBonus5.State = 1
				lBonus6.State = 1
				lBonus7.State = 1
				lBonus8.State = 1
				lBonus9.State = 1
				lBonus0.State= 1
			End If
	End Select
	
	If BonusPoints(CurrentPlayer) > 150 Then
		lBonus50.State= 1
		lBonus40.State= 1
		lBonus30.State= 1
		lBonus20.State= 1
		lBonus10.State= 1
	ElseIf BonusPoints(CurrentPlayer) > 140 Then
		lBonus50.State= 1
		lBonus40.State= 1
		lBonus30.State= 1
		lBonus20.State= 1
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 130 Then
		lBonus50.State= 1
		lBonus40.State= 1
		lBonus30.State= 1
		lBonus20.State= 0
		lBonus10.State= 1
	ElseIf BonusPoints(CurrentPlayer) > 120 Then
		lBonus50.State= 1
		lBonus40.State= 1
		lBonus30.State= 1
		lBonus20.State= 0
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 110 Then
		lBonus50.State= 1
		lBonus40.State= 1
		lBonus30.State= 0
		lBonus20.State= 1
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 100 Then
		lBonus50.State= 1
		lBonus40.State= 1
		lBonus30.State= 0
		lBonus20.State= 0
		lBonus10.State= 1
	ElseIf BonusPoints(CurrentPlayer) > 90 Then
		lBonus50.State= 1
		lBonus40.State= 1
		lBonus30.State= 0
		lBonus20.State= 0
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 80 Then
		lBonus50.State= 1
		lBonus40.State= 0
		lBonus30.State= 1
		lBonus20.State= 0
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 70 Then
		lBonus50.State= 1
		lBonus40.State= 0
		lBonus30.State= 0
		lBonus20.State= 1
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 60 Then
		lBonus50.State= 1
		lBonus40.State= 0
		lBonus30.State= 0
		lBonus20.State= 0
		lBonus10.State= 1
	ElseIf BonusPoints(CurrentPlayer) > 50 Then
		lBonus50.State= 1
		lBonus40.State= 0
		lBonus30.State= 0
		lBonus20.State= 0
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 40 Then
		lBonus50.State= 0
		lBonus40.State= 1
		lBonus30.State= 0
		lBonus20.State= 0
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 30 Then
		lBonus50.State= 0
		lBonus40.State= 0
		lBonus30.State= 1
		lBonus20.State= 0
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 20 Then
		lBonus50.State= 0
		lBonus40.State= 0
		lBonus30.State= 0
		lBonus20.State= 1
		lBonus10.State= 0
	ElseIf BonusPoints(CurrentPlayer) > 10 Then
		lBonus50.State= 0
		lBonus40.State= 0
		lBonus30.State= 0
		lBonus20.State= 0
		lBonus10.State= 1
	Else
		lBonus50.State= 0
		lBonus40.State= 0
		lBonus30.State= 0
		lBonus20.State= 0
		lBonus10.State= 0
	End If
End Sub

Sub ResetBonusLights
	BonusPoints(CurrentPlayer) = 0
	lBonus1.State = 0
	lBonus2.State = 0
	lBonus3.State = 0
	lBonus4.State = 0
	lBonus5.State = 0
	lBonus6.State = 0
	lBonus7.State = 0
	lBonus8.State = 0
	lBonus9.State = 0
	lBonus0.State= 0
	lBonus10.State= 0
	lBonus20.State= 0
	lBonus30.State= 0
	lBonus40.State= 0
	lBonus50.State= 0
End Sub

''*********************
'' Section; Reactor
''*********************
' ReactorState overview
'Targeted  0 - targets active checkgrid, grid not complete, gates 2-way
'Ready     1 - targets not active, no check grid, grid completed, gates 1 way
'Started   2 - targets active but dont check grid, reactor percent building, gates 1 way
'Critical  3 - targets not active, no check grid, gates 2-way
'Destroyed 4 - 
Dim ReactorState(4)
Dim ReactorLevel(4)
Dim ReactorPercent(4)
Dim ReactorDestroyCount(4)
Dim ReactorValue(4)
Dim ReactorValueMax(4)
Dim LastReactorBeforeDifficultyKicksIn
Dim ReactorTNAAchieved(4)
Dim ReactorReactorTotalReward(4)

Const ReactorSpinnerPercent = 2
Const ReactorSwitchPercent = 16
Const ReactorValue1 = 25000
Const ReactorValue2 = 37500
Const ReactorValue3 = 50000 'Max = 150,000
Const ReactorValue4 = 62500
Const ReactorValue5 = 75000
Const ReactorValue6 = 87500
Const ReactorValue7 = 100000
Const ReactorValue8 = 112500
Const ReactorValue9 = 125000
Const ReactorMaxMultiplier = 3

Sub ResetReactor
	dim tmp

	ReactorState(CurrentPlayer) = 0
	SetReactorPercent -1
	SetReactorDestroyCount 0
	SetReactorInserts 0
	lStart.state = 0
	lScoopEjectUpdate
	RestoreRAD

	If ReactorDifficulty = 1 Then
		LastReactorBeforeDifficultyKicksIn = 6
	Else
		LastReactorBeforeDifficultyKicksIn = 3
	End If

	'Value of this reactor
	tmp = "ReactorValue" & ReactorLevel(CurrentPlayer)	'ReactorValue1 - 9
	ReactorValue(CurrentPlayer) = eval(tmp)
	ReactorValueMax(CurrentPlayer) = ReactorValue(CurrentPlayer) * ReactorMaxMultiplier
	tReactorValue.text = ReactorValue(CurrentPlayer)

	'Light Reactor
	Select Case ReactorLevel(CurrentPlayer)
		Case 1:
			SetLight lReactor1, "green", 2
		Case 2:
			SetLight lReactor1, "red", 1
			SetLight lReactor2, "green", 2
		Case 3:
			SetLight lReactor2, "red", 1
			SetLight lReactor3, "green", 2
		Case 4:
			SetLight lReactor3, "red", 1
			SetLight lReactor4, "green", 2
		Case 5:
			SetLight lReactor4, "red", 1
			SetLight lReactor5, "green", 2
		Case 6:
			SetLight lReactor5, "red", 1
			SetLight lReactor6, "green", 2
		Case 7
			SetLight lReactor6, "red", 1
			SetLight lReactor7, "green", 2
		Case 8:
			SetLight lReactor7, "red", 1
			SetLight lReactor8, "green", 2
		Case 9:
			SetLight lReactor8, "red", 1
			SetLight lReactor9, "green", 2
		Case 10:
			SetLight lReactor9, "red", 1
	End Select
End Sub

'Sub DisableReactor
'	If debugReactor then debug.print "*****SUB:" & "DisableReactor [ReactorState(CurrentPlayer)=0]"
'	ReactorState(CurrentPlayer) = 0
'	AddReactorPercent 0
'End Sub

Sub SetReactorReady		'Called when Grid is complete
	If debugReactor then debug.print "*****SUB:" & "SetReactorReady [ReactorState(CurrentPlayer)=1]"
	ReactorState(CurrentPlayer) = 1
	lStart.state = 2
	lScoopEjectUpdate
	ReadyGrid
    DOF 176, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "REACTOR READY"), eBlinkfast, 1800, True, "tna_reactorready"
	UDMD "REACTOR", "READY", 1800
End Sub


Sub CheckReactorStart	'Checked when left scoop hit
	If ReactorState(CurrentPlayer) = 1 Then
		ReactorState(CurrentPlayer) = 2	'Reactor Started
		lStart.state = 0
		lScoopEjectUpdate
		GIReactorStarted
		
		StartGridJackpot
		DOF 177, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "REACTOR START"), eBlinkfast, 1800, True, "tna_reactoronline"
		UDMD "REACTOR", "ONLINE", 1800
		SetReactorInserts 2

'		If MaxTargetFlag = False Then
			AddReactorPercent 0

			If ReactorLevel(CurrentPlayer) > LastReactorBeforeDifficultyKicksIn Then	'Enable Reactor Percentage drop logic and only one loop
				fRones.TimerInterval = ReactorPercentLossTime * 1000
				fRones.TimerEnabled = True
				StartReactorLeftLoopInserts
			Else 'ReactorLevel(CurrentPlayer) 1 and 2 and e
				StartReactorLoopInserts
			End If
'		Else
'			SetReactorPercent 100
'			StartMAxTarget
'		End If

	End If
	If debugReactor then debug.print "*****SUB:" & "CheckReactorStart [ReactorState(CurrentPlayer)=" & ReactorState(CurrentPlayer) & "]"
End Sub

Sub fRones_Timer
	AddReactorPercent - 1
End Sub

Sub StartReactorLoopInserts
	lLoopL.state = 2
	lLoopR.state = 2	
	lTria1.state = 2
	lTria2.state = 2
	lTria3.state = 2
	lTria4.state = 2
	lTria5.state = 2
	lTria6.state = 2
End Sub
Sub ResetReactorLoopInserts
	lLoopL.state = 0
	lLoopR.state = 0
	lTria1.state = 0
	lTria2.state = 0
	lTria3.state = 0
	lTria4.state = 0
	lTria5.state = 0
	lTria6.state = 0	
End Sub

Sub StartReactorLeftLoopInserts
	If ((ReactorLevel(CurrentPlayer) > LastReactorBeforeDifficultyKicksIn) AND (ReactorState(CurrentPlayer) = 2)) Then
		lLoopL.state = 2
		lTria1.state = 2
		lTria2.state = 2
		lTria3.state = 2

		lLoopR.state = 0
		lTria4.state = 0
		lTria5.state = 0
		lTria6.state = 0
	End If
End Sub

Sub StartReactorRightLoopInserts
	If ((ReactorLevel(CurrentPlayer) > LastReactorBeforeDifficultyKicksIn) AND (ReactorState(CurrentPlayer) = 2)) Then
			lLoopR.state = 2
			lTria4.state = 2
			lTria5.state = 2
			lTria6.state = 2

			lLoopL.state = 0
			lTria1.state = 0
			lTria2.state = 0
			lTria3.state = 0
	End If
End Sub

Sub SwitchReactorLoopInserts
	If ((ReactorLevel(CurrentPlayer) > LastReactorBeforeDifficultyKicksIn) AND (ReactorState(CurrentPlayer) = 2)) Then
		If lLoopL.State = 2 Then
			StartReactorRightLoopInserts
		ElseIf lLoopR.State = 2 Then
			StartReactorLeftLoopInserts
		End If
	End If
End Sub

Sub ClearReactorPercent
	fRtens.ImageA = "blank"
	fRones.ImageA = "blank"
	SetReactorInsertsInterval 200
End Sub

Dim drtens, drones
Sub SetReactorPercent (value)
	If debugReactor then debug.print "*****SUB:" & "SetReactorPercent " & value
	ReactorPercent(CurrentPlayer) = value
	If ReactorPercent(CurrentPlayer) > 100 Then ReactorPercent(CurrentPlayer) = 100
	
	If ReactorPercent(CurrentPlayer) = -1 Then
		ClearReactorPercent
		ReactorPercent(CurrentPlayer) = 0
		fRtens.TimerEnabled = False
		fRones.TimerEnabled = False
	ElseIf ((ReactorPercent(CurrentPlayer) = 0) and (ReactorState(CurrentPlayer) <> 2)) Then
		ClearReactorPercent
	ElseIf ReactorPercent(CurrentPlayer) < 100 Then
		drtens = Int(ReactorPercent(CurrentPlayer)/10)
		drones = Int(ReactorPercent(CurrentPlayer)-drtens*10)
'		dReactor1.SetValue (drtens + 1)
'		dReactor2.SetValue (drones + 1)
		fRtens.ImageA = Eval(drtens)
		fRones.ImageA = Eval(drones)
		SetReactorInsertsInterval (200 - (ReactorPercent(CurrentPlayer)*2))

	Else	'ReactorPercent(CurrentPlayer) = 100
		dReactor1.SetValue (0)
		dReactor2.SetValue (0)
		SetReactorInsertsInterval (10)

		startReactorLEDblink
	End If
	CheckReactorCritical
End Sub

Sub AddReactorPercent (value)
	Dim obj
	If debugReactor then debug.print "*****SUB:" & "AddReactorPercent " & value
	ReactorPercent(CurrentPlayer) = ReactorPercent(CurrentPlayer) + value
	If ReactorPercent(CurrentPlayer) > 100 Then 
		ReactorPercent(CurrentPlayer) = 100
	ElseIf ReactorPercent(CurrentPlayer) < 0 Then 
		ReactorPercent(CurrentPlayer) = 0
	End If
	
	If ReactorPercent(CurrentPlayer) < 100 Then
		drtens = Int(ReactorPercent(CurrentPlayer)/10)
		drones = Int(ReactorPercent(CurrentPlayer)-drtens*10)
'		dReactor1.SetValue (drtens + 1)
'		dReactor2.SetValue (drones + 1)
		fRtens.ImageA = Eval(drtens)
		fRones.ImageA = Eval(drones)
		SetReactorInsertsInterval (200 - (ReactorPercent(CurrentPlayer)*2))

	Else
'		dReactor1.SetValue (0)
'		dReactor2.SetValue (0)

		SetReactorInsertsInterval (10)

		startReactorLEDblink
	End If

	'Increase reactor inserts as percentage goes up
'	For each obj in aInsertsReactor
'		If ReactorPercent(CurrentPlayer) < 60 Then
'			obj.intensityscale = ReactorPercent(CurrentPlayer)/200
'		Else
'			obj.intensityscale = ReactorPercent(CurrentPlayer)/100
'		End If
'	Next

	CheckReactorCritical
End Sub

Sub startReactorLEDblink
	fRtens.ImageA = "-"
	fRones.ImageA = "---"
	fRtens.TimerInterval = 250
	fRtens.TimerEnabled = True
	fRones.TimerEnabled = False
End Sub

Sub stopReactorLEDblink
	fRtens.TimerEnabled = False
	fRtens.ImageA = "blank"
	fRones.ImageA = "blank"
End Sub

Dim fRtenscount
Sub fRtens_Timer
	fRtenscount = (fRtenscount + 1) Mod 2
	If fRtenscount = 0 Then
		fRtens.ImageA = "---"
		fRones.ImageA = "-"
	Else
		fRtens.ImageA = "-"
		fRones.ImageA = "---"	
	End If
End Sub

Sub AddReactorPercentForSpinner
	AddReactorPercent ReactorSpinnerPercent
End Sub

Sub AddReactorPercentForSwitch
	Dim value
	If ReactorLevel(CurrentPlayer) < 7 Then
		value = ReactorSwitchPercent - ((ReactorLevel(CurrentPlayer) - 1)*2)
	Else
		value = 5
	End IF
	AddReactorPercent value
End Sub

Sub CheckReactorCritical	'Called when reactor targets percent increased
	If debugReactor then debug.print "*****SUB:" & "CheckReactorCritical"
	If ReactorState(CurrentPlayer) = 2 Then
		If ReactorPercent(CurrentPlayer) >= 100 Then
            DOF 178, DOFOn: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "CRITICAL"), eBlinkfast, 1800, True, "tna_reactorcriticalvoice"
			UDMD "REACTOR", "CRITICAL", 1800

			SetReactorCritical
			GiReactorCritical
			StartReactorCriticalMusic

		End If
	End If
End Sub

Sub SetReactorCritical
	If debugReactor then debug.print "*****SUB:" & "SetReactorCritical [ReactorState(CurrentPlayer)=3]"
	Gi9.TimerEnabled = False	'stop reactor online spin timer
	SaveRAD
	ReactorState(CurrentPlayer) = 3:PuPEvent 20	'Reactor Critical
	SetReactorDestroyCount ReactorLevel(CurrentPlayer)
	SetReactorInserts 1
	ResetReactorLoopInserts
	'Light Reactor

	'Extra ball Award
	If ReactorLevel(CurrentPlayer) = ExtraBallAward1 Then 
		AwardExtraBall
	ElseIf ReactorLevel(CurrentPlayer) = ExtraBallAward2 Then 
		AwardExtraBall
	End If

	Select Case ReactorLevel(CurrentPlayer)
		Case 1:
			SetLight lReactor1, "red", 2
		Case 2:
			SetLight lReactor2, "red", 2
		Case 3:
			SetLight lReactor3, "red", 2
		Case 4:
			SetLight lReactor4, "red", 2
		Case 5:
			SetLight lReactor5, "red", 2
		Case 6:
			SetLight lReactor6, "red", 2
		Case 7
			SetLight lReactor7, "red", 2
		Case 8:
			SetLight lReactor8, "red", 2
		Case 9:
			SetLight lReactor9, "red", 2
	End Select

End Sub
	

Sub SetReactorDestroyCount (value)	'Setup the reactor critical inserts 1-9
	If debugReactor then debug.print "*****SUB:" & "SetReactorDestroyCount " & value
	dim tmp, tmp2
	ReactorDestroyCount(CurrentPlayer) = 0

	tmp2 = value
	if tmp2 > 7 then tmp2 = 7  'There are only 7 targets so blink up to 7 inserts

	do while ReactorDestroyCount(CurrentPlayer) < tmp2
		tmp = INT(RND * 7)
		If debugReactor then debug.print "Reactor Target = " & tmp

		if ReactorLevel(CurrentPlayer) < 3	AND tmp < 3 then	'Dont light the RAD targets on first 2 reactor levels 
			tmp = tmp + 3
			If debugReactor then debug.print "Reactor Target Changed = " & tmp
		end if

		If debugReactor then debug.print tmp &" : "& tmp2
		if aDTGT(tmp).state = 0 then
			'aDTGT(tmp).state = 2
			SetLight aDTGT(tmp), "white", 2
			
			if (tmp < 5) Then
				aDFTGT(tmp).state = 2
			Else
				aDFTGT(5).state = 2
			End If
			ReactorDestroyCount(CurrentPlayer) = ReactorDestroyCount(CurrentPlayer) + 1
		End If
	loop

	ReactorDestroyCount(CurrentPlayer) = value
	If debugReactor then debug.print "         " & "ReactorDestroyCount(CurrentPlayer) " & value
	''ttReactorTgt.text = "Tgts = " &ReactorDestroyCount(CurrentPlayer)
End Sub

Sub DecreaseReactorDestroyCount (obj, obj2)
	If ReactorState(CurrentPlayer) = 3 Then
		If ReactorDestroyCount(CurrentPlayer) <=7 Then

			'Special case since Bumper has 2 inserts.  Check both
			If obj.name = "lD3" Then
				If lD3.state = 2 Then
					lD3.state = 0
					ReactorDestroyCount(CurrentPlayer) = ReactorDestroyCount(CurrentPlayer) - 1
					PlaySound "tna_toptarget"
				ElseIf lD4.state = 2 Then
					lD4.state = 0
					ReactorDestroyCount(CurrentPlayer) = ReactorDestroyCount(CurrentPlayer) - 1
					PlaySound "tna_toptarget"
				End If

				'Check if bumper should be turned off
				If (ld3.state = 0) AND (ld4.state = 0) then	obj2.state = 0

			ElseIf obj.State = 2 Then
				obj.State = 0
				obj2.State = 0
				ReactorDestroyCount(CurrentPlayer) = ReactorDestroyCount(CurrentPlayer) - 1
				PlaySound "tna_toptarget"
			Else 'target not lit
				Playsound "tna_targetreject"
			End If
		Else 'Keep all inserts lit, decrease count until below 7
			ReactorDestroyCount(CurrentPlayer) = ReactorDestroyCount(CurrentPlayer) - 1
			PlaySound "tna_toptarget"
		End If
			

		If debugReactor then debug.print "*****SUB:" & "DecreaseReactorDestroyCount:(), ReactorDestroyCount(CurrentPlayer)=" & ReactorDestroyCount(CurrentPlayer)
		
		if ReactorDestroyCount(CurrentPlayer) = 0 Then
			If debugReactor then debug.print "         Reactor Destroyed!!!"

			AddScore ReactorValue(CurrentPlayer)
			AddScoreForReactor
			AddToTotalReactorReward
			AddReactorBonus ReactorValue(CurrentPlayer)
			AddBonusLights

			ReactorLevel(CurrentPlayer) = ReactorLevel(CurrentPlayer) + 1

			LightSeqCritical.StopPlay 

			If ReactorLevel(CurrentPlayer) <= ReactorLevelMax Then
				DOF 179, DOFPulse:DMD "", eNone, Centerline(1, ("DESTROYED!!!")), eNone, "", eNone, CenterLine(3, FormatScore(ReactorValue(CurrentPlayer))), eBlinkFast, 2500, True, "tna_reactordestroyed":PuPEvent 30
				UDMD " REACTOR ", "", 1000
				UDMD "DESTROYED", ReactorValue(CurrentPlayer) & " x " & BallsOnPlayfield, 1500

				EnableBallSaver 10
			Else
				DOF 180, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "CONGRATS!!!"), eBlinkfast, 5000, True, "tna_totalannihilation"
				UDMD "CONGRATS!", ReactorValue(CurrentPlayer) & " x " & BallsOnPlayfield, 5000

				StopBallSaver
				ReactorTNAAchieved(CurrentPlayer) = 1
			End If

			If ReactorTNAAchieved(CurrentPlayer) = 0 Then
				GiReactorStopped	'reator destroyed.  play gi ramdom for 2 seconds
			Else 'Congratulations Game Over Man
				StartRainbow "all"
				StartLightSeq	
			End If

			ResetReactor
			ResetGrid
			StartMAxTarget
			StopReactorCriticalMusic
			StopMultiballMusic
			StartBackgroundMusic


		End if
	Else
		Playsound "tna_targetreject"
	End If
	
End Sub

Sub SetReactorInserts (newstate)
	If debugReactor then debug.print "*****SUB:" & "SetReactorInserts " & newstate

		l5.state = newstate
		l6.state = newstate
		l7.state = newstate
		l8.state = newstate
		l9.state = newstate
		l10.state = newstate
		l11.state = newstate
End sub

Sub SetReactorInsertsInterval (inter)
	If debugReactor then debug.print "*****SUB:" & "SetReactorInsertsInterval " & inter

		l5.blinkinterval = inter
		l6.blinkinterval = inter
		l7.blinkinterval = inter
		l8.blinkinterval = inter
		l9.blinkinterval = inter
		l10.blinkinterval = inter
		l11.blinkinterval = inter
End sub

Dim ReactorBonus
Sub AddReactorBonus (value)

	ReactorBonus = ReactorBonus + value
	If debugReactor Then debug.print "ReactorBonus: " & ReactorBonus
End Sub

Sub ResetReactorBonus
	ReactorBonus = 0
End Sub
'=============================================




Dim LUStep
Sub Slingshot1_Slingshot
	If debugReactor then debug.print "*****SUB:Slingshot1_Slingshot"
    PlaySoundAtVol SoundFXDOF("fxz_leftslingshot", 117, DOFPulse, DOFContactors), ActiveBall, 1
	AddscoreSpecial UpperSlingshotScore

	LightSeqReactorInserts.Play SeqRandom, 20, 1, 0
	l8.TimerEnabled = True

	PlaySound "tna_reactorslingloud"
	GiReactorEffect 3


    LeftUpSling4.Visible = 1:LeftUpSling1.Visible = 0
    LUemk.RotX = 26
    LUStep = 0
    Slingshot1.TimerEnabled = True

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If
    SetLastSwitchHit "Slingshot1"
End Sub

Sub SlingShot1_Timer
    Select Case LUStep
        Case 1:LeftUpSLing4.Visible = 0:LeftUpSLing3.Visible = 1:LUemk.RotX = 14:
        Case 2:LeftUpSLing3.Visible = 0:LeftUpSLing2.Visible = 1:LUemk.RotX = 2:
        Case 3:LeftUpSLing2.Visible = 0:LeftUpSLing1.Visible = 1:LUemk.RotX = -10:SlingShot1.TimerEnabled = False
    End Select
    LUStep = LUStep + 1
End Sub


Dim RUStep
Sub Slingshot2_Slingshot
	If debugReactor then debug.print "*****SUB:Slingshot2_Slingshot"
    PlaySoundAtVol SoundFXDOF("fxz_rightslingshot", 118, DOFPulse, DOFContactors), ActiveBall, 1
	AddscoreSpecial UpperSlingshotScore

	LightSeqReactorInserts.Play SeqRandom, 20, 1, 0
	l8.TimerEnabled = True

	PlaySound "tna_reactorslingloud"
	GiReactorEffect 3

    RightUpSling4.Visible = 1:RightUpSling1.Visible = 0
    RUemk.RotX = 26
    RUStep = 0
    Slingshot2.TimerEnabled = True

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If
    SetLastSwitchHit "Slingshot2"
End Sub

Sub SlingShot2_Timer
    Select Case RUStep
        Case 1:RightUpSLing4.Visible = 0:RightUpSLing3.Visible = 1:RUemk.RotX = 14:
        Case 2:RightUpSLing3.Visible = 0:RightUpSLing2.Visible = 1:RUemk.RotX = 2:
        Case 3:RightUpSLing2.Visible = 0:RightUpSLing1.Visible = 1:RUemk.RotX = -10:SlingShot2.TimerEnabled = False
    End Select
    RUStep = RUStep + 1
End Sub

Dim LLStep
Sub ReactorWallSling_Slingshot
	If debugReactor then debug.print "*****SUB:ReactorWall_Hit"
    PlaySoundAtVol SoundFXDOF("fxz_leftslingshot", 117, DOFPulse, DOFContactors), ActiveBall, 1
	AddscoreSpecial UpperSlingshotScore

	LightSeqReactorInserts.Play SeqRandom, 20, 1, 0
	l8.TimerEnabled = True

	PlaySound "tna_reactorslingloud"
	GiReactorEffect 3

    LeftLeftSling4.Visible = 1:LeftLeftSling1.Visible = 0
    LLemk.RotX = 26
    LLStep = 0
    ReactorWall.TimerEnabled = True


	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If
    SetLastSwitchHit "ReactorWall"
End Sub

Sub ReactorWall_Timer
    Select Case LLStep
        Case 1:LeftLeftSling4.Visible = 0:LeftLeftSling3.Visible = 1:LLemk.RotX = 14:
        Case 2:LeftLeftSling3.Visible = 0:LeftLeftSling2.Visible = 1:LLemk.RotX = 2:
        Case 3:LeftLeftSling2.Visible = 0:LeftLeftSling1.Visible = 1:LLemk.RotX = -10:ReactorWall.TimerEnabled = False
    End Select
    LLStep = LLStep + 1
End Sub

Sub ReactorInsertsFlash
	Dim i
	For i = 0 to 5
		a
	Next
End Sub

L8.TimerInterval = 500
Sub l8_Timer
	LightSeqReactorInserts.StopPlay
	l8.TimerEnabled = False
End Sub

''*********************
'' Section; Reactor Max Targets
''*********************
Sub Target1_Hit
	PlaySound SoundFXDOF("", 114, DOFPulse, DOFTargets)
	AddScoreSpecial TargetScore

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If

	Check123MaxTarget lt1, 190

    SetLastSwitchHit "Target1"
End Sub

Sub Target2_Hit
	PlaySound SoundFXDOF("", 114, DOFPulse, DOFTargets)
	AddScoreSpecial TargetScore

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If

	Check123MaxTarget lt2, 191

    SetLastSwitchHit "Target2"
End Sub

Sub Target3_Hit
	PlaySound SoundFXDOF("", 114, DOFPulse, DOFTargets)
	AddScoreSpecial TargetScore

	If ReactorState(CurrentPlayer) = 2 Then
		AddReactorPercentForSwitch
	End If

	Check123MaxTarget lt3, 192

    SetLastSwitchHit "Target3"
End Sub

'Dim MaxTargetFlag
Sub ResetMaxTarget
	If debugReactor Then debug.print "*****SUB:ResetMaxTarget"
	SetLight lt1, "red", 0	
	SetLight lt2, "red", 0
	SetLight lt3, "red", 0
	'MaxTargetFlag = False

End Sub

Sub StartMAxTarget
	If debugReactor Then debug.print "*****SUB:StartMaxTarget"
	SetLight lt1, "red", 2
	SetLight lt2, "red", 0
	SetLight lt3, "red", 0
	'MaxTargetFlag = False
End Sub

Sub Check123MaxTarget (obj, val)
	If debugReactor Then debug.print "*****SUB:Check123MaxTarget"
		If Obj.state = 2 Then
			obj.state = 1
			playsound "tna_toptarget"
			GiReactorEffect 3
			DOF val, DOFPulse
		Else
			playsound "tna_targetreject"
		End If
	
		If (lt1.State = 1 and lt2.State = 1 and lt3.State = 1) Then

			SetReactorMaxed
			AddBonusLights
			StartMAxTarget

			'to do lightseq
			DMDFlush
			DOF 181, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "MAX REACTOR"), eBlinkfast, 1800, True, "tna_reactorvaluemaxed"
			UDMD "REACTOR VALUE", "MAXED", 1800

			FlashForMs lt1, 2000, 100, 2
			FlashForMs lt2, 2000, 100, 2
			FlashForMs lt3, 2000, 100, 2
			lt1.TimerInterval = 2000
			lt1.TimerEnabled = True
		ElseIf lt2.state = 1 Then
			lt3.state = 2
		ElseIf lt1.state = 1 Then
			lt2.state = 2
		End If
End Sub
'
Sub lt1_timer
	If debugReactor Then debug.print "*****SUB:lt1_timer"
	lt1.TimerEnabled = False
	'do something 
End Sub
''*********************
'' Section; Gate control
''*********************
' REactor Targeted mode
	' Plunge - full loop.  Lgate up on plunge.  Lgate down after a switch
	' Right Loop - full loop.  Lgate up on RLswitch.  Lgate down after a switch
	' Left Loop - into toplanes. 
'Reactor Started mode
'Both into toplanes 

'Multiball
	'both loops do full loop
'Reactor Critical 
	' Left Loop - full loop

Dim loopDirection	'1 = CW, -1 = CCW
Sub swLLoop_Hit
	LoopEnter 1
    SetLastSwitchHit "swLLoop"
End Sub

Sub swRLoop_Hit
	LoopEnter -1
    SetLastSwitchHit "swRLoop"
End Sub

Dim JustPlunged
Sub LoopEnter (value)
	LoopDirection = loopDirection + value

	If JustPlunged = True Then
		GateL.open = 1
		GateR.open = 1
		JustPlunged = False
'	ElseIf bMultiBallMode = True Then
'		GateL.open = 1
'		GateR.open = 1
	ElseIf ReactorState(CurrentPlayer) = 2	Then'Reactor Started
		If ReactorLevel(CurrentPlayer) > LastReactorBeforeDifficultyKicksIn Then
			If lLoopR.state = 2 Then	'CCW goes to reactor
				If loopDirection = -1 Then
					GateL.open = 0
					GateR.open = 0
				Else
					GateL.open = 1
					GateR.open = 1
				End If
			Else 'lLoopL.state = 2
				If loopDirection = -1 Then
					GateL.open = 1
					GateR.open = 1
				Else
					GateL.open = 0
					GateR.open = 0
				End If
			End If
		Else '< 3 both gates open
			GateR.open = 0
			GateL.open = 0
		End If
	ElseIf loopDirection = -1 Then 'ball is going CCW
		GateL.open = 1
		GateR.open = 0
	ElseIf loopDirection = 1 Then
		GateR.open = 0
	ElseIf loopDirection = 0 Then
		GateR.open = 0
		GateL.open = 0
	Else
		LoopDirection = 0
		GateR.open = 0
		GateL.open = 0		
	End If
End Sub

Sub ResetGate
	loopDirection = 0
	GateL.open = 0
	GateR.open = 0
End Sub



''*********************
'' Section; RAD target
''*********************
Sub TargetRAD1_HIt
	PlaySound SoundFXDOF("", 108, DOFPulse, DOFTargets)
	If debugDestroyRAD Then debug.print "*****SUB:TargetRAD1_HIt"
	'Addscore RADScore
	CheckRADMysteryAward lRad1, 195
	DecreaseReactorDestroyCount lRad1, fRad1
    SetLastSwitchHit "TargetRAD1"
End Sub

Sub TargetRAD2_HIt
	PlaySound SoundFXDOF("", 108, DOFPulse, DOFTargets)
	If debugDestroyRAD Then debug.print "*****SUB:TargetRAD2_HIt"
	'Addscore RADScore
	CheckRADMysteryAward lRad2, 194
	DecreaseReactorDestroyCount lRad2, fRad2
    SetLastSwitchHit "TargetRAD2"
End Sub

Sub TargetRAD3_HIt
	PlaySound SoundFXDOF("", 108, DOFPulse, DOFTargets)
	If debugDestroyRAD Then debug.print "*****SUB:TargetRAD3_HIt"
	'Addscore RADScore
	CheckRADMysteryAward lRad3, 193
	DecreaseReactorDestroyCount lRad3, fRad3
    SetLastSwitchHit "TargetRAD3"
End Sub

Sub ResetRAD
	If debugDestroyRAD Then debug.print "*****SUB:ResetRAD"

	SetLight lRAD1, "red", 0	
	SetLight lRAD2, "red", 0
	SetLight lRAD3, "red", 0
End Sub

Sub StartRad
	If debugDestroyRAD Then debug.print "*****SUB:StartRad"
	If ReactorState(CurrentPlayer) <> 3 Then
		SetLight lRAD1, "red", 0	
		SetLight lRAD2, "red", 0
		SetLight lRAD3, "red", 2
	End If
End Sub

Dim PausedRAD1
Dim PausedRAD2
Dim PausedRAD3
Sub SaveRAD
	PausedRAD1 = lRAD1.State
	PausedRAD2 = lRAD2.State
	PausedRAD3 = lRAD3.State	
	lRAD1.State = 0 
	lRAD2.State = 0 
	lRAD3.State = 0 
End Sub
	
Sub RestoreRAD
	SetLight lRAD1, "red", PausedRAD1	
	SetLight lRAD2, "red", PausedRAD2
	SetLight lRAD3, "red", PausedRAD3

	If (lRAD3.State = 0) Then
		lRAD1.State = 0 
		lRAD2.State = 0 
		lRAD3.State = 2 
	End If
End Sub

''*********************
'' Section; Mystery Award 
''*********************
Dim MysteryState(4)

Sub ResetMysteryAward
	If debugMysteryAward Then debug.print "*****SUB:ResetMysteryAward"
	MysteryState(CurrentPlayer) = 0
	lMystery.State = 0
	lScoopEjectUpdate
End Sub

Sub DecrementMysteryAward
	If debugMysteryAward Then debug.print "*****SUB:DecrementMysteryAward"
	If MysteryState(CurrentPlayer) > 0 Then
		MysteryState(CurrentPlayer) = MysteryState(CurrentPlayer) - 1
	End If
	If MysteryState(CurrentPlayer) <= 0 then
		ResetMysteryAward
	End If
End Sub

Sub SetMysteryAward
	If debugMysteryAward Then debug.print "*****SUB:SetMysteryAward"
	MysteryState(CurrentPlayer) = MysteryState(CurrentPlayer) + 1
	lMystery.State = 2
	lScoopEjectUpdate
End Sub

Sub InitMysteryAwardData
	Dim i
	For i = 1 to MaxPlayers
		MysteryState(i) = 0
	Next
End Sub

Sub SaveMysteryAwardData
	'Nothing needed as always stored in MysteryState(4)
End Sub

Sub RestoreMysteryAwardData
	If MysteryState(CurrentPlayer) > 0 then
		lMystery.State = 2
		lScoopEjectUpdate
	Else
		lMystery.State = 0
		lScoopEjectUpdate
	End If
End Sub

Sub CopyMysteryAwardData (p1, p2)	
	MysteryState(p2) = MysteryState(p1)
End Sub

'CheckMysteryAward
Sub CheckRADMysteryAward (obj, val)
	If debugMysteryAward Then debug.print "*****SUB:CheckMysteryAward"
	If ReactorState(CurrentPlayer) <> 3 Then
		If Obj.state = 2 Then
			obj.state = 1
			playsound "tna_toptarget"
			Addscore RADScore
			GiEffect 2
			DOF val, DOFPulse
		End If
	
		If (lRAD1.State = 1 and lRAD2.State = 1 and lRAD3.State = 1) Then
			StartRAD
			AddBonusLights

			'to do lightseq
			DMDFlush
			DOF 182, DOFPulse: DMD "", eNone, "", eNone, "", eNone, CenterLine(3, "MYSTERY LIT"), eBlinkfast, 1800, True, "tna_mysteryawardlit"
			UDMD "MYSTERY", "AWARD LIT", 1800

			FlashForMs lRAD1, 2000, 100, 2
			FlashForMs lRAD2, 2000, 100, 2
			FlashForMs lRAD3, 2000, 100, 2
			lRAD1.TimerInterval = 2000
			lRAD1.TimerEnabled = True
		ElseIf lRAD2.state = 1 Then
			lRAD1.state = 2
		ElseIf lRAD3.state = 1 Then
			lRAD2.state = 2
		End If
	End If
End Sub

Sub lRAD1_Timer
	If debugMysteryAward Then debug.print "*****SUB:lRAD1_Timer"
	lRAD1.TimerEnabled = False
	SetMysteryAward
End Sub

'CollectMysterAward (Video: More4k 9:28)
Dim MysteryStep, MysRandom0, MysRandom1, MysRandom2, MysRandom3
Const MaxMysteryItems = 13
Function CollectMysteryAward	
	If debugMysteryAward Then debug.print "*****SUB:CollectMysteryAward"
	
	If MysteryState(CurrentPlayer) > 0 Then
	
		DOF 183, DOFPulse: 
		PlaySound "tna_mysteryselect"
		MysteryStep = 0

		'Generate 4 random awards. avoid duplicates
		MysRandom0 = INT(RND * MaxMysteryItems)
		MysRandom1 = INT(RND * MaxMysteryItems)
		MysRandom2 = INT(RND * MaxMysteryItems)
		MysRandom3 = INT(RND * MaxMysteryItems)
		If debugMysteryAward Then debug.print MysRandom0 & "-" & MysRandom1 & "-" & MysRandom2 & "-" & MysRandom3

		If MysRandom1 = MysRandom0 Then MysRandom1 = (MysRandom1+1) Mod MaxMysteryItems

		If ((MysRandom2 = MysRandom0) or (MysRandom2 = MysRandom1))  Then MysRandom2 = (MysRandom2+1) Mod MaxMysteryItems
		If ((MysRandom2 = MysRandom0) or (MysRandom2 = MysRandom1))  Then MysRandom2 = (MysRandom2+1) Mod MaxMysteryItems

		If ((MysRandom3 = MysRandom0) or (MysRandom3 = MysRandom1) or (MysRandom3 = MysRandom2))  Then MysRandom3 = (MysRandom3+1) Mod MaxMysteryItems
		If ((MysRandom3 = MysRandom0) or (MysRandom3 = MysRandom1) or (MysRandom3 = MysRandom2))  Then MysRandom3 = (MysRandom3+1) Mod MaxMysteryItems

		If debugMysteryAward Then debug.print MysRandom0 & "-" & MysRandom1 & "-" & MysRandom2 & "-" & MysRandom3
		
		ListMysteryAward MysRandom0, displayTime, 0
		DecrementMysteryAward
		lMystery.TimerInterval = 750
		lMystery.TimerEnabled = True

		CollectMysteryAward = 1	'Return 1
	Else
		CollectMysteryAward = 0
	End If
End Function

Const DisplayTime = 500
Sub lMystery_Timer
	If debugMysteryAward Then debug.print "*****SUB:lMystery_Timer"


	MysteryStep = MysteryStep + 1
	Select Case MysteryStep
		Case 1
			ListMysteryAward MysRandom1, displayTime, 0
		Case 2
			ListMysteryAward MysRandom2, displayTime, 0
		Case 3
			ListMysteryAward MysRandom3, displayTime * 3, 1
		Case 4
			PlaySound "TNALeftScoopAwardEject"

			lMystery.TimerEnabled = False
			LeftScoop.TimerInterval = 1100
			LeftScoop.TimerEnabled = True
			'LightSeqAutoLaunch.Play SeqDownOn, 10, 1, 0
	End Select

End Sub

Dim DelayedBallSaver
Sub LeftScoop_Timer
	If DelayedBallSaver = 1 Then
		DelayedBallSaver = 0
		EnableBallSaver BallSaverTime
	End If
	LeftScoop.TimerEnabled = False
	'eject ball
	LeftScoopExit

End Sub

Sub ListMysteryAward (value, duration, giveaward)
	Select Case value
		Case 0,MaxMysteryItems
			DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+10,000")), eBlink, duration, True, ""
			UDMD "  +10000  ", "", duration
		Case 1
			DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+25,000")), eBlink, duration, True, ""
			UDMD "  +25000  ", "", duration
		Case 2
			DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+150,000")), eBlink, duration, True, ""
			UDMD "  +150000  ", "", duration
		Case 3
			If ReactorState(CurrentPlayer) = 0 Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("START REACTOR")), eBlink, duration, True, ""
				UDMD "START REACTOR", "", duration
				'Targeted  0 - targets active checkgrid, grid not complete, gates 2-way
				'Ready     1 - targets not active, no check grid, grid completed, gates 1 way
				'Started   2 - targets active but dont check grid, reactor percent building, gates 1 way
				'Critical  3 - targets not active, no check grid, gates 2-way
			ElseIf giveaward = 0 Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("WARP TO LVL 9")), eBlink, duration, True, ""
				UDMD "WARP TO", "LEVEL 9", duration
			Else
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+50,000")), eBlink, duration, True, ""
				UDMD "  +50000  ", "", duration
			End If
		Case 4
			DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("BALLSAVER")), eBlink, duration, True, ""
			UDMD "BALL SAVE", "ACTIVATED", duration
		Case 5
			If bLockIsLit = False Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("LOCKS ARE LIT")), eBlink, duration, True, ""
				UDMD "LOCKS ARE LIT", "", duration
			ElseIf giveaward = 0 Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("LIONMAN!!!")), eBlink, duration, True, ""
				UDMD "LIONMAN!!!", "", duration
			Else
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+40,000")), eBlink, duration, True, ""
				UDMD "  +40000  ", "", duration
			End If
		Case 6
			DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+1 LANESAVE")), eBlink, duration, True, ""
			UDMD "+LANE SAVE", "", duration
		Case 7
			If SuperSpinnerValue = 0 Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("SUPER SPINNER")), eBlink, duration, True, ""
				UDMD "AWARD", "SUPER SPINNER", duration
			Else
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+30,000")), eBlink, duration, True, ""
				UDMD "  +30000  ", "", duration
			End If			
		Case 8
			If BonusMultiplier(CurrentPlayer) < MaxMultiplier Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+1X BONUS")), eBlink, duration, True, ""
				UDMD "MULTIPLIER", "INCREASED", duration
			Else
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+20,000")), eBlink, duration, True, ""
				UDMD "  +20000  ", "", duration
			End If
		Case 9
			If BonusMultiplier(CurrentPlayer) < MaxMultiplier Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("4X MAX BONUS")), eBlink, duration, True, ""
			Else
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+35,000")), eBlink, duration, True, ""
				UDMD "  +35000  ", "", duration
			End If
		Case 10
			If CoopMode = 0 Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("EXTRA BALL")), eBlink, duration, True, ""
				UDMD "AWARD", "EXTRA BALL", duration
			Else
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+45,000")), eBlink, duration, True, ""
				UDMD "  +45000  ", "", duration
			End If
		Case 11
			DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("MAX REACTOR")), eBlink, duration, True, ""
			UDMD "REACTOR VALUE", "MAXED", duration
		Case 12
			If ReactorState(CurrentPlayer) = 0 Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("KEYPAD UNLOCK")), eBlink, duration, True, ""
				UDMD "KEYPAD", "UNLOCKED", duration
				'Targeted  0 - targets active checkgrid, grid not complete, gates 2-way
				'Ready     1 - targets not active, no check grid, grid completed, gates 1 way
				'Started   2 - targets active but dont check grid, reactor percent building, gates 1 way
				'Critical  3 - targets not active, no check grid, gates 2-way
			ElseIf giveaward = 0 Then
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("GAME OVER")), eBlink, duration, True, ""
				UDMD "GAME OVER", "", duration
			Else
				DMD "", eNone, "", eNone, "", eNone, CenterLine(3, ("+50,000")), eBlink, duration, True, ""
				UDMD "  +50000  ", "", duration
			End If
	End Select

	If giveaward = 1 Then
		Select Case value
			Case 0,MaxMysteryItems
				AddScore 10000
			Case 1
				AddScore 25000
			Case 2
				AddScore 150000
			Case 3
				If ReactorState(CurrentPlayer) = 0 Then
					ByPassGrid
					CheckReactorStart
				Else
					AddScore 50000
				End If
			Case 4
				DelayedBallSaver = 1
			Case 5
				If bLockIsLit = False Then
					DropTargetResetLockIsLit 0
				Else
					AddScore 40000
				End If
			Case 6
				AwardSAVE 1
			Case 7
				If SuperSpinnerValue =0 Then
					SetSuperSpinner
				Else
					AddScore 30000
				End If
			Case 8
				If BonusMultiplier(CurrentPlayer) < MaxMultiplier Then
					AddBonusMultiplier 1
				Else
					AddScore 20000
				End If
			Case 9
				If BonusMultiplier(CurrentPlayer) < MaxMultiplier Then
					SetBonusMultiplier(MaxMultiplier)
				Else
					AddScore 35000
				End If			
			Case 10
				If CoopMode = 0 Then
					AwardExtraBallNoCallout
				Else
					AddScore 45000
				End If
			Case 11
				SetReactorMaxed
			Case 12
				If ReactorState(CurrentPlayer) = 0 Then
					ByPassGrid
				Else
					AddScore 50000
				End If
		End Select
	End If

End Sub


''*********************
'' Section; DESTROY target
''*********************
Sub TargetD1_Hit
	PlaySound SoundFXDOF("", 110, DOFPulse, DOFTargets)
	If debugDestroyRAD Then debug.print "*****SUB:TargetD1_Hit"
	Addscore DESTROYScore
	DecreaseReactorDestroyCount lD1, fD1
    SetLastSwitchHit "TargetD1"
End Sub

Sub TargetD2_Hit
	PlaySound SoundFXDOF("", 111, DOFPulse, DOFTargets)
	If debugDestroyRAD Then debug.print "*****SUB:TargetD2_Hit"
	Addscore DESTROYScore
	DecreaseReactorDestroyCount lD2, fD2
    SetLastSwitchHit "TargetD2"

End Sub

Sub ResetDESTROY
	If debugDestroyRAD Then debug.print "*****SUB:ResetDESTROY"
	lD1.State = 0 
	lD2.State = 0 
	lD3.State = 0 
	lD4.State = 0 
End Sub

'********
' Section; Bumper
'********
Sub Bumper1_Hit
	If debugDestroyRAD Then debug.print "*****SUB:Bumper1_Hit"
    If Tilted Then Exit Sub
    PlaySoundAtVol SoundFXDOF("fxz_topbumper_hit", 107, DOFPulse, DOFContactors), ActiveBall, 1
	PlaySound "tna_bumperloud"
	DOF 119, DOFPulse
  '  FlashForMs lBumperFlash, 500, 50, 0:FlashForMs lBumperFlash1, 500, 50, 0
    AddScore BumperScore  
	DecreaseReactorDestroyCount lD3, lBumperflash
	LightSeqBumper.StopPlay
	LightSeqBumper.UpdateInterval = 5
    LightSeqBumper.Play SeqCircleOutOn, 5, 1

	SwitchReactorLoopInserts

    SetLastSwitchHit "Bumper1"
End Sub



''*********************
'' Section; Debug routines
''*********************


	
Sub SetBallsOnPlayfield (value)
	If value < 0 Then 
		value = 0
	End If

	BallsOnPlayfield = value
	Select Case BallsOnPlayfield
		Case 1:	'Not multiball so resume based current X multiplier
			Select Case BonusMultiplier(CurrentPlayer):
				Case 1:
					SetLight l2x, "white", 0
					SetLight l3x, "white", 0
					SetLight l4x, "white", 0

				Case 2:
					SetLight l2x, "white", 1
					SetLight l3x, "white", 0
					SetLight l4x, "white", 0

				Case 3:
					SetLight l2x, "white", 1
					SetLight l3x, "white", 1
					SetLight l4x, "white", 0

				Case 4:
					SetLight l2x, "white", 1
					SetLight l3x, "white", 1
					SetLight l4x, "white", 1

				Case Else:
					SetLight l2x, "white", 1
					SetLight l3x, "white", 1
					SetLight l4x, "white", 1
			End Select


		Case 2:
			SetLight l2x, "red", 2
			SetLight l3x, "red", 0
			SetLight l4x, "red", 0
		Case 3:
			SetLight l2x, "red", 0
			SetLight l3x, "red", 2
			SetLight l4x, "red", 0
		Case 4:
			SetLight l2x, "red", 0
			SetLight l3x, "red", 0
			SetLight l4x, "red", 2	
	End Select
	
End Sub

Sub AddBallsOnPlayfield (value)
	Dim tmp
	tmp = BallsOnPlayfield + value

	SetBallsOnPlayfield tmp
End Sub


'Section; Save Player Data
'1.  Create player array
'2. Create Save routine
'3. Create Restore routine
'4.  Add to Master Save routine
'5.  Add to Master Restore routine

Sub InitializePlayerData
	InitLaneSaveData
	InitMysteryAwardData
	InitGridData
	InitReactorData
	InitiReactorDestroyData
End Sub

Sub SavePlayerData
	SaveLaneSaveData
	SaveMysteryAwardData
	SaveGridData
	'SaveReactorData - already saved
	SaveReactorDestroyData
End Sub

Sub RestorePlayerData
	RestoreLaneSaveData
	RestoreMysteryAwardData
	RestoreGridData
	RestoreReactorData
	RestoreReactorDestroyData
End Sub

Sub CopyPlayerData (p1, p2)
	CopyLaneSaveData p1, p2
	CopyMysteryAwardData p1, p2
	CopyGridData p1, p2
	CopyReactorData p1, p2
	CopyReactorDestroyData p1, p2
End Sub


Sub InitReactorData
	Dim i
    For i = 1 To MaxPlayers
		ReactorState(i) = 0
		ReactorLevel(i) = 1	
		ReactorTNAAchieved(i) = 0
		ReactorReactorTotalReward(i) = 0
		ReactorPercent(i) = -1
		ReactorDestroyCount(i) = 0
		ReactorValue(i) = ReactorValue1
		ReactorValueMax(i) = ReactorValue1 * ReactorMaxMultiplier
		ResetReactorLoopInserts
    Next
End Sub

'Sub SaveReactorData
'	Line 5071: Dim ReactorState(4)
'	Line 5072: Dim ReactorLevel(4)
'			   Dim ReactorTNAAchieved(4)
'			   Dim ReactorReactorTotalReward(4)
'	Line 5073: Dim ReactorPercent(4)
'	Line 5074: Dim ReactorDestroyCount(4)
'	Line 5075: Dim ReactorValue(4)
'	Line 5076: Dim ReactorValueMax(4)
'End Sub

Sub CopyReactorData (p1, p2)
	ReactorState(p2) = ReactorState(p1)
	ReactorLevel(p2) = ReactorLevel(p1)
	ReactorTNAAchieved(p2) = ReactorTNAAchieved(p1)
	ReactorReactorTotalReward(p2) = ReactorReactorTotalReward(p1)
	ReactorPercent(p2) = ReactorPercent(p1)
	ReactorDestroyCount(p2) = ReactorDestroyCount(p1)
	ReactorValue(p2) = ReactorValue(p1)
	ReactorValueMax(p2) = ReactorValueMax(p1)
End Sub

Sub RestoreReactorData
	Dim tmpcolor
	Dim i
	
	'Set all inserts off, light destroyed reactor green, then current reactor blinking red or green
	If ReactorState(CurrentPlayer) = 3 Then 'Critical
		tmpcolor = "red"
	Else
		tmpcolor = "green"
	End If
	For i = 0 to 8
		SetLight aReactorLevelInserts(i), "red", 0
	Next
	For i = 0 to (ReactorLevel(CurrentPlayer) - 2)
		If i >=0 Then SetLight aReactorLevelInserts(i), "red", 1
	Next
	i = ReactorLevel(CurrentPlayer) - 1
	If i >=0 AND i < 9 Then 
		SetLight aReactorLevelInserts(i), tmpcolor, 2
	End If
	
	'Set table to default state
	ResetReactorLoopInserts
	lStart.State = 0
	lScoopEjectUpdate
	SetReactorInserts 0	
	SetReactorPercent ReactorPercent(CurrentPlayer)
	fRones.TimerEnabled = False
	GIReactorStoppedImmediate	
	StopReactorCriticalMusic

	'Set up active items
	Select Case ReactorState(CurrentPlayer)
		Case 0: 'Targeted

		Case 1: 'Ready
			SetReactorReady
			
		Case 2:	'Started
			SetReactorInserts 2
			GIReactorStarted
			
			If ReactorLevel(CurrentPlayer) > LastReactorBeforeDifficultyKicksIn Then	'Enable Reactor Percentage drop logic and only one loop
				fRones.TimerInterval = ReactorPercentLossTime * 1000
				fRones.TimerEnabled = True
				StartReactorRightLoopInserts
			Else 'ReactorLevel(CurrentPlayer) 1 and 2 and 3
				StartReactorLoopInserts
			End If
						
		Case 3:	'Critical
			SetReactorInserts 1
			GiReactorCritical
'			ChangeGiImmediate "red", 1
'			GIGameImmediate 5, "red"
			StartReactorCriticalMusic

			'Need to restore Destroy targets count and inserts

	End Select		
End Sub


Dim PlayeraDTGT1(4)
Dim PlayeraDTGT2(4)
Dim PlayeraDTGT3(4)
Dim PlayeraDTGT4(4)
Dim PlayeraDTGT5(4)
Dim PlayeraDTGT6(4)
Dim PlayeraDTGT7(4)

Sub InitiReactorDestroyData
	Dim i
    For i = 1 To MaxPlayers
		PlayeraDTGT1(i) = 0	
		PlayeraDTGT2(i) = 0
		PlayeraDTGT3(i) = 0
		PlayeraDTGT4(i) = 0	
		PlayeraDTGT5(i) = 0
		PlayeraDTGT6(i) = 0
		PlayeraDTGT7(i) = 0	
    Next
End Sub

Sub SaveReactorDestroyData
	If ReactorState(CurrentPlayer) = 3 Then
		PlayeraDTGT1(CurrentPlayer) = lRAD1.State
		PlayeraDTGT2(CurrentPlayer) = lRAD2.State
		PlayeraDTGT3(CurrentPlayer) = lRAD3.State
		PlayeraDTGT4(CurrentPlayer) = lD1.State
		PlayeraDTGT5(CurrentPlayer) = lD2.State
		PlayeraDTGT6(CurrentPlayer) = lD3.State
		PlayeraDTGT7(CurrentPlayer) = lD4.State
	Else
		PlayeraDTGT1(CurrentPlayer) = 0
		PlayeraDTGT2(CurrentPlayer) = 0
		PlayeraDTGT3(CurrentPlayer) = 0
		PlayeraDTGT4(CurrentPlayer) = 0
		PlayeraDTGT5(CurrentPlayer) = 0
		PlayeraDTGT6(CurrentPlayer) = 0
		PlayeraDTGT7(CurrentPlayer) = 0
	End If
End Sub

Sub RestoreReactorDestroyData

	SetLight aDTGT(0), "white", PlayeraDTGT1(CurrentPlayer)
	SetLight aDTGT(1), "white", PlayeraDTGT2(CurrentPlayer)
	SetLight aDTGT(2), "white", PlayeraDTGT3(CurrentPlayer)
	SetLight aDTGT(3), "white", PlayeraDTGT4(CurrentPlayer)
	SetLight aDTGT(4), "white", PlayeraDTGT5(CurrentPlayer)
	SetLight aDTGT(5), "white", PlayeraDTGT6(CurrentPlayer)
	SetLight aDTGT(6), "white", PlayeraDTGT7(CurrentPlayer)


	SetLight aDFTGT(0), "white", PlayeraDTGT1(CurrentPlayer)
	SetLight aDFTGT(1), "white", PlayeraDTGT2(CurrentPlayer)
	SetLight aDFTGT(2), "white", PlayeraDTGT3(CurrentPlayer)
	SetLight aDFTGT(3), "white", PlayeraDTGT4(CurrentPlayer)
	SetLight aDFTGT(4), "white", PlayeraDTGT5(CurrentPlayer)
	If PlayeraDTGT6(CurrentPlayer) = 2 Then	
		SetLight aDFTGT(5), "white", PlayeraDTGT6(CurrentPlayer)	'bumper shared with dtgt6 and 7
	Else				
		SetLight aDFTGT(5), "white", PlayeraDTGT7(CurrentPlayer)	'bumper shared with dtgt6 and 7
	End If
End Sub

Sub CopyReactorDestroyData (p1, p2)
	PlayeraDTGT1(p2) = PlayeraDTGT1(p1) 
	PlayeraDTGT2(p2) = PlayeraDTGT2(p1) 
	PlayeraDTGT3(p2) = PlayeraDTGT3(p1) 
	PlayeraDTGT4(p2) = PlayeraDTGT4(p1) 
	PlayeraDTGT5(p2) = PlayeraDTGT5(p1) 
	PlayeraDTGT6(p2) = PlayeraDTGT6(p1) 
	PlayeraDTGT7(p2) = PlayeraDTGT7(p1) 
	
End Sub


'==================================
'******************************************************
'		FLIPPER CORRECTION SUPPORTING FUNCTIONS
'******************************************************

Sub AddPt(aStr, idx, aX, aY)	'debugger wrapper for adjusting flipper script in-game
	dim a : a = Array(LF, RF)
	dim x : for each x in a
		x.addpoint aStr, idx, aX, aY
	Next
End Sub

'Methods:
'.TimeDelay - Delay before trigger shuts off automatically. Default = 80 (ms)
'.AddPoint - "Polarity", "Velocity", "Ycoef" coordinate points. Use one of these 3 strings, keep coordinates sequential. x = %position on the flipper, y = output
'.Object - set to flipper reference. Optional.
'.StartPoint - set start point coord. Unnecessary, if .object is used.

'Called with flipper - 
'ProcessBalls - catches ball data. 
' - OR - 
'.Fire - fires flipper.rotatetoend automatically + processballs. Requires .Object to be set to the flipper.

Class FlipperPolarity
	Public DebugOn, Enabled
	Private FlipAt	'Timer variable (IE 'flip at 723,530ms...)
	Public TimeDelay	'delay before trigger turns off and polarity is disabled TODO set time!
	private Flipper, FlipperStart, FlipperEnd, LR, PartialFlipCoef
	Private Balls(20), balldata(20)
	
	dim PolarityIn, PolarityOut
	dim VelocityIn, VelocityOut
	dim YcoefIn, YcoefOut
	Public Sub Class_Initialize 
		redim PolarityIn(0) : redim PolarityOut(0) : redim VelocityIn(0) : redim VelocityOut(0) : redim YcoefIn(0) : redim YcoefOut(0)
		Enabled = True : TimeDelay = 50 : LR = 1:  dim x : for x = 0 to uBound(balls) : balls(x) = Empty : set Balldata(x) = new SpoofBall : next 
	End Sub
	
	Public Property let Object(aInput) : Set Flipper = aInput : StartPoint = Flipper.x : End Property
	Public Property Let StartPoint(aInput) : if IsObject(aInput) then FlipperStart = aInput.x else FlipperStart = aInput : end if : End Property
	Public Property Get StartPoint : StartPoint = FlipperStart : End Property
	Public Property Let EndPoint(aInput) : if IsObject(aInput) then FlipperEnd = aInput.x else FlipperEnd = aInput : end if : End Property
	Public Property Get EndPoint : EndPoint = FlipperEnd : End Property
	
	Public Sub AddPoint(aChooseArray, aIDX, aX, aY) 'Index #, X position, (in) y Position (out) 
		Select Case aChooseArray
			case "Polarity" : ShuffleArrays PolarityIn, PolarityOut, 1 : PolarityIn(aIDX) = aX : PolarityOut(aIDX) = aY : ShuffleArrays PolarityIn, PolarityOut, 0
			Case "Velocity" : ShuffleArrays VelocityIn, VelocityOut, 1 :VelocityIn(aIDX) = aX : VelocityOut(aIDX) = aY : ShuffleArrays VelocityIn, VelocityOut, 0
			Case "Ycoef" : ShuffleArrays YcoefIn, YcoefOut, 1 :YcoefIn(aIDX) = aX : YcoefOut(aIDX) = aY : ShuffleArrays YcoefIn, YcoefOut, 0
		End Select
		if gametime > 100 then Report aChooseArray
	End Sub 

	Public Sub Report(aChooseArray) 	'debug, reports all coords in tbPL.text
		if not DebugOn then exit sub
		dim a1, a2 : Select Case aChooseArray
			case "Polarity" : a1 = PolarityIn : a2 = PolarityOut
			Case "Velocity" : a1 = VelocityIn : a2 = VelocityOut
			Case "Ycoef" : a1 = YcoefIn : a2 = YcoefOut 
			case else :tbpl.text = "wrong string" : exit sub
		End Select
		dim str, x : for x = 0 to uBound(a1) : str = str & aChooseArray & " x: " & round(a1(x),4) & ", " & round(a2(x),4) & vbnewline : next
		tbpl.text = str
	End Sub
	
	Public Sub AddBall(aBall) : dim x : for x = 0 to uBound(balls) : if IsEmpty(balls(x)) then set balls(x) = aBall : exit sub :end if : Next  : End Sub

	Private Sub RemoveBall(aBall)
		dim x : for x = 0 to uBound(balls)
			if TypeName(balls(x) ) = "IBall" then 
				if aBall.ID = Balls(x).ID Then
					balls(x) = Empty
					Balldata(x).Reset
				End If
			End If
		Next
	End Sub
	
	Public Sub Fire() 
		Flipper.RotateToEnd
		processballs
	End Sub

	Public Property Get Pos 'returns % position a ball. For debug stuff.
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				pos = pSlope(Balls(x).x, FlipperStart, 0, FlipperEnd, 1)
			End If
		Next		
	End Property

	Public Sub ProcessBalls() 'save data of balls in flipper range
		FlipAt = GameTime
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				balldata(x).Data = balls(x)
				if DebugOn then StickL.visible = True : StickL.x = balldata(x).x		'debug TODO
			End If
		Next
		PartialFlipCoef = ((Flipper.StartAngle - Flipper.CurrentAngle) / (Flipper.StartAngle - Flipper.EndAngle))
		PartialFlipCoef = abs(PartialFlipCoef-1)
		if abs(Flipper.currentAngle - Flipper.EndAngle) < 30 Then
			PartialFlipCoef = 0
		End If
	End Sub
	Private Function FlipperOn() : if gameTime < FlipAt+TimeDelay then FlipperOn = True : End If : End Function	'Timer shutoff for polaritycorrect
	
	Public Sub PolarityCorrect(aBall)
		if FlipperOn() then 
			dim tmp, BallPos, x, IDX, Ycoef : Ycoef = 1
			dim teststr : teststr = "Cutoff"
			tmp = PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1)
			if tmp < 0.1 then 'if real ball position is behind flipper, exit Sub to prevent stucks	'Disabled 1.03, I think it's the Mesh that's causing stucks, not this
				if DebugOn then TestStr = "real pos < 0.1 ( " & round(tmp,2) & ")" : tbpl.text = Teststr 
				'RemoveBall aBall
				'Exit Sub
			end if

			'y safety Exit
			if aBall.VelY > -8 then 'ball going down
				if DebugOn then teststr = "y velocity: " & round(aBall.vely, 3) & "exit sub" : tbpl.text = teststr
				RemoveBall aBall
				exit Sub
			end if
			'Find balldata. BallPos = % on Flipper
			for x = 0 to uBound(Balls)
				if aBall.id = BallData(x).id AND not isempty(BallData(x).id) then 
					idx = x
					BallPos = PSlope(BallData(x).x, FlipperStart, 0, FlipperEnd, 1)
					'TB.TEXT = balldata(x).id & " " & BALLDATA(X).X & VBNEWLINE & FLIPPERSTART & " " & FLIPPEREND
					if ballpos > 0.65 then  Ycoef = LinearEnvelope(BallData(x).Y, YcoefIn, YcoefOut)				'find safety coefficient 'ycoef' data
				end if
			Next

			'Velocity correction
			if not IsEmpty(VelocityIn(0) ) then
				Dim VelCoef
				if DebugOn then set tmp = new spoofball : tmp.data = aBall : End If
				if IsEmpty(BallData(idx).id) and aBall.VelY < -12 then 'if tip hit with no collected data, do vel correction anyway
					if PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1) > 1.1 then 'adjust plz
						VelCoef = LinearEnvelope(5, VelocityIn, VelocityOut)
						if partialflipcoef < 1 then VelCoef = PSlope(partialflipcoef, 0, 1, 1, VelCoef)
						if Enabled then aBall.Velx = aBall.Velx*VelCoef'VelCoef
						if Enabled then aBall.Vely = aBall.Vely*VelCoef'VelCoef
						if DebugOn then teststr = "tip protection" & vbnewline & "velcoef: " & round(velcoef,3) & vbnewline & round(PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1),3) & vbnewline
						'debug.print teststr
					end if
				Else
		 : 			VelCoef = LinearEnvelope(BallPos, VelocityIn, VelocityOut)
					if Enabled then aBall.Velx = aBall.Velx*VelCoef
					if Enabled then aBall.Vely = aBall.Vely*VelCoef
				end if
			End If

			'Polarity Correction (optional now)
			if not IsEmpty(PolarityIn(0) ) then
				If StartPoint > EndPoint then LR = -1	'Reverse polarity if left flipper
				dim AddX : AddX = LinearEnvelope(BallPos, PolarityIn, PolarityOut) * LR
				if Enabled then aBall.VelX = aBall.VelX + 1 * (AddX*ycoef*PartialFlipcoef)
			End If
			'debug
			if DebugOn then
				TestStr = teststr & "%pos:" & round(BallPos,2)
				if IsEmpty(PolarityOut(0) ) then 
					teststr = teststr & vbnewline & "(Polarity Disabled)" & vbnewline
				else 
					teststr = teststr & "+" & round(1 *(AddX*ycoef*PartialFlipcoef),3)
					if BallPos >= PolarityOut(uBound(PolarityOut) ) then teststr = teststr & "(MAX)" & vbnewline else teststr = teststr & vbnewline end if	
					if Ycoef < 1 then teststr = teststr &  "ycoef: " & ycoef & vbnewline
					if PartialFlipcoef < 1 then teststr = teststr & "PartialFlipcoef: " & round(PartialFlipcoef,4) & vbnewline				
				end if

				teststr = teststr & vbnewline & "Vel: " & round(BallSpeed(tmp),2) & " -> " & round(ballspeed(aBall),2) & vbnewline
				teststr = teststr & "%" & round(ballspeed(aBall) / BallSpeed(tmp),2)
				tbpl.text = TestSTR
			end if
		Else
			'if DebugOn then tbpl.text = "td" & timedelay
		End If
		RemoveBall aBall
	End Sub
End Class

'================================
'Helper Functions


Sub ShuffleArray(ByRef aArray, byVal offset) 'shuffle 1d array
	dim x, aCount : aCount = 0
	redim a(uBound(aArray) )
	for x = 0 to uBound(aArray)	'Shuffle objects in a temp array
		if not IsEmpty(aArray(x) ) Then
			if IsObject(aArray(x)) then 
				Set a(aCount) = aArray(x)
			Else
				a(aCount) = aArray(x)
			End If
			aCount = aCount + 1
		End If
	Next
	if offset < 0 then offset = 0
	redim aArray(aCount-1+offset)	'Resize original array
	for x = 0 to aCount-1		'set objects back into original array
		if IsObject(a(x)) then 
			Set aArray(x) = a(x)
		Else
			aArray(x) = a(x)
		End If
	Next
End Sub

Sub ShuffleArrays(aArray1, aArray2, offset)
	ShuffleArray aArray1, offset
	ShuffleArray aArray2, offset
End Sub


Function BallSpeed(ball) 'Calculates the ball speed
	BallSpeed = SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY + ball.VelZ * ball.VelZ)
End Function

Function PSlope(Input, X1, Y1, X2, Y2)	'Set up line via two points, no clamping. Input X, output Y
	dim x, y, b, m : x = input : m = (Y2 - Y1) / (X2 - X1) : b = Y2 - m*X2
	Y = M*x+b
	PSlope = Y
End Function

Function NullFunctionZ(aEnabled):End Function	'1 argument null function placeholder	 TODO move me or replac eme

Class spoofball 
	Public X, Y, Z, VelX, VelY, VelZ, ID, Mass, Radius 
	Public Property Let Data(aBall)
		With aBall
			x = .x : y = .y : z = .z : velx = .velx : vely = .vely : velz = .velz
			id = .ID : mass = .mass : radius = .radius
		end with
	End Property
	Public Sub Reset()
		x = Empty : y = Empty : z = Empty  : velx = Empty : vely = Empty : velz = Empty 
		id = Empty : mass = Empty : radius = Empty
	End Sub
End Class


Function LinearEnvelope(xInput, xKeyFrame, yLvl)
	dim y 'Y output
	dim L 'Line
	dim ii : for ii = 1 to uBound(xKeyFrame)	'find active line
		if xInput <= xKeyFrame(ii) then L = ii : exit for : end if
	Next
	if xInput > xKeyFrame(uBound(xKeyFrame) ) then L = uBound(xKeyFrame)	'catch line overrun
	Y = pSlope(xInput, xKeyFrame(L-1), yLvl(L-1), xKeyFrame(L), yLvl(L) )

	'Clamp if on the boundry lines
	'if L=1 and Y < yLvl(LBound(yLvl) ) then Y = yLvl(lBound(yLvl) )
	'if L=uBound(xKeyFrame) and Y > yLvl(uBound(yLvl) ) then Y = yLvl(uBound(yLvl) )
	'clamp 2.0
	if xInput <= xKeyFrame(lBound(xKeyFrame) ) then Y = yLvl(lBound(xKeyFrame) ) 	'Clamp lower
	if xInput >= xKeyFrame(uBound(xKeyFrame) ) then Y = yLvl(uBound(xKeyFrame) )	'Clamp upper

	LinearEnvelope = Y
End Function



dim LF : Set LF = New FlipperPolarity
dim RF : Set RF = New FlipperPolarity

InitPolarity

Sub InitPolarity()
	dim x, a : a = Array(LF, RF)
	for each x in a
		'safety coefficient (diminishes polarity correction only)
		x.AddPoint "Ycoef", 0, RightFlipper.Y-65, 1	'disabled
		x.AddPoint "Ycoef", 1, RightFlipper.Y-11, 1

		x.enabled = True
		x.TimeDelay = 44
	Next

	'"Polarity" Profile
	AddPt "Polarity", 0, 0, 0
	AddPt "Polarity", 1, 0.368, -4
	AddPt "Polarity", 2, 0.451, -3.7
	AddPt "Polarity", 3, 0.493, -3.88
	AddPt "Polarity", 4, 0.65, -2.3
	AddPt "Polarity", 5, 0.71, -2
	AddPt "Polarity", 6, 0.785,-1.8
	AddPt "Polarity", 7, 1.18, -1
	AddPt "Polarity", 8, 1.2, 0


	'"Velocity" Profile
	addpt "Velocity", 0, 0, 	1
	addpt "Velocity", 1, 0.16, 1.06
	addpt "Velocity", 2, 0.41, 	1.05
	addpt "Velocity", 3, 0.53, 	1'0.982
	addpt "Velocity", 4, 0.702, 0.968
	addpt "Velocity", 5, 0.95,  0.968
	addpt "Velocity", 6, 1.03, 	0.945

	LF.Object = LeftFlipper	
	LF.EndPoint = EndPointLp	'you can use just a coordinate, or an object with a .x property. Using a couple of simple primitive objects
	RF.Object = RightFlipper
	RF.EndPoint = EndPointRp
End Sub

'Trigger Hit - .AddBall activeball
'Trigger UnHit - .PolarityCorrect activeball

Sub TriggerLF_Hit() :   If FlipperPhysicsMode = 2 Then LF.Addball activeball End If: End Sub
Sub TriggerLF_UnHit() : If FlipperPhysicsMode = 2 Then LF.PolarityCorrect activeball End If: End Sub
Sub TriggerRF_Hit() :   If FlipperPhysicsMode = 2 Then RF.Addball activeball End If: End Sub
Sub TriggerRF_UnHit() : If FlipperPhysicsMode = 2 Then RF.PolarityCorrect activeball End If: End Sub


Sub lScoopEjectUpdate
	if ((lmystery.state = 2) Or (lStart.state = 2)) Then		
		lScoopEject.state = 2	
	Else
		lScoopEject.state = 0	
	End If
End Sub


Dim ChooseBats

' *** 0=default flipper, 1=primitive flipper, 2=glow green, 3=glow blue, 4=glow orange ****
ChooseBats = 1


Sub UDMD (toptext, bottomtext, utime)
	If UseUltraDMD > 0 Then UltraDMD.DisplayScene00Ex "", toptext, 8, 14, bottomtext, 8,14, 14, utime, 14
	If utime > 100 Then udmdHoldOffUntil = Timer + (utime / 1000)
End Sub


'************ future update maybe
'ball trapped in RightScoop 
'5 second delay when Reactor Starting (scoop shot)
'Match not implemented
'drain on scoop eject will do a ballsave
'co-op mode
'bugs
'qqq'should revert to old software before all the gieffects and then add in one at a Time 
'DONT START game until all locked balls drained.  call setballsonplayfield when endofgame, DropTargetResetLockIsLit 0 is called  'ballsonplayfield check in keydown
'add match event
'DONE 'qqq'critical music played during Bonus 
'DONE 'qqq'gi is white on new ball with reactor critcal
'09-10-fixing6.vpx gi became purple after a bunch of jackpot mball testing
' detect ball trapped in danesi lock
'animations
	'mystery Award three circle out, three down
	'lock - down,circle out, up
	' super spinner three circle Out 
	'handsfree Skillshot 
	'Skillshot 
	'combo ccw
'dof events 
'DONE 'total anil Bonus 
'DONE 'Tilt - dmd "Danger and Tilt.  Need sound clip
'DONE 'super spinner sound
'launch ball early if lane save light or ballsaveractive
'Reactor unlocked call out for reator ready, not started.  about  5 sec later "shoot the left scoop
'DONE 'Need Reactor Online callout for started
'spinner strobes insert
'msytery award, light locks if not lit
'Based on TNABeta10_03 (11/16/19)
'Shoot again during critical, GI is wrong/purple
'improve skill LOCK check
'			If ((StrComp(value, "DropTargetOpto2") = 0) OR (StrComp(value, "DropTargetOpto3") = 0)) AND (StrComp(LastSwitchHit, "swLLoop") = 0) OR Then
'			bTimedSkillShot




'================================================================
' PUP STUFF
'================================================================
'******************** DO NOT MODIFY STUFF BELOW   THIS LINE!!!! ***************
'******************************************************************************
'*****   Create a PUPPack within PUPPackEditor for layout config!!!  **********
'******************************************************************************
'
'
'  Quick Steps:
'      1>  create a folder in PUPVideos with Starter_PuPPack.zip and call the folder "yourgame"
'      2>  above set global variable pGameName="yourgame"
'      3>  copy paste the settings section above to top of table script for user changes.
'      4>  on Table you need to create ONE timer only called pupDMDUpdate and set it to 250 ms enabled on startup.
'      5>  go to your table1_init or table first startup function and call PUPINIT function
'      6>  Go to bottom on framework here and setup game to call the appropriate events like pStartGame (call that in your game code where needed)...etc
'      7>  attractmodenext at bottom is setup for you already,  just go to each case and add/remove as many as you want and setup the messages to show.  
'      8>  Have fun and use pDMDDisplay(xxxx)  sub all over where needed.  remember its best to make a bunch of mp4 with text animations... looks the best for sure!
'
'
'Note:  for *Future Pinball* "pupDMDupdate_Timer()" timer needs to be renamed to "pupDMDupdate_expired()"  and then all is good.
'       and for future pinball you need to add the follow lines near top
'Need to use BAM and have com idll enabled.
'				Dim icom : Set icom = xBAM.Get("icom") ' "icom" is name of "icom.dll" in BAM\Plugins dir
'				if icom is Nothing then MSGBOX "Error cannot run without icom.dll plugin"
'				Function CreateObject(className)       
'   					Set CreateObject = icom.CreateObject(className)   
'				End Function


Const HasPuP = True   'dont set to false as it will break pup

Const pTopper=0
Const pDMD=1
Const pBackglass=2
Const pPlayfield=3
Const pMusic=4
Const pMusic2=5
Const pCallouts=6
Const pBackglass2=7
Const pTopper2=8
Const pPopUP=9
Const pPopUP2=10


'pages
Const pDMDBlank=0
Const pScores=1
Const pBigLine=2
Const pThreeLines=3
Const pTwoLines=4
Const pTargerLetters=5

'dmdType
Const pDMDTypeLCD=0
Const pDMDTypeReal=1
Const pDMDTypeFULL=2






Dim PuPlayer
dim PUPDMDObject  'for realtime mirroring.
Dim pDMDlastchk: pDMDLastchk= -1    'performance of updates
Dim pDMDCurPage: pDMDCurPage= 0     'default page is empty.
Dim pInAttract : pInAttract=false   'pAttract mode




'*************  starts PUP system,  must be called AFTER b2s/controller running so put in last line of table1_init
Sub PuPInit

Set PuPlayer = CreateObject("PinUpPlayer.PinDisplay")   
PuPlayer.B2SInit "", pGameName

if (PuPDMDDriverType=pDMDTypeReal) and (useRealDMDScale=1) Then 
       PuPlayer.setScreenEx pDMD,0,0,128,32,0  'if hardware set the dmd to 128,32
End if

PuPlayer.LabelInit pDMD


if PuPDMDDriverType=pDMDTypeReal then
Set PUPDMDObject = CreateObject("PUPDMDControl.DMD") 
PUPDMDObject.DMDOpen
PUPDMDObject.DMDPuPMirror
PUPDMDObject.DMDPuPTextMirror
PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 1, ""FN"":33 }"             'set pupdmd for mirror and hide behind other pups
PuPlayer.SendMSG "{ ""mt"":301, ""SN"": 1, ""FN"":32, ""FQ"":3 }"   'set no antialias on font render if real
END IF


pSetPageLayouts

pDMDSetPage(pDMDBlank)   'set blank text overlay page.
pDMDStartUP				 ' firsttime running for like an startup video..


End Sub 'end PUPINIT



'PinUP Player DMD Helper Functions

Sub pDMDLabelHide(labName)
PuPlayer.LabelSet pDMD,labName,"",0,""   
end sub




Sub pDMDScrollBig(msgText,timeSec,mColor)
PuPlayer.LabelShowPage pDMD,2,timeSec,""
PuPlayer.LabelSet pDMD,"Splash",msgText,0,"{'mt':1,'at':2,'xps':1,'xpe':-1,'len':" & (timeSec*1000000) & ",'mlen':" & (timeSec*1000) & ",'tt':0,'fc':" & mColor & "}"
end sub

Sub pDMDScrollBigV(msgText,timeSec,mColor)
PuPlayer.LabelShowPage pDMD,2,timeSec,""
PuPlayer.LabelSet pDMD,"Splash",msgText,0,"{'mt':1,'at':2,'yps':1,'ype':-1,'len':" & (timeSec*1000000) & ",'mlen':" & (timeSec*1000) & ",'tt':0,'fc':" & mColor & "}"
end sub


Sub pDMDSplashScore(msgText,timeSec,mColor)
PuPlayer.LabelSet pDMD,"MsgScore",msgText,0,"{'mt':1,'at':1,'fq':250,'len':"& (timeSec*1000) &",'fc':" & mColor & "}"
end Sub

Sub pDMDSplashScoreScroll(msgText,timeSec,mColor)
PuPlayer.LabelSet pDMD,"MsgScore",msgText,0,"{'mt':1,'at':2,'xps':1,'xpe':-1,'len':"& (timeSec*1000) &", 'mlen':"& (timeSec*1000) &",'tt':0, 'fc':" & mColor & "}"
end Sub

Sub pDMDZoomBig(msgText,timeSec,mColor)  'new Zoom
PuPlayer.LabelShowPage pDMD,2,timeSec,""
PuPlayer.LabelSet pDMD,"Splash",msgText,0,"{'mt':1,'at':3,'hstart':5,'hend':80,'len':" & (timeSec*1000) & ",'mlen':" & (timeSec*500) & ",'tt':5,'fc':" & mColor & "}"
end sub

Sub pDMDTargetLettersInfo(msgText,msgInfo, timeSec)  'msgInfo = '0211'  0= layer 1, 1=layer 2, 2=top layer3.
'this function is when you want to hilite spelled words.  Like B O N U S but have O S hilited as already hit markers... see example.
PuPlayer.LabelShowPage pDMD,5,timeSec,""  'show page 5
Dim backText
Dim middleText
Dim flashText
Dim curChar
Dim i
Dim offchars:offchars=0
Dim spaces:spaces=" "  'set this to 1 or more depends on font space width.  only works with certain fonts
                          'if using a fixed font width then set spaces to just one space.

For i=1 To Len(msgInfo)
    curChar="" & Mid(msgInfo,i,1)
    if curChar="0" Then
            backText=backText & Mid(msgText,i,1)
            middleText=middleText & spaces
            flashText=flashText & spaces          
            offchars=offchars+1
    End If
    if curChar="1" Then
            backText=backText & spaces
            middleText=middleText & Mid(msgText,i,1)
            flashText=flashText & spaces
    End If
    if curChar="2" Then
            backText=backText & spaces
            middleText=middleText & spaces
            flashText=flashText & Mid(msgText,i,1)
    End If   
Next 

if offchars=0 Then 'all litup!... flash entire string
   backText=""
   middleText=""
   FlashText=msgText
end if  

PuPlayer.LabelSet pDMD,"Back5"  ,backText  ,1,""
PuPlayer.LabelSet pDMD,"Middle5",middleText,1,""
PuPlayer.LabelSet pDMD,"Flash5" ,flashText ,0,"{'mt':1,'at':1,'fq':150,'len':" & (timeSec*1000) & "}"   
end Sub


Sub pDMDSetPage(pagenum)    
    PuPlayer.LabelShowPage pDMD,pagenum,0,""   'set page to blank 0 page if want off
    PDMDCurPage=pagenum
end Sub

Sub pHideOverlayText(pDisp)
    PuPlayer.SendMSG "{ ""mt"":301, ""SN"": "& pDisp &", ""FN"": 34 }"             'hideoverlay text during next videoplay on DMD auto return
end Sub



Sub pDMDShowLines3(msgText,msgText2,msgText3,timeSec)
Dim vis:vis=1
if pLine1Ani<>"" Then vis=0
PuPlayer.LabelShowPage pDMD,3,timeSec,""
PuPlayer.LabelSet pDMD,"Splash3a",msgText,vis,pLine1Ani
PuPlayer.LabelSet pDMD,"Splash3b",msgText2,vis,pLine2Ani
PuPlayer.LabelSet pDMD,"Splash3c",msgText3,vis,pLine3Ani
end Sub


Sub pDMDShowLines2(msgText,msgText2,timeSec)
Dim vis:vis=1
if pLine1Ani<>"" Then vis=0
PuPlayer.LabelShowPage pDMD,4,timeSec,""
PuPlayer.LabelSet pDMD,"Splash4a",msgText,vis,pLine1Ani
PuPlayer.LabelSet pDMD,"Splash4b",msgText2,vis,pLine2Ani
end Sub

Sub pDMDShowCounter(msgText,msgText2,msgText3,timeSec)
Dim vis:vis=1
if pLine1Ani<>"" Then vis=0
PuPlayer.LabelShowPage pDMD,6,timeSec,""
PuPlayer.LabelSet pDMD,"Splash6a",msgText,vis, pLine1Ani
PuPlayer.LabelSet pDMD,"Splash6b",msgText2,vis,pLine2Ani
PuPlayer.LabelSet pDMD,"Splash6c",msgText3,vis,pLine3Ani
end Sub


Sub pDMDShowBig(msgText,timeSec, mColor)
Dim vis:vis=1
if pLine1Ani<>"" Then vis=0
PuPlayer.LabelShowPage pDMD,2,timeSec,""
PuPlayer.LabelSet pDMD,"Splash",msgText,vis,pLine1Ani
end sub


Sub pDMDShowHS(msgText,msgText2,msgText3,timeSec) 'High Score
Dim vis:vis=1
if pLine1Ani<>"" Then vis=0
PuPlayer.LabelShowPage pDMD,7,timeSec,""
PuPlayer.LabelSet pDMD,"Splash7a",msgText,vis,pLine1Ani
PuPlayer.LabelSet pDMD,"Splash7b",msgText2,vis,pLine2Ani
PuPlayer.LabelSet pDMD,"Splash7c",msgText3,vis,pLine3Ani
end Sub


Sub pDMDSetBackFrame(fname)
  PuPlayer.playlistplayex pDMD,"PUPFrames",fname,0,1    
end Sub

Sub pDMDStartBackLoop(fPlayList,fname)
  PuPlayer.playlistplayex pDMD,fPlayList,fname,0,1
  PuPlayer.SetBackGround pDMD,1
end Sub

Sub pDMDStopBackLoop
  PuPlayer.SetBackGround pDMD,0
  PuPlayer.playstop pDMD
end Sub


Dim pNumLines

'Theme Colors for Text (not used currenlty,  use the |<colornum> in text labels for colouring.
Dim SpecialInfo
Dim pLine1Color : pLine1Color=8454143  
Dim pLine2Color : pLine2Color=8454143
Dim pLine3Color :  pLine3Color=8454143
Dim curLine1Color: curLine1Color=pLine1Color  'can change later
Dim curLine2Color: curLine2Color=pLine2Color  'can change later
Dim curLine3Color: curLine3Color=pLine3Color  'can change later


Dim pDMDCurPriority: pDMDCurPriority =-1
Dim pDMDDefVolume: pDMDDefVolume = 0   'default no audio on pDMD

Dim pLine1
Dim pLine2
Dim pLine3
Dim pLine1Ani
Dim pLine2Ani
Dim pLine3Ani

Dim PriorityReset:PriorityReset=-1
DIM pAttractReset:pAttractReset=-1
DIM pAttractBetween: pAttractBetween=2000 '1 second between calls to next attract page
DIM pDMDVideoPlaying: pDMDVideoPlaying=false


'************************ where all the MAGIC goes,  pretty much call this everywhere  ****************************************
'*************************                see docs for examples                ************************************************
'****************************************   DONT TOUCH THIS CODE   ************************************************************

Sub pupDMDDisplay(pEventID, pText, VideoName,TimeSec, pAni,pPriority)
' pEventID = reference if application,  
' pText = "text to show" separate lines by ^ in same string
' VideoName "gameover.mp4" will play in background  "@gameover.mp4" will play and disable text during gameplay.
' also global variable useDMDVideos=true/false if user wishes only TEXT
' TimeSec how long to display msg in Seconds
' animation if any 0=none 1=Flasher
' also,  now can specify color of each line (when no animation).  "sometext|12345"  will set label to "sometext" and set color to 12345

DIM curPos
if pDMDCurPriority>pPriority then Exit Sub  'if something is being displayed that we don't want interrupted.  same level will interrupt.
pDMDCurPriority=pPriority
if timeSec=0 then timeSec=1 'don't allow page default page by accident


pLine1=""
pLine2=""
pLine3=""
pLine1Ani=""
pLine2Ani=""
pLine3Ani=""


if pAni=1 Then  'we flashy now aren't we
pLine1Ani="{'mt':1,'at':1,'fq':150,'len':" & (timeSec*1000) &  "}"  
pLine2Ani="{'mt':1,'at':1,'fq':150,'len':" & (timeSec*1000) &  "}"  
pLine3Ani="{'mt':1,'at':1,'fq':150,'len':" & (timeSec*1000) &  "}"  
end If

curPos=InStr(pText,"^")   'Lets break apart the string if needed
if curPos>0 Then 
   pLine1=Left(pText,curPos-1) 
   pText=Right(pText,Len(pText) - curPos)
   
   curPos=InStr(pText,"^")   'Lets break apart the string
   if curPOS>0 Then
      pLine2=Left(pText,curPos-1) 
      pText=Right(pText,Len(pText) - curPos)

      curPos=InStr("^",pText)   'Lets break apart the string   
      if curPos>0 Then
         pline3=Left(pText,curPos-1) 
      Else 
        if pText<>"" Then pline3=pText 
      End if 
   Else 
      if pText<>"" Then pLine2=pText
   End if    
Else 
  pLine1=pText  'just one line with no break 
End if


'lets see how many lines to Show
pNumLines=0
if pLine1<>"" then pNumLines=pNumlines+1
if pLine2<>"" then pNumLines=pNumlines+1
if pLine3<>"" then pNumLines=pNumlines+1

if pDMDVideoPlaying and (VideoName="")  Then 
			PuPlayer.playstop pDMD
			pDMDVideoPlaying=False
End if


if (VideoName<>"") and (useDMDVideos) Then  'we are showing a splash video instead of the text.
    
    PuPlayer.playlistplayex pDMD,"DMDSplash",VideoName,pDMDDefVolume,pPriority  'should be an attract background (no text is displayed)
    pDMDVideoPlaying=true
end if 'if showing a splash video with no text




if StrComp(pEventID,"shownum",1)=0 Then              'check eventIDs
    pDMDShowCounter pLine1,pLine2,pLine3,timeSec
Elseif StrComp(pEventID,"target",1)=0 Then              'check eventIDs
    pDMDTargetLettersInfo pLine1,pLine2,timeSec
Elseif StrComp(pEventID,"highscore",1)=0 Then              'check eventIDs
    pDMDShowHS pLine1,pLine2,pline3,timeSec
Elseif (pNumLines=3) Then                'depends on # of lines which one to use.  pAni=1 will flash.
    pDMDShowLines3 pLine1,pLine2,pLine3,TimeSec
Elseif (pNumLines=2) Then
    pDMDShowLines2 pLine1,pLine2,TimeSec
Elseif (pNumLines=1) Then
    pDMDShowBig pLine1,timeSec, curLine1Color
Else
    pDMDShowBig pLine1,timeSec, curLine1Color
End if

PriorityReset=TimeSec*1000
End Sub 'pupDMDDisplay message

Sub pupDMDupdate_Timer()
	pUpdateScores    

    if PriorityReset>0 Then  'for splashes we need to reset current prioirty on timer
       PriorityReset=PriorityReset-pupDMDUpdate.interval
       if PriorityReset<=0 Then 
            pDMDCurPriority=-1            
            if pInAttract then pAttractReset=pAttractBetween ' pAttractNext  call attract next after 1 second
			pDMDVideoPlaying=false			
			End if
    End if

    if pAttractReset>0 Then  'for splashes we need to reset current prioirty on timer
       pAttractReset=pAttractReset-pupDMDUpdate.interval
       if pAttractReset<=0 Then 
            pAttractReset=-1            
            if pInAttract then pAttractNext
			End if
    end if 
End Sub



'********************* END OF PUPDMD FRAMEWORK v1.0 *************************
'******************** DO NOT MODIFY STUFF ABOVE THIS LINE!!!! ***************
'****************************************************************************

'*****************************************************************
'   **********  PUPDMD  MODIFY THIS SECTION!!!  ***************
'PUPDMD Layout for each Table1
'Setup Pages.  Note if you use fonts they must be in FONTS folder of the pupVideos\tablename\FONTS  "case sensitive exact naming fonts!"
'*****************************************************************

Sub pSetPageLayouts

DIM dmddef
DIM dmdalt
DIM dmdscr
DIM dmdfixed

'labelNew <screen#>, <Labelname>, <fontName>,<size%>,<colour>,<rotation>,<xalign>,<yalign>,<xpos>,<ypos>,<PageNum>,<visible>
'***********************************************************************'
'<screen#>, in standard we’d set this to pDMD ( or 1)
'<Labelname>, your name of the label. keep it short no spaces (like 8 chars) although you can call it anything really. When setting the label you will use this labelname to access the label.
'<fontName> Windows font name, this must be exact match of OS front name. if you are using custom TTF fonts then double check the name of font names.
'<size%>, Height as a percent of display height. 20=20% of screen height.
'<colour>, integer value of windows color.
'<rotation>, degrees in tenths   (900=90 degrees)
'<xAlign>, 0= horizontal left align, 1 = center horizontal, 2= right horizontal
'<yAlign>, 0 = top, 1 = center, 2=bottom vertical alignment
'<xpos>, this should be 0, but if you want to ‘force’ a position you can set this. it is a % of horizontal width. 20=20% of screen width.
'<ypos> same as xpos.
'<PageNum> IMPORTANT… this will assign this label to this ‘page’ or group.
'<visible> initial state of label. visible=1 show, 0 = off.



if PuPDMDDriverType=pDMDTypeReal Then 'using RealDMD Mirroring.  **********  128x32 Real Color DMD  
	dmdalt="PKMN Pinball"
    dmdfixed="Instruction"
    dmdscr="SpaceQuestItalic-g8jY"    'main scorefont
	dmddef="Zig"

	'Page 1 (default score display)
  		 PuPlayer.LabelNew pDMD,"Credits" ,dmddef,20,33023   ,0,2,2,85,0,4,0
		 PuPlayer.LabelNew pDMD,"Play1"   ,dmdalt,21,33023   ,1,0,0,15,0,1,0
		 PuPlayer.LabelNew pDMD,"Ball"    ,dmdalt,50,33023   ,1,2,0,85,0,1,0
		 PuPlayer.LabelNew pDMD,"MsgScore",dmddef,45,33023   ,0,1,0, 0,40,1,0
		 PuPlayer.LabelNew pDMD,"CurScore",dmdscr,10,8454143   ,0,0,0, 0,0,1,0


	'Page 2 (default Text Splash 1 Big Line)
		 PuPlayer.LabelNew pDMD,"Splash"  ,dmdalt,40,33023,0,1,1,0,0,2,0

	'Page 3 (default Text Splash 2 and 3 Lines)
		 PuPlayer.LabelNew pDMD,"Splash3a",dmddef,30,8454143,0,1,0,0,2,3,0
		 PuPlayer.LabelNew pDMD,"Splash3b",dmdalt,30,33023,0,1,0,0,30,3,0
	     PuPlayer.LabelNew pDMD,"Splash3c",dmdalt,25,33023,0,1,0,0,55,3,0


	'Page 4 (2 Line Gameplay DMD)
		 PuPlayer.LabelNew pDMD,"Splash4a",dmddef,40,8454143,0,1,0,0,0,4,0
	     PuPlayer.LabelNew pDMD,"Splash4b",dmddef,30,33023,0,1,2,0,75,4,0

	'Page 5 (3 layer large text for overlay targets function,  must you fixed width font!
		PuPlayer.LabelNew pDMD,"Back5"    ,dmdfixed,80,8421504,0,1,1,0,0,5,0
		PuPlayer.LabelNew pDMD,"Middle5"  ,dmdfixed,80,65535  ,0,1,1,0,0,5,0
		PuPlayer.LabelNew pDMD,"Flash5"   ,dmdfixed,80,65535  ,0,1,1,0,0,5,0

	'Page 6 (3 Lines for big # with two lines,  "19^Orbits^Count")
		PuPlayer.LabelNew pDMD,"Splash6a",dmddef,90,65280,0,0,0,15,1,6,0
		PuPlayer.LabelNew pDMD,"Splash6b",dmddef,50,33023,0,1,0,60,0,6,0
		PuPlayer.LabelNew pDMD,"Splash6c",dmddef,40,33023,0,1,0,60,50,6,0

 	'Page 7 (Show High Scores Fixed Fonts)
		PuPlayer.LabelNew pDMD,"Splash7a",dmddef,20,8454143,0,1,0,0,2,7,0
		PuPlayer.LabelNew pDMD,"Splash7b",dmdfixed,40,33023,0,1,0,0,20,7,0
		PuPlayer.LabelNew pDMD,"Splash7c",dmdfixed,40,33023,0,1,0,0,50,7,0


END IF  ' use PuPDMDDriver

if PuPDMDDriverType=pDMDTypeLCD THEN  'Using 4:1 Standard ratio LCD PuPDMD  ************ lcd **************

	'dmddef="Space Quest"
	dmdalt="Space Quest"    
    dmdfixed="Instruction"
	dmdscr="Impact"  'main score font
	dmddef="Space Quest"

	'Page 1 (default score display)
		PuPlayer.LabelNew pDMD,"Credits" ,dmddef,9, 16633150 ,1,2,0,87,4,1,0
		PuPlayer.LabelNew pDMD,"Play1"   ,dmdalt,9,2292994   ,1,1,2,13,0,1,0
		PuPlayer.LabelNew pDMD,"Ball"    ,dmdalt,9,2292994   ,0,2,2,63,0,1,0
		PuPlayer.LabelNew pDMD,"MsgScore",dmddef,45,33023   ,0,1,0, 0,40,1,0
		PuPlayer.LabelNew pDMD,"CurScore",dmdscr,8,8454143   ,0,2,2,46,0,1,0
		PuPlayer.LabelNew pDMD,"Free",dmdalt,9,2292994   ,0,2,2,98,0,1,0
		PuPlayer.LabelNew pDMD,"Status",dmddef,9, 16711935  ,1,2,0,90,13,1,0
		PuPlayer.LabelNew pDMD,"RV" ,dmddef,9, 2292994  ,1,2,0,44,4,1,0
		PuPlayer.LabelNew pDMD,"RS" ,dmddef,9, 2292994  ,1,2,0,44,13,1,0
		


	'Page 2 (default Text Splash 1 Big Line)
		PuPlayer.LabelNew pDMD,"Splash"  ,dmdalt,40,33023,0,1,1,0,0,2,0

	'Page 3 (default Text 3 Lines)
		PuPlayer.LabelNew pDMD,"Splash3a",dmddef,30,8454143,0,1,0,0,2,3,0
		PuPlayer.LabelNew pDMD,"Splash3b",dmdalt,30,33023,0,1,0,0,30,3,0
		PuPlayer.LabelNew pDMD,"Splash3c",dmdalt,25,33023,0,1,0,0,57,3,0


	'Page 4 (default Text 2 Line)
		PuPlayer.LabelNew pDMD,"Splash4a",dmddef,40,8454143,0,1,0,0,0,4,0
		PuPlayer.LabelNew pDMD,"Splash4b",dmddef,30,33023,0,1,2,0,75,4,0

	'Page 5 (3 layer large text for overlay targets function,  must you fixed width font!
		PuPlayer.LabelNew pDMD,"Back5"    ,dmdfixed,80,8421504,0,1,1,0,0,5,0
		PuPlayer.LabelNew pDMD,"Middle5"  ,dmdfixed,80,65535  ,0,1,1,0,0,5,0
		PuPlayer.LabelNew pDMD,"Flash5"   ,dmdfixed,80,65535  ,0,1,1,0,0,5,0

	'Page 6 (3 Lines for big # with two lines,  "19^Orbits^Count")
		PuPlayer.LabelNew pDMD,"Splash6a",dmddef,90,65280,0,0,0,15,1,6,0
		PuPlayer.LabelNew pDMD,"Splash6b",dmddef,50,33023,0,1,0,60,0,6,0
		PuPlayer.LabelNew pDMD,"Splash6c",dmddef,40,33023,0,1,0,60,50,6,0

	'Page 7 (Show High Scores Fixed Fonts)
		PuPlayer.LabelNew pDMD,"Splash7a",dmddef,20,8454143,0,1,0,0,2,7,0
		PuPlayer.LabelNew pDMD,"Splash7b",dmdfixed,40,33023,0,1,0,0,20,7,0
		PuPlayer.LabelNew pDMD,"Splash7c",dmdfixed,40,33023,0,1,0,0,50,7,0


END IF  ' use PuPDMDDriver

if PuPDMDDriverType=pDMDTypeFULL THEN  'Using FULL BIG LCD PuPDMD  ************ lcd **************

	'dmddef="Impact"
	dmdalt="PKMN Pinball"    
    dmdfixed="Instruction"
	dmdscr="Impact"  'main score font
	dmddef="Impact"

	'Page 1 (default score display)
		PuPlayer.LabelNew pDMD,"Credits" ,dmddef,20,33023   ,0,2,2,95,0,1,0
		PuPlayer.LabelNew pDMD,"Play1"   ,dmdalt,20,33023   ,1,0,0,15,0,1,0
		PuPlayer.LabelNew pDMD,"Ball"    ,dmdalt,20,33023   ,1,2,0,78,0,1,0
		PuPlayer.LabelNew pDMD,"MsgScore",dmddef,45,33023   ,0,1,0, 0,40,1,0
		PuPlayer.LabelNew pDMD,"CurScore",dmdscr,60,8454143   ,0,1,1, 0,0,1,0		


	'Page 2 (default Text Splash 1 Big Line)
		PuPlayer.LabelNew pDMD,"Splash"  ,dmdalt,40,33023,0,1,1,0,0,2,0

	'Page 3 (default Text 3 Lines)
		PuPlayer.LabelNew pDMD,"Splash3a",dmddef,30,8454143,0,1,0,0,2,3,0
		PuPlayer.LabelNew pDMD,"Splash3b",dmdalt,30,33023,0,1,0,0,30,3,0
		PuPlayer.LabelNew pDMD,"Splash3c",dmdalt,25,33023,0,1,0,0,57,3,0


	'Page 4 (default Text 2 Line)
		PuPlayer.LabelNew pDMD,"Splash4a",dmddef,40,8454143,0,1,0,0,0,4,0
		PuPlayer.LabelNew pDMD,"Splash4b",dmddef,30,33023,0,1,2,0,75,4,0

	'Page 5 (3 layer large text for overlay targets function,  must you fixed width font!
		PuPlayer.LabelNew pDMD,"Back5"    ,dmdfixed,80,8421504,0,1,1,0,0,5,0
		PuPlayer.LabelNew pDMD,"Middle5"  ,dmdfixed,80,65535  ,0,1,1,0,0,5,0
		PuPlayer.LabelNew pDMD,"Flash5"   ,dmdfixed,80,65535  ,0,1,1,0,0,5,0

	'Page 6 (3 Lines for big # with two lines,  "19^Orbits^Count")
		PuPlayer.LabelNew pDMD,"Splash6a",dmddef,90,65280,0,0,0,15,1,6,0
		PuPlayer.LabelNew pDMD,"Splash6b",dmddef,50,33023,0,1,0,60,0,6,0
		PuPlayer.LabelNew pDMD,"Splash6c",dmddef,40,33023,0,1,0,60,50,6,0

	'Page 7 (Show High Scores Fixed Fonts)
		PuPlayer.LabelNew pDMD,"Splash7a",dmddef,20,8454143,0,1,0,0,2,7,0
		PuPlayer.LabelNew pDMD,"Splash7b",dmdfixed,40,33023,0,1,0,0,20,7,0
		PuPlayer.LabelNew pDMD,"Splash7c",dmdfixed,40,33023,0,1,0,0,50,7,0


END IF  ' use PuPDMDDriver




end Sub 'page Layouts


'*****************************************************************
'        PUPDMD Custom SUBS/Events for each Table1
'     **********    MODIFY THIS SECTION!!!  ***************
'*****************************************************************
'
'
'  we need to somewhere in code if applicable
'
'   call pDMDStartGame,pDMDStartBall,pGameOver,pAttractStart
'
'
'
'
'


Sub pDMDStartGame
pInAttract=false
pDMDSetPage(pScores)   'set blank text overlay page.

end Sub


Sub pDMDStartBall
end Sub

Sub pDMDGameOver
pAttractStart
end Sub

Sub pAttractStart
pDMDSetPage(pDMDBlank)   'set blank text overlay page.
pCurAttractPos=0
pInAttract=true          'Startup in AttractMode
pAttractNext
end Sub

Sub pDMDStartUP
 pupDMDDisplay "attract","","",5,0,10
 pInAttract=true
end Sub

DIM pCurAttractPos: pCurAttractPos=0


'********************** gets called auto each page next and timed already in DMD_Timer.  make sure you use pupDMDDisplay or it wont advance auto.
Sub pAttractNext
pCurAttractPos=pCurAttractPos+1

  Select Case pCurAttractPos

  Case 1 pupDMDDisplay "attract","Attract^1","",5,1,10
  Case 2 pupDMDDisplay "attract","Attract^2","",3,0,10
  Case 3 pupDMDDisplay "attract","Attract^3","",2,0,10
  Case 4 pupDMDDisplay "attract","Attract^4","",3,1,10
  Case 5 pupDMDDisplay "attract","Attract^5","",1,0,10
  Case 6 pupDMDDisplay "attract","Attract^6","",3,1,10
  Case 7 pupDMDDisplay "attract","Attract^7","",2,0,10
  Case 8 pupDMDDisplay "attract","Attract^8","",1,0,10
  Case 9 pupDMDDisplay "attract","Attract^9","",1,1,10
  Case 10 pupDMDDisplay "attract","Attract^10","",3,1,10
  Case Else
    pCurAttractPos=0
    pAttractNext 'reset to beginning
  end Select

end Sub

'************************ called during gameplay to update Scores ***************************

Sub pUpdateScores  'call this ONLY on timer 300ms is good enough
	Dim ReactorStatus
	
	if pDMDCurPage <> pScores then Exit Sub

	'puPlayer.LabelSet pDMD,"Credits","CREDITS " & ""& Credits ,1,""
	'puPlayer.LabelSet pDMD,"Play1","Player 1",1,""
	'puPlayer.LabelSet pDMD,"Ball"," "&pDMDCurPriority ,1,""
	'puPlayer.LabelSet pDMD,"Free Play","" & ""& Credits ,1,""
	'puPlayer.LabelSet pDMD,"Free","CREDITS" & ""& Credits ,1,""
	'PuPlayer.LabelSet pDMD,"Status","CREDITS " & ""& Credits ,1,""
	'puPlayer.LabelSet pDMD,"Reactor Value","Reactor Value",1,""

	puPlayer.LabelSet pDMD,"CurScore","" & FormatNumber(Score(CurrentPlayer),0),1,""
	puPlayer.LabelSet pDMD,"Play1","Player: " & CurrentPlayer,1,""
	puPlayer.LabelSet pDMD,"Ball","Ball: " & BallinPlay ,1,""
	puPlayer.LabelSet pDMD,"Credits","" & ReactorValue(CurrentPlayer),1,""
	puPlayer.LabelSet pDMD,"Free","Credits: " & ""& Credits ,1,""
	puPlayer.LabelSet pDMD,"RV","REACTOR VALUE: ",1,""
	puPlayer.LabelSet pDMD,"RS","REACTOR STATUS: ",1,""

	Select Case ReactorState(CurrentPlayer)
		Case 0: ReactorStatus = "Targeted"
		Case 1: ReactorStatus = "Ready"
		Case 2: ReactorStatus = "Started"
		Case 3: ReactorStatus = "Critical"
	End Select
	puPlayer.LabelSet pDMD,"Status","" & ReactorStatus,1,""
	
end Sub
'**************************
'PinUPPlayer
'**************************
Sub PinUPInit
Set PuPlayer = CreateObject("PinUpPlayer.PinDisplay")
PuPlayer.B2SInit "",CGameName
end Sub

Sub PuPEvent(EventNum)
	If UsePinup = 1 Then 
		if hasPUP=false then Exit Sub

		PuPlayer.B2SData "D"&EventNum,1  'send event to puppack driver
   End If
End Sub
  'this should be called in table1_init at bottom after all else b2s/controller running.
'********************  pretty much only use pupDMDDisplay all over ************************   
' Sub pupDMDDisplay(pEventID, pText, VideoName,TimeSec, pAni,pPriority)
' pEventID = reference if application,  
' pText = "text to show" separate lines by ^ in same string
' VideoName "gameover.mp4" will play in background  "@gameover.mp4" will play and disable text during gameplay.
' also global variable useDMDVideos=true/false if user wishes only TEXT
' TimeSec how long to display msg in Seconds
' animation if any 0=none 1=Flasher
' also,  now can specify color of each line (when no animation).  "sometext|12345"  will set label to "sometext" and set color to 12345
'Samples
'
'pupDMDDisplay "default", "DATA GADGET LIT", "@DataGadgetLit.mp4", 3, 1, 10
'pupDMDDisplay "shoot", "SHOOT AGAIN!", "@shootagain.mp4", 3, 1, 10   
'pupDMDDisplay "balllock", "Ball^Locked|16744448", "", 5, 1, 10             '  5 seconds,  1=flash, 10=priority, ball is first line, locked on second and locked has custom color |
'pupDMDDisplay "balllock","Ball 2^is^Locked", "balllocked2.mp4",3, 1,10     '  3 seconds,  1=flash, play balllocked2.mp4 from dmdsplash folder, 
'pupDMDDisplay "balllock","Ball^is^Locked", "@balllocked.mp4",3, 1,10       '  3 seconds,  1=flash, play @balllocked.mp4 from dmdsplash folder, because @ text by default is hidden unless useDmDvideos is disabled.


'pupDMDDisplay "shownum", "3^More To|616744448^GOOOO", "", 5, 1, 10         ' "shownum" is special.  layout is line1=BIG NUMBER and line2,line3 are side two lines.  "4^Ramps^Left"

'pupDMDDisplay "target", "POTTER^110120", "blank.mp4", 10, 0, 10            ' 'target'...  first string is line,  second is 0=off,1=already on, 2=flash on for each character in line (count must match)

'pupDMDDisplay "highscore", "High Score^AAA   2451654^BBB   2342342", "", 5, 0, 10            ' highscore is special  line1=text title like highscore, line2, line3 are fixed fonts to show AAA 123,123,123
'pupDMDDisplay "highscore", "High Score^AAA   2451654|616744448^BBB   2342342", "", 5, 0, 10  ' sames as above but notice how we use a custom color for text |
'================================================================
' PUP STUFF
'================================================================

'*****************************
' AUTO TESTING
' by:NailBuster 
' Global variable "AutoQA" below will switch all this on/off during testing.  
'
'*****************************
' NailBusters AutoQA Code and triggers..  
' this to do for ROM based:  timeout on keydown.  if 30 seconds, then assume game is over and you add coins/start game key.
' add a timer called AutoQAStartGame.  you can run every 10000 interval.

Dim AutoQA:
AutoQa = 0      '0 = off, 1, 2,3,4 = 1 or 2 or 3 or 4 player test.   Main QA Testing FLAG setting to false will disable all this stuff.
AutoQAStartGame.Enabled = AutoQa
Dim QACoinStartSec:QACoinStartSec=60   'timeout seconds for AutoCoinStartSec
Dim QANumberOfCoins:QANumberOfCoins=3 + AutoQa 'number of coins to add for each start
Dim QASecondsDiff

Dim QALastFlipperTime:QALastFlipperTime=Now()
Dim AutoFlipperLeft:AutoFlipperLeft=false
Dim AutoFlipperRight:AutoFlipperRight=false



Sub AutoQAStartGame_Timer()                 'this is a timeout when sitting in attract with no flipper presses for 60 seconds, then add coins and start game.
 if AutoQA=0 Then Exit Sub

 QASecondsDiff = DateDiff("s",QALastFlipperTime,NOW())

 if QASecondsDiff>QACoinStartSec Then

    'simulate quarters and start game keys
    Dim fx : fx=0
    Dim keydelay : keydelay=100
	Do While fx<QANumberOfCoins  
		vpmtimer.addtimer keydelay,"Table1_KeyDown(keyInsertCoin1) '"
        vpmtimer.addtimer keydelay+200,"Table1_KeyUp(keyInsertCoin1) '"
        keydelay=keydelay+500
		fx=fx+1
	Loop
	
	fx=0
	Do While fx<AutoQa  
		vpmtimer.addtimer keydelay,"Table1_KeyDown(StartGameKey) '"
		vpmtimer.addtimer keydelay+200,"Table1_KeyUp(StartGameKey) '"
        keydelay=keydelay+500
		fx=fx+1
	Loop


    QALastFlipperTime=Now() 
	AutoFlipperLeft=false 	
    AutoFlipperRight=false
 End if  

 if QASecondsDiff>30 Then   'safety of stuck up flipers.
   AutoFlipperLeft=false 	
   AutoFlipperRight=false
  End if
End Sub


Sub TriggerAutoPlunger_Hit()          'add a trigger in front of plunger.  adjust the delay timings if needed.    
    if AutoQA=0 Then Exit Sub
	vpmtimer.addtimer 10,"Table1_KeyDown(PlungerKey) '"
    vpmtimer.addtimer 900+RND(400),"Table1_KeyUp(PlungerKey) '"
End Sub



Sub FlipperUP(which)  'which=1 left 2 right
QALastFlipperTime=Now()
if which=1 Then
   Table1_KeyDown(LeftFlipperKey)   
   vpmtimer.addtimer 200+Rnd(200),"Table1_KeyUP(LeftFlipperKey):AutoFlipperLeft=false  '"    
Else
   Table1_KeyDown(RightFlipperKey)
   vpmtimer.addtimer 200+Rnd(200),"Table1_KeyUP(RightFlipperKey):AutoFlipperRight=false  '"    
end If

End Sub



Sub TriggerLeftAuto_Hit()
	if AutoQA>0 And AutoFlipperLeft=false then vpmtimer.addtimer 20+Rnd(20),"FlipperUP(1) '" 
    AutoFlipperLeft=true
End Sub

Sub TriggerRightAuto_Hit()
	if AutoQA>0 and AutoFlipperRight=false then vpmtimer.addtimer 20+Rnd(20),"FlipperUP(2) '" 
    AutoFlipperRight=true
End Sub

Sub TriggerLeftAuto2_Hit()
	TriggerLeftAuto_Hit()
End Sub

Sub TriggerRightAuto2_Hit()
	TriggerRightAuto_Hit()
End Sub




'*****************************************************



'================================================================
'DOF Events -   "-- Means DOF event is used
'================================================================
'101 - Left Flipper 
'102 - Right Flipper 
'103 - Left SlingShot Solenoid
'104 - Left SlingShot Flasher
'105 - Right SlingShot Solenoid
'106 - Right SlingShot Flasher
'107 - Bumper Solenoid 
'108 - RAD Left Standup Target bank
'109 - Grid Targetx,y,z standup target
'110 - Destroy Left standup
'111 - Destroy Right Standup
'112 - Left Spinner Flasher
'113 - Right Spinner Flasher
'114 - Reactor Stand Up targets 
'115 -- Multiball - Consider Dof On and Off when MB ends
'116 - Drain
'117 - Reactor Left Slings 
'118 - Reactor Right Sling 
'119 - Bumper Flasher 
'121 - Ball Trough
'122 - Left Scoop Solenoid and Right Scoop Solenoid - Consider separating
'123 - Strobe used for Autoplunge , Extra Game, Left Scoop, Right Scoop, Single Jackpot, Double Jackpot
'125 - Autoplunge 'Solenoid
'129 - Knocker
'132 - Triple Jackpot Strobe
'133 - Super Jackpot Strobe
'136 - Drop Target Upper Solenoid
'137 - Drop Target MIddle Solenoid
'138 - Drop Target Lower Solenoid
'140 - Credits/Free Play 'Start Button
'Undercab E145 White/E146 Blue/E147 Red/E148 Green/E149 Purple
	'--Const DOFuyellow = 144
	'--Const DOFuwhite = 145
	'--Const DOFublue  = 146
	'--Const DOFured   = 147
	'--Const DOFugreen = 148
	'--Const DOFupurple= 149
'150 -- Top Lane 1
'151 -- Top Lane 2
'152 -- Top Lane 3
'153 -- Top Lane 4
'160 - Combo Loop
'161 - Tilt warning
'162 - Tilted
'163 - Shoot again
'164 - Player Bonus Count (8 seconds)
'165 - Ball Saved
'166 -- Bonus Multiplier Awarded (1.5 seconds)
'167 - Extra Ball Earned
'168 - Skill Shot
'169 - Handsfree Skill Shot
'170 - Lane Save Earned
'171 - Super Spinner Awarded
'172 - Locks are Lit
'173 -- Ball Lock 1
'173 -- Ball Lock 2 (using 173 for same Effect)
'175 - Reactor Grid Jackpot
'176 - Reactor Ready
'177 - Reactor Started
'178 -- Reactor Critical
'179 -- Reactor Destroyed
'180 -- Total Annihilation Achieved
'181 - Reactor Value Maxed
'182 - Mystery is Lit
'183 - Mystery Awarded (4 seconds)
'184 -- Grid insert Left Green
'185 -- Grid insert Middle Green
'186 -- Grid insert Right Green
'187 -- Grid insert Left Purple
'188 -- Grid insert Middle Purple
'189 -- Grid insert Right Purple
'190 -- Reactor Max 1 target inserts
'191 -- Reactor Max 2 target insert
'192 -- Reactor Max 3 target insert
'193 -- Mystery award 1 target inserts
'194 -- Mystery award 2 target insert
'195 -- Mystery award 3 target insert

'================================================================
'DOF Events
'================================================================

