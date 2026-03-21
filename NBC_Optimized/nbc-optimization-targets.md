Nightmare Before Christmas (2024) v1.02.vbs — Optimization Targets
=====================================================================
File: 13,012 lines. Ranked by frequency × waste per call.
FrameTimer_Timer (~77Hz) > GameTimer_Timer (13ms = ~77Hz) > RampRoll_Timer (100ms = 10Hz).
Status: [ ] = pending, [x] = applied.

---

## RANK 1 — FrameTimer_Timer: Cache repeated GetInPlayIntensity/colorfull reads
**File:** line ~2882 | **Frequency:** ~77Hz (FrameTimer_Timer)

**Problems — 48+ redundant COM reads per frame:**

| Property | Lines called | Reads | Fix |
|----------|-------------|-------|-----|
| `gi033.GetInPlayIntensity` | 2981, 2990, 2992, 2996, 2998, 3000, 3006, 3019, 3078-3083, 3092, 3093 | **16×** | `Dim gi033i : gi033i = gi033.GetInPlayIntensity` |
| `gi033.colorfull` | 3085, 3086, 3087, 3088, 3089, 3090 | **6×** | `Dim gi033c : gi033c = gi033.colorfull` |
| `libumper.GetInPlayIntensity` | 3100, 3101, 3103, 3104, 3105, 3196(×2) | **7×** | `Dim libui : libui = libumper.GetInPlayIntensity` |
| `f3.GetInPlayIntensity` | 3073, 3210, 3211, 3213, 3214 | **5×** | `Dim f3i : f3i = f3.GetInPlayIntensity` |
| `Flasher020.opacity` (read after write) | 3052, 3053, 3055, 3056, 3058, 3059, 3060 | **7×** | Cache the value written: `Dim fl020op : fl020op = Light001.getinplayintensity : Flasher020.opacity = fl020op` |
| `PoliceL22.getinplayintensity` | 3192, 3193, 3194 | **3×** | `Dim pol22i : pol22i = PoliceL22.getinplayintensity` |
| `f4.getinplayintensity` | 3222, 3223, 3224 | **3×** | `Dim f4i : f4i = f4.getinplayintensity` |
| `F5.GetInPlayIntensity` | 3075 (two reads in one RGB call) | **2×** | `Dim f5i : f5i = F5.GetInPlayIntensity` |
| `f4.GetInPlayStateBool` | 3010, 3011 | **2×** | `Dim f4s : f4s = f4.GetInPlayStateBool` |
| `f5.GetInPlayStateBool` | 3012, 3013 | **2×** | `Dim f5s : f5s = f5.GetInPlayStateBool` |
| `f2b.GetInPlayStateBool` | 3014, 3015 | **2×** | `Dim f2bs : f2bs = f2b.GetInPlayStateBool` |
| `f1b.GetInPlayStateBool` | 3016, 3017 | **2×** | `Dim f1bs : f1bs = f1b.GetInPlayStateBool` |

**Also fix:** Line 3073 — `(F3.GetInPlayIntensity / 5) ^2` becomes `(f3i / 5) * (f3i / 5)` after caching f3i.
Replace `^2` with multiplication — VBScript `^` is a COM math dispatch; `*` is a stack op.

**Fix:** Declare all cache vars at top of FrameTimer_Timer sub, read once, use throughout.

**Estimated savings:** ~48 redundant COM reads eliminated per frame × 77Hz = **~3,700 COM reads/sec eliminated**.

**Status:** [x]

---

## RANK 2 — FrameTimer_Timer: Cache flipper angles + remove duplicate line
**File:** line ~2889 | **Frequency:** ~77Hz

**Problems:**
- `LeftFlipper.CurrentAngle` read **4 times** on lines 2889, 2890, 2893, 2894
- `RightFlipper.CurrentAngle` read **3 times** on lines 2891, 2892, 2895
- **Line 2894 is a literal duplicate of line 2893** — same object, same property:
  ```
  2893:  FlipperLSh.RotZ = LeftFlipper.CurrentAngle
  2894:  FlipperLSh.RotZ = LeftFlipper.CurrentAngle   ← pure waste, writes same value twice
  ```
- All 7 RotZ writes are unconditional every frame (no change guard)

**Fix:**
```vbs
Dim lfa : lfa = LeftFlipper.CurrentAngle
Dim rfa : rfa = RightFlipper.CurrentAngle
' Remove line 2894 (duplicate)
' Add module-level lastLeftAngle, lastRightAngle
' Guard: If lfa <> lastLeftAngle Then ... (writes LFLogo, LFLogo1, FlipperLSh, LFLogo001, LFLogo002)
' Guard: If rfa <> lastRightAngle Then ... (writes RFlogo, RFLogo1, FlipperRSh)
```

**Estimated savings:** 5 redundant COM reads/frame + 7 unconditional writes/frame → 0 when flippers at rest (~80% of frames).
At 77Hz: **~385 COM reads/sec + up to ~540 COM writes/sec eliminated**.

