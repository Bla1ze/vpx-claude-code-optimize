Dirty Harry (vpxFile.vbs) — Ranked Optimization Targets
========================================================

Script: vpxFile.vbs (~1098 lines)
Table: Dirty Harry (WPC, dh_lx2) — Williams 1995, recreated by Knorr

Small script with JP rolling sounds, basic ball shadows, flipper shadow rotation,
MotorCallback for flipper prims/plunger/spinner/diverter, and a gun motor timer.
No FlipperTricks, no dynamic ball shadow system, no LCSeq, no LampTimer.

---

## TARGET 1: RollingTimer_Timer — PRE-BUILD SOUND STRINGS + CACHE BOT PROPERTIES (line 919)
**Heat: HIGH** — runs every timer tick (likely 10ms) × up to 6 balls

Problems:
- `"fx_ballrolling" & b` string concatenation on every iteration (lines 926, 938, 940, 944) — 3-4 allocs per ball per tick
- `"fx_ball_drop" & b` concatenation (line 950) — 1 alloc per ball per tick
- `BallVel(BOT(b))` called at line 935, then `Vol(BOT(b))` calls `BallVel()` again (line 893→901), and `Pitch(BOT(b))` calls it again (line 897→901) — 3 redundant BallVel computations per ball per tick
- `AudioPan(BOT(b))` and `AudioFade(BOT(b))` each read `.x`/`.y` via COM and call `table1.width`/`table1.height` — 4 COM reads per call, called 2× per ball (rolling + drop path)
- `BOT(b).z` read 3 times per ball (lines 937, 949, 949), `BOT(b).VelZ` read once (line 949)
- No caching of `UBound(BOT)` — read 3 times (lines 924, 930, 934)

Fix:
1. Pre-build `RollStr(6)` and `DropStr(6)` at script load
2. Cache `UBound(BOT)` into local `ub`
3. Cache `BOT(b).x`, `.y`, `.z`, `.VelX`, `.VelY`, `.VelZ` into locals
4. Compute `BallVel` once per ball, derive `Vol` and `Pitch` from single value
5. Compute `AudioPan`/`AudioFade` once per ball using cached x/y scalars
6. Fix drop sound using stale/uninitialized pan/fade (same bug as DW)

**Estimated savings:** ~30-40 string allocs/sec + ~60-80 redundant COM reads/sec + ~30-40 redundant BallVel computations/sec (at 100Hz with 3 balls)

---

## TARGET 2: AudioFade / AudioPan — REPLACE ^10 WITH REPEATED SQUARING + CACHE TABLE DIMS (lines 872, 882)
**Heat: HIGH** — called from every RollingTimer iteration, every PlaySoundAt call, every collision handler

Problems:
- `table1.height` (line 874) and `table1.width` (line 884) are COM reads on every call
- `tmp ^10` is a generic VBS exponentiation dispatch — expensive vs. 3 multiplications
- Called from RollingTimer (2× per ball per tick), from ball drop sounds, and from every hit/collision event

