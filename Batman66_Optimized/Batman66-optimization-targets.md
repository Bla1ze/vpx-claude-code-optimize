Batman66 (Batman 66 Premium) — Ranked Optimization Targets
==========================================================

Script: Batman66_1.1.0.vbs (~27,938 lines)
Table: Batman 66 Premium (Stern 2016), NailBuster, Flupper, cyberpez

Large ROM-based table with NailBuster's Lampz system (LampTimer2 at interval -1 calling
Lampz.Update), Flupper flasher system (FlashFlasher with ^2/^2.5/^3 exponentiation),
JP rolling sounds (RollingUpdate), ninuzzu ball shadows (BallShadowUpdate), FlipperTricks
at 1ms interval, and PuP DMD framework. Table object is `Table1`, referenced via `TableRef`.
`tnob = 11`, `lob = 0`. Has metal rolling sounds ("fx_metalrolling") for elevated balls.
`tablewidth`/`tableheight` already cached at line 24724.

---

## TARGET 1: RollingUpdate — CACHE BOT + PRE-BUILD STRINGS + INLINE VOL/PITCH/PAN (line 14364)
**Heat: HIGH** — runs every frame × up to 11 balls

Problems:
- `"fx_ballrolling" & b` string concatenation (lines 14372, 14401, 14403) — 2-3 allocs per ball per tick
- `"fx_metalrolling" & b` concatenation (lines 14373, 14400, 14404) — 2-3 allocs per ball per tick
- `BallVel(BOT(b))` called at line 14390, then `Vol(BOT(b))` calls BallVel again (line 14280),
  `Pitch(BOT(b))` calls BallVel again (line 14294), `Pan(BOT(b))` recomputes (14285-14290),
  `AudioFade(BOT(b))` recomputes (14257-14263) — up to 5 redundant helper calls per ball per tick
- `BOT(b).z` read 3× (lines 14391, 14399, 14415), `BOT(b).VelZ` read 1× (14415),
  `BOT(b).radius` read 1× (14390) — uncached
- `UBound(BOT)` read 3× (lines 14369, 14378, 14383) without caching
- Pan/AudioFade use `table1.width`/`table1.height` — should use cached `tablewidth`/`tableheight`
- Ball drop sound recomputes Pan, Pitch, AudioFade redundantly (line 14416)

Fix:
1. Pre-build `BallRollStr(11)` and `MetalRollStr(11)` at script load
2. Cache `UBound(BOT)` into local `ub`
3. Cache `BOT(b).x`, `.y`, `.z`, `.VelX`, `.VelY`, `.VelZ`, `.radius` into locals
4. Compute BallVel once, derive Vol and Pitch from single value
5. Compute Pan/AudioFade once per ball with XY variants using cached tablewidth/tableheight
6. Reuse cached pan/fade for drop sound path

**Estimated savings:** At 60Hz with 3 balls: ~1,080 string allocs/sec, ~2,160 COM reads/sec,
~540 redundant BallVel/sec eliminated

---

## TARGET 2: AudioFade/AudioPan/Pan/Vol/BallVel — REPLACE ^10/^2 + CACHE TABLE DIMS (lines 14255-14299)
**Heat: HIGH** — called from every RollingUpdate iteration, every hit/collision handler

Problems:
- `table1.height` (line 14257) and `table1.width` (line 14269) are COM reads on every call
  (should use cached `tablewidth`/`tableheight`)
- `tmp ^10` (lines 14260, 14262, 14272, 14274, 14287, 14289) is generic VBS exponentiation dispatch
- `BallVel(ball) ^2` in Vol (line 14280) uses generic `^` dispatch
- `ball.VelX ^2` + `ball.VelY ^2` in BallVel (line 14298) uses generic `^` dispatch
- Pan duplicates AudioPan logic with same ^10 issue (lines 14283-14291)
- `On Error Resume Next` in AudioFade/AudioPan (unnecessary overhead per call)

