Fathom-applied-changes.md (vpxFile-Fathom.vbs) — Applied Optimization Changes
===============================================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. BallRollStr ARRAY: PRE-BUILD ROLLING SOUND NAME STRINGS (~line 2993)
   Added ReDim BallRollStr(tnob) + init loop building "BallRoll_0".."BallRoll_3".
   Placed immediately after ReDim rolling(tnob).
   Replaced all 4 occurrences of "BallRoll_" & b in RollingUpdate with BallRollStr(b).
   ReDim required — VBScript Dim rejects a named Const as array bound.
   Eliminates 4 string allocations per ball per RollingUpdate tick.
   At 100Hz × 3 balls: ~1,200 string allocs/sec eliminated.

2. RollingUpdate: CACHE gBOT(b) PROPERTIES + INLINE BallVel (~line 3008)
   Added bx, by, bz, bvx, bvy, bvz, bvel to sub Dim statement.
   At top of per-ball loop: cached gBOT(b).X/Y/Z/VelX/VelY/VelZ into locals.
   bvel = INT(SQR(bvx * bvx + bvy * bvy)) — inlined BallVel with no ^ ops and no re-reads.
   Replaced VolPlayfieldRoll(gBOT(b)) inline: RollingSoundFactor * 0.0005 * (bvel*bvel*bvel) * ...
   Replaced PitchPlayfieldRoll(gBOT(b)) inline: bvel * bvel * 15
   Replaced AudioPan(gBOT(b)) with AudioPanXY(bx) — passes cached x, avoids COM read.
   Replaced AudioFade(gBOT(b)) with AudioFadeXY(by) — passes cached y, avoids COM read.
   Shadow section replaced gBOT(b).X/Y/Z with bx/by/bz throughout.
   Drop sound section replaced gBOT(b).VelZ/z with bvz/bz.
   BallVel was called 3× per rolling ball (condition + VolPlayfieldRoll + PitchPlayfieldRoll);
   now called 0× — fully inlined.
   Eliminates ~12 COM reads per ball per tick.
   At 100Hz × 3 balls: ~3,600 COM reads/sec eliminated.

3. AudioFade: REPLACE ^10 WITH REPEATED SQUARING + ADD AudioFadeXY VARIANT (~line 3237)
   Replaced tmp ^10 / -((- tmp) ^10) with:
     t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2  (3 multiplications)
   Added AudioFadeXY(y) variant that accepts a pre-cached Y scalar instead of ball object,
   eliminating the tableobj.y COM read for hot-path callers (RollingUpdate).
   Eliminates 1 ^ dispatch per AudioFade call from all event handlers.

4. AudioPan: REPLACE ^10 WITH REPEATED SQUARING + ADD AudioPanXY VARIANT (~line 3265)
   Same repeated-squaring pattern as AudioFade.
   Added AudioPanXY(x) variant accepting pre-cached X scalar.
   Eliminates 1 ^ dispatch per AudioPan call from all event handlers.

5. BallVel: REPLACE ^2 WITH MULTIPLICATION (~line 3295)
   Changed: INT(SQR((ball.VelX ^2) + (ball.VelY ^2)))
   To:      INT(SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY))
   Eliminates 2 ^ dispatches per BallVel call.
   BallVel still used by Pitch, Vol, VolPlayfieldRoll, PitchPlayfieldRoll for non-hot-path callers.

6. Vol: CACHE BallVel RESULT + REPLACE ^2 (~line 3283)
   Changed: Csng(BallVel(ball) ^2)
   To: Dim bv : bv = BallVel(ball) : Csng(bv * bv)
   Eliminates 1 ^ dispatch per Vol call. Caches BallVel to avoid any duplicate call.

7. VolPlayfieldRoll: CACHE BallVel + REPLACE ^3 (~line 3299)
   Changed: RollingSoundFactor * 0.0005 * Csng(BallVel(ball) ^3)
   To: Dim bv : bv = BallVel(ball) : RollingSoundFactor * 0.0005 * Csng(bv * bv * bv)
   Eliminates 1 ^ dispatch per call. Function body still used by non-hot-path callers.
   RollingUpdate inlines this computation directly using cached bvel.

8. PitchPlayfieldRoll: CACHE BallVel + REPLACE ^2 (~line 3304)
   Changed: BallVel(ball) ^2 * 15
   To: Dim bv : bv = BallVel(ball) : bv * bv * 15
   Eliminates 1 ^ dispatch per call.

