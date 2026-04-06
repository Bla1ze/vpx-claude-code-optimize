# Tales from the Crypt - Applied Optimization Changes

## 1. LampTimer 5ms → 10ms (line ~410)
- Changed `LampTimer.Interval = 5` to `10` (100Hz vs 200Hz)
- UpdateLamps has ~100+ NFadeL/NFadeLm/NFadeObjm/Flash calls. VP handles actual light fading internally via `.state`, so halving frequency has no visible impact.
- **Saves:** ~10,000+ Select Case evaluations/sec (100+ calls × 100 fewer ticks/sec)

## 2. PRE-COMPUTED CONSTANTS (line ~795)
- `InvTWHalf = 2 / Table1.Width` and `InvTHHalf = 2 / Table1.Height` — eliminates per-call division in AudioFade, AudioPan, Pan
- **Saves:** 2 divisions per audio function call × hundreds of calls/sec

## 3. PRE-BUILT STRING ARRAYS (line ~798)
- `BallRollStr(0..8)` pre-built with `"fx_ballrolling0"` through `"fx_ballrolling8"`
- `BallDropStr(0..8)` pre-built with `"fx_ball_drop0"` through `"fx_ball_drop8"`
- Replaces per-tick string concatenation in RollingTimer
- **Saves:** ~800+ string allocs/sec (8 balls × 100Hz)

## 4. AudioFade — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~749)
- Replaced `tmp^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
- Handled negative branch separately
- Replaced `* 2 / table1.height` with `* InvTHHalf`
- **Saves:** ~300 ^10 dispatch ops/sec + ~300 divisions/sec

## 5. AudioPan — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~759)
- Same multiply chain pattern as AudioFade
- Replaced `* 2 / table1.width` with `* InvTWHalf`
- **Saves:** ~300 ^10 dispatch ops/sec + ~300 divisions/sec

## 6. Pan — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~769)
- Same pattern, replaces `* 2 / table1.width` with `* InvTWHalf`
- **Saves:** Additional ^10 + division elimination for ball-based pan calls

## 7. BallVel — ^2 → MULTIPLY + COM CACHING (line ~788)
- Cached `ball.VelX` → `vx`, `ball.VelY` → `vy`
- Replaced `^2` with `vx*vx + vy*vy`
- **Saves:** 2 COM reads + 2 exponentiation ops per call

## 8. Vol — ^2 → MULTIPLY (line ~779)
- Cached BallVel result, replaced `^2` with `bv*bv`
- **Saves:** 1 exponentiation op per call

## 9. RollingTimer_Timer — STRING + COM OPTIMIZATION (line ~819)
- Replaced `"fx_ballrolling" & b` with `BallRollStr(b)` throughout
- Replaced `"fx_ball_drop" & b` with `BallDropStr(b)`
- Cached `UBound(BOT)` → `ub` once
- Cached `BOT(b).z` → `bz` and `BOT(b).VelZ` → `bvz` for reuse
- **Saves:** ~800 string allocs/sec + ~800 COM reads/sec

## 10. BallShadowUpdate_timer — COM CACHING + ARRAY HOISTING (line ~863)
- Moved `BallShadow = Array(...)` to module level (was recreated every frame!)
- Cached `BOT(b).X/Y/Z` → `bx/by/bz` at top of each iteration
- Cached `UBound(BOT)` → `ub` once
- **Saves:** 1 array allocation/frame + ~1,500 COM reads/sec (8 balls × 3+ reads × 60fps)

## 11. FlipperTimer_Timer — WRITE GUARDS (line ~898)
- Added `lastLFAngle`/`lastRFAngle`/`lastRF1Angle` tracking variables
- Only writes RotZ/RotY when flipper angle actually changed
- Caches each flipper's CurrentAngle once and reuses for both shadow and logo (was 2 COM reads each → 1)
- 3 flippers × 2 objects each = 6 guarded writes per tick
- **Saves:** ~360 COM writes/sec when flippers at rest + ~180 COM reads/sec (from caching)

## 12. PrimT_Timer — WRITE GUARD (line ~386)
- Added `lastTombZ` tracking variable
- Computes target Z into local `newZ` first, only writes `tombstone.z` when value changed
- Most of the time tombstone is stationary, eliminating a COM write per tick
- **Saves:** ~60 COM writes/sec when tombstone is stationary

## 13. OnBallBallCollision — ^2 → MULTIPLY (line ~860)
- Replaced `Csng(velocity)^2` with `Csng(velocity * velocity)`
- **Saves:** 1 exponentiation op per collision (event-driven, minor)

---

## Summary of Estimated Savings

| Category | Estimated ops/sec eliminated |
|----------|------------------------------|
| Select Case evaluations (lamp timer) | ~10,000 |
| COM property reads | ~2,500 |
| COM property writes | ~420 |
| Exponentiation dispatch (^10, ^2) | ~900 |
| String allocations | ~800 |
| Division operations | ~600 |
| Array allocations (shadow) | ~60/frame |
| **Total** | **~15,000-16,000 ops/sec** |

The LampTimer halving is by far the biggest win given the 100+ lamp calls per tick. The BallShadow array hoisting is notable — creating an 8-element Variant array from scratch every frame is surprisingly expensive in VBS.
