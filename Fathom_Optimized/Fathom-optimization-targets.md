Fathom-optimization-targets.md (vpxFile-Fathom.vbs) — Optimization Targets
=============================================================================
File: ~5100+ lines. Table: Fathom (Bally 1981), v2.0 by UnclePaulie.
Hot timers:
  GameTimer_Timer  (~10ms, 100Hz) → Cor.Update, RollingUpdate, DoDTAnim, DoSTAnim, SpinnerTimer
  FrameTimer_Timer (-1, every frame, ~60Hz) → FlipperVisualUpdate, DynamicBSUpdate, LampTimer (Lampz.Update2), UpdateBallBrightness
gBOT pre-allocated as Array(FBall1,Fball2,Fball3) — NOT rebuilt via GetBalls each tick.
tnob = 3, lob = 0.
Status: [x] = pending, [x] = applied.

---

## RANK 1 — RollingUpdate: Cache gBOT(b) properties + inline BallVel
**File:** lines ~2999–3061 | **Frequency:** 100Hz (GameTimer_Timer ~10ms)

**Problem:** Per-ball inner loop reads `gBOT(b)` COM properties repeatedly without caching:
- `gBOT(b).z` / `.Z` read **5–6 times** per ball:
  - line 3016: rolling condition (`z < 30`)
  - line 3019: ramp condition (`z > 70`)
  - line 3030: drop check (`z < 55`)
  - line 3030: drop check (`z > 27`)
  - line 3049: shadow section (`Z > 30`)
  - line 3050/3053: shadow height computation
- `gBOT(b).X` read 2× (AudioPan + shadow.X at 3048)
- `gBOT(b).Y` read 2× (AudioFade + shadow.Y at 3051/3054)
- `gBOT(b).VelX` / `.VelY` read 2× per `BallVel()` call — and `BallVel` is called **3× per rolling ball**:
  - line 3016: rolling condition
  - line 3018/3021: inside `VolPlayfieldRoll(gBOT(b))` (which calls `BallVel`)
  - line 3018/3021: inside `PitchPlayfieldRoll(gBOT(b))` (which calls `BallVel`)
- `gBOT(b).VelZ` read at line 3030 (drop check) and 3033 (drop sound branch)

```vbs
Sub RollingUpdate()
    ...
    For b = 0 to UBound(gBOT)
        If BallVel(gBOT(b)) > 1 AND gBOT(b).z < 30 Then        ' VelX+VelY read, z read #1
            PlaySound ("BallRoll_" & b), -1,
                VolPlayfieldRoll(gBOT(b)) * ...,                ' BallVel #2 → VelX+VelY again
                AudioPan(gBOT(b)), 0,
                PitchPlayfieldRoll(gBOT(b)), ...                ' BallVel #3 → VelX+VelY again
        ElseIf BallVel(gBOT(b)) > 1 AND gBOT(b).z > 70 Then    ' BallVel #4, z read #2
            ...
        End If
        If gBOT(b).VelZ < -1 and gBOT(b).z < 55 and gBOT(b).z > 27 Then  ' z read #3+#4
            ...
            If gBOT(b).velz > -7 Then ...                       ' VelZ 2nd read
        End If
        BallShadowA(b).X = gBOT(b).X + offsetX                 ' X read #2
        If gBOT(b).Z > 30 Then                                  ' z read #5
            BallShadowA(b).height = gBOT(b).z - ...             ' z read #6
            BallShadowA(b).Y = gBOT(b).Y + offsetY + ...        ' Y read #2
        Else
            BallShadowA(b).height = gBOT(b).z - ...             ' z read #7
            BallShadowA(b).Y = gBOT(b).Y + offsetY              ' Y read #3
        End If
    Next
```

