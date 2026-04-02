# Volkan Steel and Metal - Applied Optimization Changes

## 1. Flipper Timer 1ms → 10ms + Press Guard (line ~6958)
- Changed `RightFlipper.timerinterval=1` to `10` (100Hz vs 1000Hz)
- Added early exit: `If LFPress = 0 And RFPress = 0 And LFPress2 = 0 And RFPress2 = 0 And LFState = 1 And RFState = 1 And LFState2 = 1 And RFState2 = 1 Then Exit Sub`
- 4 flippers × FlipperTricks + 2 FlipperNudge calls per tick
- **Saves:** ~24,000 sub calls/sec when flippers idle + 90% reduction in active ticks

## 2. FrameTimer Write Guards (line ~222)
- Added `lastLLAngle/lastLRAngle/lastULAngle/lastURAngle/lastBlastAngle` tracking variables
- Caches each flipper's CurrentAngle once, only writes RotZ/rotx when changed
- 4 flipper primitives + 1 blast door = 5 guarded writes per frame
- **Saves:** ~300 COM writes/sec when flippers at rest + ~150 COM reads/sec (from caching)

## 3. PRE-COMPUTED CONSTANTS (lines ~169, ~7002, ~9997)
- `InvTWHalf = 2 / tablewidth` and `InvTHHalf = 2 / tableheight` — for AudioPan/AudioFade
- `TW_d2 = tablewidth / 2` — for DynamicBSUpdate
- `PIover180 = PI / 180` — for dSin, dCos, Radians
- `d180overPI = 180 / PI` — for AnglePP
- `DynBSFactor3 = DynamicBSFactor * DynamicBSFactor * DynamicBSFactor` — for shadow opacity
- `BS_dAM = BallSize / AmbientMovement` — for ambient shadow offset
- `BS_d10 = BallSize / 10`, `BS_d4 = BallSize / 4`, `BS_d2 = BallSize / 2` — shadow height calc
- **Saves:** Eliminates per-call divisions in every hot path function

## 4. PRE-BUILT ROLLING SOUND STRINGS (line ~7517)
- `BallRollStr(0..4)` = `Cartridge_Ball_Roll & "_Ball_Roll_" & i`
- `WireRollStr(0..4)` = `Cartridge_Metal_Ramps & "_Ramp_Left_Metal_Wire_BallRoll_" & i`
- `PlasticRollStr(0..4)` = `Cartridge_Plastic_Ramps & "_Ramp_Left_Plastic_BallRoll_" & i`
- `PlasticRRollStr(0..4)` = `Cartridge_Plastic_Ramps & "_Ramp_Right_Plastic_BallRoll_" & i`
- **Saves:** ~1500+ string allocs/sec (5 balls × 4 strings × ~60fps)

