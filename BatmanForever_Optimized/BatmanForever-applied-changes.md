# Batman Forever - Applied Optimization Changes

## 1. FLIPPER TIMER 1ms → 10ms + SHARED GetBalls + PRESS GUARD (line ~2170)
- Changed `RightFlipper.timerinterval=1` to `10` (100Hz vs 1000Hz, visually identical)
- Added press guard: `If LFPress = 0 And RFPress = 0 Then Exit Sub` — skips FlipperNudge entirely when flippers at rest
- Shared GetBalls: single `fBOT = GetBalls` call passed to both FlipperNudge calls
- Updated FlipperNudge signature to accept `fBOT` array as first parameter, removed internal GetBalls
- **Saves:** ~4,500 function calls/sec + ~2,000 GetBalls allocs/sec. When flippers at rest: eliminates 100% of FlipperNudge COM reads.

## 2. FlipperTricks — CACHE startangle AND currentangle (line ~2347)
- Cached `Flipper.startangle` → `sa`, `Abs(Flipper.currentangle)` → `ca`, `Abs(sa)` → `absSa`
- Replaced all `Abs(Flipper.startangle)` with `absSa`, all `Abs(Flipper.currentangle)` with `ca`
- **Saves:** ~6 COM reads/call × 2 flippers × 100Hz = ~1,200 COM reads/sec

## 3. FlipperNudge — CACHE currentangle + ball coords (line ~2154)
- Cached `Flipper1.currentangle` → `ca1` at top of sub
- Cached `UBound(fBOT)` → `ub` once
- Cached `fBOT(b).x/y` → `bx/by` locals before FlipperTrigger calls
- Removed internal GetBalls (now passed as parameter)
- **Saves:** ~4,000 COM reads/sec (at old 1000Hz rate; ~400/sec at new 100Hz)

## 4. FlipperTrigger — CACHE ALL FLIPPER PROPS (line ~2270)
- Cached `Flipper.x` → `fx`, `Flipper.y` → `fy`, `Flipper.currentangle` → `fca`, `Flipper.Length` → `flen`
- Pre-computed `frad = (fca + 90) * PIover180` once
- Inlined AnglePP using `Atn2` + `d180overPI` directly
- Replaced `DistanceFromFlipper` call with direct `DistancePL` using cached locals + inline trig
- **Saves:** ~10+ COM reads/call eliminated. At 100Hz × multiple balls = ~3,000+ COM reads/sec

