DW (Doctor Who) — Applied Optimization Changes
================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. PRE-CACHED TABLE DIMENSIONS (line ~62)
   Added module-level vars: `tablewidth = table1.width`, `tableheight = table1.height`.
   Computed once at script load. Eliminates 2 COM reads per AudioFade/AudioPan call.
   At ~100Hz with 3 balls: eliminates ~600 COM reads/sec from RollingTimer alone,
   plus all PlaySoundAt/PlaySoundAtBall event calls.

2. PRE-BUILT SOUND STRINGS (line ~66)
   Added `RollStr(tnob)` = "fx_ballrolling0".."fx_ballrolling6" and
   `DropStr(tnob)` = "fx_ball_drop0".."fx_ball_drop6" arrays at script load.
   Eliminates "fx_ballrolling" & b and "fx_ball_drop" & b string concatenation
   in RollingTimer_Timer. With 3 balls at 100Hz: ~500 string allocs/sec eliminated.

3. HOISTED BALLSHADOW ARRAY TO MODULE LEVEL (line ~74, init at ~139)
   Moved `BallShadow = Array(BallShadow1,...BallShadow6)` from inside BallShadow_Timer
   to a module-level Dim, initialized once in Table1_Init.
   Eliminates 1 array allocation (6 Variant elements + 6 object refs) per tick.
   At 100Hz: ~100 array allocations/sec eliminated.

4. PREVIOUS-STATE TRACKING VARS (line ~77)
   Added `lastL67`, `lastGI33`, `lastGI32` for PrimTimer_Timer guarded writes.
   Added `lastSw32` for UpdateMiniPF guarded Controller.Switch(32) writes.
   All initialized to -1 (force first-frame write).

5. AudioFade/AudioPan — REPLACE ^10 WITH REPEATED SQUARING (line ~803)
   Replaced `tmp ^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
   (3 multiplications instead of generic VBS exponentiation dispatch).
   Replaced `table1.height` with cached `tableheight`, `table1.width` with `tablewidth`.
   Added `AudioFadeXY(y)` and `AudioPanXY(x)` variants that accept pre-cached scalars,
   eliminating `.x`/`.y` COM reads for hot-path callers (RollingTimer_Timer).
   Saves ~2 COM reads + 1 ^10 dispatch per call. At ~600 calls/sec: major.

6. ADDED BallVelSq HELPER (line ~847)
   Added `BallVelSq(vx, vy)` function returning `vx*vx + vy*vy` without SQR.
   Used inline in RollingTimer_Timer to compute Vol directly from velocity-squared
   (`velSq/400`) instead of `BallVel()^2/400` which redundantly SQRs then squares.
   Eliminates 1 SQR + 1 ^2 per ball per tick for volume computation.

7. RollingTimer_Timer REWRITE (line ~897)
   - Cache `UBound(BOT)` into local `ub`. Eliminates 2 redundant UBound calls/tick.
   - Cache `BOT(b).x`, `.y`, `.z`, `.VelX`, `.VelY`, `.VelZ` into locals at top of
     each ball iteration. Eliminates ~8-12 COM reads per ball per tick.
   - Compute `velSq = vx*vx + vy*vy` once; derive Vol as `velSq/400` (no SQR needed)
     and Pitch as `vel*20` from `vel = INT(SQR(velSq))`. Eliminates 2 redundant
     BallVel computations per ball per tick (Vol and Pitch each called BallVel internally).
   - Use `AudioPanXY(bx)` and `AudioFadeXY(by)` with cached scalars — computed once
     per ball, reused for both rolling sound and ball drop sound.
   - Use pre-built `RollStr(b)` and `DropStr(b)` instead of string concatenation.
   Total per ball per tick: ~12 COM reads eliminated, ~2 BallVel calls eliminated,
   ~5 string allocs eliminated, ~2 ^10 dispatches replaced.
   At 100Hz × 3 balls: ~3600 COM reads/sec, ~600 BallVel/sec, ~1500 string allocs/sec eliminated.

8. BallShadow_Timer REWRITE (line ~949)
   - Removed per-tick `BallShadow = Array(...)` — uses module-level array (see #3).
   - Cache `UBound(BOT)` into local `ub`.
   - Cache `BOT(b).X`, `.Y`, `.Z` into locals `bx`, `by`, `bz`. Eliminates 4 redundant
     `.Z` reads per ball per tick (was read 4 times, now 1).
   - Removed duplicate `.opacity = 80` — was set unconditionally in both branches to
     the same value. Opacity is now set at table load (always 80) and never re-written.
   At 100Hz × 3 balls: ~1200 COM reads/sec + 100 array allocs/sec eliminated.

9. PrimTimer_Timer — GUARDED VISIBLE WRITES (line ~775)
   - Read `Controller.Lamp(67)` into local `curL67`; only write `l67on.visible` and
     `l67onb.visible` when value differs from `lastL67`.
   - Read `GI33.State` and `GI32.State` into locals; only write `GI33b.visible` and
     `GI32b.visible` when values differ from `lastGI33`/`lastGI32`.
   Eliminates 4-6 unconditional COM writes per tick when lamp/GI states are stable
   (which is most ticks). At 100Hz: ~400-600 redundant COM writes/sec eliminated.

10. UpdateMiniPF — CACHE zpScaled + FIX SOUND BUG + GUARD SWITCH WRITE (line ~579)
    - Cached `ZPos * .7843` into local `zpScaled`, used for all three `For Each` loops.
      Eliminates 2 redundant multiplications per mech tick.
    - **Bug fix:** Moved `PlaySound "Motor-Old1"` from inside `For Each XX in MiniPF` loop
      to after the loop. Previously played N times per tick (once per collection element)
      instead of once. This is both a performance fix and an audio bug fix.
    - Guard `Controller.Switch(32)` write with `lastSw32` — only write when value changes.
      Eliminates ~95% of redundant COM switch writes.

11. FLASH SUBS — SIMPLIFIED INTENSITY MATH (lines ~449-543)
    Replaced `(Level / 2.55) / 100` with `Level / 255` in all 8 Flash subs
    (Flash06, Flash17, Flash18, Flash19, Flash20, Flash21, who_h, who_o, Flash24).
    Mathematically equivalent, eliminates 1 division per flasher call.
    Minor savings since these fire on solenoid events, not per-tick.

12. RollingTimer_Timer — BUG FIX: panVal/fadeVal FOR DROP SOUNDS (line ~917)
    Moved `panVal = AudioPanXY(bx)` and `fadeVal = AudioFadeXY(by)` before the
    `If vel > 1` check. Previously they were only computed inside the rolling branch,
    but the ball drop sound check at the bottom of the loop used them unconditionally.
    A ball could be dropping (VelZ < -1) while barely moving horizontally (vel <= 1),
    which would use stale/uninitialized panVal/fadeVal values.

13. TEShake — CACHE Pitch(activeball) (line ~635)
    Cached `Pitch(activeball) * -.01 / 2` into local `shakeY`, used for both
    `For Each XX in MiniPF` and `For Each XX in MiniPF2` loops.
    Eliminates 1 redundant Pitch() call (which internally calls BallVel → 2 COM reads).
    Minor savings since TEShake is event-driven (ball hit), not per-tick.

--- NOT APPLIED ---

14. POTENTIAL: Merge RollingTimer + BallShadow onto one timer
    Both call `GetBalls` independently every tick. If both timers use the same interval
    in the VPX editor (check table properties), merging into a single timer sub would
    eliminate ~100 GetBalls COM calls/sec. Requires verifying timer intervals in VPX
    since they're set on the table objects, not in script.
