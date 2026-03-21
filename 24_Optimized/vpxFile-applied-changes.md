vpxFile.vbs (twenty4_150) — Applied Optimization Changes
==========================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. UpdateLamps: GUARD ALL NFadeL/NFadeObjm CALLS WITH FadingLevel CHECK (~line 505)
   Prepended every call in UpdateLamps with `If FadingLevel(n) > 1 Then`.
   NFadeL only does work when FadingLevel is 4 (off-transition) or 5 (on-transition).
   After processing, it sets FadingLevel to 0 or 1 — subsequent calls are pure no-ops.
   The guard reads one array element (cheap) and skips the sub call + Select Case when stable.
   Applied to all 78 NFadeL calls and 3 NFadeObjm calls (81 total).
   At 5ms / 200Hz with ~76 stable lamps: eliminates ~15,200 no-op sub calls/sec.

2. BallVel: REPLACE ^2 WITH MULTIPLICATION (~line 837)
   Changed: INT(SQR((ball.VelX ^2) + (ball.VelY ^2)))
   To:      INT(SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY))
   VBScript ^ is a slow COM-level math dispatch; * is a pure stack op.
   BallVel is called by Vol, Pitch, and directly from RollingTimer_Timer per ball per tick.
   Eliminates 2 ^ dispatches per BallVel call.

3. Vol: CACHE BallVel RESULT + REPLACE ^2 (~line 819)
   Changed: Csng(BallVel(ball) ^2 / 2000)
   To:      Dim bv : bv = BallVel(ball) : Csng(bv * bv / 2000)
   Eliminates 1 ^ dispatch per Vol call. Also caches BallVel so it is called once,
   not twice (BallVel itself calls ball.VelX and ball.VelY which are COM reads).

4. Pan: REPLACE ^10 WITH REPEATED SQUARING (~line 826)
   Changed: tmp ^10 / -((- tmp) ^10)
   To: t2 = tmp*tmp : t4 = t2*t2 : t8 = t4*t4 : t8*t2  (3 multiplications = tmp^10)
   Eliminates 1 ^ dispatch per branch. Pan is called per active ball per RollingTimer tick.

5. AudioPan: REPLACE ^10 WITH REPEATED SQUARING (~line 802)
   Same pattern as Pan. AudioPan is called on every collision and hit event.
   Eliminates 1 ^ dispatch per call.

6. AudioFade (tableobj version): REPLACE ^10 WITH REPEATED SQUARING (~line 792)
   Same repeated-squaring pattern applied to the first AudioFade definition.
   Note: this definition is shadowed by the second AudioFade(ball) definition in VBScript
   (second definition wins), so this is a latent fix for if the duplicate is ever resolved.

7. AudioFade (ball version): REPLACE ^10 WITH REPEATED SQUARING (~line 812)
   Same repeated-squaring pattern: t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2
   This is the active AudioFade definition. Called per active ball per RollingTimer tick
   and on every hit/collision event.
   Eliminates 1 ^ dispatch per call.

8. OnBallBallCollision: REPLACE ^2 + CACHE Csng(velocity) (~line 891)
   Changed: Csng(velocity) ^2 / 200 (computed twice, once per branch)
   To: Dim cv : cv = Csng(velocity) : cv * cv / 200
   Eliminates 1 ^ dispatch and 1 redundant Csng() call per collision event.

9. PRE-BUILT BallRollStr ARRAY (after ReDim rolling(tnob), ~line 862)
   Added: ReDim BallRollStr(tnob) + init loop building "fx_ballrolling0".."fx_ballrolling5".
   Note: ReDim required — VBScript Dim rejects named Const as array bound.
   Replaced all 4 occurrences of "fx_ballrolling" & b in RollingTimer_Timer with BallRollStr(b).
   Eliminates 4 string allocations per active ball per RollingTimer tick.
   At ~100Hz with 5 balls: ~2,000 string allocs/sec eliminated.

10. FlipperTimer_Timer: GUARD 5 UNCONDITIONAL ANGLE WRITES (~line 922)
    Added module-level state vars: lastLFAngle, lastRFAngle, lastSW14Angle, lastSW54Angle, lastSW58Angle.
    Replaced each `obj.RotZ = src.currentangle` with read-compare-write pattern:
      curA = src.currentangle
      If curA <> lastAngle Then lastAngle = curA : obj.RotZ = curA
    Flippers and gates are stationary ~80%+ of the time (during ball travel between shots).
    Eliminates up to 5 COM writes per tick when objects are idle.

11. BallShadowUpdate_timer: CACHE BOT(b).Z + GUARD .visible + FIX DUPLICATE opacity (~line 944)
    Added bz, bvis to sub Dim statement.
    bz = BOT(b).Z cached once per ball; replaces 4 reads of BOT(b).Z / BOT(b).z.
    .visible guarded: If BallShadow(b).visible <> bvis Then BallShadow(b).visible = bvis
    Duplicate `ballShadow(b).opacity = 90` (set identically in both branches) moved above
    the If/Else — now written once unconditionally instead of twice conditionally.
    Eliminates 3 COM reads per ball per frame + 1 redundant .visible write when stable
    + 1 redundant .opacity write per ball per frame.

12. SafehouseT_Timer: CACHE Safehouse.RotY (~line 446)
    Safehouse.RotY was read 5 times and written 1-2 times per tick during toy movement.
    Now: read once into sRotY, all arithmetic done locally, written back once at end.
    Eliminates 4 COM reads and up to 1 extra COM write per tick while safehouse is rotating.

13. SuitcaseT_Timer: CACHE Suitcase.RotAndTra7 (~line 468)
    Same pattern as SafehouseT_Timer — RotAndTra7 was read 5 times per tick.
    Now: read once into sRot7, arithmetic local, written back once.
    Eliminates 4 COM reads per tick while suitcase is rotating.

14. SniperT_Timer: CACHE Sniper.rotandtra8 (~line 419)
    rotandtra8 was read once and written once per active branch (2 COM ops per tick).
    Now: read once into sVal, increment/decrement local, write back once only when changed.
    Also fixed `=>` (non-standard) to `>=` for correctness.
    Eliminates 1 COM read per tick while sniper is moving.

---

## SUMMARY

Exponentiation ops eliminated:
  - BallVel: 2 ^2 per call                            = ~1,000 ops/sec (5 balls × 100Hz)
  - Vol: 1 ^2 per call                                = ~500 ops/sec
  - Pan: 1 ^10 per call                               = ~500 ops/sec
  - AudioFade: 1 ^10 per call (active definition)     = ~500 ops/sec
  - AudioPan: 1 ^10 per call (on hit events)          = per-event
  - OnBallBallCollision: 1 ^2 per event               = per-event
  TOTAL: ~2,500+ ^ dispatches/sec eliminated during rolling gameplay

No-op sub calls eliminated (UpdateLamps at 200Hz):
  - ~76 stable lamps × 200Hz                          = ~15,200 no-op sub calls/sec

String allocations eliminated:
  - BallRollStr (4 per ball per tick)                 = ~2,000 allocs/sec (5 balls × 100Hz)

COM reads eliminated per frame:
  - BallShadowUpdate: 3 reads/ball                    = ~180-300 reads/sec
  - SafehouseT: 4 reads/tick (while moving)           = per-event
  - SuitcaseT: 4 reads/tick (while moving)            = per-event
  - SniperT: 1 read/tick (while moving)               = per-event

COM writes eliminated:
  - FlipperTimer: up to 5 writes/tick at idle         = per-frame at rest
  - BallShadowUpdate: 1 .visible write/ball when stable = ~60-100/sec/ball
