table.vbs Optimization Targets
================================
Ranked by: frequency × waste per call. Framerate subs (~60Hz) outrank 10ms timers (~100Hz)
which outrank slower timers. Status: [ ] = pending, [x] = applied.

---

## RANK 1 — DynamicBSUpdate: BOT COM property caching + pre-computed constants
**File:** table.vbs ~line 3592 | **Frequency:** every frame (~60Hz)

**Problems:**
- `BOT(s).X` accessed 4 times per ball per frame (lines 3617, 3619, 3624, 3631-3633)
- `BOT(s).Y` accessed 4 times per ball per frame (lines 3621, 3625, 3635)
- `BOT(s).Z` / `.z` accessed 3 times per ball per frame (lines 3615, 3626, 3656)
- `DSSources(iii)(0)` and `DSSources(iii)(1)` each accessed 2-3x inside the source loop (lines 3666, 3672, 3674)
- `DynamicBSFactor^2` computed at lines 3677, 3694 — same value, computed twice per shadow
- `DynamicBSFactor^3` computed at line 3694 and 3702 — same value, computed twice
- `BallSize/10`, `BallSize/5`, `BallSize/4`, `BallSize/2`, `tablewidth/2` are pure constants computed inside the loop every frame

**Fixes:**
1. At module level, pre-compute:
   - `DynBSFactor2 = DynamicBSFactor^2`  (= 0.9025)
   - `DynBSFactor3 = DynamicBSFactor^3`  (= 0.857375)
   - `BS_d10 = BallSize / 10`            (= 5)
   - `BS_d5  = BallSize / 5`             (= 10)
   - `BS_d4  = BallSize / 4`             (= 12.5)
   - `BS_d2  = BallSize / 2`             (= 25)
   - `TW_d2  = tablewidth / 2`           (tablewidth is a Dim at line 337)
2. At top of ball loop: `Dim bx, by, bz : bx = BOT(s).X : by = BOT(s).Y : bz = BOT(s).Z`
3. At top of source loop: `Dim sx, sy : sx = DSSources(iii)(0) : sy = DSSources(iii)(1)`
4. Replace all `BOT(s).X/Y/Z` inside loop with `bx/by/bz`
5. Replace `DynamicBSFactor^2` → `DynBSFactor2`, `^3` → `DynBSFactor3`
6. Replace inline constant math with pre-computed vars

**Estimated savings:** ~8-10 COM reads per ball per frame eliminated; 4 power ops per frame.
With 1-3 balls: ~8-30 COM reads/frame → ~480-1800/sec. Plus 4 exponentiation ops/frame.

**Status:** [x]

---

## RANK 2 — RollingUpdate: String concatenation + BOT COM property caching
**File:** table.vbs ~line 2001 | **Frequency:** every 10ms (100Hz)

**Problems:**
- `"BallRoll_" & b` string concatenated at lines 2010, 2021, 2025 — 3 allocations per ball per tick
- `BOT(b).z` (or `.Z`) read 3 times per ball in the shadow block (lines 2048, 2051) without caching
- `BOT(b).Y`, `BOT(b).X` each read once in shadow write (lines 2053-2054) after separate Z reads
- `BallSize/4`, `BallSize/2`, `BallSize/5` are constant expressions inside loop — should be pre-computed

**Fixes:**
1. At module level or Table1_Init, pre-build `BallRollStr` array:
   ```
   Dim BallRollStr(tnob)
   Dim brsI : For brsI = 0 To tnob : BallRollStr(brsI) = "BallRoll_" & brsI : Next
   ```
2. At top of rolling loop, cache `BOT(b).z`, `.X`, `.Y` into locals `bz`, `bx`, `by`
3. Replace all `"BallRoll_" & b` with `BallRollStr(b)`
4. Replace `BOT(b).z/X/Y` in shadow block with `bz/bx/by`
5. Use pre-computed `BS_d4`, `BS_d5`, `BS_d2` (from Rank 1 constants) in shadow math

**Estimated savings:** 3 string allocations/ball/tick × up to 5 balls = up to 15 allocs/tick eliminated.
At 100Hz: ~1500 string allocs/sec. Plus 4-6 COM reads per ball per tick.

**Status:** [x]

---

## RANK 3 — GraphicsTimer_Timer: Flipper angle caching + guard writes
**File:** table.vbs ~line 1810 | **Frequency:** every frame (~60Hz)