**Fix:** Cache all per-ball properties at loop top; inline BallVel; pass cached values to audio helpers:
```vbs
Sub RollingUpdate()
    Dim b, bz, bx, by, bvx, bvy, bvz, bvel
    ' stop the sound of deleted balls
    For b = UBound(gBOT) + 1 to tnob
        rolling(b) = False
        StopSound BallRollStr(b)
    Next
    If UBound(gBOT) = -1 Then Exit Sub

    For b = 0 to UBound(gBOT)
        bx  = gBOT(b).X
        by  = gBOT(b).Y
        bz  = gBOT(b).Z
        bvx = gBOT(b).VelX
        bvy = gBOT(b).VelY
        bvz = gBOT(b).VelZ
        bvel = INT(SQR(bvx * bvx + bvy * bvy))   ' inlined BallVel — no ^2, no re-reads

        If bvel > 1 AND bz < 30 Then
            rolling(b) = True
            PlaySound BallRollStr(b), -1,
                RollingSoundFactor * 0.0005 * (bvel * bvel * bvel) * BallRollVolume * VolumeDial,
                AudioPanXY(bx), 0,
                bvel * bvel * 15, 1, 0, AudioFadeXY(by)         ' inlined Pitch/Vol/Pan/Fade
        ElseIf bvel > 1 AND bz > 70 Then
            rolling(b) = True
            PlaySound BallRollStr(b), -1,
                RollingSoundFactor * 0.0005 * (bvel * bvel * bvel) * BallRollVolume * VolumeDial,
                AudioPanXY(bx), 0,
                bvel * bvel * 15, 1, 0, AudioFadeXY(by)
        Else
            If rolling(b) = True Then
                StopSound BallRollStr(b)
                rolling(b) = False
            End If
        End If

        If bvz < -1 And bz < 55 And bz > 27 Then
            If DropCount(b) >= 5 Then
                DropCount(b) = 0
                If bvz > -7 Then
                    RandomSoundBallBouncePlayfieldSoft gBOT(b)
                Else
                    RandomSoundBallBouncePlayfieldHard gBOT(b)
                End If
            End If
        End If
        If DropCount(b) < 5 Then DropCount(b) = DropCount(b) + 1

        If AmbientBallShadowOn = 0 Then
            BallShadowA(b).visible = 1
            BallShadowA(b).X = bx + offsetX
            If bz > 30 Then
                BallShadowA(b).height = bz - BallSize/4 + b/1000
                BallShadowA(b).Y = by + offsetY + BallSize/10
            Else
                BallShadowA(b).height = bz - BallSize/2 + 1.04 + b/1000
                BallShadowA(b).Y = by + offsetY
            End If
        End If
    Next
End Sub
```
Add two thin wrappers so AudioPan/AudioFade can accept pre-cached scalars instead of ball objects:
```vbs
Function AudioPanXY(ByVal x)      ' pass cached bx
    Dim tmp, t2, t4, t8
    tmp = x * 2 / tablewidth - 1
    If tmp > 7000 Then tmp = 7000 ElseIf tmp < -7000 Then tmp = -7000 End If
    If tmp > 0 Then
        t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4 : AudioPanXY = Csng(t8*t2)
    Else
        tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4 : AudioPanXY = Csng(-(t8*t2))
    End If
End Function

Function AudioFadeXY(ByVal y)     ' pass cached by
    Dim tmp, t2, t4, t8
    tmp = y * 2 / tableheight - 1
    If tmp > 7000 Then tmp = 7000 ElseIf tmp < -7000 Then tmp = -7000 End If
    If tmp > 0 Then
        t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4 : AudioFadeXY = Csng(t8*t2)
    Else
        tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4 : AudioFadeXY = Csng(-(t8*t2))
    End If
End Function
```
Note: `RandomSoundBallBounce*` still receives `gBOT(b)` (object) — these are event-driven sounds
called at most once per 5 ticks per ball, not worth inlining.

**Estimated savings:** ~12 COM reads eliminated per ball per tick.
At 100Hz × 3 balls: **~3,600 COM reads/sec eliminated** at rolling baseline.
`BallVel` called 3× → 1× per ball per tick: **~400 duplicate VelX+VelY COM read pairs/sec eliminated**.

**Status:** [x]

---

## RANK 2 — AudioPan / AudioFade: Replace ^10 with repeated squaring
**File:** lines ~3220–3252 | **Frequency:** called per ball per rolling tick (100Hz) + every hit event

**Problem:**
```vbs
Function AudioFade(tableobj)
    ...
    AudioFade = Csng(tmp ^10)           ' ^ dispatch
    ' or:
    AudioFade = Csng(-((- tmp) ^10) )   ' ^ dispatch
End Function

Function AudioPan(tableobj)
    ...
    AudioPan = Csng(tmp ^10)            ' ^ dispatch
    ' or:
    AudioPan = Csng(-((- tmp) ^10) )    ' ^ dispatch
End Function
```
`^10` dispatches VBScript's COM-level math. Replaceable with 3 multiplications:
`tmp^10`: `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`

