BTTF (Back to the Future) — Ranked Optimization Targets
========================================================

Script: table.vbs (~3549 lines)
Table: Back to the Future Collectors Edition — Data East 1990, VP911 by JPSalas, VPX by cyberpez

Mid-size ROM-based table with Fleep-style lamp fading system (LampTimer with ~127 NFadeL/FadeR
calls per tick), JP rolling sounds (CollisionTimer_Timer), basic ball shadows
(BallShadowUpdate_timer), a MyTimer for gate/flipper/spinner prim animations, and
an InRect-based ball drop zone exclusion check. No FlipperTricks, no DynamicBSUpdate.

Notable: Table object is named `bttf` (not `table1`). `tnob = 7`. Has wire ramp
rolling sounds with separate "metalrolling" sound name. LampTimer uses `-1` interval
(fastest possible).

---

## TARGET 1: CollisionTimer_Timer (Rolling Sounds) — CACHE BOT + PRE-BUILD STRINGS + INLINE MATH (line 3079)
**Heat: HIGH** — runs every timer tick × up to 7 balls

Problems:
- `"fx_ballrolling" & b` string concatenation (lines 3086, 3097, 3102, 3107) — 3-4 allocs per ball per tick
- `"metalrolling" & b` concatenation (line 3100) — 1 alloc per ball on wire ramp
- `BallVel(BOT(b))` called at line 3094, then `Vol(BOT(b))` calls BallVel again (line 3007→3031),
  and `Pitch(BOT(b))` calls it again (line 3027→3031) — 3 redundant BallVel computations per ball per tick
- `Pan(BOT(b))` and `AudioFade(BOT(b))` each read `.x`/`.y` via COM — 2 reads per call,
  called 1-2× per ball (rolling + drop path)
- `BOT(b).z` read 2× (lines 3096, 3114), `BOT(b).VelZ` read 1× (line 3114),
  `BOT(b).x`/`.y` read 2× in InRect (line 3115) — uncached
- `UBound(BOT)` read 3× (lines 3084, 3090, 3093) without caching
- Ball drop path calls `InRect` with `pRampWedge1.x`, `.y`, `pRampWedge2.x`, `.y` — 8 COM reads
  per ball per tick just for exclusion zone checks (lines 3115-3116)
- Drop sound pan/fade computed inside `PlaySoundAtBOTBallZ` — redundant with rolling path

