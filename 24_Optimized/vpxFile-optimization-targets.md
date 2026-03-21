vpxFile.vbs (twenty4_150) — Optimization Targets
==================================================
File: 1,026 lines. Table: 24 (Williams SAM).
Hot timers: LampTimer (5ms = 200Hz) > RollingTimer (~10ms) > FlipperTimer (-1?) > BallShadowUpdate_timer.
Status: [ ] = pending, [x] = applied.

---

## RANK 1 — UpdateLamps: Guard no-op NFadeL calls
**File:** line ~505 | **Frequency:** 200Hz (LampTimer_Timer at 5ms interval)

**Problem:** `UpdateLamps()` (called every 5ms) unconditionally calls `NFadeL` for 78 lamps + `NFadeObjm` for 3 lamps = **81 function calls per tick at 200Hz = 16,200 VBScript sub calls/sec**.

`NFadeL` does work only when `FadingLevel(nr)` is 4 or 5 (just-changed). Once processed, FadingLevel drops to 0 or 1 and subsequent calls are pure no-ops — the Select Case falls through without touching the COM object:
```vbs
Sub NFadeL(nr, object)
  Select Case FadingLevel(nr)
    Case 4:object.state = 0:FadingLevel(nr) = 0   ' only fires once per off-transition
    Case 5:object.state = 1:FadingLevel(nr) = 1   ' only fires once per on-transition
  End Select
End Sub
```
During normal gameplay, lamps are stable. The lamp-change rate from `Controller.ChangedLamps` is low — perhaps 2–5 lamps per PinMAME cycle. So 76+ of the 81 calls are no-ops every tick.

**Fix:** Guard each call with a FadingLevel check before calling — eliminates the sub call + Select Case overhead for all stable lamps:
```vbs
' In UpdateLamps, replace each:
  NFadeL 3, l3
' With:
  If FadingLevel(3) > 1 Then NFadeL 3, l3
```
`FadingLevel(nr) > 1` is true only when nr is 4 or 5 (pending transition). Array read is cheap; the sub call + Select Case it avoids is expensive.

Apply the same guard to the 3 `NFadeObjm` calls at lines 562, 564, 566.

**Estimated savings:** At 5ms/200Hz with ~76 stable lamps: 76 × 200 = **~15,200 no-op sub calls/sec eliminated**.

**Status:** [x]

---

## RANK 2 — BallVel / Vol / Pan / AudioFade: Replace `^` with multiplication
**File:** lines ~819, ~837, ~826, ~812 | **Frequency:** every active ball per RollingTimer tick + collision events

**Problem:** Four hot-path functions all use VBScript `^` (slow COM-level dispatch):

| Function | Line | Exponentiation | Fix |
|----------|------|----------------|-----|
| `BallVel(ball)` | 837 | `ball.VelX ^2 + ball.VelY ^2` | `ball.VelX * ball.VelX + ball.VelY * ball.VelY` |
| `Vol(ball)` | 819 | `BallVel(ball) ^2 / 2000` | cache BallVel result: `bv*bv/2000` |
| `Pan(ball)` | 826, 828 | `tmp ^10`, `(-tmp) ^10` | `t2=tmp*tmp: t4=t2*t2: t8=t4*t4: t8*t2` |
| `AudioFade(ball)` | 812, 814 | `tmp ^10`, `(-tmp) ^10` | same pattern |

`Pan` and `AudioFade` use `^10` — replaceable with 3 multiplications using squaring:
```vbs
' tmp^10 via repeated squaring (3 muls instead of 1 ^ dispatch):
Dim t2 : t2 = tmp * tmp
Dim t4 : t4 = t2 * t2
Dim t8 : t8 = t4 * t4
result = t8 * t2   ' = tmp^10
```

`Vol` calls `BallVel(ball)` which itself does two `^2` ops, then squares the result again. Cache the result:
```vbs
Function Vol(ball)
  Dim bv : bv = BallVel(ball)
  Vol = Csng(bv * bv / 2000)
End Function
```

**Also:** `OnBallBallCollision` (line 892) uses `Csng(velocity) ^2 / 200` — replace with `v=Csng(velocity): v*v/200`.

**Estimated savings:** Called from RollingTimer per active ball per tick (~5 balls × ~100Hz = ~500 calls/sec). Each eliminates 1–2 `^` dispatches. Also benefits all collision/hit event handlers that call these functions.

**Status:** [x]

---

## RANK 3 — RollingTimer_Timer: Pre-build ball sound name strings
**File:** line ~862 | **Frequency:** ~100Hz (10ms timer or similar)

**Problem:** `"fx_ballrolling" & b` concatenated **4 times per ball** per tick:
- Line 862: `StopSound("fx_ballrolling" & b)` — in cleanup loop
- Line 873: `PlaySound("fx_ballrolling" & b), ...` — on-playfield sound
- Line 875: `PlaySound("fx_ballrolling" & b), ...` — on-ramp sound
- Line 879: `StopSound("fx_ballrolling" & b)` — stop when slowing