Fix:
1. Use cached `tablewidth`/`tableheight` instead of `table1.width`/`table1.height`
2. Replace `tmp ^10` with repeated squaring: `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
3. Add `AudioFadeXY(y)` and `AudioPanXY(x)` variants accepting pre-cached scalars
4. Replace `^2` with multiplication in BallVel and Vol
5. Remove unnecessary `On Error Resume Next`

**Estimated savings:** ~200-400 COM reads/sec + ~100-200 ^10 dispatches/sec replaced

---

## TARGET 3: FlipperTricks — TIMER 1ms → 10ms (line 22434)
**Heat: VERY HIGH** — runs at 1000Hz (1ms interval)

Problems:
- `RightFlipper.timerinterval=1` (line 22434) fires FlipperTricks + FlipperNudge at 1000Hz
- FlipperTricks reads `Flipper.currentangle`, `Flipper.startangle`, `Flipper.endangle` — COM reads
- FlipperNudge reads `Flipper1.currentangle`, `Flipper2.currentangle` — COM reads
- FlipperNudge calls GetBalls when both flippers at end angle — separate from FrameTimer GetBalls
- At 1000Hz × 2 FlipperTricks + 2 FlipperNudge calls: ~4000+ function calls/sec

Fix:
1. Change `RightFlipper.timerinterval = 10` (100Hz — visually identical, 90% reduction)

**Estimated savings:** ~3,600 function calls/sec eliminated, ~3,600 COM reads/sec eliminated

---

## TARGET 4: BallShadowUpdate — CACHE BOT PROPERTIES + HOIST ARRAY (line 14652-14684)
**Heat: HIGH** — runs every frame × up to 11 balls

Problems:
- `BallShadow = Array(BallShadow1,...BallShadow11)` created at module level (line 14654) — OK,
  not per-tick. But array was created with inline object refs (not `Set`) — value-type copy issue.
- `BOT(b).X` read 2-3× (lines 14672 twice, 14674 twice), `.Y` read 1× (14676),
  `.Z` read 1× (14677), `.radius` read 1× (14670) — uncached
- `Table1.Width/2` computed twice per ball (lines 14671, 14672, 14674) — should be pre-cached
- `Ballsize/6` computed twice per ball (lines 14672, 14674) — constant, should be pre-computed
- `UBound(BOT)` read 3× (lines 14661, 14662, 14669) without caching

Fix:
1. Pre-compute `tableHalfWidth = tablewidth / 2`, `BS_d6 = BallSize / 6` at module level
2. Cache `BOT(b).X`, `.Y`, `.Z`, `.radius` into locals
3. Cache `UBound(BOT)` into local

**Estimated savings:** At 60Hz × 3 balls: ~1,080 COM reads/sec + ~360 constant computations/sec eliminated

---

## TARGET 5: FlashFlasher — REPLACE ^2/^2.5/^3 + PRE-BUILD MATERIAL STRINGS (line 24781)
**Heat: MEDIUM-HIGH** — called per active flasher per fade tick (10ms intervals)

Problems:
- `ObjLevel(nr)^2.5` (line 24783) — generic VBS exponentiation dispatch
- `ObjLevel(nr)^3` (lines 24784, 24785) — generic exponentiation, computed twice
- `ObjLevel(nr)^2` (line 24786) — generic exponentiation
- `ObjLevel(nr)` read 6× in one call without caching
- `"Flashermaterial" & nr` (line 24787) — string concatenation per tick per flasher

Fix:
1. Cache `ObjLevel(nr)` into local `lvl`
2. Replace `^3` with `lvl * lvl * lvl`, `^2` with `lvl * lvl`
3. Replace `^2.5` with `lvl * lvl * Sqr(lvl)` (2 muls + 1 sqr vs generic dispatch)
4. Pre-build `FlasherMatStr(N)` array at init

**Estimated savings:** ~4 exponentiation dispatches + ~5 array derefs per flasher per tick.
At 100Hz × 3 active flashers: ~1,200 ^n dispatches/sec + ~1,500 array derefs/sec eliminated

---

## TARGET 6: FrameTimer_Timer — CACHE FLIPPER ANGLES (line 27650)
**Heat: HIGH** — runs every frame

Problems:
- `LeftFlipper.currentangle` (line 27654) read once — also read in FlipperTricks
- `RightFlipper.currentangle` (line 27655) read once — also read in FlipperTricks
- `Plunger.Position` (line 27656) read once — minor

Fix:
1. Cache flipper angles into locals, reuse for shadow writes
2. Guard shadow writes (if angle hasn't changed, skip the write)

**Estimated savings:** Minor — ~120 guarded writes/sec when flippers at rest (~80% of frames)

---

## TARGET 7: LampTimer chgLamp ARRAY DEREFS (line 24360)
**Heat: HIGH** — runs every frame (called from FrameTimer)

Problems:
- `chglamp(x, 0)` and `chglamp(x, 1)` each read once per loop iteration (line 24365)
  but stored in the same expression — should cache into locals

Fix:
1. Cache `chglamp(x, 0)` into local `lampId` and `chglamp(x, 1)` into `lampVal`

**Estimated savings:** Minor — reduces array dereference overhead for changed lamps per tick.

---

## Summary — Priority Order

| # | Target | Heat | Effort | Impact |
|---|--------|------|--------|--------|
| 1 | RollingUpdate (Rolling/Metal) | HIGH | Medium | Major — string allocs, redundant COM reads, redundant math |
| 2 | AudioFade/AudioPan/Pan/Vol/BallVel ^10/^2 | HIGH | Low | Major — ^10 dispatch + table dim COM reads every call |
| 3 | FlipperTricks 1ms→10ms | VERY HIGH | Trivial | Major — 90% call reduction = ~3600 calls/sec saved |
| 4 | BallShadowUpdate | HIGH | Low | Moderate — X read 2-3×, constant recomputations |
| 5 | FlashFlasher ^2/^2.5/^3 | MEDIUM-HIGH | Low | Moderate — exponentiation per flasher per tick |
| 6 | FrameTimer flipper angles | HIGH | Trivial | Minor — guard shadow writes |
| 7 | LampTimer chgLamp caching | HIGH | Trivial | Minor — array deref caching |