**Fix:**
```vbs
Function AudioFade(tableobj)
    Dim tmp, t2, t4, t8
    tmp = tableobj.y * 2 / tableheight - 1
    If tmp > 7000 Then tmp = 7000 ElseIf tmp < -7000 Then tmp = -7000 End If
    If tmp > 0 Then
        t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
        AudioFade = Csng(t8 * t2)
    Else
        tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
        AudioFade = Csng(-(t8 * t2))
    End If
End Function

Function AudioPan(tableobj)
    Dim tmp, t2, t4, t8
    tmp = tableobj.x * 2 / tablewidth - 1
    If tmp > 7000 Then tmp = 7000 ElseIf tmp < -7000 Then tmp = -7000 End If
    If tmp > 0 Then
        t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
        AudioPan = Csng(t8 * t2)
    Else
        tmp = -tmp : t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4
        AudioPan = Csng(-(t8 * t2))
    End If
End Function
```
Note: RANK 1 introduces `AudioPanXY`/`AudioFadeXY` variants that already use repeated squaring.
This fix applies to the original `AudioPan`/`AudioFade` which are still called from hit event
handlers (`PlaySoundAt`, `PlaySoundAtBall`, `RandomSoundBall*`, etc.).

**Estimated savings:** Every hit event (bumpers, targets, rubbers, etc.) calls AudioPan + AudioFade.
Eliminates 1 `^` dispatch per call. Combined with RANK 1, eliminates **all `^10` dispatches in hot paths**.

**Status:** [x]

---

## RANK 3 — BallVel / Vol / VolPlayfieldRoll / PitchPlayfieldRoll: Replace ^ with multiplication
**File:** lines ~3254–3276 | **Frequency:** called per ball per rolling tick (100Hz) + hit events

**Problem:**
```vbs
Function Vol(ball)
    Vol = Csng(BallVel(ball) ^2)             ' ^ dispatch; calls BallVel redundantly
End Function

Function BallVel(ball)
    BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2)))  ' 2 × ^ dispatch
End Function

Function VolPlayfieldRoll(ball)
    VolPlayfieldRoll = RollingSoundFactor * 0.0005 * Csng(BallVel(ball) ^3)  ' ^ dispatch + BallVel
End Function

Function PitchPlayfieldRoll(ball)
    PitchPlayfieldRoll = BallVel(ball) ^2 * 15  ' ^ dispatch + BallVel
End Function

Function Volz(ball)
    Volz = Csng((ball.velz) ^2)             ' ^ dispatch
End Function
```

**Fix:** Replace all `^2` and `^3` with multiplication. Cache BallVel in Vol:
```vbs
Function BallVel(ball)
    BallVel = INT(SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY))
End Function

Function Vol(ball)
    Dim bv : bv = BallVel(ball)
    Vol = Csng(bv * bv)
End Function

Function VolPlayfieldRoll(ball)
    Dim bv : bv = BallVel(ball)
    VolPlayfieldRoll = RollingSoundFactor * 0.0005 * Csng(bv * bv * bv)
End Function

Function PitchPlayfieldRoll(ball)
    Dim bv : bv = BallVel(ball)
    PitchPlayfieldRoll = bv * bv * 15
End Function

Function Volz(ball)
    Dim vz : vz = ball.velz
    Volz = Csng(vz * vz)
End Function
```
Note: `VolPlayfieldRoll` and `PitchPlayfieldRoll` are inlined in RANK 1 for the RollingUpdate hot path.
These function bodies still matter for any call sites outside RollingUpdate.

**Also fix OnBallBallCollision** (line ~847 area):
```vbs
' Before: PlaySound "fx_collide", ..., Csng(velocity) ^2 / 2000, ...
' After:
Dim cv : cv = Csng(velocity) : PlaySound "fx_collide", 0, cv * cv / 2000, Pan(ball1), ...
```
(Check exact line — search for `OnBallBallCollision`.)

**Estimated savings:** Eliminates 2 `^2` dispatches per `BallVel` call, plus 1 each in Vol/VolPlayfieldRoll/PitchPlayfieldRoll/Volz. All hit-event handlers benefit. At 100Hz with 3 rolling balls: **~600 `^` dispatches/sec eliminated** in RollingUpdate alone (before RANK 1 inlining).

**Status:** [x]

---

## RANK 4 — Pre-build BallRollStr array
**File:** lines ~2984–3025 | **Frequency:** 100Hz (GameTimer_Timer, every tick with balls)

