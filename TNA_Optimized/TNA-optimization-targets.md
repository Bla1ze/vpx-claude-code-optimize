TNA-optimization-targets.md — Ranked Optimization & Bug Fix Targets
================================================================================
File: Total Nuclear Annihilation (Spooky Pinball 2017)_Bigus(MOD)2.0.vbs (9109 lines, Option Explicit)
Table: Total Nuclear Annihilation — tnob = 6, lob = 4 (4 locked balls always on table)

Hot-path timers identified:
  - GameTimer_Timer (~100Hz) — calls RollingUpdate, line 1596
  - BallShadow_Timer (~100Hz) — ball shadow positions, line 1644
  - RealTime_Timer (~60Hz, per-frame) — flipper mesh rotation, line 1680
  - RainbowTimer_Timer (40ms/25Hz) — LED color cycling, line 3995 (only during rainbow effects)
  - GiReactorEffectTimer_Timer (50-150ms) — reactor GI effects, line 1139
  - GiEffectTimer_Timer (50-100ms) — GI transition effects, line 1320

Note: table always has 4 locked balls; RollingUpdate exits early when only locked balls present.
During multiball, up to 6 active balls. Normal play: 1-2 rolling balls.

---

## PERFORMANCE OPTIMIZATIONS

### RANK 1: RollingUpdate — CACHE BOT(b) PROPERTIES + INLINE BallVel/Vol/Pitch (~line 1596)
Status: [x]

Current code calls GetBalls every tick, then per ball:
  - BallVel(BOT(b)) for condition check → reads .VelX, .VelY (2 COM reads)
  - Vol(BOT(b)) calls BallVel again → 2 more COM reads + ^2 dispatch
  - Pitch(BOT(b)) calls BallVel again → 2 more COM reads
  - AudioPan(BOT(b)) reads .x + table1.width (2 COM reads)
  - AudioFade(BOT(b)) reads .y + table1.height (2 COM reads)
  - BOT(b).z read 2x in condition (z < 30 AND z > 10)
  - Total: ~14 COM reads per ball per tick

Optimization:
  - Cache bx, by, bz, bvx, bvy, bvz into locals at top of loop
  - Compute bvel = INT(SQR(bvx*bvx + bvy*bvy)) once (inline BallVel, no ^)
  - Inline Vol: Csng(bvel * bvel / VolDiv)
  - Inline Pitch: bvel * 20
  - Use AudioPanXY(bx)/AudioFadeXY(by) to pass cached scalars
  - Replace all BOT(b).property reads with locals

Estimated savings:
  BallVel called 3x per rolling ball -> 0x (fully inlined)
  At 100Hz x 2 rolling balls (typical): ~2,800 COM reads/sec eliminated
  At 100Hz x 6 balls (multiball): ~8,400 COM reads/sec eliminated

---

### RANK 2: AudioFade/AudioPan/Pan — ^10 REPEATED SQUARING + CACHE TABLE DIMS + XY VARIANTS (~line 1451)
Status: [x]

Current code:
  - AudioFade (line 1451): tmp ^10 / -((-tmp) ^10) + reads table1.height per call
  - AudioPan (line 1486): same pattern + reads table1.width per call
  - Pan (line 1521): same ^10 pattern + reads table1.width per call (ball.x variant)
  - All three have `On Error Resume Next` — must preserve this
  - No clamp — values can exceed +/-7000 causing overflow

Optimization:
  - Replace ^10 with repeated squaring: t2=tmp*tmp, t4=t2*t2, t8=t4*t4, result=t8*t2
  - Cache table1.width/height into module-level tablewidth/tableheight at init
  - Add clamp to +/-7000 range
  - Add AudioFadeXY(ByVal y) / AudioPanXY(ByVal x) variants for hot-path callers
  - Pan function: same ^10 fix + use cached tablewidth

Estimated savings:
  6x ^10 dispatches per rolling ball per tick (AudioFade + AudioPan each in RollingUpdate)
  2 COM reads (table1.width/height) per call eliminated
  At 100Hz x 2 balls: ~400 ^10 dispatches/sec + ~800 COM reads/sec eliminated

---

### RANK 3: BallVel/Vol/VolZ/OnBallBallCollision/BallSpeed — ^2 -> MULTIPLY (~line 1539)
Status: [x]

Current code:
  - BallVel (line 1548): ball.VelX ^2 + ball.VelY ^2
  - Vol (line 1539): BallVel(ball) ^2 / VolDiv
  - VolZ (line 1556): BallVelZ(ball) ^2 / 200 * 1.2
  - OnBallBallCollision (line 1636): Csng(velocity) ^2 / (VolDiv/VolCol)
  - BallSpeed (line 8104): ball.VelX^2 + ball.VelY^2 + ball.VelZ^2

