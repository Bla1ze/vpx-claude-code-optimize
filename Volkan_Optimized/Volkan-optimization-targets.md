# Volkan Steel and Metal - Optimization Targets (Ranked)

## Table Profile
- **Lines:** 10,243
- **Balls:** 5 (persistent gBOT array, no GetBalls per frame)
- **Flippers:** 4 (LeftFlipper, RightFlipper, LeftFlipper2, RightFlipper2)
- **Flipper timer:** 1ms (1000Hz!) — line 6956
- **LampTimer:** 16ms (already reasonable)
- **LampTimer2:** -1 (frame rate)
- **FrameTimer:** frame rate (calls RollingSoundUpdate + DynamicBSUpdate)

## Ranked Targets

### 1. CRITICAL — RightFlipper_timer at 1ms (line 6956)
- **Frequency:** 1000Hz — 4× FlipperTricks + 2× FlipperNudge per tick
- **Impact:** 4000 FlipperTricks + 2000 FlipperNudge calls/sec
- **Fix:** 1ms → 10ms with press/state guard to skip when all flippers at rest
- **Savings:** ~24,000 sub calls/sec eliminated when flippers idle

### 2. HIGH — FrameTimer_Timer write guards (line 221)
- **Frequency:** Every frame (~60Hz)
- **Impact:** 5 unconditional COM writes (4 flipper prims + blastdoor) = 300 writes/sec
- **Fix:** Track last angles, only write RotZ/rotx when changed
- **Savings:** ~300 COM writes/sec when flippers at rest

### 3. HIGH — RollingSoundUpdate string concat (line 8020)
- **Frequency:** Every frame (~60Hz), 5 balls
- **Impact:** Up to 20+ string concats per frame (BallRollStr, WireRollStr, PlasticRollStr × 5 balls)
- **Fix:** Pre-built string arrays at module level
- **Savings:** ~1500+ string allocs/sec

### 4. HIGH — RollingSoundUpdate COM caching (line 8020)
- **Frequency:** Every frame, 5 balls
- **Impact:** gBOT(b).z/x/y/VelZ read 5+ times per ball per frame
- **Fix:** Cache into locals at top of each iteration
- **Savings:** ~1500 COM reads/sec

### 5. HIGH — DynamicBSUpdate COM caching + constants (line 10050)
- **Frequency:** Every frame, 5 balls
- **Impact:** gBOT(s).X/Y/Z read 8-12 times each per ball, repeated divisions (tablewidth/2, BallSize/AmbientMovement, BallSize/10, BallSize/4)
- **Fix:** Cache bx/by/bz, pre-compute TW_d2/BS_dAM/BS_d10/BS_d4/BS_d2
- **Savings:** ~2000 COM reads/sec + ~600 divisions/sec

### 6. HIGH — DynamicBSUpdate DynamicBSFactor^3 + distance-squared gating (line 10162)
- **Frequency:** Every frame, per ball × numberofsources
- **Impact:** DynamicBSFactor^3 computed twice per ball, Distance() calls SQR when could use dist²
- **Fix:** Pre-compute DynBSFactor3, add falloffSq guard to skip far sources early
- **Savings:** ~600 ^3 dispatch ops/sec + early-exit on distant sources

### 7. HIGH — AudioFade/AudioPan ^10 → multiply chain (lines 7794, 7812)
- **Frequency:** Called per ball per frame from RollingSoundUpdate
- **Impact:** ^10 exponentiation dispatch
- **Fix:** t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2
- **Savings:** ~600 ^10 dispatch ops/sec

### 8. MEDIUM — Pre-computed constants
- `PIover180 = PI / 180` — used in dSin, dCos, Radians, FlipperTrigger
- `d180overPI = 180 / PI` — used in AnglePP
- `InvTWHalf = 2 / tablewidth` — for AudioPan
- `InvTHHalf = 2 / tableheight` — for AudioFade
- `TW_d2 = tablewidth / 2` — for DynamicBSUpdate
- `BS_dAM = BallSize / AmbientMovement` — for DynamicBSUpdate
- `BS_d10 = BallSize / 10`, `BS_d4 = BallSize / 4`, `BS_d2 = BallSize / 2`
- `DynBSFactor3 = DynamicBSFactor^3`

### 9. MEDIUM — BallVel/Vol/BallSpeed ^2 → multiply + COM caching (lines 7846, 7836, 6909)
- **Fix:** Cache ball.VelX/VelY into locals, replace ^2 with multiply
- **Savings:** ~600 COM reads/sec + ~600 ^2 ops/sec

### 10. MEDIUM — VolPlayfieldRoll/VolPlasticMetalRampRoll/PitchPlayfieldRoll ^(-2) (lines 7856, 7872, 7884)
- **Fix:** Rewrite `(0.75*x/(1-x))^(-2)` as `r=(1-x)/(0.75*x) : r*r`
- **Savings:** ~300 ^(-2) dispatch ops/sec

### 11. MEDIUM — Distance ^2 → multiply (line 7032)
- **Fix:** `dx=ax-bx : dy=ay-by : SQR(dx*dx+dy*dy)`
- Called from DynamicBSUpdate inner loop — hot path

### 12. MEDIUM — FlipperTricks caching (line 7142)
- **Fix:** Cache startangle/currentangle into locals
- **Savings:** ~200 COM reads/sec (at 10ms timer)

### 13. MEDIUM — CoRTracker elimination of GetBalls (line 7360)
- **Fix:** Use persistent gBOT array, pre-allocate to tnob, single-pass
- **Savings:** 1 GetBalls COM call + 2 loops → 1 loop per update

### 14. LOW — VolSpinningDiscRoll ^3 → multiply (line 7867)
- **Fix:** `bv*bv*bv` instead of `BallVel(ball)^3`

### 15. LOW — OnBallBallCollision ^2 → multiply (line 8161)
- **Fix:** `Csng(velocity * velocity)` instead of `Csng(velocity)^2`

### 16. LOW — dSin/dCos/Radians/AnglePP use PIover180/d180overPI (lines 7002-7045)
- **Fix:** Replace `Pi/180` and `180/PI` with pre-computed constants