With 5 balls at 100Hz: up to **2,000 string allocations/sec**.

**Fix:**
```vbs
' After ReDim rolling(tnob):
ReDim BallRollStr(tnob)
Dim brsI : For brsI = 0 To tnob : BallRollStr(brsI) = "fx_ballrolling" & brsI : Next
```
Replace all `"fx_ballrolling" & b` → `BallRollStr(b)`.

**Estimated savings:** 4 string allocations per ball per tick eliminated.
At 100Hz with 5 balls: **~2,000 string allocs/sec eliminated**.

**Status:** [x]

---

## RANK 4 — FlipperTimer_Timer: Guard unconditional angle writes
**File:** line ~902 | **Frequency:** every frame or fast timer interval

**Problem:** 5 unconditional COM reads + writes per tick:
```vbs
Sub FlipperTimer_Timer()
  FlipperLSh.RotZ = LeftFlipper.currentangle    ' read + write every tick
  FlipperRSh.RotZ = RightFlipper.currentangle   ' read + write every tick
  sw14Prim.Rotz = sw14.Currentangle             ' read + write every tick
  sw54Prim.Rotz = sw54.Currentangle             ' read + write every tick
  sw58Prim.Rotz = sw58.Currentangle             ' read + write every tick
End Sub
```
Flippers and gates are stationary the vast majority of the time. Unconditional writes hit the COM boundary on every tick.

**Fix:**
```vbs
' Module-level state vars:
Dim lastLFAngle, lastRFAngle, lastSW14Angle, lastSW54Angle, lastSW58Angle

' In FlipperTimer_Timer:
Dim curA
curA = LeftFlipper.currentangle
If curA <> lastLFAngle Then lastLFAngle = curA : FlipperLSh.RotZ = curA
curA = RightFlipper.currentangle
If curA <> lastRFAngle Then lastRFAngle = curA : FlipperRSh.RotZ = curA
curA = sw14.Currentangle
If curA <> lastSW14Angle Then lastSW14Angle = curA : sw14Prim.Rotz = curA
curA = sw54.Currentangle
If curA <> lastSW54Angle Then lastSW54Angle = curA : sw54Prim.Rotz = curA
curA = sw58.Currentangle
If curA <> lastSW58Angle Then lastSW58Angle = curA : sw58Prim.Rotz = curA
```

**Estimated savings:** ~80% of ticks are idle (flippers/gates stationary) → up to 5 COM writes/tick eliminated.

**Status:** [x]

---

## RANK 5 — BallShadowUpdate_timer: Cache BOT(b).Z + guard .visible
**File:** line ~918 | **Frequency:** ~60–100Hz

**Problem:** Per-ball inner loop:
```vbs
If BOT(b).Z > 20 and BOT(b).Z < 200 Then    ' BOT(b).Z read 1×
    BallShadow(b).visible = 1                 ' unconditional write
Else
    BallShadow(b).visible = 0                 ' unconditional write
End If
if BOT(b).z > 30 Then                        ' BOT(b).z read 2× (same property, different case)
    ballShadow(b).height = BOT(b).Z - 20      ' BOT(b).Z read 3×
    ballShadow(b).opacity = 90
Else
    ballShadow(b).height = BOT(b).Z - 24      ' BOT(b).Z read 4×
    ballShadow(b).opacity = 90
End If
```

- `BOT(b).Z` / `BOT(b).z` read **4 times** per ball — cache into `bz`
- `BallShadow(b).visible` written unconditionally — should guard
- `ballShadow(b).opacity = 90` set in both branches — same value both times, pure waste on second assignment; can be set once outside the if

**Fix:**
```vbs
' Add bz to sub Dim: Dim BOT, b, bz, bvis
bz = BOT(b).Z
If bz > 20 And bz < 200 Then bvis = 1 Else bvis = 0
If BallShadow(b).visible <> bvis Then BallShadow(b).visible = bvis
ballShadow(b).opacity = 90        ' same both branches — set once
If bz > 30 Then
    ballShadow(b).height = bz - 20
Else
    ballShadow(b).height = bz - 24
End If
```

**Estimated savings:** 3 saved COM reads per ball per frame + eliminated unconditional .visible write when stable.
At 60Hz with 1 ball: **~180 COM reads/sec + ~60 writes/sec eliminated**.

**Status:** [x]

---

## RANK 6 — SafehouseT_Timer + SuitcaseT_Timer: Cache repeated RotY / RotAndTra7 reads
**File:** lines ~442, ~462 | **Frequency:** while toys are moving (event-driven duration)