## 5. FlipperTimer_Timer — WRITE GUARDS (line ~1087)
- Added `lastLFAngle`/`lastRFAngle` tracking variables (initialized to -9999)
- Only writes `FlipperLSh.RotZ` / `FlipperRSh.RotZ` when angle actually changed
- **Saves:** ~200 COM writes/sec when flippers at rest (they're static ~80% of the time)

## 6. FlasherTimer 5ms → 30ms (line ~955)
- Changed `FlasherTimer.Interval = 5` to `30` (33Hz vs 200Hz, visually smooth for fades)
- Scaled `FlashSpeedUp` from 50 to 300 and `FlashSpeedDown` from 10 to 60 (6x factor) to maintain identical fade wall-clock timing
- **Saves:** ~2,400 function calls/sec (14+ flash/flashm calls × 170 fewer ticks/sec)

## 7. PRE-COMPUTED TRIG CONSTANTS (line ~2184)
- Added `PIover180 = PI / 180` and `d180overPI = 180 / PI` at module level
- Updated `dSin`, `dCos`, `Radians` to use `PIover180` instead of `Pi/180`
- Updated `AnglePP` to use `d180overPI` instead of `180/PI`
- **Saves:** 2 divisions per trig call; called from FlipperTrigger, DynamicBSUpdate = ~2,000 divisions/sec

## 8. PRE-COMPUTED SHADOW/AUDIO CONSTANTS (line ~2188)
- `BS_d10 = BallSize/10`, `BS_d5 = BallSize/5`, `BS_d4 = BallSize/4`, `BS_d2 = BallSize/2`
- `TW_d2 = tablewidth/2`, `BS_dAM = BallSize/AmbientMovement`
- `DynBSFactor3 = DynamicBSFactor^3` (computed once, eliminates per-shadow `^3`)
- `InvTWHalf = 2/tablewidth`, `InvTHHalf = 2/tableheight` (for AudioFade/AudioPan)
- **Saves:** 6+ divisions per ball per frame in DynamicBSUpdate, 2 divisions per AudioFade/AudioPan call

## 9. DynamicBSUpdate REWRITE (line ~1391)
- Cached `gBOT(s).X/Y/Z` → `bx/by/bz` at top of each ball iteration (eliminates 10-20 COM reads/ball/frame)
- Cached `UBound(gBOT)` → `ub` once at sub entry
- Cached `DSSources(iii)(0/1)` → `sx/sy` in inner source loop
- Added distance-squared gating: `dsq = dx*dx + dy*dy`, only call `SQR()` when `dsq < falloffSq`
- Pre-computed `invFalloff = 1/falloff`, replaced `dist/falloff` with `dist * invFalloff`
- Used `DynBSFactor3` instead of `DynamicBSFactor^3` per shadow
- Used all pre-computed BS_d* constants for shadow positioning math
- **Saves:** ~3,000-6,000 COM reads/sec + ~60 Sqr() calls/frame + division elimination

## 10. Distance — ^2 → dx*dx (line ~2250)
- Replaced `(ax - bx)^2 + (ay - by)^2` with `dx*dx + dy*dy` using cached locals
- **Saves:** 2 exponentiation dispatch ops per call (called heavily from DynamicBSUpdate + FlipperTrigger)

## 11. AudioFade/AudioPan — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~3012)
- Replaced `tmp^10` with manual chain: `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
- Handled negative branch separately with same pattern
- Replaced `* 2 / tableheight` with `* InvTHHalf` and `* 2 / tablewidth` with `* InvTWHalf`
- **Saves:** ~400 divisions/sec + ~200 ^10 dispatch ops/sec

## 12. BallVel/Vol/Volz/VolPlayfieldRoll/PitchPlayfieldRoll — EXPONENTIATION ELIMINATION (line ~3040)
- `BallVel`: cached `ball.VelX/VelY` → `vx/vy`, replaced `^2` with `vx*vx + vy*vy`
- `Vol`: cached BallVel result, replaced `^2` with `bv*bv`
- `Volz`: cached `ball.velz` → `vz`, replaced `^2` with `vz*vz`
- `VolPlayfieldRoll`: cached BallVel result, replaced `^3` with `bv*bv*bv`
- `PitchPlayfieldRoll`: cached BallVel result, replaced `^2` with `bv*bv`
- **Saves:** ~1,000+ exponentiation ops/sec across all audio function calls

## 13. BallSpeed — EXPONENTIATION + COM CACHING (line ~2123)
- Cached `ball.VelX/VelY/VelZ` → `vx/vy/vz` locals
- Replaced `^2` with multiply: `vx*vx + vy*vy + vz*vz`
- **Saves:** 3 COM reads + 3 exponentiation ops per call

## 14. RollingUpdate — STRING + COM OPTIMIZATION (line ~2596)
- Replaced `"BallRoll_" & b` with pre-built `BallRollStr(b)` array lookups
- Cached `gBOT(b).z` → `bz` and `gBOT(b).VelZ` → `bvz` for reuse across conditionals
- Cached `UBound(gBOT)` → `ub` once
- Used pre-computed `BS_d4/BS_d5/BS_d2` for static shadow height math
- **Saves:** ~500 string allocs/sec + ~2,000 COM reads/sec

## 15. CoRTracker.Update — PRE-ALLOCATE + SINGLE PASS (line ~2548)
- Pre-allocated `ballvel/ballvelx/ballvely` arrays to `tnob` in Class_Initialize
- Replaced dual-pass (find highest ID, then iterate) with single pass using `bid <= tnob` guard
- Eliminated per-tick ReDim checks
- **Saves:** ~100 GetBalls/sec + ~300 ReDim checks/sec + eliminated double iteration

## 16. RampRollUpdate + WRemoveBall — STRING ELIMINATION (line ~2765)
- Replaced `"RampLoop" & x` with `RampLoopStr(x)` and `"wireloop" & x` with `WireLoopStr(x)`
- Applied to both RampRollUpdate and WRemoveBall subs
- **Saves:** ~50-200 string allocs/sec (depends on active ramp ball count)

## 17. FlipperDeactivate — COM CACHING (line ~2328)
- Cached `Flipper.x` → `fx` and `Flipper.y` → `fy` before ball loop
- **Saves:** Minor (event-driven), but prevents 2× COM reads per ball on flipper release

## 18. TargetBouncer — EXPONENTIATION (line ~1524)
- Replaced `vel^2`, `aBall.velz^2`, `vratio^2` with multiply pattern
- **Saves:** Minor (event-driven, ~few/sec), eliminates 3 exponentiation dispatch ops per call

---

## Summary of Estimated Savings

| Category | Estimated ops/sec eliminated |
|----------|------------------------------|
| Function calls (timer frequency) | ~7,000 |
| GetBalls allocations | ~2,100 |
| COM property reads | ~10,000-15,000 |
| COM property writes | ~200 |
| Exponentiation dispatch | ~1,500 |
| String allocations | ~700 |
| Division operations | ~2,500 |
| Sqr() calls | ~3,600 (60/frame × 60fps) |
| **Total** | **~27,000-32,000 ops/sec** |

These savings are most impactful during multiball (up to 11 balls) when every per-ball-per-tick operation is at maximum throughput.
