Option Explicit       
'                                                                   
'     _,---.             .=-.-..-._        ,--.--------.   ,-,--.  ,--.--------.   _,.---._    .-._           ,----.    ,-,--.  
'  .-`.' ,  \   _.-.    /==/_ /==/ \  .-._/==/,  -   , -\,-.'-  _\/==/,  -   , -\,-.' , -  `. /==/ \  .-._ ,-.--` , \ ,-.'-  _\ 
' /==/_  _.-' .-,.'|   |==|, ||==|, \/ /, |==\.-.  - ,-./==/_ ,_.'\==\.-.  - ,-./==/_,  ,  - \|==|, \/ /, /==|-  _.-`/==/_ ,_.' '
'/==/-  '..-.|==|, |   |==|  ||==|-  \|  | `--`\==\- \  \==\  \    `--`\==\- \ |==|   .=.     |==|-  \|  ||==|   `.-.\==\  \    
'|==|_ ,    /|==|- |   |==|- ||==| ,  | -|      \==\_ \  \==\ -\        \==\_ \|==|_ : ;=:  - |==| ,  | -/==/_ ,    / \==\ -\   
'|==|   .--' |==|, |   |==| ,||==| -   _ |      |==|- |  _\==\ ,\       |==|- ||==| , '='     |==| -   _ |==|    .-'  _\==\ ,\  
'|==|-  |    |==|- `-._|==|- ||==|  /\ , |      |==|, | /==/\/ _ |      |==|, | \==\ -    ,_ /|==|  /\ , |==|_  ,`-._/==/\/ _ | 
'/==/   \    /==/ - , ,/==/. //==/, | |- |      /==/ -/ \==\ - , /      /==/ -/  '.='. -   .' /==/, | |- /==/ ,     /\==\ - , / 
'`--`---'    `--`-----'`--`-` `--`./  `--`      `--`--`  `--`---'       `--`--`    `--`--''   `--`./  `--`--`-----``  `--`---'  
'Williams 1994 
'                                     .:::::::::.
'                                    .::::::::::::::::,       .::
'                                  -'`;. ccccr -ccc,```'::,:::::::
'                                     `,z$$$$$$c $$$F.::::::::::::
'                                      'c`$'cc,?$$$$ :::::`:. ``':
'                                      $$$`4$$$,$$$$ :::',   `
'                                ..    F  .`$   $$"$L,`,d$c$
'                               d$$$$$cc,,d$c,ccP'J$$$$,,`"$F
'                               $$$$$$$$$$$$$$$$$$$$$$$$$",$F
'                               $$$$$$$$$$$ ccc,,"?$$$$$$c$$F
'                               `?$$$PFF",zd$P??$$$c?$$$$$$$F
'                              .,cccc=,z$$$$$b$ c$$$ $$$$$$$
'                           cd$$$F",c$$$$$$$$P'<$$$$ $$$$$$$
'                           $$$$$$$c,"?????""  $$$$$ $$$$$$F
'                       ::  $$$$L ""??"    .. d$$$$$ $$$$$P'..
'                       ::: ?$$$$J$$cc,,,,,,c$$$$$$PJ$P".::::
'                  .,,,. `:: $$$$$$$$$$$$$$$$$$$$$P".::::::'
'        ,,ccc$$$$$$$$$P" `::`$$$$$$$$$$$$$$$$P".::::::::' c$c.
'  .,cd$$PPFFF????????" .$$$$$b,
'z$$$$$$$$$$$$$$$$$$$$bc.`'!>` -:.""?$$P".:::'``. `',<'` $$$$$$$$$c
'$$$$$$$$$$$$$$$$$$$$$$$$$c,=$$ :::::  -`',;;!!!,,;!!>. J$$$$$$$$$$b,
'?$$$$$$$$$$$$$$$$$$$$$$$$$$$cc,,,.` ."?$$$$$$$$$$$$$$$$$$.
'     ""??"""   ;!!!.$$$ `?$$$$$$P'!!!!;     !!;.""?$$$$$$$$$$$$$$$r
'               !!!'<$$$ :::..  .;!!!!!!;   !!!!!!!!!!!!!>  "?$$$$$$$$$$$"
'              !!!!>`?$F::::::::`!!!!!!!!! ?"
'                  `!!!!>`::::: :: 
'               `    `!!! `:::: ,, ;!!!!!!!!!'`    ;!!!!!!!!!!!
'                \;;;;!!!! :::: !!!!!!!!!!!       ;!!!!!!!!!!!!>
'                `!!!!!!!!> ::: !!!!!!!!!!!      ;!!!!!!!!!!!!!!>
'                 !!!!!!!!!!.` !!!!!!!!!!!!!;. ;!!!!!!!!!!!!!!!!>
'                  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
'                  `!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
'                   `!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
'                    `
'                       ?$$c``!!! d $$c,c$.`!',d$$$P
'                           `$$$$$c,,d$ 3$$$$$$cc$$$$$$F
'                            `$$$$$$$$$b`$$$$$$$$$$$$$$
'                             `$$$$$$$$$ ?$$$$$$$$$$$$$
'                              `$$$$$$$$$ $$$$$$$$$$$$F
'                               `$$$$$$$$,?$$$$$$$$$$$'
'                                `$$$$$$$$ $$$$$$$$$$P
'                                  ?$$$$$$b`$$$$$$$$$F
'                                ,c$$$$$$$$c`$$"$$$$$$$cc,
'                            ,z$$$$$$$$$$$$$ $L')$$$$$$$$$$b,,,,, ,
'                       ,,-=P???$$$$$$$$$$PF $$$$$$$$$$$$$Lz =zr4%'
'                      `?'d$ $b = $$$$$$           "???????$$$P
'                         `"-"$$$$P""""                     "

'*****************************************************************************************************
' CREDITS
' Authors: g5k, 3rdaxis, DJRobX
' Bronto, Dictabird models and 3d scan cleanup of building toys: Dark
' Color DMD : Slippifishi and Wob - To be available at vpuniverse.com 
' Legends: SlyDog43, Dave Conn
' Some stuff from the vp9 version, DOF code etc (thanks to JPSalas and those who helped make that original one)
' DOF Updates: Arngrim
' Shout out to the VPX and VPM dev teams!
' Big thanks to all those who pitched in to help make this happen
' Yabba Dabba Doo
'*****************************************************************************************************
       

'First, try to load the Controller.vbs (DOF), which helps controlling additional hardware like lights, gears, knockers, bells and chimes (to increase realism)
'This table uses DOF via the 'SoundFX' calls that are inserted in some of the PlaySound commands, which will then fire an additional event, instead of just playing a sample/sound effect
Const BallSize = 50				 'Ball diameter in VPX units; must be 50
Const BallMass = 1				  'Ball mass must be 1
On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the Controller.vbs file in order to run this table (installed with the VPX package in the scripts folder)"
On Error Goto 0
Const cGameName = "fs_lx5"



'*****************************************************************************************************
'SCRIPT OPTIONS
'*****************************************************************************************************

Dim LUTmeUP:LUTMeUp = 1 '0 = No LUT, will look nice and bright, 1 = 30% contrast and brightness adj, 2 = 50% contrast and brightness adj, 3 = 70% contrast and brightness adj, 4 = 100% contrast and brightness adj, 5 = 130% contrast and brightness
Dim DisableLUTSelector:DisableLUTSelector = 0  ' Disables the ability to change LUT option with magna saves in game when set to 1
Const UseSolenoids=2 'FastFlips
Const FlipperShadows = 1 ' change to 0 to turn off flipper shadows
Const OutlaneDifficulty = 1 ' 1 = EASY, 2 = MEDIUM (Factory), 3 = HARD 
Const BallShadowOn = 1  '0=Off 1=On (Off=Performance On=Quality)
Const GiMethod = 2 ' 1 = GI control by materials less overhead; 2 = GI Double Prims, this has more overhead and will not run on shite setups
Const PreloadMe = 1  ' To prevent in-game slowdowns
Const VolRoll = 70 ' 0..100.  Ball roll volume
Const FlasherIntensity = 200' (0-1000) 200 = Default. Can be higher or lower (i.e. 220 to make them brighter, 180 to make them more dull)
Const Flasher4k = 0 '0 Uses 1024x1024 flasher overlays will help performance on systems experience frame dips in lightshow moments, 1 = 4K Overlays for beasts
					'If you still have performance issues you will need to select all the primitives on layer 4,5 and 6 and deselect "Reflection Enabled". 
					'Disabling playfield reflections would be best but at time of release this was creating an error with the inserts. Future VPX updates may fix this.


'Const bladeArt	= 0	'1=On (Art), 2=Alt 3= ALt 0=Sideblades Off.

Const UseLamps=0,UseGI=1,SSolenoidOn="SolOn",SSolenoidOff="SolOff", SCoin="coin3",SKickerOn="RearScoop"
Dim UseVPMDMD:UseVPMDMD = True
Const UseVPMModSol=1
Const MaxLut = 4

If Table1.ShowDT = false then
    Scoretext.Visible = false
	UseVPMDMD = False
End If


LoadVPM "01560000", "WPC.VBS", 3.26

Dim bsTrough, bsKicker36, dtLeftDrop, dtRightDrop, ttMachine
Set GiCallback2 = GetRef("UpdateGI")

Dim EnableBallControl
EnableBallControl = false 'Change to true to enable manual ball control (or press C in-game) via the arrow keys and B (boost movement) keys

Dim NullFader : set NullFader = new NullFadingObject
Dim FadeLights : Set FadeLights = New LampFader
Dim GI_STATUS
Dim DesktopMode: DesktopMode = Table1.ShowDT
'Dim autoflip 'AXS
'autoflip=0'(For Stress Testing)>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Sub Table1_Init

    if table1.VersionMinor < 6 AND table1.VersionMajor = 10 then MsgBox "This table requires VPX 10.6, you have " & table1.VersionMajor & "." & table.VersionMinor
	if VPinMAMEDriverVer < 3.57 then MsgBox "This table requires core.vbs 3.57 or higher, which is included with VPX 10.6.  You have " & VPinMAMEDriverVer & ". Be sure scripts folder is up to date, and that there are no old .vbs files in your table folder."

	vpmInit Me
    NoUpperLeftFlipper
    NoUpperRightFlipper

     With Controller
        .GameName = cGameName
          If Err Then MsgBox "Can't start Game " & cGameName & vbNewLine & Err.Description:Exit Sub
         .SplashInfoLine = "The Flintstones - based on the table by Williams from 1994" & vbNewLine & "VPX table by g5k, 3rdAxis, DJRobX and Dark"
          'DMD position and size for 1400x1050
         '.Games(cGameName).Settings.Value("dmd_pos_x")=500
         '.Games(cGameName).Settings.Value("dmd_pos_y")=2
         '.Games(cGameName).Settings.Value("dmd_width")=400
         '.Games(cGameName).Settings.Value("dmd_height")=92
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
     End With
 
     ' Nudging
     vpmNudge.TiltSwitch = 14
     vpmNudge.Sensitivity = 1
    ' vpmNudge.TiltObj = Array(bumper1, bumper2, bumper3, LeftSlingshot, RightSlingshot)
 		
     ' Trough
     Set bsTrough = New cvpmTrough
     With bsTrough
		 .Size = 4
         .InitSwitches Array(32, 33, 34, 35) 
         .InitExit BallRelease, 90, 4
         .InitExitSounds  SoundFX(SSolenoidOn,DOFContactors), SoundFX("BallRelease",DOFContactors)
         .Balls = 4
     End With

	' Bronto/Machine VUK
	Set bsKicker36 = New cvpmSaucer
	With bsKicker36
		.InitKicker Kicker36, 36, 0, 35, 1.56
		.InitSounds "kicker_enter_center", SoundFX(SKickerOn,DOFContactors), SoundFX(SKickerOn,DOFContactors)
		.CreateEvents "bsKicker36", Kicker36
	End With

     ' Left Drop Targets
     Set dtLeftDrop = New cvpmDropTarget
     With dtLeftDrop
         .InitDrop Array(sw45, sw46, sw47), Array(45, 46, 47)
         .initsnd "droptarget", SoundFX("DTReset", DOFContactors)
         .CreateEvents "dtLeftDrop"
     End With
 
     ' Right Drop Targets
     Set dtRightDrop = New cvpmDropTarget
     With dtRightDrop
         .InitDrop Array(sw41, sw42, sw43, sw44), Array(44, 43, 42, 41)
         .initsnd SoundFX("droptarget", DOFDropTargets), SoundFX("DTReset",DOFContactors)
         .CreateEvents "dtRightDrop"
     End With


     ' Machine Toy
     Set ttMachine = New cvpmTurnTable
     With ttMachine
         .InitTurnTable ttMachineTrigger, 32
         .SpinUp = 32
         .SpinDown = 25
         .SpinCW = True
         .CreateEvents "ttMachine"
     End With
 
	PinMAMETimer.Interval = PinMAMEInterval
    PinMAMETimer.Enabled = 1
    MachineLock.Collidable = false
    BS_HalfTableWidth = Table1.Width / 2  ' OPT4: cached once; used in BallShadowUpdate
    BS_TableWidth = Table1.Width           ' OPT11: cached for AudioPan
    BS_TableHeight = Table1.Height         ' OPT11: cached for AudioFade

	AutoPlunger.Pullback

	LUTBox.Visible = 0
	SetLUT

	if Flasher4k = 1 Then
		FlPf17.ImageA = "fl17"
		FlPf17.ImageB = "fl17"
		FlPf18.ImageA = "fl18"
		FlPf18.ImageB = "fl18"
		FlPf19.ImageA = "fl19"
		FlPf19.ImageB = "fl19"
		FlPf20.ImageA = "fl20"
		FlPf20.ImageB = "fl20"
		FlPf21.ImageA = "fl21"
		FlPf21.ImageB = "fl21"
		FlPf22.ImageA = "fl22"
		FlPf22.ImageB = "fl22"
		FlPf24.ImageA = "fl24"
		FlPf24.ImageB = "fl24"
		FlPf25.ImageA = "fl25"
		FlPf25.ImageB = "fl25"
		FlPf28.ImageA = "fl28"
		FlPf28.ImageB = "fl28"
	end If

	If DesktopMode = True Then 
		Bar_Rails.visible=True
	  Else
		Bar_Rails.visible=False
		
	end If

If Table1.ShowDT = false then 'AXS
    Fl1.State = 1
else
    Fl1.State = 0
End If

	' OPT2: OutlaneDifficulty is a Const — set Collidable once at init instead
	'       of every frame in RealTimeUpdates (was ~360 COM writes/sec).
	Select Case OutlaneDifficulty
		Case 1
			OutlaneLeft1.Collidable = True  : OutlaneLeft2.Collidable = False : OutlaneLeft3.Collidable = False
			OutlaneRight1.Collidable = True : OutlaneRight2.Collidable = False : OutlaneRight3.Collidable = False
		Case 2
			OutlaneLeft1.Collidable = False : OutlaneLeft2.Collidable = True  : OutlaneLeft3.Collidable = False
			OutlaneRight1.Collidable = False : OutlaneRight2.Collidable = True : OutlaneRight3.Collidable = False
		Case 3
			OutlaneLeft1.Collidable = False : OutlaneLeft2.Collidable = False : OutlaneLeft3.Collidable = True
			OutlaneRight1.Collidable = False : OutlaneRight2.Collidable = False : OutlaneRight3.Collidable = True
	End Select

End Sub

Sub SetLUT
	Select Case LUTmeUP
		Case 0:table1.ColorGradeImage = 0
		Case 1:table1.ColorGradeImage = "AA_FS_Lut30perc"
		Case 2:table1.ColorGradeImage = "AA_FS_Lut50perc"
		Case 3:table1.ColorGradeImage = "AA_FS_Lut70perc"
		Case 4:table1.ColorGradeImage = "AA_FS_Lut100perc"
	end Select
end sub 

Sub LUTBox_Timer
	LUTBox.TimerEnabled = 0 
	LUTBox.Visible = 0
End Sub

Sub ShowLUT
	LUTBox.visible = 1
	LUTBox.text = "LUTmeUP: " & CStr(LUTmeUP)
	LUTBox.TimerEnabled = 1
End Sub

sub Drain_Hit
	RandomSoundDrain
	bsTrough.AddBall me
End sub 