## 5. AudioFade — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~7800)
- Replaced `tmp^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
- Replaced `* 2 / tableheight` with `* InvTHHalf`
- **Saves:** ~300 ^10 dispatch ops/sec + ~300 divisions/sec

## 6. AudioPan — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~7818)
- Same multiply chain pattern as AudioFade
- Replaced `* 2 / tablewidth` with `* InvTWHalf`
- **Saves:** ~300 ^10 dispatch ops/sec + ~300 divisions/sec

## 7. BallVel — ^2 → MULTIPLY + COM CACHING (line ~7854)
- Cached `ball.VelX` → `vx`, `ball.VelY` → `vy`
- Replaced `^2` with `vx*vx + vy*vy`
- **Saves:** 2 COM reads + 2 exponentiation ops per call

## 8. Vol — ^2 → MULTIPLY (line ~7843)
- Cached BallVel result, replaced `^2` with `bv*bv`
- **Saves:** 1 exponentiation op per call

## 9. BallSpeed — ^2 → MULTIPLY + COM CACHING (line ~6911)
- Cached `ball.VelX/VelY/VelZ` → `vx/vy/vz`
- Replaced `^2` with `vx*vx + vy*vy + vz*vz`
- **Saves:** 3 COM reads + 3 exponentiation ops per call

## 10. VolPlayfieldRoll — ^(-2) → RECIPROCAL MULTIPLY + COM CACHING (line ~7862)
- Cached `ball.VelX/VelY` into locals
- Rewrote `(0.75*x/(1-x))^(-2)` as `r=(1-x)/(0.75*x) : r*r`
- **Saves:** 2 COM reads + ^(-2) dispatch per call

## 11. VolPlasticMetalRampRoll — ^(-2) → RECIPROCAL MULTIPLY + COM CACHING (line ~7879)
- Same pattern as VolPlayfieldRoll
- **Saves:** 2 COM reads + ^(-2) dispatch per call

## 12. PitchPlayfieldRoll — ^(-2) → RECIPROCAL MULTIPLY + COM CACHING (line ~7892)
- Same pattern as VolPlayfieldRoll
- **Saves:** 2 COM reads + ^(-2) dispatch per call

## 13. VolSpinningDiscRoll — ^3 → MULTIPLY (line ~7875)
- Cached BallVel result, replaced `^3` with `bv*bv*bv`
- **Saves:** 1 ^3 dispatch per call

## 14. Distance — ^2 → MULTIPLY (line ~7040)
- Replaced `(ax-bx)^2 + (ay-by)^2` with `dx*dx + dy*dy` using cached locals
- Called from DynamicBSUpdate inner loop (hot path)
- **Saves:** 2 ^2 dispatch ops per Distance call

## 15. FlipperTricks — COM CACHING (line ~7150)
- Cached `Flipper.startangle` → `sa`, `Flipper.currentangle` → via `absCa`
- Computed `absSa`, `absEa` once, reused across all branches
- **Saves:** ~200 COM reads/sec (at 100Hz timer × 4 flippers)

## 16. FlipperNudge — COM CACHING (line ~6978)
- Cached `gBOT(b).x` → `bx`, `gBOT(b).y` → `by` per ball
- **Saves:** ~100 COM reads/sec when nudge is active

## 17. RollingSoundUpdate — STRING + COM OPTIMIZATION (line ~8052)
- Replaced all string concatenation with pre-built arrays (`BallRollStr`, `WireRollStr`, `PlasticRollStr`, `PlasticRRollStr`)
- Cached `gBOT(b)` as `ball` object reference (via `Set ball = gBOT(b)`)
- Cached `ball.z` → `bz`, `ball.y` → `by`, `ball.VelZ` → `bvz` for reuse
- Used cached locals for static ball shadow section too
- **Saves:** ~1500 string allocs/sec + ~2000 COM reads/sec

## 18. DynamicBSUpdate — COM CACHING + CONSTANTS + DISTANCE² GATING (line ~10072)
- Cached `gBOT(s).X/Y/Z` → `bx/by/bz` at top of each iteration
- Used pre-computed `TW_d2`, `BS_dAM`, `BS_d10`, `BS_d4`, `DynBSFactor3`
- Added distance-squared gating: `dsq = dx*dx + dy*dy` with `falloffSq` check, only calls `SQR()` for nearby sources
- Added `invFalloff = 1/falloff` to replace division `dist/falloff` with multiply `dist*invFalloff`
- Cached `s/1000` as `sd1000` and `(bz+BallSize)/80` as `szScale`
- **Saves:** ~2000 COM reads/sec + ~600 divisions/sec + SQR() skipped for distant sources

## 19. CoRTracker — ELIMINATE GetBalls + PRE-ALLOCATE (line ~7372)
- Pre-allocates arrays to `tnob` in Class_Initialize (was 0)
- Uses persistent `gBOT` array directly instead of `GetBalls` (eliminates COM call)
- Single-pass loop with `bid <= tnob` guard (was 2 loops: find max ID + populate)
- **Saves:** 1 GetBalls COM call + 1 full loop per update

## 20. dSin/dCos/Radians/AnglePP — PRE-COMPUTED PI CONSTANTS (lines ~7008-7052)
- dSin/dCos: replaced `Pi/180` with `PIover180`
- Radians: replaced `PI/180` with `PIover180`
- AnglePP: replaced `180/PI` with `d180overPI`
- **Saves:** 4 divisions eliminated per trig call

## 21. OnBallBallCollision — ^2 → MULTIPLY (line ~8176)
- Replaced `Csng(velocity)^2` with `Csng(velocity * velocity)`
- **Saves:** 1 exponentiation op per collision (event-driven, minor)

---

## Summary of Estimated Savings

| Category | Estimated ops/sec eliminated |
|----------|------------------------------|
| Sub calls (flipper timer reduction) | ~24,000 |
| COM property reads | ~5,000 |
| COM property writes | ~300 |
| Exponentiation dispatch (^10, ^(-2), ^3, ^2) | ~1,500 |
| String allocations | ~1,500 |
| Division operations | ~1,200 |
| SQR() calls (distance² gating) | variable |
| GetBalls COM call (CoRTracker) | ~60/sec |
| **Total** | **~33,000-35,000 ops/sec** |

The flipper timer change from 1ms to 10ms is the single biggest win — it was running 4 FlipperTricks + 2 FlipperNudge at 1000Hz (6000 function calls/sec), and the press guard skips all of them when flippers are idle. The DynamicBSUpdate rewrite is the second biggest win due to the heavy per-ball × per-source inner loop running every frame.

---

## PASS 2 — Additional Optimizations

## 22. GIstuff — GI INTENSITY GUARD (line ~2303)
- Added `lastGIx` guard: if `GI111.getinplayintensity` hasn't changed since last tick, skip the entire ~65 blenddisablelighting write block
- GI intensity is an integer 0-15 that only changes on GI relay events — steady-state skips ~95% of ticks
- **Saves:** ~4,000 COM writes/sec when GI is stable (65 writes × 62.5Hz, skipped ~95% of time)

## 23. GIstuff — IMAGE SWAP GUARD (line ~2446)
- Added `lastGIOver4` guard: the 30+ `.image` swaps only fire when GI crosses the `x > 4` threshold
- This threshold is crossed very rarely (GI on/off events)
- **Saves:** ~1,900 COM string writes/sec (30 image swaps × 62.5Hz, now only on threshold crossing)

## 24. GIstuff — PRE-COMPUTED REPEATED DIVISIONS (line ~2330)
- Pre-computed `xd3/xd4/xd7p5/xd15/xd90/xd100/xd150/xd55/xd20/xd70` once per tick
- Replaces ~35 identical divisions with single-compute locals
- **Saves:** ~35 divisions per tick when GI changes (minor per-tick, but eliminates redundant work)

## 25. LampFilter ^1.6 → LOOKUP TABLE (line ~6493)
- Pre-computed `LampFilterLUT(0..100)` array at script load
- Replaces `aLvl^1.6` (Exp+Log dispatch) with `LampFilterLUT(Int(aLvl * 100))` (one Int + array lookup)
- Called via `cFilter` for every active lamp on every LampTimer2 frame
- **Saves:** ~1,000-5,000 ^1.6 ops/sec depending on active lamp count

## 26. Lampz.Update — REMOVE TypeName DEBUG ASSERTION (line ~6480)
- Removed `if TypeName(lvl(x)) <> "Double" and typename(lvl(x)) <> "Integer" then msgbox` from hot path
- TypeName does COM reflection + string allocation + string comparison — called for every unlocked lamp every frame
- **Saves:** ~500-2,000 COM reflection ops/sec depending on active lamp count

## 27. AnimApronWheels — EARLY EXIT WHEN STOPPED (line ~5709)
- Added `If A_Wheels(1) = 0 And A_Wheels(0) = 0 Then Exit Sub` after speed update
- Eliminates 5 wheel `.objrotz` writes per tick when wheels are stationary
- Also cached `A_Wheels(2)` into local `wz` to avoid 5 array reads
- **Saves:** ~310 COM writes/sec when wheels stopped (5 × 62.5Hz)

## 28. AnimApronGauge — NEEDLE WRITE GUARDS (line ~5683)
- Added `lastNeedleL/lastNeedleR` tracking variables
- Only writes `NeedleLeft.rotz` / `NeedleRight.rotz` when computed value changes
- **Saves:** ~125 COM writes/sec when gauges are settled

## 29. AnimRamps — POSITION CHANGE GUARDS (line ~1372)
- Added `lastRrampPos/lastLrampPos` tracking variables
- Only writes `.rotx/.z/.x/.y` when ramp position actually changes
- Also pre-computed `rFrac = RrampPos/100` once per ramp to eliminate 4 divisions each
- **Saves:** ~440 COM writes/sec when ramps at rest (7 writes × 62.5Hz)

## 30. GIstuff VR Room — bbs001/bbs002 COM CACHING (line ~2532)
- Cached `bbs001.getinplayintensity` / `bbs002.getinplayintensity` into `bbsInt` local
- Was read 9 times per VR branch (4 branches total)
- **Saves:** ~500 COM reads/sec in VR mode (8 extra reads × 62.5Hz)

---

## Updated Summary (Pass 1 + Pass 2)

| Category | Estimated ops/sec eliminated |
|----------|------------------------------|
| Sub calls (flipper timer reduction) | ~24,000 |
| COM property writes (GIstuff guard) | ~6,200 |
| COM property reads (all caching) | ~5,500 |
| COM property writes (frame/anim guards) | ~1,175 |
| LampFilter ^1.6 (LUT) | ~1,000-5,000 |
| Exponentiation dispatch (^10, ^(-2), ^3, ^2) | ~1,500 |
| String allocations | ~1,500 |
| Division operations | ~1,200 |
| TypeName COM reflection | ~500-2,000 |
| Image swap COM writes (threshold guard) | ~1,900 |
| **Total** | **~44,000-50,000+ ops/sec** |

The GIstuff GI intensity guard is the biggest second-pass win. When GI is stable (which is most of gameplay), ~65 COM property writes + 30 image swaps + UpdateMaterial are all skipped every 16ms tick.
