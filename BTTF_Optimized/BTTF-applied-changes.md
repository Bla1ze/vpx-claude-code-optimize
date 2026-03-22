BTTF (Back to the Future) — Applied Optimization Changes
=========================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. PRE-CACHED TABLE DIMENSIONS (line ~195)
   Added module-level vars: `tablewidth = bttf.width`, `tableheight = bttf.height`.
   Table object is named `bttf` (not `table1`). Computed once at script load.
   Eliminates 2 COM reads per Pan/AudioFade call.
   At ~100Hz with 3 balls: eliminates ~600 COM reads/sec from CollisionTimer alone.

2. PRE-COMPUTED TRIG CONSTANTS (line ~198)
   Added `DEG2RAD = 2*PI/180` and `DEG2RAD_HALF = 2*PI/360` at module level.
   Replaces `(2*PI/180)` and `(2*PI/360)` expressions recomputed every tick in MyTimer.
   Eliminates 4 constant expression evaluations per tick.

3. PRE-BUILT SOUND STRINGS (line ~201)
   Added `RollStr(7)` = "fx_ballrolling0".."fx_ballrolling7" and
   `MetalRollStr(7)` = "metalrolling0".."metalrolling7" at script load.
   Eliminates all string concatenation in CollisionTimer_Timer.
   With 3 balls at 100Hz: ~900 string allocs/sec eliminated.

4. HOISTED BALLSHADOW ARRAY TO MODULE LEVEL (line ~207, init in bttf_Init)
   Moved `BallShadow = Array(BallShadow1,...BallShadow7)` from inside BallShadowUpdate_timer
   to a module-level `Dim BallShadow(6)`, initialized once in bttf_Init with `Set`.
   Eliminates 1 array allocation (7 Variant elements + 7 object refs) per tick.
   At 100Hz: ~100 array allocations/sec eliminated.

5. PRE-CACHED RAMP WEDGE POSITIONS (init in bttf_Init, line ~324)
   Cached `pRampWedge1.x`, `.y`, `pRampWedge2.x`, `.y` into module-level vars.
   Pre-computed all 16 ±40 offsets (rw1ax..rw2dy) for InRect exclusion zones.
   These are static table prims — positions never change during gameplay.
   Eliminates 8 COM reads per ball per tick in the ball drop zone check.