**Status:** [x]

---

## RANK 3 — FrameTimer_Timer: Cache Plunger.Position + remove duplicate transz write
**File:** line ~3176 | **Frequency:** ~77Hz

**Problems:**
- `Plunger.Position * 4 + ShakeStuff1` evaluated **7 times** (lines 3176, 3177, 3178, 3187, 3189, 3190, 3191)
  — `Plunger.Position` is a COM property read, called 7 times per frame
- **Line 3187 is a literal duplicate of line 3178** — same object (Primitive187), same expression:
  ```
  3178:  Primitive187.transz = -77 + Plunger.Position * 4 + ShakeStuff1
  3179:  Primitive187.transy = ShakeStuff1 + ShakeStuff3 / 2
  ... conditional block ...
  3187:  Primitive187.transz = -77 + Plunger.Position * 4 + ShakeStuff1   ← duplicate, overwrites 3178
  ```

**Fix:**
```vbs
Dim pltz : pltz = -77 + Plunger.Position * 4 + ShakeStuff1
Primitive150.transz = pltz
Primitive148.transz = pltz
Primitive187.transz = pltz    ' line 3178, remove line 3187
Primitive187.transy = ShakeStuff1 + ShakeStuff3 / 2
' ... conditional block (no transz write needed) ...
Primitive149.transz = pltz
Primitive146.transz = pltz
Primitive012.transz = pltz
```

**Estimated savings:** 6 saved COM reads/frame (Plunger.Position) + 1 redundant write eliminated.
At 77Hz: **~462 COM reads/sec eliminated**.

**Status:** [x]

---

## RANK 4 — GameTimer_Timer: Guard GI color writes in aGILights loop
**File:** line ~721 | **Frequency:** 13ms = ~77Hz

**Problem:** Lines 721-724 — every GameTimer tick writes `bulb.color` and `bulb.colorfull` for every
bulb in aGILights unconditionally:
```vbs
For each bulb in aGILights
    bulb.color     = rgb( rl(7) , rl(8) , rl(9) )
    bulb.colorfull = rgb( rl(10), rl(11), rl(12) )
Next
```
The `rl(7-12)` values only change during GI color transitions — they are stable for most frames.
Each iteration writes 2 COM properties per bulb × N bulbs × 77Hz, even when the color is unchanged.

**Fix:**
Pre-compute and cache the RGB values; skip the loop when unchanged:
```vbs
Dim giClr : Dim giClrF   ' module-level cache vars
' In GameTimer_Timer, replace loop with:
Dim newClr  : newClr  = rgb( rl(7) , rl(8) , rl(9) )
Dim newClrF : newClrF = rgb( rl(10), rl(11), rl(12) )
If newClr <> giClr Or newClrF <> giClrF Then
    giClr = newClr : giClrF = newClrF
    For each bulb in aGILights
        bulb.color     = giClr
        bulb.colorfull = giClrF
    Next
End If
```

**Estimated savings:** During stable GI (most of gameplay), eliminates N×2 COM writes per frame.
Savings depend on bulb count (N) and transition frequency.

**Status:** [x]

---

## RANK 5 — RollingUpdate: Pre-build BallRollStr + cache gBOT(b).z/.VelZ
**File:** line ~6340 | **Frequency:** 13ms = ~77Hz (called from GameTimer_Timer)

**Problems:**
- `"BallRoll_" & b` string concatenated **3 times per ball per tick** (lines 6350, 6360, 6363)
- `gBOT(b).z` accessed **3 times** per ball: lines 6358, 6369 (×2 in condition) — no local cache
- `gBOT(b).VelZ` accessed **2 times**: lines 6369, 6372 — no local cache

**Fix:**
```vbs
' Module level (use ReDim, not Dim — VBScript Dim rejects Const as array bound):
ReDim BallRollStr(tnob)
Dim brsI : For brsI = 0 To tnob : BallRollStr(brsI) = "BallRoll_" & brsI : Next

' In RollingUpdate main loop, add at top:
Dim bz, bvz
' ...
For b = 0 To UBound(gBOT)
    bz  = gBOT(b).z    ' cache .z
    bvz = gBOT(b).VelZ ' cache .VelZ
```
Replace all `"BallRoll_" & b` with `BallRollStr(b)`.
Replace `gBOT(b).z` with `bz`, `gBOT(b).VelZ` and `gBOT(b).velz` with `bvz`.

**Estimated savings:** 3 string allocs/ball/tick eliminated; 4 COM reads/ball/tick eliminated.
With 1 ball: ~231 string allocs/sec + ~308 COM reads/sec eliminated.

**Status:** [x]

---

## RANK 6 — RampRoll_Timer + WRemoveBall: Pre-build ramp sound strings
**File:** lines ~6512, ~6489 | **Frequency:** 100ms = ~10Hz (RampRoll); per-event (WRemoveBall)

