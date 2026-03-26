DW (Doctor Who) — Ranked Optimization Targets
===============================================

Script: vpxFile.vbs (~989 lines)
Table: Doctor Who (WPC, dw_l2) — oooPLAYER1ooo & Unclewilly, VPX port by Sliderpoint

This is a relatively small script with no dynamic ball shadows (DynamicBSUpdate), no FlipperTricks/FlipperNudge, and no LCSeq light sequencer. The hot paths are limited to rolling sounds, simple ball shadows, a mini-playfield animation mech, a misc timer, and the audio helper functions called from all of them.

---

## TARGET 1: RollingTimer_Timer — PRE-BUILD SOUND STRINGS + CACHE BOT PROPERTIES (line 828)
**Heat: HIGH** — runs every timer tick (likely 10ms) × up to 6 balls

Problems:
- `"fx_ballrolling" & b` string concatenation on every iteration (lines 835, 847, 849, 853) — 4 allocs per ball per tick for rolling balls, 2 for stopped balls
- `"fx_ball_drop" & b` concatenation (line 859) — 1 alloc per ball per tick
- `BallVel(BOT(b))` called once per ball (line 844), then `Vol()` calls `BallVel()` again internally (line 764→771), and `Pitch()` calls it again (line 768→771) — 3 redundant BallVel calculations per ball per tick
- `AudioPan(BOT(b))` and `AudioFade(BOT(b))` each read `.x` and `.y` via COM (lines 753-760, 743-750) — 2 COM reads per call, called twice per ball (rolling + drop check path)
- `BOT(b).z` read 3 times per ball (lines 846, 858, 858), `BOT(b).VelZ` read once (line 858)
- No caching of `UBound(BOT)`

Fix:
1. Pre-build `RollStr(tnob)` = `"fx_ballrolling0"` .. `"fx_ballrolling6"` and `DropStr(tnob)` = `"fx_ball_drop0"` .. `"fx_ball_drop6"` at script load
2. Cache `UBound(BOT)` into local `ub`
3. Cache `BOT(b).x`, `BOT(b).y`, `BOT(b).z`, `BOT(b).VelX`, `BOT(b).VelY`, `BOT(b).VelZ` into locals at top of each ball iteration
4. Compute `BallVel` once per ball, derive `Vol` and `Pitch` from that single value
5. Compute `AudioPan`/`AudioFade` once per ball using cached x/y scalars (avoid repeated COM reads + repeated ^10)

**Estimated savings:** ~30-40 string allocs/sec + ~60-80 redundant COM reads/sec + ~30-40 redundant BallVel computations/sec (at 100Hz with 3 balls)

---

## TARGET 2: AudioFade / AudioPan — REPLACE ^10 WITH REPEATED SQUARING + CACHE TABLE DIMS (lines 743, 753)
**Heat: HIGH** — called from every RollingTimer iteration, every PlaySoundAt call, every BallShadow sound

Problems:
- `table1.height` (line 745) and `table1.width` (line 755) are COM reads on every call
- `tmp ^10` is a generic VBS exponentiation dispatch — expensive vs. 3 multiplications
- Called from RollingTimer (2× per ball per tick), from BallShadow drop sounds, and from every PlaySoundAt/PlaySoundAtBall event

Fix:
1. Cache `table1.width` and `table1.height` into module-level `Dim tablewidth`, `Dim tableheight` at script load
2. Replace `tmp ^10` with repeated squaring: `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2` (3 multiplications)
3. Add `AudioFadeXY(y)` and `AudioPanXY(x)` variants that accept pre-cached scalar values (skip `.x`/`.y` COM reads for hot-path callers)
4. Clamp result to +/-7000 range to prevent overflow

**Estimated savings:** ~2 COM reads/call eliminated, ~60-100 ^10 dispatches/sec replaced with cheap multiplications

---

## TARGET 3: BallShadow_Timer — CACHE BOT PROPERTIES + GUARD WRITES + HOIST ARRAY (line 872)
**Heat: HIGH** — runs every timer tick × up to 6 balls

Problems:
- `BallShadow = Array(BallShadow1,...BallShadow6)` **recreated every tick** (line 874) — allocates a new 6-element Variant array + 6 object references every single tick
- `BOT(b).X` read once (line 887), `BOT(b).Y` read once (line 888), `BOT(b).Z` read 4 times (lines 889, 894, 895, 898) — no caching
- `BallShadow(b).visible` written unconditionally every tick (lines 890, 892)
- `BallShadow(b).opacity = 80` written unconditionally in both branches (lines 896, 899) — always 80 regardless of path
- No caching of `UBound(BOT)`

Fix:
1. Hoist `BallShadow` array to module level — initialize once, not per tick
2. Cache `BOT(b).X`, `BOT(b).Y`, `BOT(b).Z` into locals `bx`, `by`, `bz`
3. Guard `.visible` writes: only set when value changes
4. Remove duplicate `.opacity = 80` — set once at init or guard write
5. Cache `UBound(BOT)` into local