**Problem:** `SafehouseT_Timer` reads `Safehouse.RotY` **5 times** per tick:
```vbs
If SafeRot = True and Safehouse.RotY >= 180 then     ' read 1
    Safehouse.RotY = Safehouse.RotY - 3              ' read 2 + write
End If
If SafeRot = False and Safehouse.RotY <= 270 then    ' read 3
    Safehouse.RotY = Safehouse.RotY + 3              ' read 4 + write
End If
If Safehouse.RotY = 180 then SafeRot = False         ' read 5
```

`SuitcaseT_Timer` has the identical pattern for `Suitcase.RotAndTra7` — 5 reads per tick.

**Fix:** Cache property into local var, do all arithmetic locally, write back once:
```vbs
Sub SafehouseT_Timer()
  Dim sRotY : sRotY = Safehouse.RotY
  If SafeRot = True And sRotY >= 180 Then
    DOF 201, DOFOn
    sRotY = sRotY - 3
    DOF 201, DOFOff
  End If
  If SafeRot = False And sRotY <= 270 Then
    DOF 201, DOFOn
    sRotY = sRotY + 3
    DOF 201, DOFOff
  End If
  If sRotY = 180 Then SafeRot = False
  Safehouse.RotY = sRotY   ' one write
End Sub
```
Apply same pattern to `SuitcaseT_Timer` for `Suitcase.RotAndTra7`.

**Estimated savings:** 4 COM reads → 0 per tick while toy is moving. 2 conditional writes → 1 unconditional write (same or fewer total writes).

**Status:** [x]

---

## RANK 7 — SniperT_Timer: Cache Sniper.rotandtra8
**File:** line ~418 | **Frequency:** while sniper is moving

**Problem:** `Sniper.rotandtra8` read + written on every tick:
```vbs
If Sniper.rotandtra8 <= 95 then            ' read 1
    Sniper.rotandtra8 = Sniper.rotandtra8 + 1   ' read 2 + write
```
2 COM reads per active branch; the property is a COM boundary crossing each time.

**Fix:**
```vbs
Sub SniperT_Timer()
  Dim sVal : sVal = Sniper.rotandtra8
  If sniperstate = False Then
    If sVal <= 95 Then
      sVal = sVal + 1
      Sniper.rotandtra8 = sVal
    Else
      SniperT.Enabled = True
      sniperstate = True
    End If
  Else
    If sVal >= 25 Then
      sVal = sVal - 1
      Sniper.rotandtra8 = sVal
    Else
      SniperT.Enabled = False
      sniperstate = False
    End If
  End If
End Sub
```

**Estimated savings:** 1 COM read eliminated per tick while sniper is moving. Minor but free.

**Status:** [x]

---

## BUG NOTE — AudioFade defined twice (lines 788 and 808)
**Not a performance issue, but a correctness bug:**
`Function AudioFade` is defined at line 788 (takes `tableobj`) AND again at line 808 (takes `ball`).
In VBScript, the second definition silently overwrites the first — the `tableobj` version is dead code.
This means calls like `AudioFade(Trigger1)` at line 359 use the `ball`-parameterized version, which reads `.y` and `.Y` correctly for both objects since VBScript is duck-typed. However, the dead first definition is confusing and should be removed to avoid future maintenance confusion.
This is not an optimization target — leaving as a note.

---

## SUMMARY TABLE

| Rank | Location | Type | Freq | Impact | Status |
|------|----------|------|------|--------|--------|
| 1 | UpdateLamps (~505) | Guard 81 no-op NFadeL calls per tick | 200Hz | **HIGH** — ~15,200 no-op calls/sec | [x] |
| 2 | BallVel/Vol/Pan/AudioFade (~819–837) | Replace `^2`/`^10` with multiplication | per ball/event | **MEDIUM** — eliminates ^ dispatch per ball per tick | [x] |
| 3 | RollingTimer_Timer (~862) | Pre-build ball sound name strings | ~100Hz | **MEDIUM** — ~2,000 string allocs/sec (5 balls) | [x] |
| 4 | FlipperTimer_Timer (~902) | Guard 5 unconditional angle writes | every frame | **MEDIUM** — ~5 writes/tick eliminated at idle | [x] |
| 5 | BallShadowUpdate_timer (~918) | Cache BOT(b).Z + guard .visible | ~60–100Hz | **MEDIUM** — ~180 COM reads/sec per ball | [x] |
| 6 | SafehouseT + SuitcaseT (~442, ~462) | Cache RotY/RotAndTra7 (5 reads → 1) | while moving | LOW — per-event, not always hot | [x] |
| 7 | SniperT_Timer (~418) | Cache rotandtra8 (2 reads → 0 in hot branch) | while moving | LOW — minor, per-event | [x] |

**Key characteristic:** This file's primary bottleneck is `UpdateLamps` running at 200Hz with 81 unconditional function calls — most of which are no-ops. The `^` exponentiation in the audio helper functions is the secondary target since those functions are called per-ball per rolling timer tick.