**Problems:**
- `LeftFlipper.CurrentAngle` read once but result written to two primitives without guard (lines 1831-1832)
- `RightFlipper.CurrentAngle` read once but result written to two primitives without guard (lines 1833-1834)
- GlowBats path similarly writes `LeftFlipper.CurrentAngle` and `RightFlipper.CurrentAngle` unconditionally (lines 1838-1841)
- In the GlowBat path, `LeftFlipper.CurrentAngle` appears to be read twice (line 1838 and 1839) — could be cached
- `BOT(b).z`, `.x`, `.y` in the glow ball loop (lines 1825-1826) read 3x per ball per frame without a local cache

**Fixes:**
1. Cache `LeftFlipper.CurrentAngle` and `RightFlipper.CurrentAngle` into locals at top of sub
2. For the primitive bat path, add last-angle state vars (`lastLeftAngle`, `lastRightAngle`) and guard:
   ```
   Dim la : la = LeftFlipper.CurrentAngle
   If la <> lastLeftAngle Then
       batleft.objrotz = la + 1
       batleftshadow.objrotz = la + 1
       lastLeftAngle = la
   End If
   ```
3. Cache `BOT(b).z`, `.x`, `.y` into locals inside the glow ball loop

**Estimated savings:** ~4 unconditional COM writes per frame reduced to 0 when flippers are at rest.
Flippers at rest ≈ 80%+ of frames. Savings: ~3-4 COM writes/frame on average.

**Status:** [x]

---

## RANK 4 — FlashFlasher: Pre-cache ObjLevel exponents
**File:** table.vbs ~line 4070 | **Frequency:** every 30ms per active flasher (~33Hz each)

**Problems:**
- `ObjLevel(nr)^2` computed at lines 4093, 4094, 4097, 4102, 4103, 4104, 4109, 4110, 4111 — up to 9x per call
- `ObjLevel(nr)^3` computed at lines 4095, 4096, 4105, 4112 — up to 4x per call
- Total: up to 13 power operations per FlashFlasher call, all using the same base value

**Fix:**
At top of FlashFlasher sub:
```
Dim lvl2 : lvl2 = ObjLevel(nr) * ObjLevel(nr)
Dim lvl3 : lvl3 = lvl2 * ObjLevel(nr)
```
Replace all `ObjLevel(nr)^2` → `lvl2`, `ObjLevel(nr)^3` → `lvl3`.
Note: `^` in VBScript calls a COM math dispatch — multiplication is faster.

**Estimated savings:** ~11 fewer power ops per call. With 5 flashers active: ~55 ops/frame saved.

**Status:** [x]

---

## RANK 5 — ClockTimer_Timer: Guard clock hand writes
**File:** table.vbs ~line 4840 | **Frequency:** depends on interval (appears periodic)

**Problems:**
- 4 calls to `Now()` per tick (lines 4841-4844), each a COM call to the system clock
- 3 unconditional COM writes to clock hand primitives per tick
- `Pminutes` and `Phours` change at most once per minute/hour — writing them every tick is pure waste
- `Pseconds` changes once per second — still far slower than any timer interval

**Fix:**
Cache current second/minute/hour into module-level vars. Compare before writing:
```
Dim ClkSec, ClkMin, ClkHour  ' module-level cache
' In ClockTimer_Timer:
Dim t : t = Now()
Dim s : s = Second(t)
If s <> ClkSec Then
    ClkSec = s
    Pseconds.RotAndTra2 = s * 6
    Dim m : m = Minute(t)
    If m <> ClkMin Then
        ClkMin = m
        Pminutes.RotAndTra2 = (m + (s/100)) * 6
        Dim h : h = Hour(t)
        If h <> ClkHour Then
            ClkHour = h
            Phours.RotAndTra2 = h*30 + (m/2)
        End If
    End If
End If
CurrentMinute = ClkMin
```

**Estimated savings:** Reduces 4 `Now()` COM calls + 3 COM writes per tick to 1 `Now()` call per tick,
with COM writes only when time actually advances. ~97% write reduction on hours/minutes.

**Status:** [x]

---

## RANK 6 — RampRollUpdate: String concatenation
**File:** table.vbs ~line 3825 | **Frequency:** every 100ms (10Hz) when ramp balls active

