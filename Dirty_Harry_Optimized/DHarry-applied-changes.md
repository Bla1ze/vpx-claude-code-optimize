Dirty Harry (vpxFile.vbs) — Applied Optimization Changes
=========================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. PRE-CACHED TABLE DIMENSIONS (line ~112)
   Added module-level vars: `tablewidth = table1.width`, `tableheight = table1.height`.
   Computed once at script load. Eliminates 2 COM reads per AudioFade/AudioPan call.
   At ~100Hz with 3 balls: eliminates ~600 COM reads/sec from RollingTimer alone,
   plus all PlaySoundAt/PlaySoundAtBall event calls.

2. PRE-BUILT SOUND STRINGS (line ~115)
   Added `RollStr(6)` = "fx_ballrolling0".."fx_ballrolling6" and
   `DropStr(6)` = "fx_ball_drop0".."fx_ball_drop6" arrays at script load.
   Eliminates "fx_ballrolling" & b and "fx_ball_drop" & b string concatenation
   in RollingTimer_Timer. With 3 balls at 100Hz: ~500 string allocs/sec eliminated.

3. HOISTED BALLSHADOW ARRAY TO MODULE LEVEL (line ~122, init in Table1_Init)
   Moved `BallShadow = Array(BallShadow1,...BallShadow6)` from inside BallShadowUpdate
   to a module-level `Dim BallShadow(5)`, initialized once in Table1_Init with `Set`.
   Eliminates 1 array allocation (6 Variant elements + 6 object refs) per tick.
   At 100Hz: ~100 array allocations/sec eliminated.

4. PREVIOUS-STATE TRACKING VARS (line ~125)
   Added `lastSw76` for updategun_Timer guarded Controller.Switch(76) writes.
   Added `lastLfsAngle`, `lastRfsAngle` for RealTime_Timer guarded flipper shadow writes.
   All initialized to sentinel values (force first-frame write).

5. AudioFade/AudioPan — REPLACE ^10 WITH REPEATED SQUARING (line ~933)
   Replaced `tmp ^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
   (3 multiplications instead of generic VBS exponentiation dispatch).
   Replaced `table1.height` with cached `tableheight`, `table1.width` with `tablewidth`.
   Added `AudioFadeXY(y)` and `AudioPanXY(x)` variants that accept pre-cached scalars,
   eliminating `.x`/`.y` COM reads for hot-path callers (RollingTimer_Timer).
   Also replaced `ball.VelX ^2` with `ball.VelX * ball.VelX` in BallVel.
   Saves ~2 COM reads + 1 ^10 dispatch per call. At ~600 calls/sec: major.

6. RollingTimer_Timer REWRITE (line ~980)
   - Cache `UBound(BOT)` into local `ub`. Eliminates 2 redundant UBound calls/tick.
   - Cache `BOT(b).x`, `.y`, `.z`, `.VelX`, `.VelY`, `.VelZ` into locals at top of
     each ball iteration. Eliminates ~8-12 COM reads per ball per tick.
   - Compute `velSq = vx*vx + vy*vy` once; derive Vol as `velSq/5000` (no SQR needed)
     and Pitch as `vel*20` from `vel = INT(SQR(velSq))`. Eliminates 2 redundant
     BallVel computations per ball per tick (Vol and Pitch each called BallVel internally).
   - Use `AudioPanXY(bx)` and `AudioFadeXY(by)` with cached scalars — computed once
     per ball, reused for both rolling sound and ball drop sound.
   - Use pre-built `RollStr(b)` and `DropStr(b)` instead of string concatenation.
   - BUG FIX: Moved `panVal`/`fadeVal` computation before the `vel > 1` check.
     Previously they were only available in the rolling branch, but the ball drop
     sound check used them unconditionally. A ball could be dropping (VelZ < -1)
     while barely moving horizontally (vel <= 1), using stale/uninitialized values.
   Total per ball per tick: ~12 COM reads eliminated, ~2 BallVel calls eliminated,
   ~5 string allocs eliminated, ~2 ^10 dispatches replaced.
   At 100Hz × 3 balls: ~3600 COM reads/sec, ~600 BallVel/sec, ~1500 string allocs/sec eliminated.

7. BallShadowUpdate REWRITE (line ~1038)
   - Removed per-tick `BallShadow = Array(...)` — uses module-level array (see #3).
   - Cache `UBound(BOT)` into local `ub`.
   - Cache `BOT(b).X`, `.Y`, `.Z` into locals `bx`, `by`, `bz`. Eliminates 4 redundant
     `.Z` reads per ball per tick (was read 5 times, now 1).
   At 100Hz × 3 balls: ~1500 COM reads/sec + 100 array allocs/sec eliminated.

8. RealTime_Timer — GUARDED FLIPPER SHADOW WRITES (line ~1028)
   - Cache `LeftFlipper.CurrentAngle` and `RightFlipper.CurrentAngle` into locals.
   - Only write `lfs.RotZ` / `rfs.RotZ` when angle differs from `lastLfsAngle`/`lastRfsAngle`.
   Eliminates 2 unconditional COM writes per tick when flippers are idle (most ticks).
   At 100Hz: ~200 redundant COM writes/sec eliminated.

9. RealTimeUpdates — CACHE FLIPPER ANGLES (line ~1069)
   Cached `LeftFlipper.CurrentAngle`, `RightFlipper1.CurrentAngle`,
   `RightFlipper.CurrentAngle` into locals before writing to flipper prims.
   Eliminates redundant COM reads (each `.CurrentAngle` is a COM property).
   Minor savings since each angle is only read once per call.

10. updategun_Timer — GUARD SWITCH WRITE (line ~345)
    Guard `Controller.switch(76)` write with `lastSw76` — only write when value changes.
    Eliminates ~95% of redundant COM switch writes during gun animation.

--- NOT APPLIED ---

11. POTENTIAL: Merge RollingTimer + BallShadowUpdate onto one timer
    Both call `GetBalls` independently every tick. If both timers use the same interval
    in the VPX editor, merging into a single timer sub would eliminate ~100 GetBalls
    COM calls/sec. Requires verifying timer intervals in VPX since they're set on
    the table objects, not in script. Note: BallShadowUpdate is called from
    RealTime_Timer, not its own timer, so this would mean inlining it there and
    sharing the BOT array with a rolling sound update.
