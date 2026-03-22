TNA-applied-changes.md — Applied Optimization & Bug Fix Changes
============================================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

## PERFORMANCE OPTIMIZATIONS

1. MODULE-LEVEL STATE VARS + CACHED TABLE DIMENSIONS (~line 212)
   Added: Dim tablewidth: tablewidth = table1.width
   Added: Dim tableheight: tableheight = table1.height
   Added: Dim lastLFAngle, lastRFAngle
   tablewidth/tableheight eliminate table1.width/.height COM reads in AudioFade/AudioPan/Pan.
   lastXxx vars initialize to Empty (VBScript default), causing first-frame write to always fire.

2. AudioFade: REPLACE ^10 WITH REPEATED SQUARING + CLAMP + USE CACHED tableheight (~line 1451)
   Replaced tmp ^10 / -((-tmp) ^10) with:
     t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2  (3 multiplications)
   Added clamp to +/-7000 range (prevents overflow).
   Replaced table1.height with cached tableheight.
   Preserved On Error Resume Next for error handling.
   Eliminates 1 ^ dispatch + 1 COM read per AudioFade call.

3. AudioFadeXY: NEW VARIANT ACCEPTING PRE-CACHED Y SCALAR (~line 1469)
   Added AudioFadeXY(ByVal y) — same repeated-squaring logic, accepts scalar instead of object.
   Eliminates tableobj.y COM read for hot-path callers (RollingUpdate).

4. AudioPan: REPLACE ^10 WITH REPEATED SQUARING + CLAMP + USE CACHED tablewidth (~line 1486)
   Same repeated-squaring pattern as AudioFade.
   Replaced table1.width with cached tablewidth.
   Preserved On Error Resume Next.
   Eliminates 1 ^ dispatch + 1 COM read per AudioPan call.

5. AudioPanXY: NEW VARIANT ACCEPTING PRE-CACHED X SCALAR (~line 1504)
   Added AudioPanXY(ByVal x) — same repeated-squaring logic, accepts scalar instead of object.
   Eliminates tableobj.x COM read for hot-path callers (RollingUpdate).

6. Pan: REPLACE ^10 WITH REPEATED SQUARING + CLAMP + USE CACHED tablewidth (~line 1521)
   Same repeated-squaring pattern as AudioPan.
   Replaced table1.width with cached tablewidth.
   Preserved On Error Resume Next.
   Eliminates 1 ^ dispatch + 1 COM read per Pan call.

7. Vol: CACHE BallVel RESULT + REPLACE ^2 WITH MULTIPLICATION (~line 1539)
   Changed: Csng(BallVel(ball) ^2 / VolDiv)
   To: Dim bv : bv = BallVel(ball) : Csng(bv * bv / VolDiv)
   Eliminates 1 ^ dispatch per Vol call. Caches BallVel to avoid duplicate call.

8. BallVel: REPLACE ^2 WITH MULTIPLICATION (~line 1548)
   Changed: INT(SQR((ball.VelX ^2) + (ball.VelY ^2)))
   To:      INT(SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY))
   Eliminates 2 ^ dispatches per BallVel call.

9. VolZ: CACHE BallVelZ RESULT + REPLACE ^2 WITH MULTIPLICATION (~line 1556)
   Changed: Csng(BallVelZ(ball) ^2 / 200)*1.2
   To: Dim bvz : bvz = BallVelZ(ball) : Csng(bvz * bvz / 200) * 1.2
   Eliminates 1 ^ dispatch per VolZ call. Caches BallVelZ result.

10. BallRollStr ARRAY: PRE-BUILD ROLLING SOUND NAME STRINGS (~line 1585)
    Added ReDim BallRollStr(tnob) + init loop building "fx_ballrolling0".."fx_ballrolling6".
    Replaced all 3 occurrences of "fx_ballrolling" & b in RollingUpdate with BallRollStr(b).
    Eliminates 3 string allocations per ball per RollingUpdate tick.
    At 100Hz x 2 balls (typical): ~600 string allocs/sec eliminated.
    At 100Hz x 6 balls (multiball): ~1,800 string allocs/sec eliminated.

11. RollingUpdate: CACHE BOT(b) PROPERTIES + INLINE BallVel/Vol/Pitch (~line 1596)
    Added bx, by, bz, bvx, bvy, bvel to sub Dim statement.
    At top of per-ball loop: cached BOT(b).X/Y/Z/VelX/VelY into locals.
    bvel = INT(SQR(bvx * bvx + bvy * bvy)) — inlined BallVel with no ^ ops.
    Inlined Vol: Csng(bvel * bvel / VolDiv) — no function call.
    Inlined Pitch: bvel * 20 — no function call.
    Replaced AudioPan(BOT(b)) with AudioPanXY(bx) — passes cached x.
    Replaced AudioFade(BOT(b)) with AudioFadeXY(by) — passes cached y.
    BallVel was called 3x per rolling ball (condition + Vol + Pitch); now called 0x.
    Eliminates ~14 COM reads per ball per tick.
    At 100Hz x 2 balls: ~2,800 COM reads/sec eliminated.
    At 100Hz x 6 balls (multiball): ~8,400 COM reads/sec eliminated.

