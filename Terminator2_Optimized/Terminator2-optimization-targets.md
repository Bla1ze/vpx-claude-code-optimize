# Terminator 2 - Optimization Targets (Ranked)

## 1. LampTimer at 5ms (line 495) — CRITICAL
**Current:** `LampTimer.Interval = 5` → 200Hz. UpdateLamps has ~80+ NFadeL/NFadeLm/NFadeObj calls, each doing a Select Case on FadingLevel(nr).
**Impact:** 80+ Select Case evaluations × 200Hz = 16,000+ evaluations/sec. Light fading at 60-100Hz is visually identical.
**Fix:** Increase interval to 10ms (100Hz).
**Saves:** ~8,000+ evaluations/sec

## 2. Audio functions — exponentiation + division (lines 804-834)
**Current:** `Pan`: `tmp^10`, `* 2 / table1.width`. `AudioFade`: `tmp^10`, `* 2 / Table1.height`. `BallVel`: `^2`. `Vol`: `BallVel^2 / 2000`.
**Impact:** Called multiple times per ball per tick from RollingTimer + collision handlers.
**Fix:** Multiply chain for ^10, pre-computed inverse table dimensions, multiply pattern for ^2.
**Saves:** ~500 exponentiation ops/sec + ~200 divisions/sec

## 3. RollingTimer — string concat + COM reads (line 938)
**Current:** `"fx_ballrolling" & b` string concat per ball per 10ms tick. No caching of BOT(b) properties.
**Impact:** 5 balls × 100Hz = 500 string allocs/sec + 500+ COM reads/sec
**Fix:** Pre-built string array, cache ball properties.
**Saves:** ~500 string allocs/sec + ~1,000 COM reads/sec

## 4. BallShadowUpdate — uncached COM reads + repeated math (line 1111)
**Current:** `BOT(b).X` read 4-5x per ball per frame. `Table1.Width/2` and `Ballsize/6` recomputed per ball.
**Impact:** Every frame × 5 balls.
**Fix:** Cache BOT(b).X/Y/Z, pre-compute constants.
**Saves:** ~1,500 COM reads/sec + division elimination

## 5. GraphicsTimer — unconditional COM writes (line 1095)
**Current:** Writes batleft/batright .objrotz and shadow .objrotz every frame regardless of change.
**Fix:** Guard with last-angle tracking.
**Saves:** ~240 COM writes/sec when flippers at rest

## 6. UpdateGun — per-call trig division (line 444)
**Current:** `Sin(CurrentPos*Pi/180)` and `Cos(CurrentPos*Pi/180)` — Pi/180 computed every call.
**Fix:** Pre-computed PIover180 constant.
**Saves:** Minor (gun motor speed), but trivial fix

## 7. OnBallBallCollision — exponentiation (line 974)
**Current:** `velocity^2` using generic dispatch.
**Fix:** `velocity * velocity`
**Saves:** Minor (event-driven)

## 8. BallInGunRadius — exponentiation (line 408)
**Current:** `SQR((T2_Gun.X - Sw31.X)^2 + (T2_Gun.Y - Sw31.Y)^2)`
**Fix:** multiply pattern.
**Saves:** One-shot init, trivial but consistent.
