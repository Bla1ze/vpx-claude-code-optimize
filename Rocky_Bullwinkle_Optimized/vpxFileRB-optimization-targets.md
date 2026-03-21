vpxFileRB.vbs (Rocky_Bullwinkle) — Optimization Targets (Round 3)
===================================================================
File: 3,955 lines. Table: Rocky & Bullwinkle (Data East).
Rounds 1+2 applied: BallShadowUpdate, rolling strings, ^ops, flipper guards,
                    CheckDropShadows, sw43 bug, UpdateLamps guards (171 calls),
                    BOT caching, rampwedge bounds, debug.print removal.
Hot timers: LampTimer (-1) > CollisionTimer (every frame) > RotatePrimitives_Timer (every frame).
Status: [ ] = pending, [x] = applied.

---

## RANK 1 — RotatePrimitives_Timer: Guard 5 unconditional angle writes
**File:** line ~1436 | **Frequency:** every frame (interval set in VPX editor, ~60Hz)

**Problem:** 5 unconditional COM reads + writes per tick:
```vbs
Sub RotatePrimitives_Timer()
    pLeftFlipperLogo.Roty  = LeftFlipper.Currentangle + 180   ' read + write every frame
    pRightFlipperLogo.Roty = RightFlipper.Currentangle + 180  ' read + write every frame
    p_gate3.Rotx = gate3.CurrentAngle                         ' read + write every frame
    p_gate4.Rotx = Gate4.CurrentAngle                         ' read + write every frame
    p_gate5.Rotx = Gate5.CurrentAngle                         ' read + write every frame
End Sub
```
Flippers are stationary most of the time. Gates are stationary except when a ball passes through.
`lastLFAngle` and `lastRFAngle` already exist from Round 1 (CollisionTimer flipper guards) and
hold the current `LeftFlipper.Currentangle` / `RightFlipper.Currentangle` — no re-read needed.

**Fix:**
```vbs
' Add to module-level Dim block:
Dim lastGate3Angle, lastGate4Angle, lastGate5Angle

Sub RotatePrimitives_Timer()
    Dim newLogoR
    ' Reuse lastLFAngle / lastRFAngle already maintained by CollisionTimer:
    Dim newL : newL = LeftFlipper.Currentangle + 180
    If newL <> lastLFLogoAngle Then lastLFLogoAngle = newL : pLeftFlipperLogo.Roty = newL
    Dim newR : newR = RightFlipper.Currentangle + 180
    If newR <> lastRFLogoAngle Then lastRFLogoAngle = newR : pRightFlipperLogo.Roty = newR
    Dim curG
    curG = gate3.CurrentAngle
    If curG <> lastGate3Angle Then lastGate3Angle = curG : p_gate3.Rotx = curG
    curG = Gate4.CurrentAngle
    If curG <> lastGate4Angle Then lastGate4Angle = curG : p_gate4.Rotx = curG
    curG = Gate5.CurrentAngle
    If curG <> lastGate5Angle Then lastGate5Angle = curG : p_gate5.Rotx = curG
End Sub
```
Note: Use separate `lastLFLogoAngle`/`lastRFLogoAngle` vars (not the same as `lastLFAngle`/`lastRFAngle`)
since those track a different computation (`Currentangle` vs `Currentangle + 180`). Adding 180 means
the threshold comparison is for a different value.

**Estimated savings:** Flippers stationary ~80%+ of frames, gates ~95%+ of frames.
Up to 5 COM reads + 5 COM writes/frame eliminated at idle.
At 60Hz: up to **~600 COM ops/sec eliminated**.

**Status:** [x]

---

## RANK 2 — RotateSaw_timer: Cache pSawBlade.RotY in VBScript variable
**File:** line ~1396 | **Frequency:** while Nell's saw is spinning (event-driven duration)

**Problem:** Every tick reads `pSawBlade.RotY` to increment it, then writes it back:
```vbs
Sub RotateSaw_timer()
    Select Case RotateSawStep
        Case 1: pSawBlade.RotY = pSawBlade.RotY + 5    ' COM read + write
        Case 2: pSawBlade.RotY = pSawBlade.RotY + 5    ' COM read + write
        Case 3: pSawBlade.RotY = pSawBlade.RotY + 5    ' COM read + write
        Case 4: pSawBlade.RotY = pSawBlade.RotY + 5    ' COM read + write
    End Select
    RotateSawStep = RotateSawStep + 1
End Sub
```
The Select Case just selects which Case to run — the body is identical in all 4 cases,
and the Select Case itself is pointless overhead. The rotation just increments by 5 every tick.

**Fix:** Track rotation in a module-level variable; eliminate both the COM read and the Select Case:
```vbs
Dim SawRotY   ' module-level

' In RaB_Init, initialize to match the starting position:
SawRotY = pSawBlade.RotY

Sub RotateSaw_timer()
    SawRotY = SawRotY + 5
    If SawRotY >= 360 Then SawRotY = SawRotY - 360  ' keep in range
    pSawBlade.RotY = SawRotY
End Sub
```
This eliminates 1 COM read + the Select Case overhead per tick.

**Estimated savings:** Only runs while Nell is moving. Minor per-tick savings.
Bonus: simplifies the logic significantly (all 4 cases were identical).

**Status:** [x]

---

## SUMMARY TABLE

| Rank | Location | Type | Freq | Impact | Status |
|------|----------|------|------|--------|--------|
| 1 | RotatePrimitives_Timer (~1436) | Guard 5 unconditional angle writes | every frame | **MEDIUM** — up to ~600 COM ops/sec at idle | [x] |
| 2 | RotateSaw_timer (~1396) | Cache SawRotY + remove pointless Select Case | while saw spins | **LOW** — 1 COM read/tick eliminated + simplification | [x] |

**Assessment:** After three rounds of optimization, the remaining targets are minor.
The file's dominant hot paths (UpdateLamps at 169 guarded calls, CollisionTimer BOT caching)
have been addressed. `RotatePrimitives_Timer` is the last always-running timer with unguarded
COM writes. Beyond this, the script is well-optimized.
