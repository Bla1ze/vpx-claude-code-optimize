WOO (Wrath of Olympus) — Ranked Optimization Targets
=====================================================

Script: JP's Wrath of Olympus v600.vbs (~5043 lines)
Table: Wrath of Olympus v6.0.0 — Original design by JPSalas

Mid-size custom table script with JP rolling sounds + integrated ball shadows,
FlipperTricks at 1ms timer, rainbow LED color cycling, GI update timer,
custom DMD system, and 6 flipper animate subs. No VPM/ROM — fully scripted game.

Notable: `tnob = 19` (up to 19 balls), `lob = 1` (1 locked/captive ball).
Table dimensions already cached at module level (lines 715-718).

---

## TARGET 1: RollingUpdate — CACHE BOT PROPERTIES + PRE-BUILD STRINGS + INLINE MATH (line 783)
**Heat: HIGH** — called every Realtime_Timer tick × up to 19 balls

Problems:
- `"fx_ballrolling" & b` string concatenation (lines 790, 812, 815) — 2-3 allocs per ball per tick
- `BallVel(BOT(b))` called at line 803, then `Pitch(BOT(b))` calls it again (line 805/808),
  and `Vol(BOT(b))` calls it again (line 806/809) — 3 redundant BallVel computations per ball per tick
- `Pan(BOT(b))` and `AudioFade(BOT(b))` each read `.x`/`.y` via COM — 2 COM reads per call,
  called for rolling (line 812) + drop sounds (line 822) = 4 calls per ball
- `BOT(b).X` read 1× (line 799), `BOT(b).Y` read 1× (line 800), `BOT(b).Z` read 3× (lines 801, 804, 821),
  `BOT(b).VelZ` read 1× (line 821), `BOT(b).VelX` read 2× (lines 828, 831),
  `BOT(b).VelY` read 2× (lines 829, 835), `BOT(b).AngMomZ` read+write (line 826) — ~12 COM reads uncached
- `BallSize/2` computed on line 801 every ball every tick — should be pre-computed constant
- `UBound(BOT)` read 3 times (lines 788, 795, 798) without caching
- Drop sound uses `"fx_balldrop"` (no per-ball index) but Pan/Pitch/AudioFade recomputed fresh
- Speed control section (lines 826-838) reads `BOT(b).VelX` and `BOT(b).VelY` multiple times

Fix:
1. Pre-build `RollStr(19)` at script load
2. Pre-compute `Const BS_d2 = BallSize / 2` or `Dim BS_d2` at module level
3. Cache `UBound(BOT)` into local `ub`
4. Cache all `BOT(b)` properties into locals at top of each iteration
5. Compute BallVel once, derive Vol and Pitch from single value
6. Compute Pan/AudioFade once per ball using cached x/y with XY variants
7. Reuse cached VelX/VelY for speed control section

**Estimated savings:** At 100Hz with 6 balls during multiball:
~36 string allocs/sec, ~3600 COM reads/sec, ~1800 redundant BallVel/sec eliminated

---

## TARGET 2: AudioFade / Pan — REPLACE ^10 WITH REPEATED SQUARING (lines 724, 742)
**Heat: HIGH** — called from every RollingUpdate iteration, every PlaySoundAt/PlaySoundAtBall call

Problems:
- `tmp ^10` (lines 728, 730, 746, 748) is generic VBS exponentiation dispatch — expensive
- `ball.VelX ^2` in BallVel (line 739) uses generic `^` dispatch instead of multiplication
- Table dimensions already cached (good!) but `^10` still hits every call
- Called from RollingUpdate (2× per ball per tick), from all collision/hit handlers

