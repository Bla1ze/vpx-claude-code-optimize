Gill-applied-changes.md (vpxFile_Gill.vbs) — Applied Optimization Changes
============================================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. MODULE-LEVEL STATE VARS + CACHED TABLE DIMENSIONS (~line 91)
   Added: Dim tablewidth: tablewidth = Gilligan.width
   Added: Dim tableheight: tableheight = Gilligan.height
   Added: Dim lastLFAngle, lastRFAngle
   Added: Dim lastVUKGateAngle, lastGate4Angle
   tablewidth/tableheight eliminate Gilligan.width/.height COM reads in AudioFade/AudioPan.
   lastXxx vars initialize to Empty (VBScript default), causing first-frame write to always fire.

2. AudioFade: REPLACE ^10 WITH REPEATED SQUARING + CLAMP + USE CACHED tableheight (~line 1028)
   Replaced tmp ^10 / -((-tmp) ^10) with:
     t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2  (3 multiplications)
   Added clamp to ±7000 range (prevents overflow).
   Replaced Gilligan.height with cached tableheight (eliminates 1 COM read per call).
   Eliminates 1 ^ dispatch + 1 COM read per AudioFade call.

3. AudioFadeXY: NEW VARIANT ACCEPTING PRE-CACHED Y SCALAR (~line 1045)
   Added AudioFadeXY(ByVal y) — same repeated-squaring logic, accepts scalar instead of object.
   Eliminates tableobj.y COM read for hot-path callers (RollingTimer).

4. AudioPan: REPLACE ^10 WITH REPEATED SQUARING + CLAMP + USE CACHED tablewidth (~line 1062)
   Same repeated-squaring pattern as AudioFade.
   Replaced Gilligan.width with cached tablewidth.
   Eliminates 1 ^ dispatch + 1 COM read per AudioPan call.

5. AudioPanXY: NEW VARIANT ACCEPTING PRE-CACHED X SCALAR (~line 1079)
   Added AudioPanXY(ByVal x) — same repeated-squaring logic, accepts scalar instead of object.
   Eliminates tableobj.x COM read for hot-path callers (RollingTimer).

6. Vol: CACHE BallVel RESULT + REPLACE ^2 WITH MULTIPLICATION (~line 1096)
   Changed: Csng(BallVel(ball) ^2 / 400)
   To: Dim bv : bv = BallVel(ball) : Csng(bv * bv / 400)
   Eliminates 1 ^ dispatch per Vol call. Caches BallVel to avoid duplicate call.

7. BallVel: REPLACE ^2 WITH MULTIPLICATION (~line 1105)
   Changed: INT(SQR((ball.VelX ^2) + (ball.VelY ^2)))
   To:      INT(SQR(ball.VelX * ball.VelX + ball.VelY * ball.VelY))
   Eliminates 2 ^ dispatches per BallVel call.

8. BallRollStr + BallDropStr ARRAYS: PRE-BUILD SOUND NAME STRINGS (~line 1115)
   Added ReDim BallRollStr(tnob) + ReDim BallDropStr(tnob) + init loop.
   Builds "fx_ballrolling0".."fx_ballrolling7" and "fx_ball_drop0".."fx_ball_drop7".
   Replaced all 4 occurrences of "fx_ballrolling" & b with BallRollStr(b).
   Replaced 1 occurrence of "fx_ball_drop" & b with BallDropStr(b).
   Eliminates 5 string allocations per ball per RollingTimer tick.
   At 100Hz × 7 balls: ~3,500 string allocs/sec eliminated.

9. RollingTimer_Timer: CACHE BOT(b) PROPERTIES + INLINE BallVel/Vol/Pitch (~line 1127)
   Added bx, by, bz, bvx, bvy, bvz, bvel to sub Dim statement.
   At top of per-ball loop: cached BOT(b).X/Y/Z/VelX/VelY/VelZ into locals.
   bvel = INT(SQR(bvx * bvx + bvy * bvy)) — inlined BallVel with no ^ ops.
   Inlined Vol: Csng(bvel * bvel / 400)/12 — no function call.
   Inlined Pitch: bvel * 20 — no function call.
   Replaced AudioPan(BOT(b)) with AudioPanXY(bx) — passes cached x.
   Replaced AudioFade(BOT(b)) with AudioFadeXY(by) — passes cached y.
   Drop sound section uses cached bvz/bz/bx/by/bvel.
   BallVel was called 3× per rolling ball (condition + Vol + Pitch); now called 0×.
   Eliminates ~15 COM reads per ball per tick.
   At 100Hz × 7 balls: ~10,500 COM reads/sec eliminated.
   Plus ~2,100 function call frames/sec eliminated.