**Problems:**
- `"RampLoop" & x` concatenated at lines 3830, 3833, 3838, 3842, 3843, 3847 — 2-4 allocs per loop iteration
- `"wireloop" & x` concatenated at lines 3831, 3834, 3839, 3848 — 2-4 allocs per iteration
- Loop runs up to `UBound(RampBalls)` iterations (max 6 ramps)
- Total: up to 8 string allocations per iteration × 6 iterations = 48 allocs per 100ms tick

**Fix:**
Pre-build string arrays at module level or init. Max ramp index needs to be verified but appears to be 6:
```
Dim RampLoopStr(6), WireLoopStr(6)
Dim rsiI : For rsiI = 1 To 6
    RampLoopStr(rsiI) = "RampLoop" & rsiI
    WireLoopStr(rsiI) = "wireloop" & rsiI
Next
```
Replace all concatenated string args with indexed lookups.

**Estimated savings:** Eliminates up to 48 string allocations per 100ms tick when ramps are active.
Lower priority due to 10Hz frequency and only active during ramp use.

**Status:** [x]

---

## RANK 7 — DynamicBSUpdate: Pre-computed falloff constant
**File:** table.vbs ~line 3593 | **Frequency:** every frame if DynamicBallShadowsOn = 1

**Note:** `DynamicBallShadowsOn` is currently `0` (line 100), so this sub exits early after the
shadow hiding pass. This optimization only matters if the user enables dynamic shadows.

**Problem:**
- `falloff = 150` is a local Dim inside the sub, re-assigned every call
- `1/falloff` is implicitly computed as division in `(falloff-LSd)/falloff` and `(falloff-...)/falloff` — twice per shadow check
- Pre-computing `invFalloff = 1/falloff` and using multiplication is faster than repeated division

**Fix:**
Move `falloff` to a module-level Const, add `invFalloff`:
```
Const DS_falloff    = 150
Const DS_invFalloff = 1/150   ' = 0.006666...
```
Replace `(falloff-LSd)/falloff` → `(DS_falloff-LSd)*DS_invFalloff`
Replace `falloff^2` comparisons (if any added in distance gate) accordingly.

**Also:** The distance-squared gate optimization from dhChanges.txt is applicable here:
compute `dx*dx+dy*dy` and compare to `DS_falloff^2` before calling `DistanceFast()`.

**Status:** [x] (deferred — feature is disabled by default)

---

## RANK 8 — BeerTimer_Timer: Remove redundant Randomize call
**File:** table.vbs ~line 4815 | **Frequency:** depends on interval (bubble animation)

**Problem:**
- `Randomize(21)` is called at line 4817 on every timer tick with the same fixed seed (21)
- This resets the RNG to the same sequence each tick, making the animation cycle deterministic
- It also means every tick starts at the same RNG state — the bubbles always move by the same
  pseudo-random amounts in the same order, which defeats the purpose of using Rnd()
- `Randomize` is a non-trivial VBScript runtime call

**Fix:**
Remove `Randomize(21)` from the timer sub body. Call it once at script init (or not at all —
VBScript auto-seeds Rnd). If deterministic animation was intentional, the behavior is already
achieved just by having all 8 bubbles use the same successive Rnd calls each tick.

**Estimated savings:** 1 RNG seed call per timer tick. Minor but free.

**Status:** [x]

---

## SUMMARY TABLE

| Rank | Location              | Type                         | Freq   | Impact   | Status |
|------|-----------------------|------------------------------|--------|----------|--------|
| 1    | DynamicBSUpdate       | COM caching + pre-computed   | 60Hz   | HIGH     | [ ]    |
| 2    | RollingUpdate         | String alloc + COM caching   | 100Hz  | HIGH     | [ ]    |
| 3    | GraphicsTimer_Timer   | Guard writes + COM caching   | 60Hz   | MEDIUM   | [ ]    |
| 4    | FlashFlasher          | Pre-cache exponents          | ~33Hz  | MEDIUM   | [ ]    |
| 5    | ClockTimer_Timer      | Guard writes                 | varies | MEDIUM   | [ ]    |
| 6    | RampRollUpdate        | String alloc                 | 10Hz   | LOW      | [ ]    |
| 7    | DynamicBSUpdate       | Const + distance gate        | 60Hz   | LOW*     | [ ]    |
| 8    | BeerTimer_Timer       | Remove redundant Randomize   | varies | TRIVIAL  | [ ]    |

*Rank 7 impact is LOW because DynamicBallShadowsOn = 0 by default; HIGH if enabled.