12. OnBallBallCollision: REPLACE ^2 + CACHE CSng(velocity) (~line 1636)
    Changed: Csng(velocity) ^2 / (VolDiv/VolCol)
    To: Dim cv : cv = Csng(velocity) : cv * cv / (VolDiv/VolCol)
    Eliminates 1 ^ dispatch per ball-ball collision event.

13. BallShadow ARRAY: MOVE TO MODULE LEVEL (~line 1642)
    Moved: BallShadow = Array(BallShadow1,...BallShadow6) from inside sub to module level.
    Previously rebuilt every BallShadow_Timer tick — now built once at init.
    Eliminates 1 array allocation per tick.
    At 100Hz: ~100 allocs/sec eliminated.

14. BallShadow_Timer: CACHE BOT(b) PROPERTIES (~line 1644)
    Added bx, by, bz to sub Dim statement.
    Cached BOT(b).X/Y/Z into locals at top of per-ball loop.
    All shadow property writes now use cached bx/by/bz.
    BOT(b).Z was read 4x per ball — now read 1x.
    Eliminates 3 redundant COM reads per ball per tick.
    At 100Hz x 6 balls: ~1,800 COM reads/sec eliminated.

15. RealTime_Timer: CACHE FLIPPER ANGLES + GUARD RotZ WRITES (~line 1680)
    LeftFlipper.CurrentAngle cached into 'a'; RotZ write guarded by lastLFAngle comparison.
    RightFlipper.CurrentAngle cached into 'a'; RotZ write guarded by lastRFAngle comparison.
    Flippers idle ~80%+ of frames -> eliminates ~96 COM writes/sec at 60Hz.

16. BallSpeed: REPLACE ^2 WITH MULTIPLICATION (~line 8104)
    Changed: SQR(ball.VelX^2 + ball.VelY^2 + ball.VelZ^2)
    To:      SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY + ball.VelZ * ball.VelZ)
    Eliminates 3 ^ dispatches per BallSpeed call. Not hot-path but still beneficial.

---

## ULTRADMD BUG FIXES

17. UDMD HOLD-OFF VARIABLE (~line 215)
    Added: Dim udmdHoldOffUntil: udmdHoldOffUntil = 0
    Module-level variable tracks when the current UDMD scene expires.
    Used by uDMDScoreUpdate to skip DisplayScoreboard calls while a scene is active.

18. uDMDScoreUpdate: HOLD-OFF + HIGH SCORE GUARDS (~line 110)
    Added: If hsbModeActive Then Exit Sub        (line 111)
    Added: If Timer < udmdHoldOffUntil Then Exit Sub  (line 112)
    First guard: prevents DisplayScoreboard from overwriting during high score entry.
    Second guard: prevents DisplayScoreboard from overwriting DisplayScene00Ex scenes
    (e.g. "BALL SAVED", jackpot awards) during their display time.

19. UDMD SUB: SET HOLD-OFF TIMER AFTER SCENE DISPLAY (~line 8219)
    Added: If utime > 100 Then udmdHoldOffUntil = Timer + (utime / 1000)
    Any UDMD call with duration > 100ms now blocks scoreboard updates for that duration.
    Timer returns seconds since midnight; utime is in milliseconds, so divide by 1000.

20. HighScoreEntryInit: DISABLE SCORE TIMER (~line 3047)
    Added: uDMDScoreTimer.Enabled = False
    Stops the 5-second scoreboard refresh timer entirely during high score entry.
    Belt-and-suspenders with the hsbModeActive guard — ensures no DisplayScoreboard00
    calls can fire while the initials picker is active.

21. HighScoreDisplayName: CENTERLINE PADDING FOR DMDUpdate (~line 3128)
    Changed: dLine(1) = TempTopStr
    To:      dLine(1) = CenterLine(1, TempTopStr)
    CenterLine pads the string to dCharsPerLine(1) = 19 characters.
    Without padding, DMDUpdate crashes with VBSE_ILLEGAL_FUNC_CALL at the
    ASC(mid(dLine(id), digit+1, 1)) call when the string is shorter than 19 chars.
    This was the root cause of the "random crashes with no log" — the crash occurred
    in DMDUpdate which has no error handler.