6. Pan/AudioFade — REPLACE ^10 WITH REPEATED SQUARING (line ~3070)
   Replaced `tmp ^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
   (3 multiplications instead of generic VBS exponentiation dispatch).
   Replaced `bttf.width`/`bttf.height` with cached `tablewidth`/`tableheight`.
   Added `PanXY(x)` and `AudioFadeXY(y)` variants accepting pre-cached scalars.
   Also replaced `ball.VelX ^2` with `ball.VelX * ball.VelX` in BallVel.
   Saves ~1 ^10 dispatch + ~2 COM reads per call. At ~600 calls/sec: significant.

7. CollisionTimer_Timer REWRITE (line ~3133)
   - Cache `UBound(BOT)` into local `ub`. Eliminates 2 redundant UBound calls/tick.
   - Cache `BOT(b).X`, `.Y`, `.Z`, `.VelX`, `.VelY`, `.VelZ` into locals at top of
     each ball iteration. Eliminates ~10 COM reads per ball per tick.
   - Compute `velSq = vx*vx + vy*vy` once; derive Vol as `Csng(velSq/200)*1.2`
     (no SQR needed) and Pitch as `vel*20` from `vel = INT(SQR(velSq))`.
     Eliminates 2 redundant BallVel computations per ball per tick.
   - Use `PanXY(bx)` and `AudioFadeXY(by)` with cached scalars — computed once
     per ball, reused for all sound calls.
   - Use pre-built `RollStr(b)` and `MetalRollStr(b)` instead of string concat.
   - Use pre-cached ramp wedge positions in InRect calls instead of COM reads.
   - BUG FIX: panVal/fadeVal computed before the `vel > 1` check so drop sounds
     always have valid values (previously PlaySoundAtBOTBallZ recomputed them,
     but now the InRect check uses cached bx/by instead of COM reads).
   Total per ball per tick: ~10 COM reads eliminated, ~2 BallVel calls eliminated,
   ~3 string allocs eliminated, ~8 InRect COM reads eliminated.
   At 100Hz × 3 balls: ~3600 COM reads/sec, ~600 BallVel/sec, ~900 string allocs/sec eliminated.

8. BallShadowUpdate_timer REWRITE (line ~3019)
   - Removed per-tick `BallShadow = Array(...)` — uses module-level array (see #4).
   - Cache `UBound(BOT)` into local `ub`.
   - Cache `BOT(b).X`, `.Y`, `.Z` into locals `bx`, `by`, `bz`. Eliminates 4 redundant
     `.Z` reads per ball per tick (was read 5 times, now 1).
   At 100Hz × 3 balls: ~1200 COM reads/sec + 100 array allocs/sec eliminated.

9. MyTimer_Timer — CACHE ANGLES + PRE-COMPUTED TRIG (line ~456)
   - Cache `gate1.CurrentAngle` through `gate4.CurrentAngle` into locals (each was read 2×).
   - Cache `LeftFlipper.Currentangle` and `RightFlipper.Currentangle` into locals (each read 2-3×).
   - Cache `sw28.Currentangle` into local (was read 3×).
   - Replace `(2*PI/180)` with pre-computed `DEG2RAD` and `(2*PI/360)` with `DEG2RAD_HALF`.
   Eliminates ~8 redundant COM reads per tick + 4 constant recomputations.
   At 100Hz: ~800 COM reads/sec eliminated.

10. LampTimer_Timer — CACHE chgLamp ARRAY DEREFS (line ~2299)
    Cached `chgLamp(ii, 0)` into local `lampId` and `chgLamp(ii, 1)` into `lampVal`.
    Each was previously read twice (once for LampState, once for FadingLevel).
    Minor savings since the loop only iterates over changed lamps.

11. GiCompensationSingle — CACHE ARRAY DEREFS + COLLECTION COUNT (line ~2862)
    Cached `a.Count - 1` into local `cnt` (was recomputed every tick via COM).
    Cached `LampsOpacity(x, 0) * Giscaler` into local `lo0` — was computed twice per
    iteration (once for `.Opacity`, once for `.Intensity`). Same for lo1/lo2.
    Eliminates N redundant multiplications per tick (N = aLampsAll collection size).
    Applied same pattern to GiCompensation (dual-NR version).

12. FadeLUTsingle — GUARD ColorGradeImage WRITE (line ~2878)
    Added `LastGoLut` state tracking. Only writes `bttf.ColorGradeImage = LutName & GoLut`
    when the computed LUT index actually changes. Eliminates redundant string concatenation
    and COM property write on every tick when GI is in steady state.
    During GI fading (most ticks): eliminates ~100 string allocs/sec + 100 COM writes/sec.

13. FlexDMD — PRE-BUILT "Seg" STRINGS + CACHE Lightning IMAGE (line ~3595)
    Pre-built `FlexSegStr(31)` = "Seg0".."Seg31" at script load. Eliminates per-call
    `"Seg" & id` string concatenation in UpdateFlexChar.
    Cached `FlexDMDScene.GetImage("Lightning")` into local in FlexTimer_Timer —
    was called twice per tick (once for `.Visible` check, once for `.Visible = False`).
    Only active when UseFlexDMD = 1 (off by default).

--- NOT APPLIED ---

14. POTENTIAL: LampTimer structural optimization
    UpdateLamps calls 127+ individual NFadeL/FadeR/FadeMaterial subs every tick.
    Most lamps are in steady state (FadingLevel 0 or 1) and Select Case exits immediately,
    but the function call overhead is substantial. Would require converting to a loop-based
    approach with parallel arrays instead of individual sub calls — major refactoring.

15. POTENTIAL: Merge CollisionTimer + BallShadowUpdate onto one timer
    Both call GetBalls independently every tick. If intervals match, merging would
    eliminate ~100 GetBalls COM calls/sec.
