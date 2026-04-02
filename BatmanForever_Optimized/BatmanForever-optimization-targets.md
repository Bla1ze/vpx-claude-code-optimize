# Batman Forever - Optimization Targets (Ranked)

## 1. RightFlipper_Timer at 1ms (line 2136) — CRITICAL
**Current:** `RightFlipper.timerinterval=1` → 1000Hz. Calls FlipperTricks 2x + FlipperNudge 2x per tick.
**Impact:** ~4500 function calls/sec eliminated by moving to 10ms. FlipperNudge calls GetBalls twice per tick = 2000 GetBalls allocs/sec.
**Fix:** Timer → 10ms, add press guard, share GetBalls between FlipperNudge calls.
**Saves:** ~6500+ function calls/sec, ~2000 GetBalls allocs/sec

## 2. FlipperTrigger / FlipperNudge / DistanceFromFlipper — COM reads (lines 2148-2240)
**Current:** FlipperTrigger reads Flipper.x, .y, .currentangle, .Length through multiple function calls (AnglePP, DistanceFromFlipper, Distance, Radians). Each FlipperTrigger call = ~10+ COM reads.
**Impact:** At 1000Hz × up to 11 balls × 2 flippers = massive COM overhead.
**Fix:** Cache flipper props into locals, inline DistanceFromFlipper, add pre-computed trig constants.
**Saves:** ~30,000+ COM reads/sec (with Fix 1 reducing to ~3,000/sec)

## 3. FlipperTricks — uncached COM reads (line 2313)
**Current:** Reads `Flipper.startangle` 3x and `Flipper.currentangle` 3x per call. At 1000Hz × 2 flippers = 12,000 COM reads/sec.
**Fix:** Cache startangle and currentangle into locals.
**Saves:** ~8,000 COM reads/sec (reduced proportionally after Fix 1)

## 4. DynamicBSUpdate — COM reads + repeated math (line 1357)
**Current:** `gBOT(s).X/Y/Z` read 10-20x per ball per frame without caching. `Ballsize/10`, `Ballsize/AmbientMovement`, `tablewidth/2` recomputed every frame. `DynamicBSFactor^3` computed per shadow. No distance-squared gating.
**Impact:** Every frame × up to 11 balls × up to 27 sources.
**Fix:** Pre-compute constants, cache COM reads into locals, distance-squared gate, pre-compute inverse falloff.
**Saves:** ~3,000-6,000 COM reads/sec + ~60 Sqr() calls/frame

## 5. FlasherTimer at 5ms (line 955) — timer frequency
**Current:** `FlasherTimer.Interval = 5` → 200Hz. Flasher fades are smooth at 33Hz.
**Fix:** Increase to 30ms.
**Saves:** ~170 timer invocations/sec × 14+ flash calls = ~2,400 function calls/sec

## 6. Distance function — exponentiation (line 2210)
**Current:** `SQR((ax - bx)^2 + (ay - by)^2)` — `^2` uses generic math dispatch.
**Fix:** `dx*dx + dy*dy` pattern.
**Saves:** Eliminates 2 exponentiation ops per call, called heavily from DynamicBSUpdate + FlipperTrigger.

## 7. AudioFade/AudioPan — exponentiation + division (lines 2962-2994)
**Current:** `tmp^10` uses generic dispatch. `* 2 / tableheight` division per call.
**Fix:** Manual multiplication chain for ^10, pre-computed InvTHHalf/InvTWHalf.
**Saves:** ~400 divisions/sec + ~200 ^10 ops/sec (from RollingUpdate + RampRollUpdate)

## 8. BallVel/Vol/VolPlayfieldRoll/PitchPlayfieldRoll — exponentiation (lines 2996-3017)
**Current:** `^2`, `^3` using generic dispatch. BallVel reads ball.VelX/VelY without caching.
**Fix:** Multiply pattern, cache COM reads.
**Saves:** ~1,000 exponentiation ops/sec

## 9. BallSpeed — exponentiation (line 2089)
**Current:** `SQR(ball.VelX^2 + ball.VelY^2 + ball.VelZ^2)`
**Fix:** Cache into locals, multiply pattern.
**Saves:** ~300 exponentiation ops/sec (called from CoRTracker + TargetBouncer)

## 10. RollingUpdate — string concatenation + COM reads (line 2552)
**Current:** `"BallRoll_" & b` string concat per ball per tick. No COM caching for gBOT(b) properties.
**Fix:** Pre-built BallRollStr array, cache ball properties.
**Saves:** ~500 string allocs/sec + ~2,000 COM reads/sec

## 11. CoRTracker.Update — GetBalls + ReDim (line 2501)
**Current:** Calls GetBalls independently (GameTimer already has gBOT). Iterates allballs twice. ReDim checks per tick.
**Fix:** Pre-allocate to tnob, use shared gBOT, single pass.
**Saves:** ~100 GetBalls/sec + ~300 ReDim checks/sec

## 12. RampRollUpdate — string concatenation (line 2721)
**Current:** `"RampLoop" & x` and `"wireloop" & x` per ball per tick.
**Fix:** Pre-built string arrays.
**Saves:** ~50-200 string allocs/sec (conditional on active ramp balls)

## 13. Pre-computed trig constants (line 2178)
**Current:** `Pi/180` and `180/PI` computed per call in dSin, dCos, Radians, AnglePP.
**Fix:** PIover180, d180overPI module-level vars.
**Saves:** ~2,000 divisions/sec

## 14. FlipperTimer_Timer — unconditional COM writes (line 1053)
**Current:** Writes FlipperLSh.RotZ and FlipperRSh.RotZ every tick, even when flippers haven't moved.
**Fix:** Guard with last-angle tracking.
**Saves:** ~200 COM writes/sec (at 100Hz after Fix 1 interval change)

## 15. TargetBouncer — exponentiation (line 1489)
**Current:** `vel^2`, `aBall.velz^2`, `vratio^2` using `^` operator.
**Fix:** Multiply pattern.
**Saves:** Minor (event-driven, ~few/sec), but trivial to fix.
