# Terminator 2 - Applied Optimization Changes

## 1. LampTimer 5ms → 10ms (line ~508)
- Changed `LampTimer.Interval = 5` to `10` (100Hz vs 200Hz)
- UpdateLamps has ~80+ NFadeL/NFadeLm/NFadeObj calls. The fading system uses integer FadingLevel states (0-13) with Select Case — halving frequency doesn't affect visual quality since VP handles actual light fading internally via `.state`.
- **Saves:** ~8,000 Select Case evaluations/sec (80+ calls × 100 fewer ticks/sec)

## 2. PRE-COMPUTED CONSTANTS (line ~406)
- `PIover180 = Pi / 180` — used in UpdateGun trig
- `TblW = Table1.Width`, `TblH = Table1.Height` — cached table dimensions
- `InvTWHalf = 2 / TblW`, `InvTHHalf = 2 / TblH` — for Pan/AudioFade
- `TW_d2 = TblW / 2` — for BallShadowUpdate
- `BS_d6 = BallSize / 6` — for BallShadowUpdate
- **Saves:** Eliminates per-call division in Pan, AudioFade, BallShadowUpdate

## 3. PRE-BUILT ROLLING SOUND STRINGS (line ~415)
- `BallRollStr(0..5)` array pre-built at init with `"fx_ballrolling0"` through `"fx_ballrolling5"`
- Replaces `"fx_ballrolling" & b` string concatenation in RollingTimer
- **Saves:** ~500 string allocs/sec (5 balls × 100Hz)

## 4. Pan — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~821)
- Replaced `tmp^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
- Handled negative branch separately with same pattern
- Replaced `* 2 / table1.width` with `* InvTWHalf`
- **Saves:** ~200 ^10 dispatch ops/sec + ~200 divisions/sec

## 5. AudioFade — ^10 → MULTIPLY CHAIN + DIVISION ELIMINATION (line ~835)
- Same multiply chain pattern as Pan
- Replaced `* 2 / Table1.height` with `* InvTHHalf`
- **Saves:** ~200 ^10 dispatch ops/sec + ~200 divisions/sec

## 6. BallVel — ^2 → MULTIPLY + COM CACHING (line ~829)
- Cached `ball.VelX` → `vx`, `ball.VelY` → `vy`
- Replaced `^2` with `vx*vx + vy*vy`
- **Saves:** 2 COM reads + 2 exponentiation ops per call

## 7. Vol — ^2 → MULTIPLY (line ~817)
- Cached BallVel result, replaced `^2` with `bv*bv`
- **Saves:** 1 exponentiation op per call

## 8. RollingTimer_Timer — STRING + COM OPTIMIZATION (line ~950)
- Replaced `"fx_ballrolling" & b` with `BallRollStr(b)` throughout
- Cached `UBound(BOT)` → `ub` once at sub entry
- Cached `BOT(b).z` → `bz` for reuse
- **Saves:** ~500 string allocs/sec + ~500 COM reads/sec

## 9. BallShadowUpdate_timer — COM CACHING + CONSTANTS (line ~1123)
- Cached `BOT(b).X/Y/Z` → `bx/by/bz` at top of each iteration
- Cached `UBound(BOT)` → `ub` once
- Used pre-computed `TW_d2` (was `Table1.Width/2`) and `BS_d6` (was `Ballsize/6`)
- **Saves:** ~1,500 COM reads/sec (5 balls × 4-5 reads × 60fps) + division elimination

## 10. GraphicsTimer_Timer — WRITE GUARDS (line ~1107)
- Added `lastLFAngle`/`lastRFAngle` tracking variables
- Only writes batleft/batright `.objrotz` and shadow `.objrotz` when flipper angle actually changed
- Caches CurrentAngle once and reuses for both bat and shadow
- **Saves:** ~240 COM writes/sec when flippers at rest (~80% of the time)

## 11. UpdateGun — PIover180 (line ~483)
- Replaced `CurrentPos*Pi/180` with `CurrentPos * PIover180`
- Computed `gRad` once, used for both Sin and Cos
- **Saves:** 2 divisions per gun update cycle

## 12. OnBallBallCollision — ^2 → MULTIPLY (line ~988)
- Replaced `Csng(velocity)^2` with `Csng(velocity * velocity)`
- **Saves:** 1 exponentiation op per collision (event-driven, minor)

## 13. BallInGunRadius — ^2 → MULTIPLY (line ~420)
- Replaced `(T2_Gun.X - Sw31.X)^2` with `gdx*gdx` using cached locals
- **Saves:** One-shot init, ensures consistency with optimization patterns

---

## Summary of Estimated Savings

| Category | Estimated ops/sec eliminated |
|----------|------------------------------|
| Select Case evaluations (lamp timer) | ~8,000 |
| COM property reads | ~2,500 |
| COM property writes | ~240 |
| Exponentiation dispatch (^10, ^2) | ~600 |
| String allocations | ~500 |
| Division operations | ~400 |
| **Total** | **~12,000-13,000 ops/sec** |

This is a smaller table (1,135 lines, 5 balls) so the savings are proportionally smaller than large tables, but the LampTimer halving alone is a significant win given the 80+ lamp calls per tick.