**Problems:**
- `"RampLoop" & x` concatenated at lines 6518, 6521, 6526, 6530 — up to 4× per iteration
- `"wireloop" & x` concatenated at lines 6519, 6522, 6527, 6531, 6535, 6536 — up to 4× per iteration
- `WRemoveBall` also has `StopSound("RampLoop" & x)` and `StopSound("wireloop" & x)` (lines 6499-6500)
- Loop runs up to `UBound(RampBalls)` = 6 iterations

**Fix:**
```vbs
' Module level:
ReDim RampLoopStr(6), WireLoopStr(6)
Dim rsiI : For rsiI = 1 To 6 : RampLoopStr(rsiI) = "RampLoop" & rsiI : WireLoopStr(rsiI) = "wireloop" & rsiI : Next
```
Replace all `"RampLoop" & x` → `RampLoopStr(x)`, `"wireloop" & x` → `WireLoopStr(x)`.

**Estimated savings:** Up to 8 string allocs per 100ms tick eliminated; also eliminates allocs on ball removal events.

**Status:** [x]

---

## RANK 7 — FrameTimer_Timer: Guard GI material string assignments
**File:** line ~3112 | **Frequency:** ~77Hz

**Problem:** Lines 3112-3133 — every frame inside `If tmp > 0.02 Then`, 10 sling/spinner
primitive material strings + a For-Each over Wireramps are written unconditionally:
```vbs
If tmp > 0.02 Then
    Spinner003.material = "plastic"
    RightSling001.material = "Rubber White"
    ... (7 more assignments)
    For Each BL in Wireramps : BL.material = "Metal Dark3" : Next
Else
    Spinner003.material = "plastic2"
    ... same pattern with different strings
End If
```
`tmp = gi033i / 123` (after rank 1 fix). The `tmp > 0.02` condition switches at GI threshold.
String COM assignments are expensive even when value hasn't changed — they trigger VPX material
lookup every frame.

**Fix:** Add a module-level boolean `lastGIBright`. Only write materials on the frame the
threshold is crossed, not on every frame it's already in the same state:
```vbs
Dim lastGIBright   ' module-level, initialized to -1 (unknown)
' ...
Dim giNowBright : giNowBright = (tmp > 0.02)
If giNowBright <> lastGIBright Then
    lastGIBright = giNowBright
    If giNowBright Then
        Spinner003.material = "plastic"
        ... etc ...
    Else
        Spinner003.material = "plastic2"
        ... etc ...
    End If
End If
```

**Estimated savings:** Eliminates ~11 string COM assignments + N ForEach writes per frame (every frame except transition frames).
At 77Hz: **~847+ COM string writes/sec eliminated**.

**Status:** [x]

---

## RANK 8 — FlipperNudge: Pre-compute PI/180 constant
**File:** line ~5012 | **Frequency:** ~10-30Hz (called from RightFlipper_timer)

**Problem:**
- Lines 5012, 5016: `dSin = Sin(degrees * Pi / 180)`, `dCos = Cos(degrees * Pi / 180)`
- `Pi / 180` is a constant expression recomputed on every call
- `degrees * Pi / 180` where Pi is already a Const — the division is redundant per call

**Fix:**
```vbs
Const Pi_over_180 = 3.14159265358979 / 180   ' = 0.01745329...
' Then:
dSin = Sin(degrees * Pi_over_180)
dCos = Cos(degrees * Pi_over_180)
```

**Estimated savings:** 2 divisions eliminated per FlipperNudge call. Minor but free.

**Status:** [x]

---

## SUMMARY TABLE

| Rank | Location | Type | Freq | Impact | Status |
|------|----------|------|------|--------|--------|
| 1 | FrameTimer_Timer (~2882) | Cache 12 repeated COM reads | 77Hz | **HIGH** — ~3,700 reads/sec | [x] |
| 2 | FrameTimer_Timer (~2889) | Cache flipper angles + fix dup line | 77Hz | **HIGH** — ~925 ops/sec | [x] |
| 3 | FrameTimer_Timer (~3176) | Cache Plunger.Position + fix dup write | 77Hz | **MEDIUM** — ~462 reads/sec | [x] |
| 4 | GameTimer_Timer (~721) | Guard GI loop writes | 77Hz | **MEDIUM** — N×2 writes/frame | [x] |
| 5 | RollingUpdate (~6340) | String cache + COM cache | 77Hz | **MEDIUM** — ~540 ops/sec/ball | [x] |
| 6 | RampRoll+WRemoveBall (~6512) | String cache | 10Hz | LOW — string allocs when active | [x] |
| 7 | FrameTimer_Timer (~3112) | Guard material string writes | 77Hz | **MEDIUM** — ~847 writes/sec | [x] |
| 8 | FlipperNudge (~5012) | Pre-compute Pi/180 | 10-30Hz | TRIVIAL | [x] |

**Key difference from table.vbs:** This table's bottleneck is FrameTimer_Timer's mass of unconditional
COM reads and writes (~300 per frame). The primary wins are caching repeated reads of the same
light property within one frame, plus fixing 2 literal duplicate assignments (lines 2894 and 3187).