22. HighScoreDisplayNameNow: CANCEL RENDERING + TRIM (~line 3116-3117)
    Added: If UseUltraDMD > 0 Then UltraDMD.CancelRendering   (line 3116)
    Changed: UDMD "NEW HIGH SCORE", "ENTER INITIALS", 5000
    To:      UDMD Trim(dLine(1)), Trim(dLine(2)), 5000         (line 3117)
    CancelRendering breaks out of the persistent DisplayScoreboard00 mode before
    showing the scene. Without it, the scoreboard reasserts itself over DisplayScene00Ex.
    Trim strips the CenterLine padding (19-char space-padded strings) so UltraDMD
    auto-sizes the font to fit the actual text, not 19 characters of spaces.

23. HighScoreFlashTimer_Timer: CANCEL RENDERING + TRIM (~line 3159-3160)
    Added: If UseUltraDMD > 0 Then UltraDMD.CancelRendering   (line 3159)
    Changed: UDMD "NEW HIGH SCORE", "ENTER INITIALS", 5000
    To:      UDMD Trim(dLine(1)), Trim(dLine(2)), 5000         (line 3160)
    Same fix as HighScoreDisplayNameNow — this sub fires every 250ms to flash the
    current letter cursor. Each call needs CancelRendering + Trim to keep the
    initials picker visible on UltraDMD.

24. HighscoreDelay: RE-ENABLE SCORE TIMER (~line 3185)
    Added: uDMDScoreTimer.Enabled = True
    Restores the 5-second scoreboard refresh timer after high score entry completes.
    Called 800ms after HighScoreCommitName via vpmtimer.addtimer.

25. SHORTENED UDMD LABELS — PREVENT TEXT OVERFLOW
    DisplayScene00Ex auto-sizes font based on string length. No font size parameter
    is available. Long strings cause text to extend outside the DMD bounding box.

    Line 1977: "UNUSED BALLSAVE"   -> "BALLSAVE BONUS"
    Line 2364: "CONGRATULATIONS"   -> "CONGRATS!"       (game over screen)
    Line 2888: "DOUBLE JACKPOT"    -> "DBL JACKPOT"
    Line 2897: "TRIPLE JACKPOT"    -> "TRPL JACKPOT"
    Line 5110: "MULTI-BALL TOTAL"  -> "MBALL TOTAL"     (DMD line)
    Line 5111: "MULTI-BALL TOTAL"  -> "MBALL TOTAL"     (UDMD call)
    Line 6794: "CONGRATULATIONS"   -> "CONGRATS!!!"     (DMD line, reactor destroyed)
    Line 6795: "CONGRATULATIONS"   -> "CONGRATS!"       (UDMD call, reactor destroyed)
    Line 7439: "AWARD LANE SAVE"   -> "+LANE SAVE"      (with empty bottom text)

    Note: "REACTOR JACKPOT" intentionally kept at full length.

26. AddReactorBonus: GUARD debug.print (~line 6851)
    Changed: debug.print "ReactorBonus: " & ReactorBonus
    To:      If debugReactor Then debug.print "ReactorBonus: " & ReactorBonus
    The unguarded debug.print fired on every AddReactorBonus call, flooding the log.
    Now only prints when debugReactor is True (matching other reactor debug prints).

---

## SUMMARY

^ dispatches eliminated:
  - AudioFade: 1 ^10 per call                    = per-ball/tick + events
  - AudioPan: 1 ^10 per call                     = per-ball/tick + events
  - Pan: 1 ^10 per call                          = per-event
  - BallVel: 2 ^2 per call                       = per non-hot-path call
  - Vol: 1 ^2 per call                           = per non-hot-path call
  - VolZ: 1 ^2 per call                          = per-event
  - OnBallBallCollision: 1 ^2 per event          = per-event
  - BallSpeed: 3 ^2 per call                     = per-call (not hot path)

COM reads eliminated per tick:
  - RollingUpdate: ~14 reads/ball/tick            = ~2,800 reads/sec (2 balls x 100Hz typical)
  - AudioFade/AudioPan table dims: 2/call         = ~800 reads/sec
  - BallShadow BOT(b).Z: 3 reads/ball/tick       = ~1,800 reads/sec (6 balls x 100Hz)
  Total: ~5,400 COM reads/sec (typical), ~11,000 during multiball

COM writes eliminated:
  - RealTime_Timer: 2 writes/frame when idle      = ~96 writes/sec at 60Hz

String allocations eliminated:
  - BallRollStr: 3 per ball per tick              = ~600 allocs/sec (typical), ~1,800 multiball

Object allocations eliminated:
  - BallShadow array: 1 per tick                  = ~100 allocs/sec

UltraDMD bugs fixed:
  - Scene hold-off prevents scoreboard from overwriting transient displays
  - High score initials: CancelRendering + timer disable + Trim + CenterLine crash fix
  - 9 long labels shortened to prevent text overflow
  - Unguarded debug.print in AddReactorBonus
