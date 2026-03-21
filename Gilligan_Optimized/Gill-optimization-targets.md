Gill-optimization-targets.md (vpxFile_Gill.vbs) — Ranked Optimization Targets
================================================================================
File: vpxFile_Gill.vbs (1497 lines, Option Explicit active)
Table: Gilligan's Island (Bally 1991) — tnob = 7 (up to 7 balls)

Hot-path timers identified:
  - RollingTimer_Timer (~100Hz) — ball rolling sounds, line 1068
  - BallShadowTimer_timer (~100Hz) — ball shadow positions, line 1113
  - RealTime_timer (~60Hz, per-frame) — flipper mesh rotation, line 1145
  - LampTimer_Timer (10ms/100Hz) — lamp fading + UpdateLamps, line 1262
  - GateTimer_Timer (per-frame) — gate wire rotation, line 716
  - TurnTableTimer_Timer (solenoid-gated) — island rotation, line 655

---

### RANK 1: RollingTimer — CACHE BOT(b) PROPERTIES + INLINE BallVel (~line 1068)
Status: [x]

Current code calls GetBalls every tick, then per ball:
  - BallVel(BOT(b)) for condition check → reads .VelX, .VelY (2 COM reads)
  - Vol(BOT(b)) calls BallVel again → 2 more COM reads
  - Pitch(BOT(b)) calls BallVel again → 2 more COM reads
  - AudioPan(BOT(b)) reads .x + Gilligan.width (2 COM reads)
  - AudioFade(BOT(b)) reads .y + Gilligan.height (2 COM reads)
  - BOT(b).z read 3× directly (lines 1086, 1098, 1098)
  - BOT(b).VelZ read 1× (line 1098)
  - Total: ~15-20 COM reads per ball per tick

Optimization:
  - Cache bx, by, bz, bvx, bvy, bvz into locals at top of loop
  - Compute bvel = INT(SQR(bvx*bvx + bvy*bvy)) once (inline BallVel, no ^)
  - Inline Vol/Pitch using bvel: vol = bvel*bvel/400, pitch = bvel*20
  - Use AudioPanXY(bx)/AudioFadeXY(by) to pass cached scalars
  - Replace all BOT(b).property reads in loop body with locals

Estimated savings:
  BallVel called 3× per rolling ball → 0× (fully inlined)
  At 100Hz × 7 balls: ~10,500 COM reads/sec eliminated
  Plus 2,100 function call frames/sec eliminated (3 BallVel + Vol + Pitch per ball)

---

### RANK 2: AudioFade/AudioPan — ^10 REPEATED SQUARING + CACHE TABLE DIMS + XY VARIANTS (~line 1021)
Status: [x]

Current code:
  - AudioFade: tmp ^10 / -((-tmp) ^10) — expensive COM float dispatch
  - AudioPan: same pattern
  - Both read Gilligan.height / Gilligan.width per call (COM property reads)
  - No clamp — values can exceed ±7000 causing overflow

Optimization:
  - Replace ^10 with repeated squaring: t2=tmp*tmp, t4=t2*t2, t8=t4*t4, result=t8*t2
    (3 multiplies instead of 1 COM power dispatch)
  - Cache Gilligan.width/height into module-level tablewidth/tableheight at init
  - Add clamp to ±7000 range (matching Fathom pattern)
  - Add AudioFadeXY(ByVal y) / AudioPanXY(ByVal x) variants for hot-path callers

Estimated savings:
  2× ^10 dispatches per AudioFade call, 2× per AudioPan call
  2 COM reads (Gilligan.width/height) per call eliminated
  At 100Hz × 7 balls × 2 calls: ~2,800 ^10 dispatches/sec + ~2,800 COM reads/sec eliminated
  Plus event handler calls (lower frequency)

---

### RANK 3: BallVel/Vol/OnBallBallCollision — ^2 → MULTIPLY (~line 1042)
Status: [x]

Current code:
  - BallVel (line 1050): ball.VelX ^2 + ball.VelY ^2
  - Vol (line 1042): BallVel(ball) ^2 / 400
  - OnBallBallCollision (line 1109): Csng(velocity) ^2 / 2000

Optimization:
  - BallVel: ball.VelX * ball.VelX + ball.VelY * ball.VelY
  - Vol: Dim bv : bv = BallVel(ball) : Vol = Csng(bv * bv / 400)
  - OnBallBallCollision: Dim cv : cv = Csng(velocity) : ... cv * cv / 2000