Optimization:
  - BallVel: ball.VelX * ball.VelX + ball.VelY * ball.VelY
  - Vol: Dim bv : bv = BallVel(ball) : Csng(bv * bv / VolDiv)
  - VolZ: Dim bvz : bvz = BallVelZ(ball) : Csng(bvz * bvz / 200) * 1.2
  - OnBallBallCollision: Dim cv : cv = Csng(velocity) : cv * cv / (VolDiv/VolCol)
  - BallSpeed: ball.VelX*ball.VelX + ball.VelY*ball.VelY + ball.VelZ*ball.VelZ

Estimated savings:
  BallVel: 2 ^2 dispatches per call
  Vol: 1 ^2 dispatch per call + caches BallVel
  VolZ: 1 ^2 dispatch per call + caches BallVelZ
  OnBallBallCollision: 1 ^2 dispatch per event
  BallSpeed: 3 ^2 dispatches per call (not hot path)

---

### RANK 4: PRE-BUILD SOUND NAME STRINGS (~line 1585)
Status: [x]

Current code:
  - "fx_ballrolling" & b — 3 occurrences in RollingUpdate (lines 1603, 1621, 1625)
  - Each concatenation allocates a new string every tick

Optimization:
  - ReDim BallRollStr(tnob) + init loop: BallRollStr(i) = "fx_ballrolling" & i
  - Replace all "fx_ballrolling" & b with BallRollStr(b)

Estimated savings:
  3 string allocations per ball per tick
  At 100Hz x 2 rolling balls: ~600 string allocs/sec eliminated
  At 100Hz x 6 balls (multiball): ~1,800 string allocs/sec eliminated

---

### RANK 5: BallShadow_Timer — CACHE BOT(b).Z + PRE-BUILD BallShadow ARRAY (~line 1644)
Status: [x]

Current code:
  - BallShadow = Array(BallShadow1,...BallShadow6) — rebuilt EVERY tick
  - BOT(b).Z read 4x per ball per tick
  - BOT(b).X read 1x, BOT(b).Y read 1x
  - GetBalls called independently of RollingUpdate — second COM allocation per tick

Optimization:
  - Move BallShadow array to module level (built once at init, line 1642)
  - Cache BOT(b).X, BOT(b).Y, BOT(b).Z into locals per iteration

Estimated savings:
  3 redundant BOT(b).Z reads per ball per tick
  At 100Hz x 6 balls: ~1,800 COM reads/sec eliminated
  Plus 1 array allocation per tick (~100 allocs/sec eliminated)

---

### RANK 6: RealTime_Timer — GUARD FLIPPER RotZ WRITES (~line 1680)
Status: [x]

Current code:
  lfs.RotZ = LeftFlipper.CurrentAngle       — unconditional every frame
  rfs.RotZ = RightFlipper.CurrentAngle       — unconditional every frame

Optimization:
  - Add module-level lastLFAngle, lastRFAngle (line 214)
  - Guard each write: If a <> lastAngle Then lastAngle = a : obj.RotZ = a

Estimated savings:
  Flippers idle ~80%+ of frames -> ~96 wasted writes/sec eliminated at 60Hz

---

## ULTRADMD BUG FIXES

### UDMD 1: SCOREBOARD OVERWRITES DisplayScene00Ex SCENES (~line 110, 215, 8219)
Status: [x]

Problem:
  uDMDScoreUpdate (called every 5s by uDMDScoreTimer, and from DMDScore) calls
  DisplayScoreboard00 which is a persistent mode. It immediately overwrites any
  DisplayScene00Ex scene (e.g. "BALL SAVED", jackpot awards, mode announcements).

Fix:
  - Added module-level udmdHoldOffUntil variable (line 215), initialized to 0
  - UDMD sub (line 8219) sets udmdHoldOffUntil = Timer + (utime / 1000) for scenes > 100ms
  - uDMDScoreUpdate (line 112) checks If Timer < udmdHoldOffUntil Then Exit Sub

---

### UDMD 2: HIGH SCORE INITIALS NOT SHOWING ON ULTRADMD (~line 3044-3185)
Status: [x]

Problem:
  DisplayScoreboard00 puts UltraDMD into a persistent scoreboard mode that keeps
  reasserting itself over DisplayScene00Ex scenes. The scoreboard was activated before
  high score entry started and kept overwriting the initials picker. Three sub-issues:

  A) HighScoreFlashTimer_Timer was showing static "NEW HIGH SCORE" / "ENTER INITIALS"
     text instead of the actual letter picker content from dLine(1)/dLine(2).

  B) uDMDScoreUpdate (via uDMDScoreTimer every 5s) was overwriting with scoreboard
     even during high score entry because there was no guard.

  C) dLine values padded to 19 chars by CenterLine caused UltraDMD to auto-size
     font too small (fitting 19 chars of spaces).

  D) Even with guards, DisplayScoreboard00 is persistent/sticky and keeps reasserting.