Fix:
1. Cache `table1.width` and `table1.height` into module-level `tablewidth`, `tableheight` at script load
2. Replace `tmp ^10` with repeated squaring: `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
3. Add `AudioFadeXY(y)` and `AudioPanXY(x)` variants that accept pre-cached scalar values

**Estimated savings:** ~2 COM reads/call eliminated, ~60-100 ^10 dispatches/sec replaced with cheap multiplications

---

## TARGET 3: BallShadowUpdate — CACHE BOT PROPERTIES + HOIST ARRAY (line 973)
**Heat: HIGH** — called every RealTime_Timer tick × up to 6 balls

Problems:
- `BallShadow = Array(BallShadow1,...BallShadow6)` **recreated every tick** (line 975) — allocates a new 6-element Variant array + 6 object references every tick
- `BOT(b).X` read once (line 988), `BOT(b).Y` read once (line 989), `BOT(b).Z` read 5 times uncached (lines 990, 990, 995, 996, 999) — worst of any hot path
- `UBound(BOT)` read 3 times (lines 979, 980, 987) without caching
- `.visible` written unconditionally every tick (lines 991, 993)
- Separate `GetBalls` call from RollingTimer — both timers call it independently

Fix:
1. Hoist `BallShadow` array to module level — initialize once in Table1_Init
2. Cache `BOT(b).X`, `BOT(b).Y`, `BOT(b).Z` into locals `bx`, `by`, `bz`
3. Cache `UBound(BOT)` into local `ub`

**Estimated savings:** ~100 array allocs/sec eliminated, ~1500 COM reads/sec reduced (at 100Hz × 3 balls)

---

## TARGET 4: BallVel / Vol / Pitch — ELIMINATE REDUNDANT SQR AND ^2 (lines 892-901)
**Heat: MEDIUM** (mostly addressed by Target 1 caching)

Problems:
- `BallVel` computes `SQR(VelX^2 + VelY^2)` (line 901)
- `Vol` then squares the result: `BallVel^2 / 5000` (line 893) — the SQR and ^2 cancel out
- Both `VelX^2` and `VelY^2` use generic `^` dispatch instead of `VelX*VelX`

Fix:
1. Add `BallVelSq(vx, vy)` helper returning `vx*vx + vy*vy`
2. In RollingTimer, compute `velSq` once, derive Vol as `velSq/5000` (no SQR) and Pitch from `INT(SQR(velSq))*20`

**Estimated savings:** ~1 SQR + 1 ^2 per ball per tick eliminated. Mostly folded into Target 1.

---

## TARGET 5: RealTime_Timer — CACHE FLIPPER ANGLES (line 966)
**Heat: MEDIUM-HIGH** — runs every timer tick

Problems:
- `LeftFlipper.CurrentAngle` and `RightFlipper.CurrentAngle` are COM reads every tick (lines 967-968)
- These are written unconditionally to `lfs.RotZ` / `rfs.RotZ` even when unchanged
- Minor: flipper shadow rotation is a simple assignment, but still 2 COM reads + 2 COM writes per tick

Fix:
1. Cache `LeftFlipper.CurrentAngle` and `RightFlipper.CurrentAngle` into locals
2. Guard writes: only set `.RotZ` when value differs from previous tick

**Estimated savings:** ~2-4 redundant COM writes/tick when flippers are idle (which is most ticks)

---

## TARGET 6: RealTimeUpdates (MotorCallback) — CACHE FLIPPER ANGLES (line 1010)
**Heat: MEDIUM** — called by MotorCallback (frame rate)

Problems:
- `LeftFlipper.CurrentAngle` read again (line 1012) — already read in RealTime_Timer
- `RightFlipper.CurrentAngle` read again (line 1014)
- `RightFlipper1.CurrentAngle` read once (line 1013) — third flipper
- `Spinner1.currentangle` and `diverterR.CurrentAngle` — COM reads but needed for animation, leave alone

Fix:
1. Cache flipper angles into locals

**Estimated savings:** Minor — ~3 COM reads/frame. Low priority since these are simple assignments.

---

## TARGET 7: PRE-CACHED TABLE DIMENSIONS (module level)
**Heat: HIGH** (enables Target 2)

Fix:
1. Add `Dim tablewidth : tablewidth = table1.width` and `Dim tableheight : tableheight = table1.height` at module level
2. Used by AudioFade/AudioPan (Target 2) to eliminate 2 COM reads per call

**Estimated savings:** Eliminates ~200-400 COM reads/sec across all AudioFade/AudioPan calls

---

## TARGET 8: updategun_Timer — GUARD SWITCH WRITES (line 324)
**Heat: LOW-MEDIUM** — only enabled during gun animation

Problems:
- `Controller.switch(76)` written every tick (line 328) even when value hasn't changed
- Gun position check `GPos >= -4` is simple math — no real optimization needed

Fix:
1. Guard `Controller.switch(76)` writes with previous state tracking

**Estimated savings:** Minor — eliminates ~90% of redundant switch writes during gun animation only

---

## Summary — Priority Order

| # | Target | Heat | Effort | Impact |
|---|--------|------|--------|--------|
| 1 | RollingTimer_Timer | HIGH | Medium | Major — string allocs, redundant COM reads, redundant math |
| 2 | AudioFade/AudioPan | HIGH | Low | Major — ^10 dispatch + COM reads on every sound call |
| 3 | BallShadowUpdate | HIGH | Low | Major — per-tick array alloc, uncached COM reads |
| 4 | BallVel/Vol/Pitch | MEDIUM | Low | Minor — redundant SQR (mostly folded into #1) |
| 5 | RealTime_Timer | MED-HIGH | Low | Moderate — flipper shadow COM reads/writes |
| 6 | RealTimeUpdates | MEDIUM | Low | Minor — redundant flipper angle reads |
| 7 | Table dimensions | HIGH | Trivial | Enables Target 2 savings |
| 8 | updategun_Timer | LOW-MED | Trivial | Minor — guarded switch writes |