**Estimated savings:** ~100 array allocs/sec eliminated, ~400-600 COM reads/sec reduced, redundant `.opacity` writes eliminated

---

## TARGET 4: PrimTimer_Timer — GUARD VISIBLE WRITES + CACHE LAMP STATE (line 706)
**Heat: MEDIUM** — runs every timer tick

Problems:
- `Controller.Lamp(67)` COM read every tick (line 710)
- `l67on.visible` and `l67onb.visible` set unconditionally every tick (lines 711-718) even when state hasn't changed
- `GI33.State` and `GI32.State` COM reads every tick (lines 722, 727)
- `GI33b.visible` and `GI32b.visible` set unconditionally every tick even when unchanged
- Gate angle reads (`Gate68.currentAngle`, etc.) are COM reads but needed for animation — leave alone

Fix:
1. Cache previous lamp/GI states in module-level variables (`lastL67`, `lastGI33State`, `lastGI32State`)
2. Only write `.visible` when state actually changes
3. Skip `SideWallFlashers` check entirely if const is 0 (compiler may already optimize this, but explicit `If` removal is cleaner)

**Estimated savings:** ~6-8 unconditional COM writes/tick eliminated when states are stable (most ticks)

---

## TARGET 5: UpdateMiniPF — REDUCE REDUNDANT COM WRITES + CACHE COMPUTED VALUES (line 510)
**Heat: MEDIUM** — called by mech callback, frequency depends on mech update rate

Problems:
- `ZPos * .7843` computed 3 times (lines 519, 524, 527) — should be computed once
- Sound `"Motor-Old1"` played inside the `For Each XX in MiniPF` loop (line 520) — plays once per collection element, not once per call. Likely a bug: sound should be outside the loop
- Cascade of `If aCurrPos > X and aCurrPos < Y` checks (lines 531-543) — 16 comparisons that could be a Select Case or pre-computed lookup, but not a real perf issue unless mech ticks very fast
- `Controller.Switch(32)` set unconditionally on every call even when value hasn't changed (lines 531-538)

Fix:
1. Cache `ZPos * .7843` into local `zpScaled`
2. Move `PlaySound "Motor-Old1"` outside the `For Each` loop (bug fix + perf)
3. Guard `Controller.Switch(32)` writes with a cached previous value

**Estimated savings:** ~2 redundant multiplications/tick, eliminates N-1 duplicate PlaySound calls per tick (where N = MiniPF collection size)

---

## TARGET 6: Flash subs — PRE-COMPUTE INTENSITY DIVISOR (lines 381-475)
**Heat: LOW-MEDIUM** — called by solModCallback on lamp changes (not per-tick, but can burst during flasher sequences)

Problems:
- `(Level / 2.55) / 100` computed in every Flash sub (8 subs × potentially rapid fire during multiball light shows) — two divisions per call
- Could be simplified to `Level / 255` (single division) or `Level * 0.003921568627` (single multiplication)

Fix:
1. Replace `(Level / 2.55) / 100` with `Level / 255` in all Flash subs (mathematically equivalent, one division instead of two)

**Estimated savings:** Minor — eliminates 1 division per flasher call. Low priority since these fire on solenoid events, not per-tick.

---

## TARGET 7: BallVel / Vol / Pitch — ELIMINATE REDUNDANT SQR AND ^2 (lines 763-772)
**Heat: MEDIUM** (but mostly addressed by Target 1 caching)

Problems:
- `BallVel` computes `SQR(VelX^2 + VelY^2)` (line 772)
- `Vol` then squares the result: `BallVel^2 / 400` (line 764) — the SQR and ^2 cancel out, making SQR unnecessary for Vol
- These functions are called from RollingTimer (Target 1) and from collision event handlers

Fix:
1. Add a `BallVelSq` function or inline: `velSq = ball.VelX*ball.VelX + ball.VelY*ball.VelY` — use directly for Vol (`velSq/400`), only SQR when actual speed is needed (Pitch)
2. In RollingTimer (after Target 1 caching), compute `velSq` once, derive everything from it

**Estimated savings:** ~1 SQR/ball/tick eliminated when only Vol is needed. Mostly folded into Target 1.

---

## Summary — Priority Order

| # | Target | Heat | Effort | Impact |
|---|--------|------|--------|--------|
| 1 | RollingTimer_Timer | HIGH | Medium | Major — string allocs, redundant COM reads, redundant math |
| 2 | AudioFade/AudioPan | HIGH | Low | Major — ^10 dispatch + COM reads on every sound call |
| 3 | BallShadow_Timer | HIGH | Low | Major — per-tick array alloc, uncached COM reads |
| 4 | PrimTimer_Timer | MEDIUM | Low | Moderate — unconditional COM writes every tick |
| 5 | UpdateMiniPF | MEDIUM | Low | Moderate — redundant math + probable sound bug |
| 6 | Flash subs | LOW-MED | Trivial | Minor — arithmetic simplification |
| 7 | BallVel/Vol/Pitch | MEDIUM | Low | Minor — redundant SQR (mostly folded into #1) |