Fix:
  - HighScoreDisplayNameNow (line 3117) and HighScoreFlashTimer_Timer (line 3160):
    Changed to UDMD Trim(dLine(1)), Trim(dLine(2)), 5000
    Trim strips CenterLine padding so UltraDMD sizes font to actual text.

  - uDMDScoreUpdate (line 111): Added If hsbModeActive Then Exit Sub

  - HighScoreEntryInit (line 3047): Added uDMDScoreTimer.Enabled = False
    Stops the scoreboard timer entirely during high score entry.

  - HighScoreDisplayNameNow (line 3116) and HighScoreFlashTimer_Timer (line 3159):
    Added If UseUltraDMD > 0 Then UltraDMD.CancelRendering before each UDMD call.
    Breaks out of persistent scoreboard mode so DisplayScene00Ex actually shows.

  - HighscoreDelay (line 3185): Added uDMDScoreTimer.Enabled = True
    Restores scoreboard timer after high score entry completes.

---

### UDMD 3: DMDUpdate CRASH — UNPADDED dLine STRING (~line 3128)
Status: [x]

Problem:
  HighScoreDisplayName was setting dLine(1) = TempTopStr directly (14 chars) without
  padding to dCharsPerLine(1) = 19 characters. DMDUpdate iterates 19 chars using
  ASC(mid(dLine(id), digit+1, 1)) — crashes with VBSE_ILLEGAL_FUNC_CALL when the
  string is shorter than 19 chars. This was the root cause of "random crashes with
  no log" — the crash occurred in DMDUpdate which has no error handler.

Fix:
  - Changed dLine(1) = TempTopStr to dLine(1) = CenterLine(1, TempTopStr) (line 3128)
  - CenterLine pads the string to 19 characters, preventing the out-of-bounds mid() call.

---

### UDMD 4: SHORTENED LABELS — PREVENT TEXT OVERFLOW
Status: [x]

Problem:
  DisplayScene00Ex auto-sizes font based on string length. No font size parameter
  is available. Long strings cause text to extend outside the DMD bounding box.

Fix — shortened the following labels:
  - Line 1977: "UNUSED BALLSAVE"   -> "BALLSAVE BONUS"
  - Line 2364: "CONGRATULATIONS"   -> "CONGRATS!"      (game over screen)
  - Line 2888: "DOUBLE JACKPOT"    -> "DBL JACKPOT"
  - Line 2897: "TRIPLE JACKPOT"    -> "TRPL JACKPOT"
  - Line 5110: "MULTI-BALL TOTAL"  -> "MBALL TOTAL"    (DMD line)
  - Line 5111: "MULTI-BALL TOTAL"  -> "MBALL TOTAL"    (UDMD call)
  - Line 6794: "CONGRATULATIONS"   -> "CONGRATS!!!"    (DMD line, reactor destroyed)
  - Line 6795: "CONGRATULATIONS"   -> "CONGRATS!"      (UDMD call, reactor destroyed)
  - Line 7439: "AWARD LANE SAVE"   -> "+LANE SAVE"     (with empty bottom text)

  Note: "REACTOR JACKPOT" intentionally kept at full length.

---

### UDMD 5: UNGUARDED debug.print IN AddReactorBonus (~line 6851)
Status: [x]

Problem:
  debug.print "ReactorBonus: " & ReactorBonus fired on every AddReactorBonus call
  with no guard, flooding the log output.

Fix:
  - Changed to: If debugReactor Then debug.print "ReactorBonus: " & ReactorBonus
  - Matches the guard pattern used by other reactor debug prints (lines 7018-7069).

---

## SUMMARY — ESTIMATED TOTAL SAVINGS (typical 2 rolling balls)

COM reads eliminated:
  - RollingUpdate: ~2,800 reads/sec (2 balls x 100Hz)
  - AudioFade/AudioPan table dims: ~800 reads/sec
  - BallShadow BOT(b).Z: ~1,800 reads/sec
  Total: ~5,400 COM reads/sec (up to ~11,000 during multiball)

^ dispatches eliminated:
  - AudioFade/AudioPan ^10: ~400/sec
  - BallVel/Vol/VolZ ^2: per call
  - OnBallBallCollision ^2: per event
  - BallSpeed ^2: per call (not hot path)

COM writes eliminated:
  - Flipper guards: ~96 writes/sec when idle

String allocations eliminated:
  - BallRollStr: ~600 allocs/sec (up to ~1,800 in multiball)

Object allocations eliminated:
  - BallShadow array: ~100 allocs/sec

UltraDMD bugs fixed:
  - Scene hold-off prevents scoreboard from overwriting transient displays
  - High score initials display: CancelRendering + timer disable + Trim
  - DMDUpdate crash from unpadded dLine string (CenterLine fix)
  - Shortened long labels to prevent text overflow
  - Guarded unprotected debug.print in AddReactorBonus