**Problem:** `"BallRoll_" & b` concatenated **4 times per ball** per tick:
- Line 3007: `StopSound("BallRoll_" & b)` — cleanup loop
- Line 3018: `PlaySound ("BallRoll_" & b), ...` — playfield roll sound
- Line 3021: `PlaySound ("BallRoll_" & b), ...` — ramp roll sound
- Line 3024: `StopSound("BallRoll_" & b)` — stop when slowing

With 3 balls at 100Hz: **~1,200 string allocations/sec**.

**Fix:**
```vbs
' After ReDim rolling(tnob) and ReDim DropCount(tnob), add:
ReDim BallRollStr(tnob)
Dim brsI : For brsI = 0 To tnob : BallRollStr(brsI) = "BallRoll_" & brsI : Next
```
Replace all `"BallRoll_" & b` → `BallRollStr(b)` (4 occurrences).

Note: `ReDim` required — VBScript `Dim` rejects a named `Const` as array bound.

**Estimated savings:** 4 string allocations per ball per tick eliminated.
At 100Hz × 3 balls: **~1,200 string allocs/sec eliminated**.

**Status:** [x]

---

## RANK 5 — FlipperVisualUpdate: Cache duplicate CurrentAngle reads + guard writes
**File:** lines ~312–325 | **Frequency:** every frame (~60Hz, FrameTimer_Timer at -1)

**Problem:** `FlipperVisualUpdate` reads each of 3 flipper angles twice (once per visual object),
and writes all 8 COM properties unconditionally every frame:
```vbs
Sub FlipperVisualUpdate
    FlipperLSh.RotZ  = LeftFlipper.currentangle     ' read #1 + write
    FlipperRSh.RotZ  = RightFlipper.currentangle    ' read #1 + write
    Lflipmesh1.RotZ  = LeftFlipper.CurrentAngle     ' read #2 (duplicate!)
    Rflipmesh1.RotZ  = RightFlipper.CurrentAngle    ' read #2 (duplicate!)
    RflipmeshUp.RotZ = RightFlipper1.CurrentAngle   ' read #1 + write
    FlipperRShUp.RotZ = RightFlipper1.currentangle  ' read #2 (duplicate!)
    Gate1p.rotx = max(Gate1.CurrentAngle,0)         ' read + write
    Gate2p.rotx = max(Gate2.CurrentAngle,0)         ' read + write
    Gate3p.rotx = max(Gate3.CurrentAngle,0)         ' read + write
    Gate4p.rotx = max(Gate4.CurrentAngle,0)         ' read + write
End Sub
```
3 duplicate flipper angle reads (could cache into locals).
All 8 writes fire every frame — flippers stationary ~80%+ of frames, gates ~95%+ of frames.

**Fix:**
```vbs
' Module-level state vars:
Dim lastLFAngle, lastRFAngle, lastRF1Angle
Dim lastGate1Angle, lastGate2Angle, lastGate3Angle, lastGate4Angle

Sub FlipperVisualUpdate
    Dim a
    a = LeftFlipper.currentangle
    If a <> lastLFAngle Then lastLFAngle = a : FlipperLSh.RotZ = a : Lflipmesh1.RotZ = a
    a = RightFlipper.currentangle
    If a <> lastRFAngle Then lastRFAngle = a : FlipperRSh.RotZ = a : Rflipmesh1.RotZ = a
    a = RightFlipper1.CurrentAngle
    If a <> lastRF1Angle Then lastRF1Angle = a : RflipmeshUp.RotZ = a : FlipperRShUp.RotZ = a
    Dim g
    g = Gate1.CurrentAngle : If g <> lastGate1Angle Then lastGate1Angle = g : Gate1p.rotx = IIf(g > 0, g, 0)
    g = Gate2.CurrentAngle : If g <> lastGate2Angle Then lastGate2Angle = g : Gate2p.rotx = IIf(g > 0, g, 0)
    g = Gate3.CurrentAngle : If g <> lastGate3Angle Then lastGate3Angle = g : Gate3p.rotx = IIf(g > 0, g, 0)
    g = Gate4.CurrentAngle : If g <> lastGate4Angle Then lastGate4Angle = g : Gate4p.rotx = IIf(g > 0, g, 0)
End Sub
```
Note: VBScript does not have `IIf` — replace with explicit `If` or use the existing `max()` function
already defined in the file (`max(Gate1.CurrentAngle,0)` → use `max(g,0)` after caching `g`).