Fix:
1. Replace `tmp ^10` with repeated squaring: `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
2. Add `AudioFadeXY(y)` and `PanXY(x)` variants accepting pre-cached scalars
3. Replace `ball.VelX ^2` with `ball.VelX * ball.VelX` in BallVel
4. Note: function is named `Pan` here (not `AudioPan`) — maintain naming

**Estimated savings:** ~60-100 ^10 dispatches/sec replaced with 3 multiplications each

---

## TARGET 3: LeftFlipper_Timer (FlipperTricks) — 1ms→10ms + CACHE ANGLES (line 411)
**Heat: VERY HIGH** — runs at 1ms interval = 1000 calls/sec

Problems:
- Timer interval is 1ms (line 408) — 1000 calls/sec is extreme, 10ms is sufficient for flipper physics
- `LeftFlipper.CurrentAngle` read 2× (lines 413, 417), `LeftFlipper.StartAngle` read 1× (line 413),
  `LeftFlipper.EndAngle` read 1× (line 417) — 4 COM reads per tick for left flipper alone
- `RightFlipper.CurrentAngle` read 2× (lines 435, 439), `RightFlipper.StartAngle` 1× (line 435),
  `RightFlipper.EndAngle` 1× (line 439) — 4 more COM reads
- Total: 8 COM reads per tick × 1000 ticks/sec = 8000 COM reads/sec just for flipper tricks
- `.Strength`, `.EOSTorque`, `.Elasticity` written unconditionally in some branches

Fix:
1. Change timer interval from 1ms to 10ms (line 408)
2. Cache `LeftFlipper.CurrentAngle`, `.StartAngle` into locals
3. Cache `RightFlipper.CurrentAngle`, `.StartAngle` into locals

**Estimated savings:** 90% reduction in call frequency (1000→100/sec) + ~4 COM reads cached per tick.
Total: ~7200 COM reads/sec eliminated. Single biggest win on this table.

---

## TARGET 4: BallVel / Vol / Pitch — ELIMINATE REDUNDANT SQR AND ^2 (lines 720-739)
**Heat: MEDIUM** (mostly addressed by Target 1 caching)

Problems:
- `BallVel` computes `SQR(VelX^2 + VelY^2)` (line 739) — note: no INT() wrapper unlike other tables
- `Vol` squares the result: `BallVel^2 / 2000` (line 721) — SQR and ^2 cancel out
- `VelX ^2` uses generic `^` dispatch

Fix:
1. Replace `^2` with multiplication in BallVel
2. In RollingUpdate, compute `velSq` once, derive Vol as `velSq/2000` (no SQR)
   and Pitch from `SQR(velSq)*20`

**Estimated savings:** ~1 SQR + 1 ^2 per ball per tick. Mostly folded into Target 1.

---

## TARGET 5: GIUpdateTimer_Timer — AVOID GetBalls FOR BALL COUNT (line 629)
**Heat: MEDIUM** — runs every timer tick

Problems:
- Calls `GetBalls` every tick (line 631) just to check `UBound(tmp)` for ball count
- `GetBalls` allocates a new array via COM every call
- Already has `OldGiState` guard (line 632) — only acts on change, which is good
- But the `GetBalls` allocation still happens every tick

Fix:
1. Use module-level `BallsOnPlayfield` variable (already exists, line 67) instead of GetBalls
   if it's reliably maintained. Verify it tracks actual ball count.
   OR: Keep GetBalls but note it's a minor cost since only 1 call/tick (not per-ball).

**Estimated savings:** ~100 GetBalls COM calls/sec eliminated if replaceable with existing variable. Low priority if not.

---

## TARGET 6: RainbowTimer_Timer — PRE-COMPUTE RGB VALUES (line 2584)
**Heat: LOW-MEDIUM** — only active during rainbow effects

Problems:
- `RGB(rRed \ 10, rGreen \ 10, rBlue \ 10)` computed in loop over collection (line 2625)
- `.color` and `.colorfull` written to every light every tick even when values unchanged between ticks
- `rRed \ 10` etc. integer divisions repeated per light — should be computed once before loop

Fix:
1. Compute `RGB(...)` values once before the `For Each` loop into locals
2. Minor since rainbow is only active during specific effects

**Estimated savings:** Minor — eliminates N integer divisions per tick (N = collection size)

---

## TARGET 7: PRE-COMPUTED BallSize CONSTANT (module level)
**Heat: HIGH** (enables Target 1)

Fix:
1. Add `Dim BS_d2 : BS_d2 = BallSize / 2` at module level (or use `Const BS_d2 = 25`)
2. Replace `BallSize/2` in RollingUpdate line 801 with `BS_d2`

**Estimated savings:** Eliminates 1 division per ball per tick. Trivial alone but part of the overall RollingUpdate cleanup.

---

## Summary — Priority Order

| # | Target | Heat | Effort | Impact |
|---|--------|------|--------|--------|
| 1 | RollingUpdate | HIGH | Medium | Major — string allocs, redundant COM reads, redundant math, combined with shadows |
| 2 | AudioFade/Pan ^10 | HIGH | Low | Major — ^10 dispatch on every sound call |
| 3 | FlipperTricks 1ms→10ms | VERY HIGH | Trivial | Major — 90% call reduction, ~7200 COM reads/sec eliminated |
| 4 | BallVel/Vol/Pitch | MEDIUM | Low | Minor — redundant SQR (folded into #1) |
| 5 | GIUpdateTimer GetBalls | MEDIUM | Low | Minor — unnecessary per-tick COM allocation |
| 6 | RainbowTimer | LOW-MED | Trivial | Minor — pre-compute RGB before loop |
| 7 | BallSize pre-compute | HIGH | Trivial | Enables #1 cleanup |
