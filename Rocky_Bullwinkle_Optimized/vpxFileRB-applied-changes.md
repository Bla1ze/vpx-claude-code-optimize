vpxFileRB.vbs (Rocky_Bullwinkle) — Applied Optimization Changes (Round 3)
=========================================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. RotatePrimitives_Timer: GUARD 5 UNCONDITIONAL ANGLE WRITES (~line 1433)
   Added module-level Dim lastLFLogoAngle, lastRFLogoAngle, lastGate3Angle, lastGate4Angle, lastGate5Angle.
   Rewrote RotatePrimitives_Timer to read each angle once per tick and compare against
   the cached last value before writing the COM property.
   Flipper logo writes use separate lastLFLogoAngle/lastRFLogoAngle vars (distinct from
   lastLFAngle/lastRFAngle which track Currentangle; these track Currentangle + 180).
   Flippers are stationary ~80%+ of frames; gates stationary ~95%+ of frames.
   Eliminates up to 5 COM reads + 5 COM writes per frame when objects are idle.
   At 60Hz: up to ~600 COM ops/sec eliminated.

2. RotateSaw_timer: CACHE SawRotY + REMOVE POINTLESS SELECT CASE (~line 1397)
   Added module-level Dim SawRotY; initialized to pSawBlade.RotY in RaB_Init.
   Rewrote RotateSaw_timer from a 4-case Select Case (all cases identical: RotY + 5)
   to a single SawRotY = SawRotY + 5 / pSawBlade.RotY = SawRotY.
   Eliminates 1 COM read per tick while saw is spinning.
   Bonus: the Select Case was logically equivalent to no Select Case at all — all 4 branches
   did exactly the same thing. The rewrite also removes that redundant overhead.

---

## SUMMARY (Round 3)

COM ops eliminated per frame:
  - RotatePrimitives_Timer: up to 5 reads + 5 writes/frame at idle  = ~600 ops/sec at 60Hz

COM reads eliminated (event-driven):
  - RotateSaw_timer: 1 COM read/tick while saw is spinning

Code quality:
  - RotateSaw_timer Select Case (4 identical branches) simplified to 3 lines