9. Volz: REPLACE ^2 WITH MULTIPLICATION (~line 3288)
   Changed: Csng((ball.velz) ^2)
   To: Dim vz : vz = ball.velz : Csng(vz * vz)
   Eliminates 1 ^ dispatch + caches the velz COM read.

10. OnBallBallCollision: REPLACE ^2 + CACHE CSng(velocity) (~line 3731)
    Changed: CSng(velocity) ^ 2 / 200
    To: Dim cv : cv = CSng(velocity) : cv * cv / 200
    Eliminates 1 ^ dispatch per ball-ball collision event.

11. MODULE-LEVEL STATE VARS FOR GUARDS (~line 142)
    Added: Dim lastLFAngle, lastRFAngle, lastRF1Angle
    Added: Dim lastGate1Angle, lastGate2Angle, lastGate3Angle, lastGate4Angle
    Added: Dim lastSpinnerAngle
    All initialize to Empty (VBScript default), causing first-frame write to always fire.

12. PI_180 PRE-COMPUTED CONSTANT (~line 1928)
    Added: Dim PI_180 : PI_180 = PI / 180
    Placed immediately after PI = 4 * Atn(1).
    Eliminates 2 * (2*PI/360) computations per SpinnerTimer tick when spinner is moving.

13. FlipperVisualUpdate: CACHE DUPLICATE ANGLE READS + GUARD 8 UNCONDITIONAL WRITES (~line 315)
    LeftFlipper.currentangle was read twice (FlipperLSh + Lflipmesh1) — now cached into 'a'.
    RightFlipper.currentangle was read twice (FlipperRSh + Rflipmesh1) — now cached into 'a'.
    RightFlipper1.CurrentAngle was read twice (RflipmeshUp + FlipperRShUp) — now cached into 'a'.
    Each cached angle guarded: both shadow+mesh writes fire together only when angle changed.
    Gate1..4 CurrentAngle each cached into 'g'; rotx write guarded per gate.
    Flippers idle ~80%+ of frames, gates ~95%+ → eliminates up to 8 COM writes + 3 duplicate
    reads per frame when idle.
    At 60Hz: up to ~480 COM writes/sec eliminated + ~180 redundant reads/sec eliminated.

14. SpinnerTimer: CACHE Spinner.CurrentAngle + GUARD ALL WRITES + USE PI_180 (~line 808)
    Spinner.CurrentAngle was read 3× per tick — now cached once into 'a'.
    Entire body guarded: only executes when angle has changed (spinner spinning).
    sin() calls updated from (angle * (2*PI/360)) to (angle * PI_180) — same value, pre-computed.
    Spinner idle ~95%+ of ticks.
    Eliminates 3 COM reads + 3 COM writes + 2 sin() calls per idle tick.
    At 100Hz: ~285 COM reads/sec + ~285 COM writes/sec + ~190 sin()/sec eliminated when idle.

---

## SUMMARY

^ dispatches eliminated:
  - BallVel: 2 ^2 per call                                      = ~600/sec (3 balls × 100Hz rolling)
  - Vol: 1 ^2 per call                                          = per-event
  - VolPlayfieldRoll: 1 ^3 per call                             = (inlined in hot path)
  - PitchPlayfieldRoll: 1 ^2 per call                           = (inlined in hot path)
  - Volz: 1 ^2 per call                                         = per-event
  - AudioFade: 1 ^10 per call                                    = per-ball/tick + events
  - AudioPan: 1 ^10 per call                                     = per-ball/tick + events
  - OnBallBallCollision: 1 ^2 per event                          = per-event

COM reads eliminated per frame/tick:
  - RollingUpdate: ~12 reads/ball/tick                           = ~3,600 reads/sec (3 balls × 100Hz)
  - FlipperVisualUpdate: 3 duplicate reads/frame                 = ~180 reads/sec at 60Hz
  - SpinnerTimer: 3 reads/tick when idle                         = ~285 reads/sec at 100Hz

COM writes eliminated:
  - FlipperVisualUpdate: up to 8 writes/frame at idle            = ~480 writes/sec at 60Hz
  - SpinnerTimer: up to 3 writes/tick at idle                    = ~285 writes/sec at 100Hz

String allocations eliminated:
  - BallRollStr: 4 per ball per tick                             = ~1,200 allocs/sec (3 balls × 100Hz)

sin() calls eliminated:
  - SpinnerTimer: 2 calls/tick when idle                         = ~190 sin()/sec at 100Hz