'**********************************
' 	F12 Menu For Cabinet
'**********************************
Dim RailChoice: RailChoice = True
'//////////////F12 Menu//////////////
' Called when options are tweaked by the player. 
' - 0: game has started, good time to load options and adjust accordingly
' - 1: an option has changed
' - 2: options have been reseted
' - 3: player closed the tweak UI, good time to update staticly prerendered parts
' Table1.Option arguments are: 
' - option name, minimum value, maximum value, step between valid values, default value, unit (0=None, 1=Percent), an optional arry of literal strings
Dim dspTriggered : dspTriggered = False
Sub Table1_OptionEvent(ByVal eventId)
	If eventId = 1 And Not dspTriggered Then dspTriggered = True : DisableStaticPreRendering = True : End If

    	RailChoice = Table1.Option("Side Walls", 0, 1, 1, 1, 0, Array("SideWall Art", "(Default)"))
	SetRails RailChoice
If eventId = 3 And dspTriggered Then dspTriggered = False : DisableStaticPreRendering = False : End If
	End Sub

	
Sub SetRails(Opt)
	Select Case Opt
		Case 0:
			'Ramp15.Visible = 0
			'Ramp16.Visible = 0
			PinCab_Blades.visible = 1
		Case 1:
			'Ramp15.Visible = 1
			'Ramp16.Visible = 1
			PinCab_Blades.visible = 0
	End Select
End Sub

'***********
' Update GI
'***********

Dim LastGi0:LastGi0 = 7
Dim LastGi1:LastGi1 = 7

Dim LastGiDir:LastGiDir = 0

' OPT8: Last-written image string per flipper primitive.
'       RealTimeUpdates only writes .image when the value actually changes.
'       During normal play the flipper is held steady for long periods —
'       this eliminates 3 unconditional COM .image writes/frame (~180/sec).
Dim LastFlipperLImg : LastFlipperLImg = ""
Dim LastFlipperRImg : LastFlipperRImg = ""
Dim LastFlipperR1Img : LastFlipperR1Img = ""

