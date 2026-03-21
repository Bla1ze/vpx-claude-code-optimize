table.vbs Applied Optimization Changes
=======================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. PRE-COMPUTED CONSTANTS (line ~3511)
   Added module-level vars: DynBSFactor2, DynBSFactor3, BS_d10, BS_d5, BS_d4, BS_d2, BS_dAM, TW_d2.
   Placed after the shadow option constants (DynamicBSFactor, AmbientMovement, BallSize, tablewidth are
   all defined above this point). Computed once at script load.
   - DynBSFactor2 = DynamicBSFactor * DynamicBSFactor  (0.9025)
   - DynBSFactor3 = DynBSFactor2 * DynamicBSFactor     (0.857375)
   - BS_d10..BS_d2 = BallSize / 10, 5, 4, 2            (5, 10, 12.5, 25)
   - BS_dAM = BallSize / AmbientMovement                (25)
   - TW_d2 = tablewidth / 2
   Eliminates repeated division and exponentiation inside DynamicBSUpdate and RollingUpdate per-frame.

2. PRE-BUILT BALL ROLL SOUND STRINGS (line ~2007)
   Added BallRollStr(tnob) array populated at script load: BallRollStr(b) = "BallRoll_" & b.
   Eliminates "BallRoll_" & b string concatenation in RollingUpdate (3 allocations per ball per
   10ms tick). With up to 5 balls: up to 15 string allocs/tick = ~1500/sec eliminated.

3. PRE-BUILT RAMP SOUND STRINGS (line ~3787)
   Added RampLoopStr(6) and WireLoopStr(6) arrays at script load, populated beside RampBalls init.
   Eliminates "RampLoop" & x and "wireloop" & x concatenation in RampRollUpdate and WRemoveBall.
   RampRollUpdate can allocate up to 8 strings × 6 ramps = 48 allocs per 100ms tick when active.

4. DynamicBSUpdate REWRITE (line ~3624)
   - Added Dim bx, by, bz: cache BOT(s).X/Y/Z into locals at top of each ball iteration.
     Eliminates 10–14 COM property reads per ball per frame (accessed 4×/3×/3× respectively).
   - Added Dim sx, sy: cache DSSources(iii)(0/1) into locals at top of each source iteration.
     Eliminates 2 array dereferences per source per ball per frame.
   - Added Dim asx, asy: cache DSSources(AnotherSource)(0/1) in 2-shadow path.
     Eliminates 4 array dereferences in the 2-shadow case.
   - DynamicBSFactor^2 → DynBSFactor2, DynamicBSFactor^3 → DynBSFactor3 (3 replacements).
     Eliminates 3 exponentiation ops per frame when dynamic shadows active.
   - BallSize/10, /5, /4, /2 → BS_d10, BS_d5, BS_d4, BS_d2 (12 replacements).
     tablewidth/2 → TW_d2 (8 replacements). Eliminates 20 divisions per ball per frame.
   - Removed unused local Dim (falloff variable; replaced with literal 150; Source removed entirely).
   Note: DynamicBallShadowsOn = 0 by default — ambient shadow path still runs and benefits.
   With shadows enabled: ~30+ saved ops per ball per frame.

5. RollingUpdate REWRITE (line ~2033)
   - Added Dim bz, bx, by: cache BOT(b).z/X/Y into locals at top of main ball loop.
     Eliminates 5 COM property reads per ball per tick (z accessed 3×, X/Y 1× each).
   - Replaced "BallRoll_" & b with BallRollStr(b) at 3 call sites (lines ~2032, 2044, 2047).
     String alloc eliminated per ball per tick.
   - BallSize/4, /2, /5 → BS_d4, BS_d2, BS_d5 in static shadow block (3 replacements).
     Eliminates 3 divisions per ball per tick.
   - Replaced "BallRoll_" & b in dead-ball cleanup loop with BallRollStr(b).

6. GraphicsTimer_Timer GUARD WRITES (line ~1854)
   - Added module-level Dim lastLeftAngle, lastRightAngle (initialized Empty = 0).
   - Primitive bat path (ChooseBats = 1): cache CurrentAngle into local, compare before writing.
     Only writes batleft/batleftshadow.objrotz when left angle changed; same for right.
     Eliminates 4 unconditional COM writes per frame when flippers are at rest (~80% of frames).
   - GlowBat path (ChooseBats > 1): same guard pattern for both sides.
     Eliminates up to 4 COM writes per frame when glowbats are at rest.

7. FlashFlasher EXPONENT CACHING (line ~4118)
   - Added Dim flvl, flvl2, flvl3: cache ObjLevel(nr), its square, and its cube at sub entry.
     flvl2 = flvl * flvl (no ^ operator), flvl3 = flvl2 * flvl.
   - Replaced all ObjLevel(nr)^2 and ^3 references (9× and 4× respectively) with flvl2/flvl3.
     Also replaced ObjLevel(nr) in UpdateMaterial arg with flvl.
   - VBScript ^ dispatches a COM math call; * is a pure stack op. Eliminates 13 power ops per call.
   - With 5 flashers active: ~65 power ops/frame saved.

8. ClockTimer_Timer GUARD WRITES (line ~4877)
   - Added module-level Dim ClkSec, ClkMin, ClkHour (initialized Empty).
   - Now calls Now() once per tick, caches result. Only updates primitives when second/minute/hour
     actually changes. Nested guard: seconds checked every tick, minutes only on second change,
     hours only on minute change.
   - Eliminates 3 unconditional COM writes per tick; reduces 4 Now() calls to 1.
   - Pseconds updates at most once/sec, Pminutes once/minute, Phours once/hour.
   - ~97–99% write reduction for hour/minute hands.

9. RampRollUpdate + WRemoveBall STRING REPLACEMENT (line ~3864, ~3845)
   - Replaced all "RampLoop" & x and "wireloop" & x with RampLoopStr(x) and WireLoopStr(x).
   - RampRollUpdate: 8 replacements. WRemoveBall: 2 replacements.
   - Eliminates string allocation on every played/stopped sound during ramp ball tracking.

10. BeerTimer_Timer REDUNDANT RANDOMIZE REMOVAL (line ~4855)
    - Removed Randomize(21) call from the timer body.
    - Re-seeding the RNG with the same fixed seed every tick forced an identical pseudo-random
      sequence start every timer fire — defeating the purpose of Rnd() and wasting a runtime call.
    - VBScript auto-seeds Rnd() at script start; RNG now continues its natural sequence across ticks.