10. OnBallBallCollision: REPLACE ^2 + CACHE CSng(velocity) (~line 1175)
    Changed: Csng(velocity) ^2 / 2000
    To: Dim cv : cv = Csng(velocity) : cv * cv / 2000
    Eliminates 1 ^ dispatch per ball-ball collision event.

11. BallShadow ARRAY: MOVE TO MODULE LEVEL (~line 1181)
    Moved: BallShadow = Array(BallShadow1,...BallShadow8) from inside sub to module level.
    Previously rebuilt every BallShadowTimer tick — now built once at init.
    Eliminates 1 array allocation per tick.
    At 100Hz: ~100 allocs/sec eliminated.

12. BallShadowTimer: CACHE BOT(b) PROPERTIES (~line 1184)
    Added bx, by, bz to sub Dim statement.
    Cached BOT(b).X/Y/Z into locals at top of per-ball loop.
    All shadow property writes now use cached bx/by/bz.
    BOT(b).Z was read 4× per ball — now read 1×.
    Eliminates 3 redundant COM reads per ball per tick.
    At 100Hz × 7 balls: ~2,100 COM reads/sec eliminated.

13. RealTime_timer: CACHE FLIPPER ANGLES + GUARD RotZ WRITES (~line 1217)
    LeftFlipper.CurrentAngle cached into 'a'; RotZ write guarded by lastLFAngle comparison.
    RightFlipper.CurrentAngle cached into 'a'; RotZ write guarded by lastRFAngle comparison.
    Flippers idle ~80%+ of frames → eliminates ~96 COM writes/sec at 60Hz.

14. GateTimer_Timer: CACHE GATE ANGLES + GUARD RotX WRITES (~line 720)
    VUKGate.Currentangle cached into 'g'; RotX write guarded by lastVUKGateAngle comparison.
    Gate4.Currentangle cached into 'g'; RotX write guarded by lastGate4Angle comparison.
    Gates idle ~95%+ of ticks → eliminates ~114 COM writes/sec at 60Hz.

---

## SUMMARY

^ dispatches eliminated:
  - AudioFade: 1 ^10 per call                    = per-ball/tick + events
  - AudioPan: 1 ^10 per call                     = per-ball/tick + events
  - BallVel: 2 ^2 per call                       = per non-hot-path call
  - Vol: 1 ^2 per call                           = per non-hot-path call
  - OnBallBallCollision: 1 ^2 per event          = per-event

COM reads eliminated per tick:
  - RollingTimer: ~15 reads/ball/tick             = ~10,500 reads/sec (7 balls × 100Hz)
  - BallShadowTimer: 3 reads/ball/tick            = ~2,100 reads/sec (7 balls × 100Hz)
  - AudioFade/AudioPan table dims: 2/call         = ~2,800 reads/sec
  Total: ~15,400 COM reads/sec eliminated

COM writes eliminated:
  - RealTime_timer: 2 writes/frame when idle      = ~96 writes/sec at 60Hz
  - GateTimer_Timer: 2 writes/tick when idle       = ~114 writes/sec at 60Hz
  Total: ~210 COM writes/sec eliminated when idle

String allocations eliminated:
  - BallRollStr + BallDropStr: 5 per ball per tick = ~3,500 allocs/sec (7 balls × 100Hz)

Object allocations eliminated:
  - BallShadow array: 1 per tick                  = ~100 allocs/sec

Function call frames eliminated:
  - BallVel/Vol/Pitch inlined in RollingTimer      = ~2,100 frames/sec (3 per ball × 7 balls × 100Hz)