Sub UpdateGI(no, value)

	
	dim obj, GiDir
	Select Case no
		case 0:
				
				if value >= 7 Then 
					RG13_Plastics_Machine_GiOff.Visible=0
					TurnTable_giOFF.Visible=0
					RG_Bulbs_giOFF_Machine.Visible = 0
					RG4_giOFF_Machine.Visible = 0
					RG_Bulbs_Machine.visible = 1
					Fl001.IntensityScale = 1
					RearBulbsCard.image = "RearWall_GI8"
				    LastGi1 = value 

					LastGi0 = value
					'debug.print "GI: " & CStr(no) & " to " & CStr(value) & " lastgi0 " & LastGi0 & " lastgi1 " & LastGi1 & " LastGiDir = " & GiDir 

					LastGiDir = 0
				else	
					if value < LastGi0 then GiDir = -1 else GiDir = 1

					if LastGi0 >= 7 or LastGi0 <= 1 or ((LastGiDir = 0 or GiDir = LastGiDir) and abs(LastGi0 - value < 2) and value <> LastGi1) then  ' VPM output seems to be a little glitchy, throw out changes in the wrong direction if in the middle of a fade sequence
						RG13_Plastics_Machine_GiOff.Visible=1
						RG13_Plastics_Machine_GiOff.material = "GIShading_" & (value)
						TurnTable_giOFF.Visible=1
						TurnTable_giOFF.material = "GIShading_" & (value)
						RG_Bulbs_giOFF_Machine.Visible=1
						RG_Bulbs_giOFF_Machine.material = "GIShading_" & (value)
						if value <2 Then RG_Bulbs_Machine.Visible = 0 Else RG_Bulbs_Machine.visible = 1
						if GI_STATUS = 1 then 
							RG4_giOFF_Machine.Visible=1
							RG4_giOFF_Machine.material = "GIShading_" & (value)
						Else
							RG4_giOFF_Machine.Visible=0
						end if 
						Fl001.IntensityScale = (Value-1) / 7
						RearBulbsCard.image = "RearWall_GI" & (value)
						LastGi1 = LastGi0
						LastGi0 = value
						if LastGi0 < 2 or LastGi0 >= 6 then LastGiDir = 0 else LastGiDir = GiDir
						'debug.print "GI: " & CStr(no) & " to " & CStr(value) & " lastgi0 " & LastGi0 & " lastgi1 " & LastGi1 & " LastGiDir = " & GiDir 
					Else	
						'debug.print "RejectGI: " & CStr(no) & " to " & CStr(value) & "lastgi0 " & LastGi0
					end if
					
				end if 
				
	
			
		Case 2

			'Table1.ColorGradeImage = "LUT1_1_0" & (8-value)  '''''' GI Fading via LUT (removed)
			'PF_GiON_Flasher.IntensityScale = (value/8) '''''''''''''Additive GI playfield method (removed)


			'GiOFF Playfield fade up/down
			'if value <7 Then PF_GiOFF.Opacity = 100-(value*14.28) else PF_GiOFF.Opacity = 0 end If
			fl1.IntensityScale = (Value-1) / 7

if value <7 Then
	DOF 104, DOFOff
else
	DOF 104, DOFOn
end if

select case value
		case 0: 
			PF_GiOFF.Opacity = 100
			GI_STATUS=0
			'SpotlightBeam.image = "BulbAlpha_GI0"
			
		case 1:
			PF_GiOFF.Opacity = 100
			GI_STATUS=0
			'SpotlightBeam.image = "BulbAlpha_GI1"
			
		case 2: 
			PF_GiOFF.Opacity = 85
			GI_STATUS=1
			'SpotlightBeam.image = "BulbAlpha_GI2"
			
		case 3:
			PF_GiOFF.Opacity = 68
			GI_STATUS=1
			'SpotlightBeam.image = "BulbAlpha_GI3"

		case 4:
			PF_GiOFF.Opacity = 51
			GI_STATUS=1
			'SpotlightBeam.image = "BulbAlpha_GI4"
			
		case 5:
			PF_GiOFF.Opacity = 34
			GI_STATUS=1
			'SpotlightBeam.image = "BulbAlpha_GI5"
			
		case 6:
			PF_GiOFF.Opacity = 17
			GI_STATUS=1
			'SpotlightBeam.image = "BulbAlpha_GI6"
	
		case 7:
			PF_GiOFF.Opacity = 0
			GI_STATUS=1
			'SpotlightBeam.image = "BulbAlpha_GI7"
			
		case 8:
			PF_GiOFF.Opacity = 0
			GI_STATUS=1
			'SpotlightBeam.image = "BulbAlpha_GI8"
			

		end select 







if GiMethod = 2 then

			' This is the double prim method

			for each obj in GIOFF_Collection	
				obj.material = "GIShading_" & (value)
				if value >= 7 Then obj.Visible=0
				if value <7 Then obj.Visible=1
				if value <2 Then RG_Bulbs.Visible = 0 Else RG_Bulbs.visible = 1
			
			next

			for each obj in GION_DuplicateSet
				if value <2 Then obj.Visible=0 else obj.Visible=1
			next







			for each obj in GIOFF_MaterialShade	
				obj.material = "GIMATERIALShading" & (value)
			next

Elseif GiMethod = 1 then

			' This is the single prim method

			for each obj in GIOFF_Collection
				obj.Visible=0
			Next


			for each obj in GIOFF_SinglePrimMethod	
				obj.material = "GIMATERIALShading" & (value)
			next

End If


' For each lightobj in Lamps
	end select
End sub
             

'' Choose Side Blades 
'	if bladeArt = 1 then
'		PinCab_Blades.Image = "Sidewalls FS"
'		PinCab_Blades.visible = 1
'    elseif bladeArt = 2 then
'		PinCab_Blades.Image = "Sidewalls FS1"
'		PinCab_Blades.visible = 1
'    elseif bladeArt = 3 then
'		PinCab_Blades.Image = "Sidewalls FS2"
'		PinCab_Blades.visible = 1
'	elseif bladeArt = 0 then
'		PinCab_Blades.visible = 0
'	End if 




' *****  Drop targets with ball hop  *************

Dim HopLeftBall:HopLeftBall = Empty
Dim HopRightBall:HopRightBall = Empty

Sub SolLeftDrop(Enabled)
	dtLeftDrop.SolDropUp Enabled
	If Not IsEmpty(HopLeftBall) Then
 	   HopLeftBall.velZ = 2
          SlingHopTimer.Enabled = 1
	End If
End sub

Sub SolRightDrop(Enabled)
	dtRightDrop.SolDropUp Enabled
	If Not IsEmpty(HopRightBall) Then
 	   HopRightBall.velZ = 2
	SlingHopTimer.Enabled = 1
	End If
End sub

Sub TargetResetHopLeft_Hit
	Set HopLeftBall = ActiveBall
End Sub

Sub TargetResetHopLeft_UnHit
    HopLeftBall = Empty
End Sub

Sub TargetResetHopRight_Hit
	Set HopRightBall = ActiveBall
End Sub

Sub TargetResetHopRight_UnHit
    HopRightBall = Empty
End Sub


' *** Nudge 

Dim mMagnet, cBall

Sub WobbleMagnet_Init
	 Set mMagnet = new cvpmMagnet
	 With mMagnet
		.InitMagnet WobbleMagnet, 1
		.Size = 100
		.CreateEvents mMagnet
		.MagnetOn = True
		.GrabCenter = False
	 End With
	Set cBall = ckicker.CreateBall
'	Set cBall = ckicker.CreateSizedBallWithMass(25, 1)
	ckicker.Kick 0,0:mMagnet.addball cball
End Sub


Sub ShakeTimer_Timer
	dim NudgeAmount:NudgeAmount = cball.y - ckicker.y
	if abs(NudgeAmount) > .3 then
		cball.x = ckicker.x
		cball.y = ckicker.y 
		cball.velx = 0
		cball.vely = 0
		NudgePins(NudgeAmount)
		if abs(NudgeAmount) > 4 then HTBronto.Start
	end if 	
	UpdatePins
End Sub

Dim PinAngleMax:PinAngleMax = 30
Dim PinAngleMin:PinAngleMin = -30
Dim PinAngle(5)
Dim PinSpeed(5)
Dim PinObjs:PinObjs = Array(BPin1, BPin2, BPin3, BPin4, BPin5)
Dim PinDamping:PinDamping = 0.985
Dim PinGravity:PinGravity = 1
InitPins

Sub InitPins
	dim i 
	for i=0 to 4
		PinAngle(i) = 0
		PinSpeed(i) = 0
	Next
end sub 

Sub UpdatePins
	dim i
	for i=0 to 4
		UpdatePin(i)
	Next
End Sub 

Sub NudgePins(NudgeAmount)
	dim i 
	for i=0 to 4
		PinSpeed(i) = PinSpeed(i) + (NudgeAmount + (-.5 + rnd(1)))  
	Next
End Sub

Sub UpdatePin(n)
	if abs(PinSpeed(n)) <> 0.0 Then
		PinSpeed(n) = PinSpeed(n) - sin(PinAngle(n) * 3.14159 / 180) * PinGravity
		PinSpeed(n) = PinSpeed(n) * PinDamping
	end if
	PinAngle(n) = PinAngle(n) + PinSpeed(n)
	if PinAngle(n) > PinAngleMax Then
		PinAngle(n) = PinAngleMax
		PinSpeed(n) = -PinSpeed(n)
		PinSpeed(n) = PinSpeed(n) * PinDamping * 0.8
	elseif PinAngle(n) < PinAngleMin Then
		PinAngle(n) = PinAngleMin
		PinSpeed(n) = -PinSpeed(n)
		PinSpeed(n) = PinSpeed(n) * PinDamping * 0.8
	end if
	'debug.print PinSpeed & "  " & PinAngle
	'BowlingPin1.ObjRotX = (cball.y - ckicker.y)*2
	PinObjs(n).ObjRotX = PinAngle(n)
'	PinAngle = PinAngle + PinVel
'	if abs(PinAngle) > PinMax then PinVel = -PinVel
End Sub

Sub BPTrigger_Hit
	RandomSoundFlipper
    NudgePins(10)
End Sub


Dim GIInit: GIInit=10 * 4

Sub PreloadImages
	If PreloadMe = 1 and GIInit > 0 Then
		GIInit = GIInit -1
		select case (GIInit \ 4) ' Divide by 4, this is not a frame timer, so we want to be sure frame is visible 
		case 0:
				FlipperL.image="leftflipper_giON_BLK"
				FlipperR.image="rightflipper_giON_BLK"
				FlipperR1.image="rightUPPERflipper_giON_BLK"

		case 1:
				FlipperL.image="leftflipper_giOFF_BLK"
				FlipperR.image="rightflipperUP_giOFF_BLK"
				FlipperR1.image="rightUPPERflipperUP_giOFF_BLK"
		case 2:
				FlipperL.image="leftflipperUP_giON_BLK"
				FlipperR.image="rightflipper_giOFF_BLK"
				FlipperR1.image="rightUPPERflipper_giOFF_BLK"
		case 3:
				FlipperL.image="leftflipperUP_giOFF_BLK"
				FlipperR.image="rightflipperUP_giON_BLK"
				FlipperR1.image="rightUPPERflipperUP_giON_BLK"
		end select 
	End If
End Sub 


Set MotorCallback = GetRef("RealTimeUpdates")

Sub RealTimeUpdates

	Dim chgLamp, num, chg, ii
	chgLamp = Controller.ChangedLamps
	If Not IsEmpty(chgLamp) Then
		For ii = 0 To UBound(chgLamp)
			 SetLamp ChgLamp(ii,0), ChgLamp(ii,1)
		Next
	End If
	FadeLights.Update
	UpdateTheMachine
	PreloadImages

	' OPT3: Cache all three flipper CurrentAngle COM reads into locals once.
	'       Each angle was previously read up to 3x per frame (image branch,
	'       RotZ sync, shadow RotZ). 9 redundant COM reads/frame (~540/sec).
	Dim lfAngle, rfAngle, rf1Angle
	lfAngle  = LeftFlipper.CurrentAngle
	rfAngle  = RightFlipper.CurrentAngle
	rf1Angle = RightFlipper1.CurrentAngle

	' OPT8: Compute desired image into a local, write to COM only if changed.
	'       Eliminates up to 3 .image COM writes/frame when flippers are steady.
	'       String comparison (cheap) replaces unconditional COM write (expensive).
	Dim newImgL, newImgR, newImgR1
	If GI_STATUS = 0 Then
		If lfAngle < 80 Then
			newImgL = "leftflipperUp_giOff_BLK"
		Else
			newImgL = "leftflipper_giOFF_BLK"
		End If
		If rfAngle < -80 Then
			newImgR = "rightflipper_giOFF_BLK"
		Else
			newImgR = "rightflipperUP_giOFF_BLK"
		End If
		If rf1Angle < -125 Then
			newImgR1 = "rightUPPERflipper_giOFF_BLK"
		Else
			newImgR1 = "rightUPPERflipperUp_giOFF_BLK"
		End If
	ElseIf GI_STATUS = 1 Then
		If lfAngle < 80 Then
			newImgL = "leftflipperUP_giON_BLK"
		Else
			newImgL = "leftflipper_giON_BLK"
		End If
		If rfAngle < -80 Then
			newImgR = "rightflipper_giON_BLK"
		Else
			newImgR = "rightflipperUP_giON_BLK"
		End If
		If rf1Angle < -125 Then
			newImgR1 = "rightUPPERFlipper_giON_BLK"
		Else
			newImgR1 = "rightUPPERflipperUP_giON_BLK"
		End If
	End If
	If newImgL  <> LastFlipperLImg  Then FlipperL.image  = newImgL  : LastFlipperLImg  = newImgL
	If newImgR  <> LastFlipperRImg  Then FlipperR.image  = newImgR  : LastFlipperRImg  = newImgR
	If newImgR1 <> LastFlipperR1Img Then FlipperR1.image = newImgR1 : LastFlipperR1Img = newImgR1

	WireGate.rotx= 0- Sw38.Currentangle / 1
	WireGate2.rotx= 0 - Gate5.Currentangle / 1
	GateFlapLeft.roty= 0- Gate4.Currentangle / 1
	GateFlapRight.roty= 150 - Gate2.Currentangle / -1

	flipperL.RotZ = lfAngle
	flipperR.RotZ = rfAngle
	flipperR1.RotZ = rf1Angle

	if BallShadowOn = 1 then BallShadowUpdate

	If FlipperShadows = 1 Then
		FlipperShadowL.RotZ = lfAngle
		FlipperShadowR.RotZ = rfAngle
		FlipperShadowR1.RotZ = rf1Angle
	End If

	' OPT2: OutlaneDifficulty Collidable block removed from here.
	'       OutlaneDifficulty is a Const — these values never change at runtime.
	'       Previously wrote .Collidable to 6 wall objects every frame (~360
	'       redundant COM writes/sec at 60Hz). Moved to Table1_Init.

End Sub

 SolCallback(1) = "SolRelease"
 SolCallback(2) = "vpmSolAutoPlungeS AutoPlunger, SoundFX(SSolenoidOn, DOFContactors), 8,"
 SolCallback(3) = "SolTopDiverter"
 SolCallback(4) = "bsKicker36.SolOut"
 SolCallback(5) = "SolLeftDrop" 
 SolCallback(6) = "SolRightDrop"
 SolCallback(7) = "vpmSolSound SoundFX(""Knocker"",DOFKnocker),"
 SolCallback(8) = "SolBrontoDiverter"
 SolCallback(9) = "sRightSlingshot"
 SolCallback(10) = "sLeftSlingshot"
 SolCallback(14) = "SetLamp 114," 
 SolCallBack(15) = "SolLeftApronDiverter"
 SolCallback(16) = "SolRightApronDiverter"
 SolModCallback(17) = "FadeLights.LampMod 117,"
 SolModCallback(18) = "FadeLights.LampMod 118,"
 SolModCallback(19) = "FadeLights.LampMod 119,"
 SolModCallBack(20) = "FadeLights.LampMod 120,"
 SolModCallback(21) = "FadeLights.LampMod 121,"
 SolModCallback(22) = "FadeLights.LampMod 122," 
 SolCallback(23) = "SolMachine"
 SolModCallback(24) = "FadeLights.LampMod 124,"
 SolModCallback(25) = "FadeLights.LampMod 125,"
 SolCallback(26) = ""
 SolCallback(27) = ""
 SolModCallBack(28) =  "Flasher28" 
 SolCallback(35) = "SolGateRGate" '"vpmSolGate RGate,false,"
 SolCallback(36) = "SolGateLGate" '"vpmSolGate LGate,false,"
 SolCallback(sLRFlipper) = "SolRFlipper"
 SolCallback(sLLFlipper) = "SolLFlipper"

Sub  Flasher28(Intensity)
	FadeLights.LampMod 128,(Intensity / 5)
	RG5_PlasticsFlasher.BlendDisableLighting = Intensity / 255
	RG13_PlasticsFlasher.BlendDisableLighting = Intensity / 255
	if Intensity = 0 Then
		RG5_PlasticsFlasher.visible = false
		RG13_PlasticsFlasher.visible = False
	Fl002.State=0
	Fl003.State=0
	Fl004.State=0
	Else	
		RG5_PlasticsFlasher.visible = true
		RG13_PlasticsFlasher.visible = true
	
		RG5_PlasticsFlasher.material = "GIShading_" & ((255-Intensity) * 6 \ 255)
		RG13_PlasticsFlasher.material = "GIShading_" & ((255 - Intensity)  * 6 \ 255)
	Fl002.State=1
	Fl003.State=1
	Fl004.State=1
	end if 
'	if Enabled Then
'		RG5_Plastics.image = "Flasher28FredsChoiceB"
'		RG13_Plastics.image = "Flasher28FredsChoiceAC"
'	else
'		RG5_Plastics.image = "RG_15_plastics_giON_AXS"
'		RG13_Plastics.image = "RG_13_giON"
'	end if
end sub



' ************************************************
' The Machine
' ************************************************

dim MachineSpeedMax:MachineSpeedMax = 20.0
dim MachineSpeedCur:MachineSpeedCur = 0	
dim MachineRamp:MachineRamp = .5
dim MachinePos:MachinePos = 0 

Sub SolMachine(Enabled)
     If Enabled Then
         ttMachine.MotorOn = 1
     Else
         ttMachine.MotorOn = 0
     End If
End Sub

Sub UpdateTheMachine
	if ttMachine.MotorOn = 1 Then
		if MachineSpeedCur < MachineSpeedMax then MachineSpeedCur = MachineSpeedCur + MachineRamp
		if MachineSpeedCur > MachineSpeedMax then MachineSpeedCur = MachineSpeedMax
	Else
		if MachineSpeedCur > 0 then 
			MachineSpeedCur = MachineSpeedCur - MachineRamp
			if MachineSpeedCur <= 0 then 
				MachineSpeedCur = 0
				StopSound "machine"
			end if
		end if
	end if 
	
	' This is a bit of a dirty trick to help keep the balls spinning in the machine longer.   Blocks the exit at certain angles.
	if MachinePos < 90 and ttMachine.MotorOn then 
		MachineLock.Collidable = true
	Else		
		MachineLock.Collidable = False
	end if 
	if MachineSpeedCur > 0 then 
		PlaySound SoundFX("machine", DOFGear), -1, MachineSpeedCur / MachineSpeedMax / 400, AudioPan(ttMachineTrigger), 0, MachineSpeedCur * 100000/ MachineSpeedMax, 1, 0, AudioFade(ttMachineTrigger)
		MachinePos = MachinePos - MachineSpeedCur
		if MachinePos < 0 then MachinePos = MachinePos + 360

		TurnTable.rotz = MachinePos
		TurnTable_giOFF.rotz = MachinePos
		'TurnTableNut.rotz = MachinePos 'AXS
		' OPT5: Int(MachinePos/2.5) was computed 3x and the padded frame string
		'       built twice per frame while spinning (~180 redundant ops/sec).
		'       Now computed once each.
		Dim x, machFrameStr
		x = Int(MachinePos / 2.5)
		machFrameStr = Right("00" & CStr(x), 3)
		TurnTable.image       = "Turntable_giON_"  & machFrameStr
		TurnTable_giOFF.image = "Turntable_giOFF_" & machFrameStr
		if x < 0 or x > 143 then debug.print "X out of range " & CStr(x) & " for degree " & MachinePos
	end if 
End Sub

' ************************************************
' Dictabird
' ************************************************

Sub UpdateDictabird(Value)
	Dictabird.objrotx = -7 + (-Value) * 9 
End Sub


Sub SolBrontoDiverter(Enabled)
	if Enabled Then
		BrontoDiverter.RotateToEnd'BrontoDiverter.RotateToStart'
		Diverter.TransX = -40
	Else
		BrontoDiverter.RotateToStart'BrontoDiverter.RotateToEnd'
		Diverter.TransX = 0
	end if 
End Sub

Sub SolLeftApronDiverter(Enabled)
 If Enabled Then
	 'LeftApronGate.RotatetoStart
         DiverterLeft.TransZ  = -40
	 DiverterLeft.Collidable = 0
         PlaySoundAt SoundFX("DiverterLeftUp", DOFContactors), DiverterLeft
 Else
	 'LeftApronGate.RotatetoEnd
	 DiverterLeft.TransZ = -20
	 DiverterLeft.Collidable = 1	
	 'Playsound "DiverterLeftDown"
         LDTimer.Enabled = 1
 End If
End Sub

Sub SolRightApronDiverter(Enabled)
	If Enabled Then
		'RightApronGate.RotatetoStart
                DiverterRight.TransZ = -40
		DiverterRight.Collidable = 0
		PlaySoundAt SoundFX("DiverterRightUp", DOFContactors), DiverterRight
	Else
		'RightApronGate.RotatetoEnd
                DiverterRight.TransZ = -20
		DiverterRight.Collidable = 1
		'Playsound "DiverterRightDown"
		RDtimer.Enabled = 1
	End If
End Sub

Sub SolGateLGate(Enabled) 'AXS
	If Enabled Then
		Gate4.Collidable = False
	Else
		Gate4.Collidable = True
	End If
End Sub

Sub SolGateRGate(Enabled) 'AXS
	If Enabled Then
		Gate2.Collidable = False
	Else
		Gate2.Collidable = True
	End If
End Sub

Sub SolTopDiverter(Enabled) 'AXS
	If Enabled Then
		DiverterPost.Collidable = True
	Else
		DiverterPost.Collidable = False
	End If
End Sub

Sub LDTimer_Timer 'AXS
	DiverterLeft.TransZ  = 0
	'DiverterRight.TransZ  = 0
	PlaySoundAt SoundFX("DiverterLeftDown", DOFContactors), DiverterLeft
    LDTimer.Enabled = 0
End Sub

Sub RDTimer_Timer 'AXS
	'DiverterLeft.TransZ  = 0
	DiverterRight.TransZ  = 0
	PlaySoundAt SoundFX("DiverterRightDown", DOFContactors), DiverterRight
    RDTimer.Enabled = 0
End Sub

'************************************************** AXS AutoFlip (Testing)
'Sub TriggerAutoFlipLeft_Hit 'Axs
'if autoflip=1 Then
'                LeftFlipper.RotateToEnd
'		PlaySound SoundFX("FlipperUpLeft",DOFFlippers), 0, .67, AudioPan(LeftFlipper), 0.05,0,0,1,AudioFade(LeftFlipper)
'                TimerLeftFlipper.Enabled=1
'end if
'End Sub
'
'Sub TimerLeftFlipper_Timer
'		LeftFlipper.RotateToStart
'		TimerLeftFlipper.Enabled=0
'		PlaySound SoundFX("FlipperDown",DOFFlippers), 0, 1, AudioPan(LeftFlipper), 0.05,0,0,1,AudioFade(LeftFlipper)
'End Sub
'
'Sub TriggerAutoFlipRight_Hit 
'if autoflip=1 Then
'		PlaySound SoundFX("Flipper(s)UpRight",DOFFlippers), 0, .67, AudioPan(RightFlipper), 0.05,0,0,1,AudioFade(RightFlipper)
'                RightFlipper.RotateToEnd
'                TimerRightFlipper.Enabled=1
'end if
'End Sub
'
'Sub TimerRightFlipper_Timer
'		RightFlipper.RotateToStart
'		TimerRightFlipper.Enabled=0
'		PlaySound SoundFX("FlipperDown",DOFFlippers), 0, 1, AudioPan(RightFlipper), 0.05,0,0,1,AudioFade(RightFlipper)
'End Sub
'
'Sub TriggerAutoFlipRight1_Hit 
'if autoflip=1 Then
'		PlaySound SoundFX("Flipper(s)UpRight",DOFFlippers), 0, .67, AudioPan(RightFlipper), 0.05,0,0,1,AudioFade(RightFlipper)
'                RightFlipper1.RotateToEnd
'                TimerRightFlipper1.Enabled=1
'end if
'End Sub
'
'Sub TimerRightFlipper1_Timer
'		RightFlipper1.RotateToStart
'		TimerRightFlipper1.Enabled=0
'		PlaySound SoundFX("FlipperDown",DOFFlippers), 0, 1, AudioPan(RightFlipper), 0.05,0,0,1,AudioFade(RightFlipper)
'End Sub

'**************************************************

Sub SolLFlipper(Enabled)
    If Enabled Then
		'LeftFlipper.RotateToEnd
        FlipperActivate LeftFlipper, LFPress
        LF.Fire
		PlaySound SoundFX("FlipperUpLeft",DOFFlippers), 0, .67, AudioPan(LT41d), 0.05,0,0,1,AudioFade(LeftFlipper)
	Else
        FlipperDeActivate LeftFlipper, LFPress
		LeftFlipper.RotateToStart
		PlaySound SoundFX("FlipperDown",DOFFlippers), 0, 1, AudioPan(LT41d), 0.05,0,0,1,AudioFade(LeftFlipper)
	End If
End Sub

Sub SolRFlipper(Enabled)
	If Enabled Then
        FlipperActivate RightFlipper, RFPress
        FlipperActivate RightFlipper1, RFPress1
        RF.Fire
		'RightFlipper.RotateToEnd
		RightFlipper1.RotateToEnd
		PlaySound SoundFX("Flipper(s)UpRight",DOFFlippers), 0, .67, AudioPan(LT41c), 0.05,0,0,1,AudioFade(RightFlipper)
	Else
        FlipperDeActivate RightFlipper, RFPress
        FlipperDeActivate RightFlipper1, RFPress1
		RightFlipper.RotateToStart
		RightFlipper1.RotateToStart
		PlaySound SoundFX("FlipperDown",DOFFlippers), 0, 1, AudioPan(LT41c), 0.05,0,0,1,AudioFade(RightFlipper)
	End If
End Sub



Sub Table1_KeyDown(ByVal Keycode)
    If keycode = RightMagnaSave Then
		if DisableLUTSelector = 0 then
			LUTmeUP = LUTMeUp + 1
			if LutMeUp > MaxLut then LUTmeUP = 0
			SetLUT
			ShowLUT
		end if
	end if
	If keycode = LeftMagnaSave Then
          if DisableLUTSelector = 0 then
			LUTmeUP = LUTMeUp - 1
			if LutMeUp < 0 then LUTmeUP = MaxLut
			SetLUT
			ShowLUT
		end if
	end if
    If keycode = PlungerKey Then Controller.Switch(11) = 1
    If keycode = keyFront Then Controller.Switch(23) = 1
	If keycode = LeftTiltKey Then
		Nudge 90, 2
    
	End If

	If keycode = RightTiltKey Then
		Nudge 270, 2
	End If

	If keycode = CenterTiltKey Then
		Nudge 0, 2
	End If

    'If keycode = 31 then autoflip = 1 - autoflip: playsound "button-click" 'AXS
'Msgbox Keycode
	If vpmKeyDown(keycode) Then Exit Sub
End Sub
 
Sub table1_KeyUp(ByVal Keycode)
	If vpmKeyUp(keycode) Then Exit Sub
	If keycode = PlungerKey Then Controller.Switch(11) = 0
	If keycode = keyFront Then Controller.Switch(23) = 0
    
End Sub


Sub SolRelease(Enabled)
	If Enabled And bsTrough.Balls > 0 Then
		vpmTimer.PulseSw 31
		bsTrough.ExitSol_On
	End If
End Sub

' ************************************************
' Slingshots 
' ************************************************

Dim RStep, Lstep

Sub RightSlingShot_Slingshot()
	vpmTimer.PulseSW 62
End Sub

Sub LeftSlingShot_Slingshot()
	vpmTimer.PulseSW 61
End Sub


Sub sRightSlingShot(enabled)
	If enabled Then
    PlaySound SoundFX("slingshotRight", DOFContactors), 0, 1, 0.05, 0.05
    'RSling.Visible = 0
    RSling1.Visible = 1
    'sling1.TransZ = -20
    RStep = 0
    RightSlingShot.TimerEnabled = 1
	End If
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 3:RSLing1.Visible = 0:RSLing2.Visible = 1:SlingArmR.TransZ = -10
        Case 4:RSLing2.Visible = 0:RSling1.Visible = 0:SlingArmR.TransZ = 0:RightSlingShot.TimerEnabled = 0
    End Select
    RStep = RStep + 1
End Sub

Sub sLeftSlingShot(enabled)
	If enabled Then
    PlaySound SoundFX("slingshotLeft", DOFContactors),0,1,-0.05,0.05
    'LSling.Visible = 0
    LSling1.Visible = 1
    'sling2.TransZ = -20
    LStep = 0
    LeftSlingShot.TimerEnabled = 1
	End If
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 3:LSLing1.Visible = 0:LSLing2.Visible = 1:SlingArmL.TransZ = -10
        Case 4:LSLing2.Visible = 0:SlingArmL.TransZ = 0:LeftSlingShot.TimerEnabled = 0
    End Select
    LStep = LStep + 1
End Sub

Sub SlingHopL_Hit
     'Msgbox Activeball.velx'Msgbox "left Hit"
     If Activeball.velX < -7 Then
		'Msgbox Activeball.velx
		SlingHopTimer.Enabled = 1
		Activeball.velZ = 2
	End If  
End Sub 

Sub SlingHopR_Hit
     'Msgbox Activeball.velx'Msgbox "Right hit"
	If Activeball.velX > 7 Then
		'Msgbox Activeball.velx
		SlingHopTimer.Enabled = 1
		Activeball.velZ = 2
	End If 
End Sub 

Sub SlingHopTimer_Timer
     Playsound "ball_bounce",0,.05,0,.1
     SlingHopTimer.Enabled = 0
End Sub


' ************************************************
' HitTarget and Bronto Crane animation 
' ************************************************



Class HTAnim
	Dim HTPrimObj, HTSwitchObj, HTOsc, HTOscIncrement, HTDist, HTSwitchNum
	Dim HTDistMax, HTStartOscDeg, HTDecay, HTOscInitialIncrement, HTTimerInterval, HTOscRampIncrement
	Dim HTAxis
	
	public default function Init(primobj, switchobj, switchnum)
		set HTPrimObj = primobj
		set HTSwitchObj = switchobj
		HTTimerInterval = 8
		HTSwitchObj.TimerEnabled = 0
		HTSwitchNum = switchnum
		HTDistMax = 6
		HTStartOscDeg = 0
		HTDecay = 0.6
		HTOscInitialIncrement = .474
		HTOscRampIncrement = .013
		
		set Init = Me
	end function

	sub SetAxis(axis)
		HTAxis = axis
	end sub

	sub Start
		HTOsc = HTStartOscDeg
	    HTDist = HTDistMax
		HTOscIncrement = HTOscInitialIncrement
		HTSwitchObj.TimerInterval = HTTimerInterval 
		HTSwitchObj.TimerEnabled = 1
		vpmTimer.PulseSw HTSwitchNum
	end sub 
	
	sub Update
		select case HTAxis
		case "Y+"
			HTPrimObj.RotY = HTDist * cos(HTOsc)
		case "Y-"
			HTPrimObj.RotY = -HTDist * cos(HTOsc)
		case else
			HTPrimObj.RotX = 180 + HTDist * cos(HTOsc)
		end select
		if HTDist > 0 Then
			HTDist = HTDist - HTDecay
			HTOsc = HTOsc + HTOscIncrement
			HTOscIncrement = HTOscIncrement + HTOscRampIncrement
			if HTOsc > 6.28 then HTOsc = HTOsc - 6.28
		Else
			HTSwitchObj.TimerEnabled = 0
		end if
	end sub 
End Class

Dim HTAnim26:Set HTAnim26 = (new HTAnim)(Rg9_T26, Sw26, 26)

Sub sw26_Hit:	HTAnim26.Start: PlaySoundAtBallVol SoundFX("target", DOFTargets): End Sub
Sub sw26_Timer:	HTAnim26.Update:End Sub

Dim HTAnim51a:Set HTAnim51a = (new HTAnim)(Rg9_T51a, Sw51a, 51):HTAnim51a.SetAxis("Y+")

Sub sw51a_Hit:	 HTAnim51a.Start: PlaySoundAtBallVol SoundFXDOF("target",101,DOFPulse,DOFTargets): End Sub
Sub sw51a_Timer: HTAnim51a.Update:End Sub

Dim HTAnim51b:Set HTAnim51b = (new HTAnim)(Rg9_T51b, Sw51b, 51):HTAnim51b.SetAxis("Y-")

Sub sw51b_Hit:	 HTAnim51b.Start: PlaySoundAtBallVol SoundFXDOF("target",102,DOFPulse,DOFTargets): End Sub
Sub sw51b_Timer: HTAnim51b.Update:End Sub

Dim HTAnim52a:Set HTAnim52a = (new HTAnim)(Rg9_T52a, Sw52a, 52):HTAnim52a.SetAxis("Y+")

Sub sw52a_Hit:	 HTAnim52a.Start: PlaySoundAtBallVol SoundFXDOF("target",101,DOFPulse,DOFTargets): End Sub
Sub sw52a_Timer: HTAnim52a.Update:End Sub

Dim HTAnim52b:Set HTAnim52b = (new HTAnim)(Rg9_T52b, Sw52b, 52):HTAnim52b.SetAxis("Y-")

Sub sw52b_Hit:	 HTAnim52b.Start: PlaySoundAtBallVol SoundFXDOF("target",102,DOFPulse,DOFTargets): End Sub
Sub sw52b_Timer: HTAnim52b.Update:End Sub

Dim HTAnim53a:Set HTAnim53a = (new HTAnim)(Rg9_T53a, Sw53a, 53):HTAnim53a.SetAxis("Y+")

Sub sw53a_Hit:	 HTAnim53a.Start: PlaySoundAtBallVol SoundFXDOF("target",101,DOFPulse,DOFTargets): End Sub
Sub sw53a_Timer: HTAnim53a.Update:End Sub

Dim HTAnim53b:Set HTAnim53b = (new HTAnim)(Rg9_T53b, Sw53b, 53):HTAnim53b.SetAxis("Y-")

Sub sw53b_Hit:	 HTAnim53b.Start: PlaySoundAtBallVol SoundFXDOF("target",102,DOFPulse,DOFTargets):End Sub
Sub sw53b_Timer: HTAnim53b.Update:End Sub

Dim HTAnim54:Set HTAnim54 = (new HTAnim)(Rg9_T54, Sw54, 54)

Sub sw54_Hit:	HTAnim54.Start: PlaySoundAtBallVol SoundFX("target", DOFTargets):End Sub
Sub sw54_Timer:	HTAnim54.Update:End Sub

Dim HTAnim55:Set HTAnim55 = (new HTAnim)(Rg9_T55, Sw55, 55)

Sub sw55_Hit:	HTAnim55.Start: PlaySoundAtBallVol SoundFX("target", DOFTargets):End Sub
Sub sw55_Timer:	HTAnim55.Update:End Sub

Dim HTAnim56:Set HTAnim56 = (new HTAnim)(Rg9_T56, Sw56, 56)

Sub sw56_Hit:	HTAnim56.Start: PlaySoundAtBallVol SoundFX("target", DOFTargets):End Sub
Sub sw56_Timer:	HTAnim56.Update:End Sub

Dim HTBronto:Set HTBronto = (new HTAnim)(BrontoCrane, BrontoTrigger1, 200):HTBronto.HTDistMax = .75:HTBronto.HTDecay = 0.01:HTBronto.HTOscInitialIncrement = .05:HTBronto.HTStartOscDeg = 2.14

Sub BrontoTrigger1_Hit: HTBronto.Start: DOF 103, DOFOn: End Sub
Sub BrontoTrigger2_Hit: HTBronto.Start: DOF 103, DOFOn: BrontoTrigger2.TimerInterval = 100:BrontoTrigger2.TimerEnabled = 1:End Sub

Sub BrontoTrigger1_Timer 
	HTBronto.Update
	if BrontoTrigger1.TimerEnabled = 0 then DOF 103, DOFOff
End Sub

Sub BrontoTrigger2_Timer: 
	PlaySound "ball_bounce", 1, .1, AudioPan(BrontoTrigger2), 0,0,0, 1, AudioFade(BrontoTrigger2)'PlaySoundAt "ball_bounce", BrontoTrigger2 
	BrontoTrigger2.TimerEnabled = 0
End Sub

' ************************************************
' Pop bumpers
' ************************************************


Sub Sw63_Hit:vpmTimer.PulseSw 63:PlaySoundAtBall SoundFX("BumperTop_Hit", DOFContactors):End Sub
Sub Sw64_Hit:vpmTimer.PulseSw 64:PlaySoundAtBall SoundFX("BumperRight_Hit", DOFContactors):End Sub
Sub Sw65_Hit:vpmTimer.PulseSw 65:PlaySoundAtBall SoundFX("BumperLeft_Hit", DOFContactors):End Sub


' ************************************************
' Drop targets 
' ************************************************

'Sub Sw41_Hit:vpmTimer.PulseSw 41:PlaySoundAtBallVol "target":End Sub
'Sub Sw42_Hit:vpmTimer.PulseSw 42:PlaySoundAtBallVol "target":End Sub
'Sub Sw43_Hit:vpmTimer.PulseSw 43:PlaySoundAtBallVol "target":End Sub
'Sub Sw44_Hit:vpmTimer.PulseSw 44:PlaySoundAtBallVol "target":End Sub
'Sub Sw45_Hit:vpmTimer.PulseSw 45:PlaySoundAtBallVol "target":End Sub
'Sub Sw46_Hit:vpmTimer.PulseSw 46:PlaySoundAtBallVol "target":End Sub
'Sub Sw47_Hit:vpmTimer.PulseSw 47:PlaySoundAtBallVol "target":End Sub

' ************************************************
' Other switches 
' ************************************************

Sub sw15_Hit:Controller.Switch(15) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw15_Unhit:Controller.Switch(15) = 0:End Sub

Sub sw16_Hit:vpmTimer.PulseSw 16:PlaySoundAtBallVol "sensor":End Sub
'Sub sw16_Unhit:Controller.Switch(16) = 0:End Sub

Sub sw17_Hit:vpmTimer.PulseSw 17:PlaySoundAtBallVol "sensor":End Sub
'Sub sw17_Unhit:Controller.Switch(17) = 0:End Sub

Sub sw18_Hit:vpmTimer.PulseSw 18:PlaySoundAtBallVol "sensor":End Sub
'Sub sw18_Unhit:Controller.Switch(18) = 0:End Sub

Sub sw25_Hit:Controller.Switch(25) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw25_Unhit:Controller.Switch(25) = 0:End Sub


Sub sw48_Hit:Controller.Switch(48) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw48_UnHit:Controller.Switch(48) = 0:End Sub

Sub sw27_Hit:Controller.Switch(27) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw27_UnHit:Controller.Switch(27) = 0:End Sub


Sub sw28_Hit:Controller.Switch(28) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw28_UnHit:Controller.Switch(28) = 0:End Sub

Sub sw37_Hit:vpmTimer.PulseSw 37:PlaySoundAtBallVol "gate":End Sub

Sub sw38_Hit:vpmTimer.PulseSw 38:PlaySoundAtBallVol "gate":End Sub

Sub sw75_Hit:vpmTimer.PulseSw 75:PlaySoundAtBallVol "sensor":End Sub

Sub sw66_Hit:Controller.Switch(66) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw66_UnHit:Controller.Switch(66) = 0:End Sub

Sub sw67_Hit:Controller.Switch(67) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw67_UnHit:Controller.Switch(67) = 0:End Sub

Sub sw68_Hit:Controller.Switch(68) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw68_UnHit:Controller.Switch(68) = 0:End Sub

Sub sw71_Hit:Controller.Switch(71) = 1:PlaySoundAt "sensor", Sw71:End Sub
Sub sw71_UnHit:Controller.Switch(71) = 0:End Sub

Sub sw72_Hit:Controller.Switch(72) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw72_UnHit:Controller.Switch(72) = 0:End Sub

Sub sw73_Hit:Controller.Switch(73) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw73_UnHit:Controller.Switch(73) = 0:End Sub

Sub sw74_Hit:Controller.Switch(74) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw74_UnHit:Controller.Switch(74) = 0:End Sub

Sub sw76_Hit:Controller.Switch(76) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw76_Unhit:Controller.Switch(76) = 0:End Sub

Sub sw77_Hit:Controller.Switch(77) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw77_Unhit:Controller.Switch(77) = 0:End Sub

Sub sw78_Hit:Controller.Switch(78) = 1:PlaySoundAtBallVol "sensor":End Sub
Sub sw78_Unhit:Controller.Switch(78) = 0:End Sub



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

Sub PlaySoundAtBallVol(soundname)
	PlaySound soundname, 1, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub PlaySoundAtBall(soundname)
    PlaySoundAt soundname, ActiveBall
End Sub

Sub TriggerBallBounce1_UnHit:PlaySound "ball_bounce",0,.08,-0.05,.1:End Sub 'AXS
Sub TriggerBallBounce2_UnHit:PlaySound "ball_bounce" ,0, .08,0.05,.1:End Sub
Sub TriggerBallBounce3_UnHit:PlaySound "ball_bounce",0,.06,-0.05,.1:End Sub
Sub TriggerBallBounce4_UnHit:PlaySound "ball_bounce" ,0, .06,0.05,.1:End Sub

Sub LRHit1_Hit() : PlaySound "fx_lr1",0,.02,-0.05,.1: End Sub 'AXS
Sub LRHit2_Hit() : PlaySound "fx_lr2",0,.02,-0.05,.1: End Sub
Sub LRHit3_Hit() : PlaySound "fx_lr3",0,.02,-0.05,.1: End Sub
Sub LRHit4_Hit() : PlaySound "fx_lr4",0, .02,0.05,.1 : End Sub
Sub LRHit5_Hit() : PlaySound "fx_lr5",0, .02,0.05,.1: End Sub
Sub LRHit6_Hit() : PlaySound "fx_lr6",0, .02,0.05,.1: End Sub
Sub LRHit7_Hit() : PlaySound "fx_lr7",0,.01,-0.05,.1 : End Sub

'*********************************************************************
'                     Supporting Ball & Sound Functions
'*********************************************************************

Function AudioFade(tableobj) ' OPT11+OPT12: cached table height, multiplication chain replaces ^10
	Dim tmp
    tmp = tableobj.y * 2 / BS_TableHeight-1
    If tmp > 0 Then
		Dim tf2,tf4,tf8 : tf2=tmp*tmp : tf4=tf2*tf2 : tf8=tf4*tf4
		AudioFade = Csng(tf8 * tf2)
    Else
        Dim ntf, nf2,nf4,nf8 : ntf=-tmp : nf2=ntf*ntf : nf4=nf2*nf2 : nf8=nf4*nf4
        AudioFade = Csng(-(nf8 * nf2))
    End If
End Function

Function AudioPan(tableobj) ' OPT11+OPT12: cached table width, multiplication chain replaces ^10
    Dim tmp
    tmp = tableobj.x * 2 / BS_TableWidth-1
    If tmp > 0 Then
        Dim tp2,tp4,tp8 : tp2=tmp*tmp : tp4=tp2*tp2 : tp8=tp4*tp4
        AudioPan = Csng(tp8 * tp2)
    Else
        Dim ntp, np2,np4,np8 : ntp=-tmp : np2=ntp*ntp : np4=np2*np2 : np8=np4*np4
        AudioPan = Csng(-(np8 * np2))
    End If
End Function

Function Vol(ball) ' OPT15: x*x replaces ^2
    Dim bv : bv = BallVel(ball)
    Vol = Csng(bv * bv / 200)
End Function

' OPT10: Pre-computed denominator — VolRoll is Const 70, so this is constant.
'        Eliminates 2× Log() + division per call (~600 calls/sec at 4 balls).
Dim RollVolDenom : RollVolDenom = 80000 - (79900 * Log(VolRoll) / Log(100))

Function RollVol(ball) ' Calculates the Volume of the sound based on the ball speed.   Targets 100-80000 when VolRoll is 0-100
    Dim bv : bv = BallVel(ball)
    RollVol = Csng(bv * bv / RollVolDenom)   ' OPT10+OPT15: pre-computed denom, x*x
End Function

' OPT6: Speed-value variant — accepts pre-computed speed, avoids repeat BallVel/COM reads.
'       Used by RollingTimer_Timer hot path. Original RollVol left for other callers.
Function RollVolV(spd)
    RollVolV = Csng(spd * spd / RollVolDenom)  ' OPT10+OPT15: pre-computed denom, x*x
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function

' OPT6: Speed-value variant — accepts pre-computed speed. Original Pitch left for other callers.
Function PitchV(spd)
    PitchV = spd * 20
End Function

Function BallVel(ball) 'OPT15: cache COM reads, x*x replaces ^2
    Dim vx, vy : vx = ball.VelX : vy = ball.VelY
    BallVel = INT(SQR(vx*vx + vy*vy))
End Function

Sub WireRampSFX_Hit
       Playsound "WireRolling"
End Sub


Sub RampDropSFX_Hit
       Playsound "RampDrop"
End Sub


'*****************************************
'   rothbauerw's Manual Ball Control
'*****************************************

Dim BCup, BCdown, BCleft, BCright
Dim ControlBallInPlay, ControlActiveBall
Dim BCvel, BCyveloffset, BCboostmulti, BCboost

BCboost = 1				'Do Not Change - default setting
BCvel = 4				'Controls the speed of the ball movement
BCyveloffset = -0.01 	'Offsets the force of gravity to keep the ball from drifting vertically on the table, should be negative
BCboostmulti = 3		'Boost multiplier to ball veloctiy (toggled with the B key) 

ControlBallInPlay = false

Sub StartBallControl_Hit()
	Set ControlActiveBall = ActiveBall
	ControlBallInPlay = true
End Sub

Sub StopBallControl_Hit()
	ControlBallInPlay = false
End Sub	

Sub BallControlTimer_Timer()
	If EnableBallControl and ControlBallInPlay then
		If BCright = 1 Then
			ControlActiveBall.velx =  BCvel*BCboost
		ElseIf BCleft = 1 Then
			ControlActiveBall.velx = -BCvel*BCboost
		Else
			ControlActiveBall.velx = 0
		End If

		If BCup = 1 Then
			ControlActiveBall.vely = -BCvel*BCboost
		ElseIf BCdown = 1 Then
			ControlActiveBall.vely =  BCvel*BCboost
		Else
			ControlActiveBall.vely = bcyveloffset
		End If
	End If
End Sub


'*****************************************
'      JP's VP10 Rolling Sounds
'*****************************************

Const tnob = 5 ' total number of balls
Const fakeballs = 1
ReDim rolling(tnob)
' OPT6: Pre-built sound name strings — eliminates "fx_ballrolling" & b string
'       concatenation (up to 3 allocs per ball per 10ms tick = ~600 allocs/sec
'       at 4 balls). Built once at init, indexed by ball slot.
Dim RollSndStr(5)
InitRolling

Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
        RollSndStr(i) = "fx_ballrolling" & i   ' OPT6: pre-built, reused at runtime
    Next
End Sub


Sub RollingTimer_Timer()
	if VolRoll = 0 then exit sub
    Dim BOT, b
    BOT = GetBalls

	' stop the sound of deleted balls
    For b = UBound(BOT) + 1 to tnob-1
		If rolling(b-fakeballs) = True Then
			rolling(b-fakeballs) = False
			StopSound RollSndStr(b-fakeballs)   ' OPT6: pre-built string, no alloc
		end if 
    Next

	' exit the sub if no balls on the table
    If UBound(BOT) = fakeballs-1 Then Exit Sub

	' play the rolling sound for each ball
	' OPT6: bvel caches BallVel (2 COM reads) once per ball per tick.
	'       RollVolV/PitchV accept the pre-computed speed — eliminates 4 extra
	'       VelX/VelY COM reads per ball vs calling RollVol(ball)/Pitch(ball).
	'       RollSndStr replaces "fx_ballrolling" & idx string concat each branch.
	'       Net: ~2,400 COM reads/sec + ~600 string allocs/sec eliminated at 4 balls.
	Dim bvel, bIdx
	For b = fakeballs to UBound(BOT)
		bIdx = b - fakeballs
		bvel = BallVel(BOT(b))
        If bvel > 1 Then
            rolling(bIdx) = True
			If BOT(b).z < 30 Then
				PlaySound RollSndStr(bIdx), -1, RollVolV(bvel), AudioPan(BOT(b)), 0, PitchV(bvel), 1, 0, AudioFade(BOT(b))
            Else
				PlaySound RollSndStr(bIdx), -1, RollVolV(bvel)*.2, AudioPan(BOT(b)), 0, PitchV(bvel)+50000, 1, 0, AudioFade(BOT(b))
            End If
        Else
            If rolling(bIdx) = True Then
                StopSound RollSndStr(bIdx)
                rolling(bIdx) = False
            End If
        End If
    Next
End Sub



'**********************
' Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
    FlipperCradleCollision ball1, ball2, velocity
	Dim cv : cv = Csng(velocity) : PlaySound("fx_collide"), 0, cv * cv / 200, AudioPan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)  ' OPT15: x*x
End Sub


'*****************************************
'	ninuzzu's	BALL SHADOW
'*****************************************
Dim BallShadow
BallShadow = Array (BallShadow1,BallShadow2,BallShadow3,BallShadow4,BallShadow5)
' OPT4: Pre-computed shadow constants — Table1.Width/2 is a one-time COM read;
'        BallSize/6 is constant math. Both were recalculated every frame per ball.
Dim BS_HalfTableWidth   ' set in Table1_Init after Table1 is available
Dim BS_TableWidth       ' OPT11: cached Table1.Width for AudioPan
Dim BS_TableHeight      ' OPT11: cached Table1.Height for AudioFade
Const BS_d6 = 8.33333333   ' OPT4: BallSize/6 = 50/6. VBScript Const requires a
                            '       literal — Const x = OtherConst/n is a parse error.

Sub BallShadowUpdate()
    ' OPT4: bx caches BOT(b).X (was read 3x per ball per frame).
    '        BS_HalfTableWidth and BS_d6 replace Table1.Width/2 and BallSize/6
    '        which were recomputed via COM/division every iteration.
    Dim BOT, b, bx
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
    For b = fakeballs to UBound(BOT)
        bx = BOT(b).X
        If bx < BS_HalfTableWidth Then
            BallShadow(b).X = (bx - BS_d6 + ((bx - BS_HalfTableWidth)/7)) + 6
        Else
            BallShadow(b).X = (bx + BS_d6 + ((bx - BS_HalfTableWidth)/7)) - 6
        End If
        ballShadow(b).Y = BOT(b).Y + 12
        If BOT(b).Z > 20 Then
            BallShadow(b).visible = 1
        Else
            BallShadow(b).visible = 0
        End If
    Next
End Sub


InitLamps()             ' turn off the lights and flashers and reset them to the default parameters

' Called every 1ms.
Sub OneMsec_Timer()
	FadeLights.Update1
End Sub
 
' div lamp subs


Sub InitLamps()
	dim id, lightobj

	For each lightobj in Lamps
		' Asumptions: Light is named "LTxxy" where x is the lamp number, and y is optionally a,b,c for multiple on the same id
		dim arr
		id = cInt(mid(lightobj.Name,3, 2))
	    if TypeName(FadeLights.Obj(id)) = "NullFadingObject" then 
			arr = array(lightobj)
		Else
			arr = FadeLights.Obj(id)
			ReDim Preserve arr(UBound(arr) + 1)
			set arr(UBound(arr)) = lightobj
		end if
		FadeLights.Obj(id) = arr			
	next
	FadeLights.Callback(114) = "UpdateDictabird "
    FadeLights.FadeSpeedUp(114) = 1/50 : FadeLights.FadeSpeedDown(114) = 1/50

	FadeLights.Obj(117) = array(FlPf17,Fl17)
	FadeLights.Obj(118) = array(FlPf18,Fl18)
	FadeLights.Obj(119) = array(FlPf19,Fl19)
	FadeLights.Obj(120) = array(FlPf20,Fl20)
	FadeLights.Obj(121) = array(FlPf21,Fl21)
	FadeLights.Obj(122) = array(FlPf22,Fl22)
	FadeLights.Obj(124) = array(FlPf24,Fl24)
	FadeLights.Obj(125) = array(FlPf25,Fl25,DigMillions)
	FadeLights.Obj(128) = array(FlPf28,Fl28)
End Sub 


Sub AllLampsOff
    Dim x
    For x = 0 to 200
        SetLamp x, 0
    Next
End Sub

Sub SetLamp(nr, value)
	' If the lamp state is not changing, just exit. 
	if FadeLights.state(nr) = value then exit sub

    FadeLights.state(nr) = value
End Sub


' *** NFozzy's lamp fade routines *** 


Class NullFadingObject : Public Property Let IntensityScale(input) : : End Property : End Class	'todo do better

Class LampFader
	Public FadeSpeedDown(140), FadeSpeedUp(140)
	Private Lock(140), Loaded(140), OnOff(140)
	Public UseFunction
	Private cFilter
	Private UseCallback(140), cCallback(140)
	Public Lvl(140), Obj(140)
	' OPT7: Dirty list — tracks only the indices currently unlocked (Lock=False).
	'       Update1 iterates this list instead of all 141 entries every 1ms tick.
	'       On a quiet frame (0-2 active fades) drops from 141 to 0-2 iterations.
	'       Eliminates up to ~136,000 wasted array reads/sec during idle play.
	Private m_dirty(140)
	Private m_dirtyCount

	Sub Class_Initialize()
		dim x : for x = 0 to uBound(OnOff) 	'Set up fade speeds
			if FadeSpeedDown(x) <= 0 then FadeSpeedDown(x) = 1/100	'fade speed down
			if FadeSpeedUp(x) <= 0 then FadeSpeedUp(x) = 1/80'Fade speed up
			UseFunction = False
			lvl(x) = 0
			OnOff(x) = False
			Lock(x) = True : Loaded(x) = False
		Next

		for x = 0 to uBound(OnOff) 		'clear out empty obj
			if IsEmpty(obj(x) ) then Set Obj(x) = NullFader' : Loaded(x) = True
		Next
		m_dirtyCount = 0  ' OPT7: start with empty dirty list
	End Sub

	' OPT7: Add idx to dirty list if not already present.
	Private Sub DirtyAdd(idx)
		Dim i
		For i = 0 To m_dirtyCount - 1
			If m_dirty(i) = idx Then Exit Sub  ' already tracked
		Next
		m_dirty(m_dirtyCount) = idx
		m_dirtyCount = m_dirtyCount + 1
	End Sub

	' OPT7: Remove idx from dirty list via swap-with-last (O(1), no shifting).
	Private Sub DirtyRemove(idx)
		Dim i
		For i = 0 To m_dirtyCount - 1
			If m_dirty(i) = idx Then
				m_dirtyCount = m_dirtyCount - 1
				m_dirty(i) = m_dirty(m_dirtyCount)
				Exit Sub
			End If
		Next
	End Sub

	Public Property Get Locked(idx) : Locked = Lock(idx) : End Property		'debug.print Lampz.Locked(100)	'debug
	Public Property Get state(idx) : state = OnOff(idx) : end Property
	Public Property Let Filter(String) : Set cFilter = GetRef(String) : UseFunction = True : End Property
	Public Property Let Callback(idx, String) : cCallback(idx) = String : UseCallBack(idx) = True : End Property

	Public Property Let state(ByVal idx, input) 'Major update path
		input = cBool(input)
		if OnOff(idx) = Input then : Exit Property : End If	'discard redundant updates
		OnOff(idx) = input
		Lock(idx) = False 
		Loaded(idx) = False
		DirtyAdd idx  ' OPT7: mark this index as needing Update1 attention
	End Property

	Public sub LampMod(ByVal idx, input) 
		if Lvl(idx) = input then Exit Sub
		Lvl(idx) = (input * FlasherIntensity) / 25500
		Lock(idx) = True  ' LampMod is Lock=True — invisible to Update1, no DirtyAdd needed
		Loaded(idx) = False
	End Sub

	Public Sub TurnOnStates()	'If obj contains any light objects, set their states to 1 (Fading is our job!)
		dim debugstr
		dim idx : for idx = 0 to uBound(obj)
			if IsArray(obj(idx)) then 
				dim x, tmp : tmp = obj(idx) 'set tmp to array in order to access it
				for x = 0 to uBound(tmp)
					if typename(tmp(x)) = "Light" then DisableState tmp(x) : debugstr = debugstr & tmp(x).name & " state'd" & vbnewline
					
				Next
			Else
				if typename(obj(idx)) = "Light" then DisableState obj(idx) : debugstr = debugstr & obj(idx).name & " state'd (not array)" & vbnewline
				
			end if
		Next
	End Sub
	Private Sub DisableState(ByRef aObj) : aObj.FadeSpeedUp = 1000 : aObj.State = 1 : End Sub	'turn state to 1

	Public Sub Update1()	 ' OPT7: iterate only dirty list instead of all 141 entries.
		' Swap-with-last removal keeps the list compact without shifting.
		' i is NOT incremented after a removal — the swapped-in entry needs processing.
		Dim i, x
		i = 0
		Do While i < m_dirtyCount
			x = m_dirty(i)
			If OnOff(x) Then  ' Fade Up
				Lvl(x) = Lvl(x) + FadeSpeedUp(x)
				If Lvl(x) > 1 Then
					Lvl(x) = 1 : Lock(x) = True
					m_dirtyCount = m_dirtyCount - 1
					m_dirty(i) = m_dirty(m_dirtyCount)  ' swap-with-last
					' do not increment i — reprocess this slot
				Else
					i = i + 1
				End If
			Else              ' Fade Down
				Lvl(x) = Lvl(x) - FadeSpeedDown(x)
				If Lvl(x) < 0 Then
					Lvl(x) = 0 : Lock(x) = True
					m_dirtyCount = m_dirtyCount - 1
					m_dirty(i) = m_dirty(m_dirtyCount)  ' swap-with-last
					' do not increment i — reprocess this slot
				Else
					i = i + 1
				End If
			End If
		Loop
	End Sub


	Public Sub Update()	'Handle object updates. Update on a -1 Timer! If done fading, loaded(x) = True
		dim x,xx : for x = 0 to uBound(OnOff)
			if not Loaded(x) then
				if IsArray(obj(x) ) Then	'if array
					If UseFunction then 
						for each xx in obj(x) : xx.IntensityScale = cFilter(Lvl(x)) : Next
					Else
						for each xx in obj(x) : xx.IntensityScale = Lvl(x) : Next
					End If
				else						'if single lamp or flasher
					If UseFunction then 
						obj(x).Intensityscale = cFilter(Lvl(x))
					Else
						obj(x).Intensityscale = Lvl(x)
					End If
				end if
				' Sleazy hack for regional decimal point problem
				If UseCallBack(x) then execute cCallback(x) & " CSng(" & CInt(10000 * Lvl(x)) & " / 10000)"	'Callback
				If Lock(x) Then
					Loaded(x) = True	'finished fading
				end if
			end if
		Next
	End Sub
End Class



'************************************
' What you need to add to your table
'************************************

' a timer called RollingTimer. With a fast interval, like 10
' one collision sound, in this script is called fx_collide
' as many sound files as max number of balls, with names ending with 0, 1, 2, 3, etc
' for ex. as used in this script: fx_ballrolling0, fx_ballrolling1, fx_ballrolling2, fx_ballrolling3, etc


'******************************************
' Explanation of the rolling sound routine
'******************************************

' sounds are played based on the ball speed and position

' the routine checks first for deleted balls and stops the rolling sound.

' The For loop goes through all the balls on the table and checks for the ball speed and 
' if the ball is on the table (height lower than 30) then then it plays the sound
' otherwise the sound is stopped, like when the ball has stopped or is on a ramp or flying.

' The sound is played using the VOL, AUDIOPAN, AUDIOFADE and PITCH functions, so the volume and pitch of the sound
' will change according to the ball speed, and the AUDIOPAN & AUDIOFADE functions will change the stereo position
' according to the position of the ball on the table.


'**************************************
' Explanation of the collision routine
'**************************************

' The collision is built in VP.
' You only need to add a Sub OnBallBallCollision(ball1, ball2, velocity) and when two balls collide they 
' will call this routine. What you add in the sub is up to you. As an example is a simple Playsound with volume and paning
' depending of the speed of the collision.


Sub RandomSoundDrain
	dim DrainSnd:DrainSnd= "drain" & CStr(Int(Rnd*4)+1)
	PlaySound DrainSnd, 0, 1, 0, .2
End Sub

Sub Pins_Hit (idx)
	PlaySound "pinhit_low", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub Targets_Hit (idx)
	PlaySoundAtBallVol "target", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 0, 0, AudioFade(ActiveBall)
End Sub

Sub Metals_Thin_Hit (idx)
	PlaySound "metalhit_thin", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Metals_Medium_Hit (idx)
	PlaySound "metalhit_medium", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Metals2_Hit (idx)
	PlaySound "metalhit2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Gates_Hit (idx)
	PlaySound "gate4", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
End Sub

Sub Rubbers_Hit(idx)
 	dim finalspeed
  	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
 	If finalspeed > 20 then 
		PlaySound "fx_rubber2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End if
	If finalspeed >= 6 AND finalspeed <= 20 then
 		RandomSoundRubber()
 	End If
End Sub

Sub Posts_Hit(idx)
 	dim finalspeed
  	finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
 	If finalspeed > 16 then 
		PlaySound "fx_rubber2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End if
	If finalspeed >= 6 AND finalspeed <= 16 then
 		RandomSoundRubber()
 	End If
End Sub

Sub RandomSoundRubber()
	Select Case Int(Rnd*3)+1
		Case 1 : PlaySound "rubber_hit_1", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 2 : PlaySound "rubber_hit_2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 3 : PlaySound "rubber_hit_3", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End Select
End Sub

Sub LeftFlipper_Collide(parm)
    CheckLiveCatch ActiveBall, LeftFlipper, LFCount, parm
	LF.ReProcessBalls ActiveBall
 	RandomSoundFlipper()
End Sub

Sub RightFlipper_Collide(parm)
    CheckLiveCatch ActiveBall, RightFlipper, RFCount, parm
	RF.ReProcessBalls ActiveBall
 	RandomSoundFlipper()
End Sub

Sub RandomSoundFlipper()
	Select Case Int(Rnd*3)+1
		Case 1 : PlaySound "flip_hit_1", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 2 : PlaySound "flip_hit_2", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
		Case 3 : PlaySound "flip_hit_3", 0, Vol(ActiveBall), AudioPan(ActiveBall), 0, Pitch(ActiveBall), 1, 0, AudioFade(ActiveBall)
	End Select
End Sub

Dim NextOrbitHit:NextOrbitHit = 0 


Sub PlasticRampBump1_Hit
	RandomBump 1, Pitch(ActiveBall)
End Sub

Sub PlasticRampBump2_Hit
	RandomBump 1, Pitch(ActiveBall)
End Sub

Sub PlasticRampBumps_Hit(idx)
	if BallVel(ActiveBall) > .3 and Timer > NextOrbitHit then
		RandomBump 2, Pitch(ActiveBall)
		' Schedule the next possible sound time.  This prevents it from rapid-firing noises too much. 
		' Lowering these numbers allow more closely-spaced clunks.
		NextOrbitHit = Timer + .1 + (Rnd * .2)
	end if 
End Sub

Sub MetalWallBumps_Hit(idx)
	if BallVel(ActiveBall) > .3 and Timer > NextOrbitHit then
		RandomBump 1, 20000 'Increased pitch to simulate metal wall
		' Schedule the next possible sound time.  This prevents it from rapid-firing noises too much. 
		' Lowering these numbers allow more closely-spaced clunks.
		NextOrbitHit = Timer + .2 + (Rnd * .2)
	end if 
End Sub


'' Requires rampbump1 to 7 in Sound Manager
Sub RandomBump(voladj, freq)
	dim BumpSnd:BumpSnd= "rampbump" & CStr(Int(Rnd*7)+1)
		PlaySound BumpSnd, 0, Vol(ActiveBall)+voladj, AudioPan(ActiveBall), 0, freq, 0, 1, AudioFade(ActiveBall)
End Sub

'**********************************
' 	ZMAT: General Math Functions
'**********************************
' These get used throughout the script. 

Dim PI
PI = 4 * Atn(1)
' OPT9: Pre-computed trig conversion constants — eliminates 2 divisions per
'       dSin/dCos/Radians/AnglePP call. At 1000Hz from FlipperTrigger, ~8000 div/sec.
Dim PIover180 : PIover180 = PI / 180
Dim d180overPI : d180overPI = 180 / PI

Function dSin(degrees)
	dsin = Sin(degrees * PIover180)    ' OPT9: pre-computed constant
End Function

Function dCos(degrees)
	dcos = Cos(degrees * PIover180)    ' OPT9: pre-computed constant
End Function

Function Atn2(dy, dx)
	If dx > 0 Then
		Atn2 = Atn(dy / dx)
	ElseIf dx < 0 Then
		If dy = 0 Then
			Atn2 = pi
		Else
			Atn2 = Sgn(dy) * (pi - Atn(Abs(dy / dx)))
		End If
	ElseIf dx = 0 Then
		If dy = 0 Then
			Atn2 = 0
		Else
			Atn2 = Sgn(dy) * pi / 2
		End If
	End If
End Function

Function ArcCos(x)
	If x = 1 Then
		ArcCos = 0/180*PI
	ElseIf x = -1 Then
		ArcCos = 180/180*PI
	Else
		ArcCos = Atn(-x/Sqr(-x * x + 1)) + 2 * Atn(1)
	End If
End Function

Function max(a,b)
	If a > b Then
		max = a
	Else
		max = b
	End If
End Function

Function min(a,b)
	If a > b Then
		min = b
	Else
		min = a
	End If
End Function

' Used for drop targets
Function InRect(px,py,ax,ay,bx,by,cx,cy,dx,dy) 'Determines if a Points (px,py) is inside a 4 point polygon A-D in Clockwise/CCW order
	Dim AB, BC, CD, DA
	AB = (bx * py) - (by * px) - (ax * py) + (ay * px) + (ax * by) - (ay * bx)
	BC = (cx * py) - (cy * px) - (bx * py) + (by * px) + (bx * cy) - (by * cx)
	CD = (dx * py) - (dy * px) - (cx * py) + (cy * px) + (cx * dy) - (cy * dx)
	DA = (ax * py) - (ay * px) - (dx * py) + (dy * px) + (dx * ay) - (dy * ax)
	
	If (AB <= 0 And BC <= 0 And CD <= 0 And DA <= 0) Or (AB >= 0 And BC >= 0 And CD >= 0 And DA >= 0) Then
		InRect = True
	Else
		InRect = False
	End If
End Function

Function InRotRect(ballx,bally,px,py,angle,ax,ay,bx,by,cx,cy,dx,dy)
	Dim rax,ray,rbx,rby,rcx,rcy,rdx,rdy
	Dim rotxy
	rotxy = RotPoint(ax,ay,angle)
	rax = rotxy(0) + px
	ray = rotxy(1) + py
	rotxy = RotPoint(bx,by,angle)
	rbx = rotxy(0) + px
	rby = rotxy(1) + py
	rotxy = RotPoint(cx,cy,angle)
	rcx = rotxy(0) + px
	rcy = rotxy(1) + py
	rotxy = RotPoint(dx,dy,angle)
	rdx = rotxy(0) + px
	rdy = rotxy(1) + py
	
	InRotRect = InRect(ballx,bally,rax,ray,rbx,rby,rcx,rcy,rdx,rdy)
End Function

Function RotPoint(x,y,angle)
	Dim rx, ry
	rx = x * dCos(angle) - y * dSin(angle)
	ry = x * dSin(angle) + y * dCos(angle)
	RotPoint = Array(rx,ry)
End Function

'******************************************************
'	ZNFF:  FLIPPER CORRECTIONS by nFozzy
'******************************************************
'
' There are several steps for taking advantage of nFozzy's flipper solution.  At a high level we'll need the following:
'	1. flippers with specific physics settings
'	2. custom triggers for each flipper (TriggerLF, TriggerRF)
'	3. and, special scripting
'
' TriggerLF and RF should now be 27 vp units from the flippers. In addition, 3 degrees should be added to the end angle
' when creating these triggers.
'
' RF.ReProcessBalls Activeball and LF.ReProcessBalls Activeball must be added the flipper_collide subs.
'
' A common mistake is incorrect flipper length.  A 3-inch flipper with rubbers will be about 3.125 inches long.
' This translates to about 147 vp units.  Therefore, the flipper start radius + the flipper length + the flipper end
' radius should  equal approximately 147 vp units. Another common mistake is is that sometimes the right flipper
' angle was set with a large postive value (like 238 or something). It should be using negative value (like -122).
'
' The following settings are a solid starting point for various eras of pinballs.
' |                    | EM's           | late 70's to mid 80's | mid 80's to early 90's | mid 90's and later |
' | ------------------ | -------------- | --------------------- | ---------------------- | ------------------ |
' | Mass               | 1              | 1                     | 1                      | 1                  |
' | Strength           | 500-1000 (750) | 1400-1600 (1500)      | 2000-2600              | 3200-3300 (3250)   |
' | Elasticity         | 0.88           | 0.88                  | 0.88                   | 0.88               |
' | Elasticity Falloff | 0.15           | 0.15                  | 0.15                   | 0.15               |
' | Fricition          | 0.8-0.9        | 0.9                   | 0.9                    | 0.9                |
' | Return Strength    | 0.11           | 0.09                  | 0.07                   | 0.055              |
' | Coil Ramp Up       | 2.5            | 2.5                   | 2.5                    | 2.5                |
' | Scatter Angle      | 0              | 0                     | 0                      | 0                  |
' | EOS Torque         | 0.4            | 0.4                   | 0.375                  | 0.375              |
' | EOS Torque Angle   | 4              | 4                     | 6                      | 6                  |
'

'******************************************************
' Flippers Polarity (Select appropriate sub based on era)
'******************************************************

Dim LF : Set LF = New FlipperPolarity
Dim RF : Set RF = New FlipperPolarity

InitPolarity

'*******************************************
' Early 90's and after

Sub InitPolarity()
	Dim x, a
	a = Array(LF, RF)
	For Each x In a
		x.AddPt "Ycoef", 0, RightFlipper.Y-65, 1 'disabled
		x.AddPt "Ycoef", 1, RightFlipper.Y-11, 1
		x.enabled = True
		x.TimeDelay = 60
		x.DebugOn=False ' prints some info in debugger

		x.AddPt "Polarity", 0, 0, 0
		x.AddPt "Polarity", 1, 0.05, - 5.5
		x.AddPt "Polarity", 2, 0.16, - 5.5
		x.AddPt "Polarity", 3, 0.20, - 0.75
		x.AddPt "Polarity", 4, 0.25, - 1.25
		x.AddPt "Polarity", 5, 0.3, - 1.75
		x.AddPt "Polarity", 6, 0.4, - 3.5
		x.AddPt "Polarity", 7, 0.5, - 5.25
		x.AddPt "Polarity", 8, 0.7, - 4.0
		x.AddPt "Polarity", 9, 0.75, - 3.5
		x.AddPt "Polarity", 10, 0.8, - 3.0
		x.AddPt "Polarity", 11, 0.85, - 2.5
		x.AddPt "Polarity", 12, 0.9, - 2.0
		x.AddPt "Polarity", 13, 0.95, - 1.5
		x.AddPt "Polarity", 14, 1, - 1.0
		x.AddPt "Polarity", 15, 1.05, -0.5
		x.AddPt "Polarity", 16, 1.1, 0
		x.AddPt "Polarity", 17, 1.3, 0

		x.AddPt "Velocity", 0, 0, 0.85
		x.AddPt "Velocity", 1, 0.23, 0.85
		x.AddPt "Velocity", 2, 0.27, 1
		x.AddPt "Velocity", 3, 0.3, 1
		x.AddPt "Velocity", 4, 0.35, 1
		x.AddPt "Velocity", 5, 0.6, 1 '0.982
		x.AddPt "Velocity", 6, 0.62, 1.0
		x.AddPt "Velocity", 7, 0.702, 0.968
		x.AddPt "Velocity", 8, 0.95,  0.968
		x.AddPt "Velocity", 9, 1.03,  0.945
		x.AddPt "Velocity", 10, 1.5,  0.945

	Next
	
	' SetObjects arguments: 1: name of object 2: flipper object: 3: Trigger object around flipper
	LF.SetObjects "LF", LeftFlipper, TriggerLF
	RF.SetObjects "RF", RightFlipper, TriggerRF
End Sub

'******************************************************
'  FLIPPER CORRECTION FUNCTIONS
'******************************************************

' modified 2023 by nFozzy
' Removed need for 'endpoint' objects
' Added 'createvents' type thing for TriggerLF / TriggerRF triggers.
' Removed AddPt function which complicated setup imo
' made DebugOn do something (prints some stuff in debugger)
'   Otherwise it should function exactly the same as before\
' modified 2024 by rothbauerw
' Added Reprocessballs for flipper collisions (LF.Reprocessballs Activeball and RF.Reprocessballs Activeball must be added to the flipper collide subs
' Improved handling to remove correction for backhand shots when the flipper is raised

Class FlipperPolarity
	Public DebugOn, Enabled
	Private FlipAt		'Timer variable (IE 'flip at 723,530ms...)
	Public TimeDelay		'delay before trigger turns off and polarity is disabled
	Private Flipper, FlipperStart, FlipperEnd, FlipperEndY, LR, PartialFlipCoef, FlipStartAngle
	Private Balls(20), balldata(20)
	Private Name
	
	Dim PolarityIn, PolarityOut
	Dim VelocityIn, VelocityOut
	Dim YcoefIn, YcoefOut
	Public Sub Class_Initialize
		ReDim PolarityIn(0)
		ReDim PolarityOut(0)
		ReDim VelocityIn(0)
		ReDim VelocityOut(0)
		ReDim YcoefIn(0)
		ReDim YcoefOut(0)
		Enabled = True
		TimeDelay = 50
		LR = 1
		Dim x
		For x = 0 To UBound(balls)
			balls(x) = Empty
			Set Balldata(x) = new SpoofBall
		Next
	End Sub
	
	Public Sub SetObjects(aName, aFlipper, aTrigger)
		
		If TypeName(aName) <> "String" Then MsgBox "FlipperPolarity: .SetObjects error: first argument must be a String (And name of Object). Found:" & TypeName(aName) End If
		If TypeName(aFlipper) <> "Flipper" Then MsgBox "FlipperPolarity: .SetObjects error: Second argument must be a flipper. Found:" & TypeName(aFlipper) End If
		If TypeName(aTrigger) <> "Trigger" Then MsgBox "FlipperPolarity: .SetObjects error: third argument must be a trigger. Found:" & TypeName(aTrigger) End If
		If aFlipper.EndAngle > aFlipper.StartAngle Then LR = -1 Else LR = 1 End If
		Name = aName
		Set Flipper = aFlipper
		FlipperStart = aFlipper.x
		FlipperEnd = Flipper.Length * Sin((Flipper.StartAngle / 57.295779513082320876798154814105)) + Flipper.X ' big floats for degree to rad conversion
		FlipperEndY = Flipper.Length * Cos(Flipper.StartAngle / 57.295779513082320876798154814105)*-1 + Flipper.Y
		
		Dim str
		str = "Sub " & aTrigger.name & "_Hit() : " & aName & ".AddBall ActiveBall : End Sub'"
		ExecuteGlobal(str)
		str = "Sub " & aTrigger.name & "_UnHit() : " & aName & ".PolarityCorrect ActiveBall : End Sub'"
		ExecuteGlobal(str)
		
	End Sub
	
	' Legacy: just no op
	Public Property Let EndPoint(aInput)
		
	End Property
	
	Public Sub AddPt(aChooseArray, aIDX, aX, aY) 'Index #, X position, (in) y Position (out)
		Select Case aChooseArray
			Case "Polarity"
				ShuffleArrays PolarityIn, PolarityOut, 1
				PolarityIn(aIDX) = aX
				PolarityOut(aIDX) = aY
				ShuffleArrays PolarityIn, PolarityOut, 0
			Case "Velocity"
				ShuffleArrays VelocityIn, VelocityOut, 1
				VelocityIn(aIDX) = aX
				VelocityOut(aIDX) = aY
				ShuffleArrays VelocityIn, VelocityOut, 0
			Case "Ycoef"
				ShuffleArrays YcoefIn, YcoefOut, 1
				YcoefIn(aIDX) = aX
				YcoefOut(aIDX) = aY
				ShuffleArrays YcoefIn, YcoefOut, 0
		End Select
	End Sub
	
	Public Sub AddBall(aBall)
		Dim x
		For x = 0 To UBound(balls)
			If IsEmpty(balls(x)) Then
				Set balls(x) = aBall
				Exit Sub
			End If
		Next
	End Sub
	
	Private Sub RemoveBall(aBall)
		Dim x
		For x = 0 To UBound(balls)
			If TypeName(balls(x) ) = "IBall" Then
				If aBall.ID = Balls(x).ID Then
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
		Dim x
		For x = 0 To UBound(balls)
			If Not IsEmpty(balls(x)) Then
				pos = pSlope(Balls(x).x, FlipperStart, 0, FlipperEnd, 1)
			End If
		Next
	End Property
	
	Public Sub ProcessBalls() 'save data of balls in flipper range
		FlipAt = GameTime
		Dim x
		For x = 0 To UBound(balls)
			If Not IsEmpty(balls(x)) Then
				balldata(x).Data = balls(x)
			End If
		Next
		FlipStartAngle = Flipper.currentangle
		PartialFlipCoef = ((Flipper.StartAngle - Flipper.CurrentAngle) / (Flipper.StartAngle - Flipper.EndAngle))
		PartialFlipCoef = abs(PartialFlipCoef-1)
	End Sub

	Public Sub ReProcessBalls(aBall) 'save data of balls in flipper range
		If FlipperOn() Then
			Dim x
			For x = 0 To UBound(balls)
				If Not IsEmpty(balls(x)) Then
					if balls(x).ID = aBall.ID Then
						If isempty(balldata(x).ID) Then
							balldata(x).Data = balls(x)
						End If
					End If
				End If
			Next
		End If
	End Sub

	'Timer shutoff for polaritycorrect
	Private Function FlipperOn()
		If GameTime < FlipAt+TimeDelay Then
			FlipperOn = True
		End If
	End Function
	
	Public Sub PolarityCorrect(aBall)
		If FlipperOn() Then
			Dim tmp, BallPos, x, IDX, Ycoef, BalltoFlip, BalltoBase, NoCorrection, checkHit
			Ycoef = 1
			
			'y safety Exit
			If aBall.VelY > -8 Then 'ball going down
				RemoveBall aBall
				Exit Sub
			End If
			
			'Find balldata. BallPos = % on Flipper
			For x = 0 To UBound(Balls)
				If aBall.id = BallData(x).id And Not IsEmpty(BallData(x).id) Then
					idx = x
					BallPos = PSlope(BallData(x).x, FlipperStart, 0, FlipperEnd, 1)
					BalltoFlip = DistanceFromFlipperAngle(BallData(x).x, BallData(x).y, Flipper, FlipStartAngle)
					If ballpos > 0.65 Then  Ycoef = LinearEnvelope(BallData(x).Y, YcoefIn, YcoefOut)								'find safety coefficient 'ycoef' data
				End If
			Next
			
			If BallPos = 0 Then 'no ball data meaning the ball is entering and exiting pretty close to the same position, use current values.
				BallPos = PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1)
				If ballpos > 0.65 Then  Ycoef = LinearEnvelope(aBall.Y, YcoefIn, YcoefOut)												'find safety coefficient 'ycoef' data
				NoCorrection = 1
			Else
				checkHit = 50 + (20 * BallPos) 

				If BalltoFlip > checkHit or (PartialFlipCoef < 0.5 and BallPos > 0.22) Then
					NoCorrection = 1
				Else
					NoCorrection = 0
				End If
			End If
			
			'Velocity correction
			If Not IsEmpty(VelocityIn(0) ) Then
				Dim VelCoef
				VelCoef = LinearEnvelope(BallPos, VelocityIn, VelocityOut)
				
				'If partialflipcoef < 1 Then VelCoef = PSlope(partialflipcoef, 0, 1, 1, VelCoef)
				
				If Enabled Then aBall.Velx = aBall.Velx*VelCoef
				If Enabled Then aBall.Vely = aBall.Vely*VelCoef
			End If
			
			'Polarity Correction (optional now)
			If Not IsEmpty(PolarityIn(0) ) Then
				Dim AddX
				AddX = LinearEnvelope(BallPos, PolarityIn, PolarityOut) * LR
				
				If Enabled and NoCorrection = 0 Then aBall.VelX = aBall.VelX + 1 * (AddX*ycoef*PartialFlipcoef*VelCoef)
			End If
			If DebugOn Then debug.print "PolarityCorrect" & " " & Name & " @ " & GameTime & " " & Round(BallPos*100) & "%" & " AddX:" & Round(AddX,2) & " Vel%:" & Round(VelCoef*100)
		End If
		RemoveBall aBall
	End Sub
End Class

'******************************************************
'  FLIPPER POLARITY AND RUBBER DAMPENER SUPPORTING FUNCTIONS
'******************************************************

' Used for flipper correction and rubber dampeners
Sub ShuffleArray(ByRef aArray, byVal offset) 'shuffle 1d array
	Dim x, aCount
	aCount = 0
	ReDim a(UBound(aArray) )
	For x = 0 To UBound(aArray)		'Shuffle objects in a temp array
		If Not IsEmpty(aArray(x) ) Then
			If IsObject(aArray(x)) Then
				Set a(aCount) = aArray(x)
			Else
				a(aCount) = aArray(x)
			End If
			aCount = aCount + 1
		End If
	Next
	If offset < 0 Then offset = 0
	ReDim aArray(aCount-1+offset)		'Resize original array
	For x = 0 To aCount-1				'set objects back into original array
		If IsObject(a(x)) Then
			Set aArray(x) = a(x)
		Else
			aArray(x) = a(x)
		End If
	Next
End Sub

' Used for flipper correction and rubber dampeners
Sub ShuffleArrays(aArray1, aArray2, offset)
	ShuffleArray aArray1, offset
	ShuffleArray aArray2, offset
End Sub

' Used for flipper correction, rubber dampeners, and drop targets
Function BallSpeed(ball) 'OPT15: cache COM reads, x*x replaces ^2
	Dim vx, vy, vz : vx = ball.VelX : vy = ball.VelY : vz = ball.VelZ
	BallSpeed = Sqr(vx*vx + vy*vy + vz*vz)
End Function

' Used for flipper correction and rubber dampeners
Function PSlope(Input, X1, Y1, X2, Y2)		'Set up line via two points, no clamping. Input X, output Y
	Dim x, y, b, m
	x = input
	m = (Y2 - Y1) / (X2 - X1)
	b = Y2 - m*X2
	Y = M*x+b
	PSlope = Y
End Function

' Used for flipper correction
Class spoofball
	Public X, Y, Z, VelX, VelY, VelZ, ID, Mass, Radius
	Public Property Let Data(aBall)
		With aBall
			x = .x
			y = .y
			z = .z
			velx = .velx
			vely = .vely
			velz = .velz
			id = .ID
			mass = .mass
			radius = .radius
		End With
	End Property
	Public Sub Reset()
		x = Empty
		y = Empty
		z = Empty
		velx = Empty
		vely = Empty
		velz = Empty
		id = Empty
		mass = Empty
		radius = Empty
	End Sub
End Class

' Used for flipper correction and rubber dampeners
Function LinearEnvelope(xInput, xKeyFrame, yLvl)
	Dim y 'Y output
	Dim L 'Line
	'find active line
	Dim ii
	For ii = 1 To UBound(xKeyFrame)
		If xInput <= xKeyFrame(ii) Then
			L = ii
			Exit For
		End If
	Next
	If xInput > xKeyFrame(UBound(xKeyFrame) ) Then L = UBound(xKeyFrame)		'catch line overrun
	Y = pSlope(xInput, xKeyFrame(L-1), yLvl(L-1), xKeyFrame(L), yLvl(L) )
	
	If xInput <= xKeyFrame(LBound(xKeyFrame) ) Then Y = yLvl(LBound(xKeyFrame) )		 'Clamp lower
	If xInput >= xKeyFrame(UBound(xKeyFrame) ) Then Y = yLvl(UBound(xKeyFrame) )		'Clamp upper
	
	LinearEnvelope = Y
End Function

'******************************************************
'  FLIPPER TRICKS
'******************************************************
' To add the flipper tricks you must
'	 - Include a call to FlipperCradleCollision from within OnBallBallCollision subroutine
'	 - Include a call the CheckLiveCatch from the LeftFlipper_Collide and RightFlipper_Collide subroutines
'	 - Include FlipperActivate and FlipperDeactivate in the Flipper solenoid subs

' OPT18: 1ms → 10ms. Profiler showed RightFlipper timer consumed 2.4-3.7ms/frame
'        (60-65% of all script time). 100Hz is visually identical for flipper
'        correction. Saves ~4500 function calls/sec.
RightFlipper.timerinterval = 10
Rightflipper.timerenabled = True

Sub RightFlipper_timer()
	FlipperTricks LeftFlipper, LFPress, LFCount, LFEndAngle, LFState
	FlipperTricks RightFlipper, RFPress, RFCount, RFEndAngle, RFState
    FlipperTricks RightFlipper1, RFPress1, RFCount1, RFEndAngle1, RFState1
	' OPT18: Press guard — skip FlipperNudge entirely when both flippers at rest.
	'        During idle play (majority of time), eliminates GetBalls + 2× FlipperNudge
	'        + all ball-loop COM reads. Profiler showed this as 60-65% of script time.
	If LFPress = 0 And RFPress = 0 Then Exit Sub
	' OPT1: GetBalls called once here and passed to both FlipperNudge calls.
	Dim gBOT_FN : gBOT_FN = GetBalls
	FlipperNudge RightFlipper, RFEndAngle, RFEOSNudge, LeftFlipper, LFEndAngle, gBOT_FN
	FlipperNudge LeftFlipper, LFEndAngle, LFEOSNudge,  RightFlipper, RFEndAngle, gBOT_FN
End Sub

Dim LFEOSNudge, RFEOSNudge

Sub FlipperNudge(Flipper1, Endangle1, EOSNudge1, Flipper2, EndAngle2, gBOT)
	' OPT1: gBOT is now passed in from RightFlipper_timer.
	' OPT17: Cache currentangle (read 2-3× per call). Cache ball x/y in loops.
	Dim b, ca1, bx, by
	ca1 = Flipper1.currentangle

	If ca1 = Endangle1 And EOSNudge1 <> 1 Then
		EOSNudge1 = 1
		If Flipper2.currentangle = EndAngle2 Then
			For b = 0 To UBound(gBOT)
				bx = gBOT(b).x : by = gBOT(b).y
				If FlipperTrigger(bx, by, Flipper1) Then
					Exit Sub
				End If
			Next
			For b = 0 To UBound(gBOT)
				bx = gBOT(b).x : by = gBOT(b).y
				If FlipperTrigger(bx, by, Flipper2) Then
					gBOT(b).velx = gBOT(b).velx / 1.3
					gBOT(b).vely = gBOT(b).vely - 0.5
				End If
			Next
		End If
	Else
		If Abs(ca1) > Abs(EndAngle1) + 30 Then EOSNudge1 = 0
	End If
End Sub


Dim FCCDamping: FCCDamping = 0.4

Sub FlipperCradleCollision(ball1, ball2, velocity)
	if velocity < 0.7 then exit sub		'filter out gentle collisions
    Dim DoDamping, coef
    DoDamping = false
    'Check left flipper
    If LeftFlipper.currentangle = LFEndAngle Then
		If FlipperTrigger(ball1.x, ball1.y, LeftFlipper) OR FlipperTrigger(ball2.x, ball2.y, LeftFlipper) Then DoDamping = true
    End If
    'Check right flipper
    If RightFlipper.currentangle = RFEndAngle Then
		If FlipperTrigger(ball1.x, ball1.y, RightFlipper) OR FlipperTrigger(ball2.x, ball2.y, RightFlipper) Then DoDamping = true
    End If
    If DoDamping Then
		coef = FCCDamping
        ball1.velx = ball1.velx * coef: ball1.vely = ball1.vely * coef: ball1.velz = ball1.velz * coef
        ball2.velx = ball2.velx * coef: ball2.vely = ball2.vely * coef: ball2.velz = ball2.velz * coef
    End If
End Sub
	




'*************************************************
'  Check ball distance from Flipper for Rem
'*************************************************

Function Distance(ax,ay,bx,by)  ' OPT15: x*x replaces ^2
	Dim dx, dy : dx = ax - bx : dy = ay - by
	Distance = Sqr(dx*dx + dy*dy)
End Function

Function DistancePL(px,py,ax,ay,bx,by) 'Distance between a point and a line where point Is px,py
	DistancePL = Abs((by - ay) * px - (bx - ax) * py + bx * ay - by * ax) / Distance(ax,ay,bx,by)
End Function

Function Radians(Degrees)
	Radians = Degrees * PIover180       ' OPT9: pre-computed constant
End Function

Function AnglePP(ax,ay,bx,by)
	AnglePP = Atn2((by - ay),(bx - ax)) * d180overPI  ' OPT9: pre-computed constant
End Function

Function DistanceFromFlipper(ballx, bally, Flipper)
	DistanceFromFlipper = DistancePL(ballx, bally, Flipper.x, Flipper.y, Cos(Radians(Flipper.currentangle + 90)) + Flipper.x, Sin(Radians(Flipper.currentangle + 90)) + Flipper.y)
End Function

Function DistanceFromFlipperAngle(ballx, bally, Flipper, Angle)
	DistanceFromFlipperAngle = DistancePL(ballx, bally, Flipper.x, Flipper.y, Cos(Radians(Angle + 90)) + Flipper.x, Sin(Radians(angle + 90)) + Flipper.y)
End Function

Function FlipperTrigger(ballx, bally, Flipper)
	' OPT14: Cache all flipper COM props once. Previously read .x 3×, .y 3×,
	'        .currentangle 2×, .Length 1× across this + DistanceFromFlipper + AnglePP.
	'        At 1000Hz with 4 balls = ~30,000 COM reads/sec eliminated.
	Dim fx, fy, fca, flen, frad, dfl, DiffAngle
	fx = Flipper.x : fy = Flipper.y
	fca = Flipper.currentangle : flen = Flipper.Length
	DiffAngle = Abs(fca - AnglePP(fx, fy, ballx, bally) - 90)
	If DiffAngle > 180 Then DiffAngle = DiffAngle - 360
	frad = (fca + 90) * PIover180   ' OPT9: pre-computed constant
	dfl = DistancePL(ballx, bally, fx, fy, Cos(frad)+fx, Sin(frad)+fy)
	If dfl < 48 And DiffAngle <= 90 And Distance(ballx, bally, fx, fy) < flen Then
		FlipperTrigger = True
	Else
		FlipperTrigger = False
	End If
End Function

'*************************************************
'  End - Check ball distance from Flipper for Rem
'*************************************************

Dim LFPress, RFPress, LFCount, RFCount
Dim LFState, RFState
Dim EOST, EOSA,Frampup, FElasticity,FReturn
Dim RFEndAngle, LFEndAngle
Dim RFPress1, RFCount1, RFEndAngle1, RFState1

Const FlipperCoilRampupMode = 0 '0 = fast, 1 = medium, 2 = slow (tap passes should work)

LFState = 1
RFState = 1
RFState1 = 1
EOST = leftflipper.eostorque
EOSA = leftflipper.eostorqueangle
Frampup = LeftFlipper.rampup
FElasticity = LeftFlipper.elasticity
FReturn = LeftFlipper.return
'Const EOSTnew = 1.5 'EM's to late 80's - new recommendation by rothbauerw (previously 1)
Const EOSTnew = 1.2 '90's and later - new recommendation by rothbauerw (previously 0.8)
Const EOSAnew = 1
Const EOSRampup = 0
Dim SOSRampup
Select Case FlipperCoilRampupMode
	Case 0
		SOSRampup = 2.5
	Case 1
		SOSRampup = 6
	Case 2
		SOSRampup = 8.5
End Select

Const LiveCatch = 16
Const LiveElasticity = 0.45
Const SOSEM = 0.815
'   Const EOSReturn = 0.055  'EM's
'   Const EOSReturn = 0.045  'late 70's to mid 80's
'Const EOSReturn = 0.035  'mid 80's to early 90's
   Const EOSReturn = 0.025  'mid 90's and later

LFEndAngle = Leftflipper.endangle
RFEndAngle = RightFlipper.endangle
RFEndAngle1 = RightFlipper1.endangle

Sub FlipperActivate(Flipper, FlipperPress)
	FlipperPress = 1
	Flipper.Elasticity = FElasticity
	
	Flipper.eostorque = EOST
	Flipper.eostorqueangle = EOSA
End Sub

Sub FlipperDeactivate(Flipper, FlipperPress)
	FlipperPress = 0
	Flipper.eostorqueangle = EOSA
	Flipper.eostorque = EOST * EOSReturn / FReturn
	
	If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 0.1 Then
		Dim b, gBOT
				gBOT = GetBalls
		
		For b = 0 To UBound(gBOT)
			If Distance(gBOT(b).x, gBOT(b).y, Flipper.x, Flipper.y) < 55 Then 'check for cradle
				If gBOT(b).vely >= - 0.4 Then gBOT(b).vely =  - 0.4
			End If
		Next
	End If
End Sub

Sub FlipperTricks (Flipper, FlipperPress, FCount, FEndAngle, FState)
	' OPT13: Cache startangle/currentangle — each was read 2-4× per call via COM.
	'        At 1000Hz × 3 flippers = ~12,000 COM reads/sec eliminated.
	Dim sa : sa = Flipper.startangle
	Dim Dir : Dir = sa / Abs(sa)  '-1 for Right Flipper
	Dim ca : ca = Abs(Flipper.currentangle)
	Dim absSa : absSa = Abs(sa)

	If ca > absSa - 0.05 Then
		If FState <> 1 Then
			Flipper.rampup = SOSRampup
			Flipper.endangle = FEndAngle - 3 * Dir
			Flipper.Elasticity = FElasticity * SOSEM
			FCount = 0
			FState = 1
		End If
	ElseIf ca <= Abs(Flipper.endangle) And FlipperPress = 1 Then
		If FCount = 0 Then FCount = GameTime

		If FState <> 2 Then
			Flipper.eostorqueangle = EOSAnew
			Flipper.eostorque = EOSTnew
			Flipper.rampup = EOSRampup
			Flipper.endangle = FEndAngle
			FState = 2
		End If
	ElseIf ca > Abs(Flipper.endangle) + 0.01 And FlipperPress = 1 Then
		If FState <> 3 Then
			Flipper.eostorque = EOST
			Flipper.eostorqueangle = EOSA
			Flipper.rampup = Frampup
			Flipper.Elasticity = FElasticity
			FState = 3
		End If
	End If
End Sub

Const LiveDistanceMin = 5  'minimum distance In vp units from flipper base live catch dampening will occur
Const LiveDistanceMax = 114 'maximum distance in vp units from flipper base live catch dampening will occur (tip protection)
Const BaseDampen = 0.55

Sub CheckLiveCatch(ball, Flipper, FCount, parm) 'Experimental new live catch
    Dim Dir, LiveDist
    Dir = Flipper.startangle / Abs(Flipper.startangle)    '-1 for Right Flipper
    Dim LiveCatchBounce   'If live catch is not perfect, it won't freeze ball totally
    Dim CatchTime
    CatchTime = GameTime - FCount
    LiveDist = Abs(Flipper.x - ball.x)

    If CatchTime <= LiveCatch And parm > 3 And LiveDist > LiveDistanceMin And LiveDist < LiveDistanceMax Then
        If CatchTime <= LiveCatch * 0.5 Then   'Perfect catch only when catch time happens in the beginning of the window
            LiveCatchBounce = 0
        Else
            LiveCatchBounce = Abs((LiveCatch / 2) - CatchTime)  'Partial catch when catch happens a bit late
        End If
        
        If LiveCatchBounce = 0 And ball.velx * Dir > 0 And LiveDist > 30 Then ball.velx = 0

        If ball.velx * Dir > 0 And LiveDist < 30 Then
            ball.velx = BaseDampen * ball.velx
            ball.vely = BaseDampen * ball.vely
            ball.angmomx = BaseDampen * ball.angmomx
            ball.angmomy = BaseDampen * ball.angmomy
            ball.angmomz = BaseDampen * ball.angmomz
        Elseif LiveDist > 30 Then
            ball.vely = LiveCatchBounce * (32 / LiveCatch) ' Multiplier for inaccuracy bounce
            ball.angmomx = 0
            ball.angmomy = 0
            ball.angmomz = 0
        End If
    Else
        If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 1 Then FlippersD.Dampenf ActiveBall, parm
    End If
End Sub

'******************************************************
'****  END FLIPPER CORRECTIONS
'******************************************************





'******************************************************
' 	ZDMP:  RUBBER  DAMPENERS
'******************************************************
' These are data mined bounce curves,
' dialed in with the in-game elasticity as much as possible to prevent angle / spin issues.
' Requires tracking ballspeed to calculate COR

Sub dPosts_Hit(idx)
	RubbersD.dampen ActiveBall
	TargetBouncer ActiveBall, 1
End Sub

Sub dSleeves_Hit(idx)
	SleevesD.Dampen ActiveBall
	TargetBouncer ActiveBall, 0.7
End Sub

Dim RubbersD				'frubber
Set RubbersD = New Dampener
RubbersD.name = "Rubbers"
RubbersD.debugOn = False	'shows info in textbox "TBPout"
RubbersD.Print = False	  'debug, reports In debugger (In vel, out cor); cor bounce curve (linear)

'for best results, try to match in-game velocity as closely as possible to the desired curve
'   RubbersD.addpoint 0, 0, 0.935   'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 0, 0, 1.1		 'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 1, 3.77, 0.97
RubbersD.addpoint 2, 5.76, 0.967	'dont take this as gospel. if you can data mine rubber elasticitiy, please help!
RubbersD.addpoint 3, 15.84, 0.874
RubbersD.addpoint 4, 56, 0.64	   'there's clamping so interpolate up to 56 at least

Dim SleevesD	'this is just rubber but cut down to 85%...
Set SleevesD = New Dampener
SleevesD.name = "Sleeves"
SleevesD.debugOn = False	'shows info in textbox "TBPout"
SleevesD.Print = False	  'debug, reports In debugger (In vel, out cor)
SleevesD.CopyCoef RubbersD, 0.85

'######################### Add new FlippersD Profile
'######################### Adjust these values to increase or lessen the elasticity

Dim FlippersD
Set FlippersD = New Dampener
FlippersD.name = "Flippers"
FlippersD.debugOn = False
FlippersD.Print = False
FlippersD.addpoint 0, 0, 1.1
FlippersD.addpoint 1, 3.77, 0.99
FlippersD.addpoint 2, 6, 0.99

Class Dampener
	Public Print, debugOn   'tbpOut.text
	Public name, Threshold  'Minimum threshold. Useful for Flippers, which don't have a hit threshold.
	Public ModIn, ModOut
	Private Sub Class_Initialize
		ReDim ModIn(0)
		ReDim Modout(0)
	End Sub
	
	Public Sub AddPoint(aIdx, aX, aY)
		ShuffleArrays ModIn, ModOut, 1
		ModIn(aIDX) = aX
		ModOut(aIDX) = aY
		ShuffleArrays ModIn, ModOut, 0
		If GameTime > 100 Then Report
	End Sub
	
	Public Sub Dampen(aBall)
		If threshold Then
			If BallSpeed(aBall) < threshold Then Exit Sub
		End If
		Dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id) + 0.0001)
		coef = desiredcor / realcor
		If debugOn Then str = name & " In vel:" & Round(cor.ballvel(aBall.id),2 ) & vbNewLine & "desired cor: " & Round(desiredcor,4) & vbNewLine & _
		"actual cor: " & Round(realCOR,4) & vbNewLine & "ballspeed coef: " & Round(coef, 3) & vbNewLine
		If Print Then Debug.print Round(cor.ballvel(aBall.id),2) & ", " & Round(desiredcor,3)
		
		aBall.velx = aBall.velx * coef
		aBall.vely = aBall.vely * coef
		aBall.velz = aBall.velz * coef
		If debugOn Then TBPout.text = str
	End Sub
	
	Public Sub Dampenf(aBall, parm) 'Rubberizer is handle here
		Dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id) + 0.0001)
		coef = desiredcor / realcor
		If Abs(aball.velx) < 2 And aball.vely < 0 And aball.vely >  - 3.75 Then
			aBall.velx = aBall.velx * coef
			aBall.vely = aBall.vely * coef
			aBall.velz = aBall.velz * coef
		End If
	End Sub
	
	Public Sub CopyCoef(aObj, aCoef) 'alternative addpoints, copy with coef
		Dim x
		For x = 0 To UBound(aObj.ModIn)
			addpoint x, aObj.ModIn(x), aObj.ModOut(x) * aCoef
		Next
	End Sub
	
	Public Sub Report() 'debug, reports all coords in tbPL.text
		If Not debugOn Then Exit Sub
		Dim a1, a2
		a1 = ModIn
		a2 = ModOut
		Dim str, x
		For x = 0 To UBound(a1)
			str = str & x & ": " & Round(a1(x),4) & ", " & Round(a2(x),4) & vbNewLine
		Next
		TBPout.text = str
	End Sub
End Class

'******************************************************
'  TRACK ALL BALL VELOCITIES
'  FOR RUBBER DAMPENER AND DROP TARGETS
'******************************************************

Dim cor
Set cor = New CoRTracker

Class CoRTracker
	Public ballvel, ballvelx, ballvely
	
	Private Sub Class_Initialize
		ReDim ballvel(0)
		ReDim ballvelx(0)
		ReDim ballvely(0)
	End Sub
	
	Public Sub Update()	'tracks in-ball-velocity
		' OPT16: merged two For Each loops into one. Eliminates a full extra pass
		'        over all balls (~100 extra COM reads/sec at 4 balls × 100Hz).
		Dim b, AllBalls, highestID, bid
		allBalls = GetBalls

		For Each b In allballs
			bid = b.id
			If bid >= HighestID Then highestID = bid
		Next

		If UBound(ballvel) < highestID Then ReDim ballvel(highestID)
		If UBound(ballvelx) < highestID Then ReDim ballvelx(highestID)
		If UBound(ballvely) < highestID Then ReDim ballvely(highestID)

		For Each b In allballs
			bid = b.id
			ballvel(bid) = BallSpeed(b)
			ballvelx(bid) = b.velx
			ballvely(bid) = b.vely
		Next
	End Sub
End Class

' Note, cor.update must be called in a 10 ms timer. The example table uses the GameTimer for this purpose, but sometimes a dedicated timer call RDampen is used.

Sub RDampen_Timer
	Cor.Update
End Sub

'******************************************************
'****  END PHYSICS DAMPENERS
'******************************************************



'******************************************************
' 	ZBOU: VPW TargetBouncer for targets and posts by Iaakki, Wrd1972, Apophis
'******************************************************

Const TargetBouncerEnabled = 1	  '0 = normal standup targets, 1 = bouncy targets
Const TargetBouncerFactor = 0.9	 'Level of bounces. Recommmended value of 0.7-1

Sub TargetBouncer(aBall,defvalue)
	Dim zMultiplier, vel, vratio
	If TargetBouncerEnabled = 1 And aball.z < 30 Then
		'   debug.print "velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
		vel = BallSpeed(aBall)
		If aBall.velx = 0 Then vratio = 1 Else vratio = aBall.vely / aBall.velx
		Select Case Int(Rnd * 6) + 1
			Case 1
				zMultiplier = 0.2 * defvalue
			Case 2
				zMultiplier = 0.25 * defvalue
			Case 3
				zMultiplier = 0.3 * defvalue
			Case 4
				zMultiplier = 0.4 * defvalue
			Case 5
				zMultiplier = 0.45 * defvalue
			Case 6
				zMultiplier = 0.5 * defvalue
		End Select
		aBall.velz = Abs(vel * zMultiplier * TargetBouncerFactor)
		Dim avz : avz = aBall.velz   ' OPT15: cache + x*x replaces ^2
		aBall.velx = Sgn(aBall.velx) * Sqr(Abs((vel * vel - avz * avz) / (1 + vratio * vratio)))
		aBall.vely = aBall.velx * vratio
		'   debug.print "---> velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
		'   debug.print "conservation check: " & BallSpeed(aBall)/vel
	End If
End Sub

'Add targets or posts to the TargetBounce collection if you want to activate the targetbouncer code from them
Sub TargetBounce_Hit(idx)
	TargetBouncer ActiveBall, 1
End Sub



'******************************************************
'	ZSSC: SLINGSHOT CORRECTION FUNCTIONS by apophis
'******************************************************
' To add these slingshot corrections:
'	 - On the table, add the endpoint primitives that define the two ends of the Slingshot
'	 - Initialize the SlingshotCorrection objects in InitSlingCorrection
'	 - Call the .VelocityCorrect methods from the respective _Slingshot event sub

Dim LS
Set LS = New SlingshotCorrection
Dim RS
Set RS = New SlingshotCorrection

InitSlingCorrection

Sub InitSlingCorrection
	LS.Object = LeftSlingshot
	LS.EndPoint1 = EndPoint1LS
	LS.EndPoint2 = EndPoint2LS
	
	RS.Object = RightSlingshot
	RS.EndPoint1 = EndPoint1RS
	RS.EndPoint2 = EndPoint2RS
	
	'Slingshot angle corrections (pt, BallPos in %, Angle in deg)
	' These values are best guesses. Retune them if needed based on specific table research.
	AddSlingsPt 0, 0.00, - 4
	AddSlingsPt 1, 0.45, - 7
	AddSlingsPt 2, 0.48,	0
	AddSlingsPt 3, 0.52,	0
	AddSlingsPt 4, 0.55,	7
	AddSlingsPt 5, 1.00,	4
End Sub

Sub AddSlingsPt(idx, aX, aY)		'debugger wrapper for adjusting flipper script In-game
	Dim a
	a = Array(LS, RS)
	Dim x
	For Each x In a
		x.addpoint idx, aX, aY
	Next
End Sub

'' The following sub are needed, however they may exist somewhere else in the script. Uncomment below if needed
'Dim PI: PI = 4*Atn(1)
'Function dSin(degrees)
'	dsin = sin(degrees * Pi/180)
'End Function
'Function dCos(degrees)
'	dcos = cos(degrees * Pi/180)
'End Function
'
'Function RotPoint(x,y,angle)
'	dim rx, ry
'	rx = x*dCos(angle) - y*dSin(angle)
'	ry = x*dSin(angle) + y*dCos(angle)
'	RotPoint = Array(rx,ry)
'End Function

Class SlingshotCorrection
	Public DebugOn, Enabled
	Private Slingshot, SlingX1, SlingX2, SlingY1, SlingY2
	
	Public ModIn, ModOut
	
	Private Sub Class_Initialize
		ReDim ModIn(0)
		ReDim Modout(0)
		Enabled = True
	End Sub
	
	Public Property Let Object(aInput)
		Set Slingshot = aInput
	End Property
	
	Public Property Let EndPoint1(aInput)
		SlingX1 = aInput.x
		SlingY1 = aInput.y
	End Property
	
	Public Property Let EndPoint2(aInput)
		SlingX2 = aInput.x
		SlingY2 = aInput.y
	End Property
	
	Public Sub AddPoint(aIdx, aX, aY)
		ShuffleArrays ModIn, ModOut, 1
		ModIn(aIDX) = aX
		ModOut(aIDX) = aY
		ShuffleArrays ModIn, ModOut, 0
		If GameTime > 100 Then Report
	End Sub
	
	Public Sub Report() 'debug, reports all coords in tbPL.text
		If Not debugOn Then Exit Sub
		Dim a1, a2
		a1 = ModIn
		a2 = ModOut
		Dim str, x
		For x = 0 To UBound(a1)
			str = str & x & ": " & Round(a1(x),4) & ", " & Round(a2(x),4) & vbNewLine
		Next
		TBPout.text = str
	End Sub
	
	
	Public Sub VelocityCorrect(aBall)
		Dim BallPos, XL, XR, YL, YR
		
		'Assign right and left end points
		If SlingX1 < SlingX2 Then
			XL = SlingX1
			YL = SlingY1
			XR = SlingX2
			YR = SlingY2
		Else
			XL = SlingX2
			YL = SlingY2
			XR = SlingX1
			YR = SlingY1
		End If
		
		'Find BallPos = % on Slingshot
		If Not IsEmpty(aBall.id) Then
			If Abs(XR - XL) > Abs(YR - YL) Then
				BallPos = PSlope(aBall.x, XL, 0, XR, 1)
			Else
				BallPos = PSlope(aBall.y, YL, 0, YR, 1)
			End If
			If BallPos < 0 Then BallPos = 0
			If BallPos > 1 Then BallPos = 1
		End If
		
		'Velocity angle correction
		If Not IsEmpty(ModIn(0) ) Then
			Dim Angle, RotVxVy
			Angle = LinearEnvelope(BallPos, ModIn, ModOut)
			'   debug.print " BallPos=" & BallPos &" Angle=" & Angle
			'   debug.print " BEFORE: aBall.Velx=" & aBall.Velx &" aBall.Vely" & aBall.Vely
			RotVxVy = RotPoint(aBall.Velx,aBall.Vely,Angle)
			If Enabled Then aBall.Velx = RotVxVy(0)
			If Enabled Then aBall.Vely = RotVxVy(1)
			'   debug.print " AFTER: aBall.Velx=" & aBall.Velx &" aBall.Vely" & aBall.Vely
			'   debug.print " "
		End If
	End Sub
End Class