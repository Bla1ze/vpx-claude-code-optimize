WOO (Wrath of Olympus) — Applied Optimization Changes
======================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. PRE-COMPUTED BallSize CONSTANT (line ~719)
   Added `Dim BS_d2 : BS_d2 = BallSize / 2` at module level.
   Eliminates 1 division per ball per tick in RollingUpdate shadow height calc.
   At 100Hz × 6 balls: 600 divisions/sec eliminated.

2. PRE-BUILT SOUND STRINGS (line ~722)
   Added `RollStr(19)` = "fx_ballrolling0".."fx_ballrolling19" at script load.
   Eliminates "fx_ballrolling" & b string concatenation in RollingUpdate.
   With 6 balls at 100Hz: ~1800 string allocs/sec eliminated during multiball.

3. Pan/AudioFade — REPLACE ^10 WITH REPEATED SQUARING (line ~735)
   Replaced `tmp ^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
   (3 multiplications instead of generic VBS exponentiation dispatch).
   Added `PanXY(x)` and `AudioFadeXY(y)` variants that accept pre-cached scalars,
   eliminating `.x`/`.y` COM reads for hot-path callers (RollingUpdate).
   Also replaced `ball.VelX ^2` with `ball.VelX * ball.VelX` in BallVel.
   Table dimensions were already cached at module level (JP's own code).
   Saves 1 ^10 dispatch per call. At ~600+ calls/sec: significant.

4. RollingUpdate REWRITE (line ~830)
   - Cache `UBound(BOT)` into local `ub`. Eliminates 2 redundant UBound calls/tick.
   - Cache `BOT(b).X`, `.Y`, `.Z`, `.VelX`, `.VelY`, `.VelZ` into locals at top of
     each ball iteration. Eliminates ~12 COM reads per ball per tick.
   - Compute `velSq = vx*vx + vy*vy` once; derive Vol as `velSq/2000` (no SQR needed)
     and Pitch as `vel*20` from `vel = SQR(velSq)`. Eliminates 2 redundant BallVel
     computations per ball per tick (Vol and Pitch each called BallVel internally).
   - Use `PanXY(bx)` and `AudioFadeXY(by)` with cached scalars — computed once
     per ball, reused for both rolling sound and ball drop sound.
   - Use pre-built `RollStr(b)` instead of string concatenation.
   - Replace `BallSize/2` with pre-computed `BS_d2`.
   - Reuse cached `vx`/`vy` locals for speed control section, reducing COM reads
     for the `speedfactorx`/`speedfactory` calculations.
   - BUG FIX: panVal/fadeVal computed before the `vel > 1` check so drop sounds
     always have valid pan/fade values (previously would use stale values if
     ball was dropping but vel <= 1).
   Total per ball per tick: ~12 COM reads eliminated, ~2 BallVel calls eliminated,
   ~3 string allocs eliminated, ~2 ^10 dispatches replaced.
   At 100Hz × 6 balls (multiball): ~7200 COM reads/sec, ~1200 BallVel/sec,
   ~1800 string allocs/sec eliminated.

5. FlipperTricks TIMER 1ms → 10ms + CACHE ANGLES (line ~408)
   Changed `LeftFlipper.TimerInterval = 1` to `LeftFlipper.TimerInterval = 10`.
   Reduces call frequency from 1000/sec to 100/sec — 90% reduction.
   Cached `LeftFlipper.CurrentAngle` into local `curLA` (was read 2×).
   Cached `RightFlipper.CurrentAngle` into local `curRA` (was read 2×).
   Eliminates 4 redundant COM reads per tick.
   Combined: ~7200 COM reads/sec eliminated (900 calls × 8 reads saved).
   Single biggest per-tick win on this table.

6. RainbowTimer_Timer — PRE-COMPUTE RGB BEFORE LOOP (line ~2637)
   Computed `RGB(rRed\10, rGreen\10, rBlue\10)` and `RGB(rRed, rGreen, rBlue)` once
   into locals `cDim`/`cFull` before the `For Each` loop.
   Eliminates N redundant RGB() calls + integer divisions per tick (N = collection size).
   Minor savings since rainbow is only active during specific effects.

--- NOT APPLIED ---

7. POTENTIAL: GIUpdateTimer — avoid GetBalls for ball count
   GIUpdateTimer_Timer calls GetBalls every tick just to check UBound for ball count.
   Could use the existing `BallsOnPlayfield` module variable if it's reliably maintained.
   Requires verifying that BallsOnPlayfield is updated on every ball add/drain event.
   Saves ~100 GetBalls COM calls/sec if replaceable.