Fix:
1. Pre-build `RollStr(7)` and `MetalRollStr(7)` at script load
2. Cache `UBound(BOT)` into local `ub`
3. Cache `BOT(b).x`, `.y`, `.z`, `.VelX`, `.VelY`, `.VelZ` into locals
4. Compute BallVel once, derive Vol and Pitch from single value
5. Compute Pan/AudioFade once per ball with XY variants
6. Cache `pRampWedge1.x`, `.y`, `pRampWedge2.x`, `.y` into module-level vars at init
   (they're static table objects — positions never change)

**Estimated savings:** At 100Hz with 3 balls: ~1800 string allocs/sec, ~3600 COM reads/sec,
~900 redundant BallVel/sec eliminated

---

## TARGET 2: Pan / AudioFade — REPLACE ^10 WITH REPEATED SQUARING + CACHE TABLE DIMS (lines 3016, 3034)
**Heat: HIGH** — called from every CollisionTimer iteration, every PlaySoundAt/AtBall call

Problems:
- `bttf.width` (line 3018) and `bttf.height` (line 3036) are COM reads on every call
- `tmp ^10` (lines 3020, 3022, 3038, 3040) is generic VBS exponentiation dispatch
- `ball.VelX ^2` in BallVel (line 3031) uses generic `^` dispatch
- Called from CollisionTimer (2× per ball per tick), from all hit/collision handlers

Fix:
1. Cache `bttf.width` and `bttf.height` into module-level `tablewidth`, `tableheight`
2. Replace `tmp ^10` with repeated squaring: `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
3. Add `PanXY(x)` and `AudioFadeXY(y)` variants accepting pre-cached scalars
4. Replace `^2` with multiplication in BallVel

**Estimated savings:** ~200-400 COM reads/sec + ~60-100 ^10 dispatches/sec replaced

---

## TARGET 3: BallShadowUpdate_timer — CACHE BOT PROPERTIES + HOIST ARRAY (line 2969)
**Heat: HIGH** — runs every timer tick × up to 7 balls

Problems:
- `BallShadow = Array(BallShadow1,...BallShadow7)` **recreated every tick** (line 2971)
- `BOT(b).X` read 1× (line 2984), `BOT(b).Y` read 1× (line 2985),
  `BOT(b).Z` read 5× uncached (lines 2986, 2986, 2991, 2992, 2995) — worst of any path
- `UBound(BOT)` read 3× (lines 2975, 2976, 2983) without caching
- `.visible` written unconditionally every tick (lines 2987, 2989)

Fix:
1. Hoist `BallShadow` array to module level, init in Table1_Init
2. Cache `BOT(b).X`, `.Y`, `.Z` into locals
3. Cache `UBound(BOT)` into local

**Estimated savings:** ~100 array allocs/sec + ~1500 COM reads/sec eliminated (100Hz × 3 balls)

---

## TARGET 4: MyTimer_Timer — CACHE FLIPPER/GATE ANGLES + PRE-COMPUTE TRIG CONSTANTS (line 417)
**Heat: HIGH** — runs every timer tick (animation/prim updates)

Problems:
- `LeftFlipper.Currentangle` read 2× (lines 442, 444) — should be cached
- `RightFlipper.Currentangle` read 2× (lines 446, 448) — should be cached
- `sw28.CurrentAngle` read 3× (lines 450, 452, 453) — should be cached
- `gate3.CurrentAngle` read 2× (lines 422, 424) — plus 1 for prim (line 424)
- `gate4.CurrentAngle` read 2× (lines 431, 440) — plus 1 for prim
- `2*PI/180` computed every tick (lines 426, 428) — constant, should be pre-computed
- `2*PI/360` computed every tick (lines 452, 453) — constant, should be pre-computed
- `sin()` calls with recomputed constants every tick

Fix:
1. Cache all `.CurrentAngle` reads into locals
2. Pre-compute `Dim DEG2RAD : DEG2RAD = 2*3.14159265/180` and `Dim DEG2RAD_HALF : DEG2RAD_HALF = 2*3.14159265/360` at module level

**Estimated savings:** ~5-8 COM reads/tick eliminated + constant expression elimination. At 100Hz: ~500-800 COM reads/sec.

---

## TARGET 5: LampTimer_Timer — CACHE chgLamp ARRAY DEREFS (line 2249)
**Heat: VERY HIGH** — runs at interval -1 (every frame), 127+ function calls per tick

Problems:
- `chgLamp(ii, 0)` and `chgLamp(ii, 1)` each read twice (lines 2255-2256) — should be cached into locals
- UpdateLamps calls 127+ NFadeL/FadeR/FadeMaterial/etc. subs every tick — each does a
  `Select Case FadingLevel(nr)` lookup. Most lamps are in steady state (FadingLevel 0 or 1)
  and the Select Case exits immediately, but the function call overhead of 127+ calls/tick is substantial
- `GiCompensationSingle` iterates over `aLampsAll` collection with `a.Count - 1` loop and
  `On Error Resume Next` — collection count re-read each tick

Fix:
1. Cache `chgLamp(ii, 0)` and `chgLamp(ii, 1)` into locals `lampId`/`lampVal` in the loop
2. Note: The 127+ NFadeL calls are the main cost but cannot be easily optimized without
   restructuring the entire lamp fading system (would require a loop-based approach with
   parallel arrays instead of individual sub calls). This is a structural issue, not a quick fix.

**Estimated savings:** Minor for chgLamp caching. The 127-call structure is the real bottleneck
but requires major refactoring to fix.

---

## TARGET 6: BallVel / Vol / Pitch — ELIMINATE REDUNDANT SQR AND ^2 (lines 3007-3031)
**Heat: MEDIUM** (mostly addressed by Target 1 caching)

Problems:
- `BallVel` computes `INT(SQR(VelX^2 + VelY^2))` (line 3031)
- `Vol` squares the result: `BallVel^2 / 200 * 1.2` (line 3008) — SQR and ^2 cancel out
- `VolZ` does `INT(ball.VelZ * -1)` then `^2 / 200 * 1.2` (lines 3012, 3045)

Fix:
1. In CollisionTimer, compute `velSq` once, derive Vol as `velSq/200*1.2` (no SQR)
2. Replace `^2` with multiplication in BallVel

**Estimated savings:** ~1 SQR + 1 ^2 per ball per tick. Mostly folded into Target 1.

---

## TARGET 7: InRect EXCLUSION ZONES — CACHE STATIC PRIM POSITIONS (line 3115)
**Heat: MEDIUM** — called per ball per tick in drop-sound check

Problems:
- `pRampWedge1.x`, `.y`, `pRampWedge2.x`, `.y` are COM reads every tick (8 total per ball)
- These are static table prims — positions never change during gameplay
- Each ball evaluates both InRect calls every tick when in the drop zone

Fix:
1. Cache `pRampWedge1.x`, `.y`, `pRampWedge2.x`, `.y` into module-level vars at script load
2. Pre-compute the ±40 offsets into 8 constants (ax, ay, bx, by, cx, cy, dx, dy for each wedge)

**Estimated savings:** ~8 COM reads per ball per tick in drop zone. Minor since balls are
in the drop zone briefly.

---

## Summary — Priority Order

| # | Target | Heat | Effort | Impact |
|---|--------|------|--------|--------|
| 1 | CollisionTimer (Rolling) | HIGH | Medium | Major — string allocs, redundant COM reads, redundant math |
| 2 | Pan/AudioFade ^10 | HIGH | Low | Major — ^10 dispatch + table dim COM reads every call |
| 3 | BallShadowUpdate | HIGH | Low | Major — per-tick array alloc, Z read 5× uncached |
| 4 | MyTimer (gate/flipper prims) | HIGH | Low | Moderate — ~8 COM reads/tick, trig constants |
| 5 | LampTimer chgLamp caching | VERY HIGH | Trivial | Minor — array deref caching (structural issue not fixable) |
| 6 | BallVel/Vol/Pitch | MEDIUM | Low | Minor — redundant SQR (folded into #1) |
| 7 | InRect static positions | MEDIUM | Low | Minor — cache static prim positions |
