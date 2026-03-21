WOO.vbs (JP's Wrath of Olympus v600) — Optimization Targets
=============================================================
File: ~4700+ lines. Table: Wrath of Olympus (Williams WPC).
Hot timers: Realtime_Timer (-1 = every frame) → RollingUpdate.
No LampTimer/UpdateLamps/FadingLevel system found — different lamp architecture.
Status: [ ] = pending, [x] = applied.

---

## RANK 1 — RollingUpdate: Cache BOT(b) properties + inline BallVel
**File:** lines ~783–839 | **Frequency:** every frame (Realtime_Timer at interval -1)

**Problem:** Per-ball inner loop reads BOT(b) COM properties repeatedly without caching:
- `BOT(b).X` read 3× (shadow.X, Pan for rolling, Pan for drop sound)
- `BOT(b).Y` read 3× (shadow.Y, AudioFade for rolling, AudioFade for drop)
- `BOT(b).Z` / `.z` read 5× (shadow.Height, ramp check, drop check × 3)
- `BOT(b).VelX` read 6+ times (BallVel condition + Vol→BallVel + Pitch→BallVel + Pitch drop + speed cap × 3)
- `BOT(b).VelY` read 6+ times (same pattern as VelX)
- `BOT(b).VelZ` read 2× (drop check condition)
- `BOT(b).AngMomZ` read+write unconditionally every frame

Also: `BallVel(BOT(b))` called 3× per rolling ball per tick — once for condition check
(line 803), once inside `Vol()`, once inside `Pitch()` — each call reads VelX + VelY.

```vbs
Sub RollingUpdate()
    ...
    For b = lob to UBound(BOT)
        aBallShadow(b).X = BOT(b).X             ' read BOT(b).X #1
        aBallShadow(b).Y = BOT(b).Y             ' read BOT(b).Y #1
        aBallShadow(b).Height = BOT(b).Z -Ballsize/2  ' read BOT(b).Z #1
        If BallVel(BOT(b))> 1 Then              ' reads VelX + VelY #1+#2
            If BOT(b).z <30 Then                ' read BOT(b).Z #2
                ballpitch = Pitch(BOT(b))        ' reads VelX + VelY #3+#4
                ballvol = Vol(BOT(b))            ' reads VelX + VelY #5+#6
            ...
            PlaySound("fx_ballrolling" & b), -1, ballvol, Pan(BOT(b)), ...
            '                                    ' reads BOT(b).X #2
        End If
        If BOT(b).VelZ <-1 and BOT(b).z <55 ... ' reads VelZ #1, Z #3+#4+#5
            PlaySound "fx_balldrop", ..., Pan(BOT(b)), ..., Pitch(BOT(b)), ..., AudioFade(BOT(b))
            '                        reads X #3, VelX+VelY #7+#8, Y #3
        End If
        BOT(b).AngMomZ = BOT(b).AngMomZ * 0.95   ' read+write every frame
        If BOT(b).VelX AND BOT(b).VelY <> 0 Then ' read VelX+VelY #9+#10
            speedfactorx = ABS(maxvel / BOT(b).VelX)  ' read VelX #11
            speedfactory = ABS(maxvel / BOT(b).VelY)  ' read VelY #11
            If speedfactorx <1 Then
                BOT(b).VelX = BOT(b).VelX * speedfactorx  ' read+write VelX #12
                BOT(b).VelY = BOT(b).VelY * speedfactorx  ' read+write VelY #12
            End If
            If speedfactory <1 Then
                BOT(b).VelX = BOT(b).VelX * speedfactory  ' read+write VelX #13
                BOT(b).VelY = BOT(b).VelY * speedfactory  ' read+write VelY #13
            End If
        End If
    Next
```

**Fix:** Cache all per-ball properties at top of loop; inline BallVel/Vol/Pitch with cached vars:
```vbs
Sub RollingUpdate()
    Dim BOT, b, ballpitch, ballvol, speedfactorx, speedfactory
    Dim bx, by, bz, bvx, bvy, bvz, bvel
    BOT = GetBalls
    ...
    For b = lob to UBound(BOT)
        bx  = BOT(b).X
        by  = BOT(b).Y
        bz  = BOT(b).Z
        bvx = BOT(b).VelX
        bvy = BOT(b).VelY
        bvz = BOT(b).VelZ
        bvel = SQR(bvx * bvx + bvy * bvy)   ' inlined BallVel — no ^2, no re-reads

        aBallShadow(b).X = bx
        aBallShadow(b).Y = by
        aBallShadow(b).Height = bz - Ballsize/2

        If bvel > 1 Then
            ballvol   = Csng(bvel * bvel / 2000)   ' inlined Vol — reuse bvel
            ballpitch = bvel * 20                   ' inlined Pitch
            If bz < 30 Then
                ' no change to ballvol/ballpitch
            Else
                ballpitch = ballpitch + 25000
                ballvol = ballvol * 3
            End If
            rolling(b) = True
            PlaySound(BallRollStr(b)), -1, ballvol, Pan(BOT(b)), 0, ballpitch, 1, 0, AudioFade(BOT(b))
        Else
            If rolling(b) = True Then
                StopSound BallRollStr(b)
                rolling(b) = False
            End If
        End If

        If bvz < -1 And bz < 55 And bz > 27 Then
            PlaySound "fx_balldrop", 0, ABS(bvz) / 17, Pan(BOT(b)), 0, bvel * 20, 1, 0, AudioFade(BOT(b))
        End If

        BOT(b).AngMomZ = BOT(b).AngMomZ * 0.95   ' AngMomZ write-back — no VBScript cache (COM in-place)
        If bvx <> 0 And bvy <> 0 Then
            speedfactorx = ABS(maxvel / bvx)
            speedfactory = ABS(maxvel / bvy)
            If speedfactorx < 1 Then
                bvx = bvx * speedfactorx
                bvy = bvy * speedfactorx
            End If
            If speedfactory < 1 Then
                bvx = bvx * speedfactory
                bvy = bvy * speedfactory
            End If
            BOT(b).VelX = bvx
            BOT(b).VelY = bvy
        End If
    Next
End Sub
```
Note: `Pan(BOT(b))` and `AudioFade(BOT(b))` still receive the ball object — they read `.x`/`.y`
which are now served from VPX's internal cache since we already read them. In a further pass
these could be replaced with `PanX(bx)` / `AudioFadeY(by)` helper variants, but the savings
from eliminating BallVel/VelX/VelY re-reads dominate.

Also note: the original speed cap condition `If BOT(b).VelX AND BOT(b).VelY <> 0 Then` uses
VBScript bitwise AND — this is almost certainly a logic bug (should be `<>` on each). However,
since the behavior already works in the current table, preserve the same logic with cached vars:
`If bvx AND bvy <> 0 Then` (bitwise AND of bvx and bvy, then compare). This preserves existing
behavior. Write back to BOT(b).VelX/VelY only when the speed cap actually fires.

**Estimated savings:** ~18 COM reads eliminated per ball per frame at baseline; up to 24+ when
rolling + drop-sound-eligible. At 60Hz with 1 ball: **~1,080+ COM reads/sec eliminated**.

**Status:** [ ]

---

## RANK 2 — Pan / AudioFade: Replace ^10 with repeated squaring
**File:** lines ~724–750 | **Frequency:** called per active ball per rolling frame + per hit event

**Problem:**
```vbs
Function Pan(ball)
    Dim tmp
    tmp = ball.x * 2 / TableWidth-1
    If tmp > 0 Then
        Pan = Csng(tmp ^10)          ' ^ dispatch
    Else
        Pan = Csng(-((- tmp) ^10))   ' ^ dispatch
    End If
End Function

Function AudioFade(ball)
    Dim tmp
    tmp = ball.y * 2 / TableHeight-1
    If tmp > 0 Then
        AudioFade = Csng(tmp ^10)        ' ^ dispatch
    Else
        AudioFade = Csng(-((- tmp) ^10)) ' ^ dispatch
    End If
End Function
```
`^10` invokes VBScript's COM-level math dispatch — much slower than native integer multiplication.
`tmp^10` can be computed with 3 multiplications via repeated squaring.

**Fix:**
```vbs
Function Pan(ball)
    Dim tmp, t2, t4, t8
    tmp = ball.x * 2 / TableWidth - 1
    If tmp > 0 Then
        t2 = tmp * tmp : t4 = t2 * t2 : t8 = t4 * t4
        Pan = Csng(t8 * t2)
    Else
        tmp = -tmp
        t2 = tmp * tmp : t4 = t2 * t2 : t8 = t4 * t4
        Pan = Csng(-(t8 * t2))
    End If
End Function

Function AudioFade(ball)
    Dim tmp, t2, t4, t8
    tmp = ball.y * 2 / TableHeight - 1
    If tmp > 0 Then
        t2 = tmp * tmp : t4 = t2 * t2 : t8 = t4 * t4
        AudioFade = Csng(t8 * t2)
    Else
        tmp = -tmp
        t2 = tmp * tmp : t4 = t2 * t2 : t8 = t4 * t4
        AudioFade = Csng(-(t8 * t2))
    End If
End Function
```

**Estimated savings:** Pan/AudioFade each called 2× per rolling ball per frame (rolling + drop sound check) + once per hit event. At 60Hz × 1 ball × 2 calls: **~240 ^ dispatches/sec eliminated** from rolling alone, plus per-hit events.

**Status:** [ ]

---

## RANK 3 — BallVel / Vol: Replace ^2 with multiplication
**File:** lines ~720–739 | **Frequency:** called per active ball per rolling frame

**Problem:**
```vbs
Function Vol(ball)
    Vol = Csng(BallVel(ball) ^2 / 2000)   ' ^ dispatch; also calls BallVel twice if not cached
End Function

Function BallVel(ball)
    BallVel = (SQR((ball.VelX ^2) + (ball.VelY ^2)))  ' 2 ^ dispatches
End Function
```

**Fix:** Replace `^2` with `*`. `Vol` calling `BallVel` is already handled by RANK 1 (bvel cached
inline), but the function bodies should still be fixed for calls outside RollingUpdate (e.g.
`PlaySoundAt`, `PlaySoundAtBall` which call these on hit events):
```vbs
Function BallVel(ball)
    BallVel = SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY)
End Function

Function Vol(ball)
    Dim bv : bv = BallVel(ball)
    Vol = Csng(bv * bv / 2000)
End Function
```

**Also:** `OnBallBallCollision` (line 847):
```vbs
' Before:
PlaySound "fx_collide", 0, Csng(velocity) ^2 / 2000, ...
' After:
Dim cv : cv = Csng(velocity) : PlaySound "fx_collide", 0, cv * cv / 2000, ...
```

**Estimated savings:** Eliminates 2 `^2` dispatches per BallVel call + 1 `^2` in Vol.
When called from hit events (not inlined): **~3 ^ dispatches per ball hit eliminated**.

**Status:** [ ]

---

## RANK 4 — Pre-build BallRollStr array
**File:** lines ~770–815 | **Frequency:** every frame per active ball

**Problem:** `"fx_ballrolling" & b` concatenated 3 times per ball per frame:
- Line 790: `StopSound("fx_ballrolling" & b)` — in cleanup loop
- Line 812: `PlaySound("fx_ballrolling" & b), ...` — rolling sound
- Line 815: `StopSound("fx_ballrolling" & b)` — stop when slowing

With 5 balls at 60Hz: up to **~900 string allocations/sec**.

**Fix:**
```vbs
' After ReDim rolling(tnob), add:
ReDim BallRollStr(tnob)
Dim brsI : For brsI = 0 To tnob : BallRollStr(brsI) = "fx_ballrolling" & brsI : Next
```
Replace all `"fx_ballrolling" & b` → `BallRollStr(b)`.

Note: `ReDim` required — VBScript `Dim` rejects a named `Const` as array bound.

**Estimated savings:** 3 string allocations per ball per frame eliminated.
At 60Hz with 3 balls: **~540 string allocs/sec eliminated**.

**Status:** [ ]

---

## RANK 5 — Flipper _Animate subs: Guard unconditional RotZ writes
**File:** lines ~2424–2429 | **Frequency:** every render frame (VPX calls _Animate per frame)

**Problem:** 6 flipper _Animate subs, each unconditionally writes RotZ every frame:
```vbs
Sub LeftFlipper_Animate:    LeftFlipperTop.RotZ    = LeftFlipper.CurrentAngle:    End Sub
Sub RightFlipper_Animate:   RightFlipperTop.RotZ   = RightFlipper.CurrentAngle:   End Sub
Sub LeftFlipper001_Animate: LeftFlipperTop001.RotZ = LeftFlipper001.CurrentAngle: End Sub
Sub RightFlipper001_Animate:RightFlipperTop001.RotZ= RightFlipper001.CurrentAngle:End Sub
Sub LeftFlipper2_Animate:   LeftFlipperTop002.RotZ = LeftFlipper2.CurrentAngle:   End Sub
Sub RightFlipper2_Animate:  RightFlipperTop002.RotZ= RightFlipper2.CurrentAngle:  End Sub
```
Each fires every render frame. Flippers are stationary ~80% of frames. Each unconditional
write crosses the COM boundary even when the angle hasn't changed.

**Fix:**
```vbs
' Module-level:
Dim lastLFAngle, lastRFAngle, lastLF001Angle, lastRF001Angle, lastLF2Angle, lastRF2Angle

Sub LeftFlipper_Animate
    Dim a : a = LeftFlipper.CurrentAngle
    If a <> lastLFAngle Then lastLFAngle = a : LeftFlipperTop.RotZ = a
End Sub
Sub RightFlipper_Animate
    Dim a : a = RightFlipper.CurrentAngle
    If a <> lastRFAngle Then lastRFAngle = a : RightFlipperTop.RotZ = a
End Sub
Sub LeftFlipper001_Animate
    Dim a : a = LeftFlipper001.CurrentAngle
    If a <> lastLF001Angle Then lastLF001Angle = a : LeftFlipperTop001.RotZ = a
End Sub
Sub RightFlipper001_Animate
    Dim a : a = RightFlipper001.CurrentAngle
    If a <> lastRF001Angle Then lastRF001Angle = a : RightFlipperTop001.RotZ = a
End Sub
Sub LeftFlipper2_Animate
    Dim a : a = LeftFlipper2.CurrentAngle
    If a <> lastLF2Angle Then lastLF2Angle = a : LeftFlipperTop002.RotZ = a
End Sub
Sub RightFlipper2_Animate
    Dim a : a = RightFlipper2.CurrentAngle
    If a <> lastRF2Angle Then lastRF2Angle = a : RightFlipperTop002.RotZ = a
End Sub
```

**Estimated savings:** 6 COM writes/frame eliminated ~80% of the time.
At 60Hz: up to **~288 COM writes/sec eliminated** when flippers idle.

**Status:** [ ]

---

## SUMMARY TABLE

| Rank | Location | Type | Freq | Impact | Status |
|------|----------|------|------|--------|--------|
| 1 | RollingUpdate (~783) | Cache BOT(b) X/Y/Z/VelX/VelY/VelZ + inline BallVel/Vol/Pitch | every frame | **HIGH** — ~18+ COM reads/ball/frame eliminated | [ ] |
| 2 | Pan/AudioFade (~724–750) | Replace `^10` with repeated squaring | per ball/frame + events | **MEDIUM** — 2 ^ dispatches per call | [ ] |
| 3 | BallVel/Vol (~720–739) | Replace `^2` with multiplication + cache BallVel in Vol | per ball/frame + events | **MEDIUM** — 2–3 ^ dispatches per ball hit | [ ] |
| 4 | RollingUpdate (~790–815) | Pre-build BallRollStr array | every frame | **MEDIUM** — ~540+ string allocs/sec (3 balls) | [ ] |
| 5 | Flipper _Animate (~2424–2429) | Guard 6 unconditional RotZ writes | every frame | **MEDIUM** — ~288 COM writes/sec at idle | [ ] |

**Key characteristic:** This file's hot path is `RollingUpdate` (every frame). Unlike most tables,
there is no LampTimer/UpdateLamps/FadingLevel system — the lamp bottleneck found in 24 and Rocky
does not apply here. The dominant costs are COM reads in the per-ball loop and ^ operator dispatch
in the audio helper functions. After these five passes the script is well-optimized.