**Estimated savings:**
- Duplicate reads eliminated: 3 COM reads/frame = ~180 COM reads/sec
- Guards eliminate: up to 8 COM writes/frame when idle = up to ~480 COM writes/sec at 60Hz

**Status:** [x]

---

## RANK 6 — SpinnerTimer: Cache Spinner.CurrentAngle + guard writes
**File:** line ~804–808 | **Frequency:** 100Hz (GameTimer_Timer, every tick)

**Problem:** `Spinner.CurrentAngle` read **3 times** per tick; 3 unconditional COM writes:
```vbs
Sub SpinnerTimer
    SpinnerPrim.Rotx = Spinner.CurrentAngle                                ' read #1 + write
    SpinnerRod.TransX = sin( (Spinner.CurrentAngle+180) * (2*PI/360)) * 12 ' read #2 + write
    SpinnerRod.TransZ = sin( (Spinner.CurrentAngle- 90) * (2*PI/360)) * 10 ' read #3 + write
End Sub
```
Spinner is stationary except when a ball passes through it. Also note: `2*PI/360` = `PI/180` — minor simplification.

**Fix:**
```vbs
Dim lastSpinnerAngle   ' module-level

Sub SpinnerTimer
    Dim a : a = Spinner.CurrentAngle
    If a <> lastSpinnerAngle Then
        lastSpinnerAngle = a
        SpinnerPrim.Rotx  = a
        SpinnerRod.TransX = sin((a + 180) * PI_180) * 12
        SpinnerRod.TransZ = sin((a -  90) * PI_180) * 10
    End If
End Sub
```
Add module-level `Const PI_180 = 3.14159265358979 / 180` (or use existing PI constant divided by 180
as a module-level Dim). This pre-computes the degree→radian factor once rather than computing
`2*PI/360` twice per tick.

**Estimated savings:** Spinner idle ~95%+ of ticks.
- 3 COM reads eliminated per tick when idle: **~285 COM reads/sec eliminated**
- 3 COM writes eliminated per tick when idle: **~285 COM writes/sec eliminated**
- 2 trig `sin()` calls eliminated per tick when idle: **~190 sin() calls/sec eliminated**

**Status:** [x]

---

## SUMMARY TABLE

| Rank | Location | Type | Freq | Impact | Status |
|------|----------|------|------|--------|--------|
| 1 | RollingUpdate (~2999) | Cache gBOT(b) X/Y/Z/VelX/VelY/VelZ + inline BallVel/Vol/Pitch/Pan/Fade | 100Hz | **HIGH** — ~12 COM reads/ball/tick eliminated | [x] |
| 2 | AudioPan/AudioFade (~3220) | Replace `^10` with repeated squaring | per ball/tick + events | **MEDIUM** — 1 ^ dispatch per call eliminated | [x] |
| 3 | BallVel/Vol/VolPlayfieldRoll/PitchPlayfieldRoll (~3254) | Replace `^2`/`^3` with multiplication | per ball/tick + events | **MEDIUM** — 2–3 ^ dispatches per BallVel call | [x] |
| 4 | RollingUpdate (~2984) | Pre-build BallRollStr array | 100Hz | **MEDIUM** — ~1,200 string allocs/sec (3 balls) | [x] |
| 5 | FlipperVisualUpdate (~312) | Cache 3 duplicate angle reads + guard 8 unconditional writes | 60Hz | **MEDIUM** — ~480 COM writes/sec at idle | [x] |
| 6 | SpinnerTimer (~804) | Cache Spinner.CurrentAngle + guard 3 writes + precompute PI_180 | 100Hz | **MEDIUM** — ~285 COM reads+writes/sec + 190 sin/sec at idle | [x] |

**Key characteristic:** This file runs two hot loops — `GameTimer_Timer` at 100Hz and `FrameTimer_Timer`
at 60Hz. Unlike 24 and Rocky, Lampz.Update2 already has guard logic built-in (`Lock(x)` / `Loaded(x)`
flags skip lamps that have finished fading), so there is no NFadeL equivalent to guard.
The Lampz `LampFilter` function uses `aLvl^1.6` — a fractional exponent that cannot be replaced
with integer multiplication, so it is left as-is.
Primary targets are the RollingUpdate per-ball property cache, `^` operator elimination across the
audio helpers, string pre-building, and the duplicate angle reads in FlipperVisualUpdate.