Estimated savings:
  BallVel: 2 ^2 dispatches per call (still used by non-hot-path event handlers)
  Vol: 1 ^2 dispatch per call + caches BallVel result
  OnBallBallCollision: 1 ^2 dispatch per event

---

### RANK 4: PRE-BUILD SOUND NAME STRINGS (~line 1057)
Status: [x]

Current code:
  - "fx_ballrolling" & b — 4 occurrences in RollingTimer loop (lines 1075, 1087, 1089, 1093)
  - "fx_ball_drop" & b — 1 occurrence (line 1099)
  - Each concatenation allocates a new string every tick

Optimization:
  - ReDim BallRollStr(tnob) + init loop: BallRollStr(i) = "fx_ballrolling" & i
  - ReDim BallDropStr(tnob) + init loop: BallDropStr(i) = "fx_ball_drop" & i
  - Replace all "fx_ballrolling" & b with BallRollStr(b)
  - Replace "fx_ball_drop" & b with BallDropStr(b)

Estimated savings:
  5 string allocations per ball per tick
  At 100Hz × 7 balls: ~3,500 string allocs/sec eliminated

---

### RANK 5: BallShadowTimer — CACHE BOT(b).Z + PRE-BUILD BallShadow ARRAY (~line 1113)
Status: [x]

Current code:
  - BallShadow = Array(BallShadow1,...BallShadow8) — rebuilt EVERY tick (line 1115)
  - BOT(b).Z read 4× per ball per tick (lines 1130, 1135, 1136, 1139)
  - BOT(b).X read 1×, BOT(b).Y read 1× — could share with RollingTimer if merged
  - GetBalls called independently of RollingTimer — second COM allocation per tick

Optimization:
  - Move BallShadow array to module level (built once at init)
  - Cache BOT(b).X, BOT(b).Y, BOT(b).Z into locals per iteration
  - Reduces 4 COM reads to 1 per ball for Z

Estimated savings:
  3 redundant BOT(b).Z reads per ball per tick
  At 100Hz × 7 balls: ~2,100 COM reads/sec eliminated
  Plus 1 array allocation per tick (~100 allocs/sec eliminated)

---

### RANK 6: RealTime_timer + GateTimer — GUARD FLIPPER/GATE RotZ/RotX WRITES (~line 1145, 716)
Status: [x]

Current code:
  RealTime_timer (line 1145):
    lfs.RotZ = LeftFlipper.CurrentAngle       — unconditional every frame
    rfs.RotZ = RightFlipper.CurrentAngle       — unconditional every frame
  GateTimer_Timer (line 716):
    Primitive_VUKGateWire.RotX = -VUKGate.Currentangle    — unconditional
    Primitive_GateWire.RotX = -Gate4.Currentangle          — unconditional

Optimization:
  - Add module-level lastLFAngle, lastRFAngle, lastVUKGateAngle, lastGate4Angle
  - Guard each write: If a <> lastAngle Then lastAngle = a : obj.RotZ = a
  - Cache CurrentAngle into local to avoid double COM read in comparison

Estimated savings:
  Flippers idle ~80%+ of frames → ~96 wasted writes/sec eliminated at 60Hz
  Gates idle ~95%+ → ~114 wasted writes/sec eliminated at 60Hz
  Total: ~210 COM writes/sec eliminated when idle

---

## SUMMARY — ESTIMATED TOTAL SAVINGS

COM reads eliminated:
  - RollingTimer: ~10,500 reads/sec (7 balls × 100Hz)
  - AudioFade/AudioPan table dims: ~2,800 reads/sec
  - BallShadowTimer BOT(b).Z: ~2,100 reads/sec
  Total: ~15,400 COM reads/sec

^ dispatches eliminated:
  - AudioFade/AudioPan ^10: ~2,800/sec
  - BallVel ^2: per non-hot-path call
  - Vol ^2: per non-hot-path call
  - OnBallBallCollision ^2: per event

COM writes eliminated:
  - Flipper + gate guards: ~210 writes/sec when idle

String allocations eliminated:
  - Rolling/drop sound names: ~3,500 allocs/sec

Function call frames eliminated:
  - BallVel/Vol/Pitch inlined in hot path: ~2,100 frames/sec

Object allocations eliminated:
  - BallShadow array: ~100 allocs/sec
