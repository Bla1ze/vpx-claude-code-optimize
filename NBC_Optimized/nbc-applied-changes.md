Nightmare Before Christmas (2024) v1.02.vbs — Applied Optimization Changes
===========================================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. PRE-COMPUTED Pi_over_180 CONSTANT (near PI declaration)
   Added module-level Dim: `Pi_over_180 = PI / 180`
   Replaces the repeated `Pi / 180` division in FlipperNudge sub (lines ~5012, 5016).
   PI is a Dim (not a Const literal), so Pi_over_180 must also be Dim.
   Eliminates 2 floating-point divisions per FlipperNudge call (~10-30Hz).

2. MODULE-LEVEL FLIPPER ANGLE STATE VARS (before FrameTimer.interval = -1)
   Added: `lastLeftAngle`, `lastRightAngle`, `lastLeft001Angle`
   Used to guard flipper shadow/logo RotZ writes in FrameTimer_Timer.
   Enables change-detection so writes only happen when angle actually changes.

3. MODULE-LEVEL GI BRIGHT STATE VAR (before FrameTimer.interval = -1)
   Added: `lastGIBright = -1`
   Used to guard material string assignments in FrameTimer_Timer (~line 3112).
   -1 forces the guard to fire on first frame, setting correct initial state.

4. MODULE-LEVEL GI COLOR CACHE VARS (before FrameTimer.interval = -1)
   Added: `giClr = -1`, `giClrF = -1`
   Used to guard aGILights bulb color writes in GameTimer_Timer (~line 721).
   -1 forces the guard to fire on first tick, initializing bulb colors.

5. PRE-BUILT BallRollStr ARRAY (after ReDim rolling(tnob))
   Added: `ReDim BallRollStr(tnob)` + init loop building "BallRoll_0" through "BallRoll_N".
   Note: ReDim required (not Dim) — VBScript Dim rejects named Const as array bound.
   Replaces `"BallRoll_" & b` string concatenation in RollingUpdate per-ball loop.
   At 77Hz with 1 ball: eliminates ~77 string allocations/sec. Scales with ball count.

6. PRE-BUILT RampLoopStr / WireLoopStr ARRAYS (after Dim RampBalls(6,2))
   Added: `ReDim RampLoopStr(6), WireLoopStr(6)` + init loop for indices 1-6.
   Replaces `"RampLoop" & x` / `"wireloop" & x` concatenation in RampRollUpdate and WRemoveBall.
   Eliminates up to 8 string allocations per RampRoll_Timer tick (10Hz) and per ball-removal event.

7. FrameTimer_Timer: CACHE 14 HOT COM READS AT SUB ENTRY (~line 2882)
   Added Dim cache declarations at top of FrameTimer_Timer:
     lfa    = LeftFlipper.CurrentAngle        (was read 4×: lines ~2889, 2890, 2893, 2894)
     rfa    = RightFlipper.CurrentAngle       (was read 3×: lines ~2891, 2892, 2895)
     lf001a = LeftFlipper001.CurrentAngle     (was read 3×)
     gi033i = gi033.GetInPlayIntensity        (was read 16×: lines ~2981-3093)
     gi033c = gi033.colorfull                 (was read 6×: lines ~3085-3090)
     libui  = libumper.GetInPlayIntensity     (was read 7×: lines ~3100-3196)
     f3i    = f3.GetInPlayIntensity           (was read 5×: lines ~3073-3214)
     f4i    = f4.getinplayintensity           (was read 3×: lines ~3222-3224)
     f5i    = F5.GetInPlayIntensity           (was read 2×: line ~3075, two reads in RGB call)
     pol22i = PoliceL22.getinplayintensity    (was read 3×: lines ~3192-3194)
     f4s    = f4.GetInPlayStateBool           (was read 2×: lines ~3010-3011)
     f5s    = f5.GetInPlayStateBool           (was read 2×: lines ~3012-3013)
     f2bs   = f2b.GetInPlayStateBool          (was read 2×: lines ~3014-3015)
     f1bs   = f1b.GetInPlayStateBool          (was read 2×: lines ~3016-3017)
   All occurrences of the above COM reads in FrameTimer_Timer body replaced with cache vars.
   Eliminates ~54 redundant COM reads per frame × 77Hz = ~4,158 COM reads/sec eliminated.

8. FrameTimer_Timer: FIX DUPLICATE LINE 2894 (FlipperLSh.RotZ written twice)
   Removed the second identical write: `FlipperLSh.RotZ = LeftFlipper.CurrentAngle`
   The line was a pure duplicate — same object, same property, same value as line 2893.
   Eliminates 1 unconditional COM write per frame = ~77 wasted COM writes/sec.

9. FrameTimer_Timer: GUARD FLIPPER ANGLE WRITES (~line 2889)
   Wrapped LeftFlipper RotZ writes in `If lfa <> lastLeftAngle Then` block.
   Wrapped RightFlipper RotZ writes in `If rfa <> lastRightAngle Then` block.
   Wrapped LeftFlipper001 RotZ writes in `If lf001a <> lastLeft001Angle Then` block.
   At rest (~80% of frames), eliminates 7 unconditional COM writes per frame.
   At 77Hz: up to ~540 COM writes/sec eliminated when flippers not moving.

10. FrameTimer_Timer: REPLACE ^2 WITH MULTIPLICATION (~line 3073)
    Changed `(F3.GetInPlayIntensity / 5) ^2` → `(f3i * f3i) / 25`
    VBScript `^` dispatches a COM math call; `*` is a pure stack operation.
    After f3i caching (change 7), the division is also folded: no repeated COM read.
    Eliminates 1 COM math dispatch per frame = ~77/sec.

11. FrameTimer_Timer: CACHE Flasher020.opacity WRITE VALUE (~line 3052)
    Added: `fl020op = Light001.getinplayintensity` before `Flasher020.opacity = fl020op`
    Replaced 7 subsequent `Flasher020.opacity` reads with `fl020op`.
    Previously opacity was written then re-read 6 more times in the same block.
    Eliminates 6 COM reads per frame = ~462 COM reads/sec.

12. FrameTimer_Timer: CACHE Plunger.Position + FIX DUPLICATE WRITE (~line 3176)
    Added: `plpos = Plunger.Position`, `pltz = -77 + plpos * 4 + ShakeStuff1`
    Replaced all 7 `Plunger.Position * 4 + ShakeStuff1` expressions with `pltz`.
    Removed duplicate line 3187: `Primitive187.transz = -77 + Plunger.Position * 4 + ShakeStuff1`
    was overwriting line 3178's identical assignment — pure waste.
    Eliminates 6 saved COM reads/frame + 1 redundant write = ~462 COM reads/sec + ~77 writes/sec.

13. FrameTimer_Timer: GUARD MATERIAL STRING WRITES (~line 3112)
    Wrapped the `If tmp > 0.02 Then / Else` material assignment block in:
      `Dim giNowBright : giNowBright = (tmp > 0.02)`
      `If giNowBright <> lastGIBright Then`
    Material strings for 10 primitives + For-Each over Wireramps are now written only on the
    frame the GI threshold crosses — not on every frame it remains in the same state.
    String COM assignments trigger VPX material lookup every frame even when value is unchanged.
    Eliminates ~11 string COM assignments + N ForEach writes per frame (all except transition frames).
    At 77Hz: ~847+ COM string writes/sec eliminated during stable GI.

14. GameTimer_Timer: GUARD GI BULB COLOR WRITES (~line 721)
    Added module-level cache vars giClr / giClrF (initialized to -1).
    Replaced unconditional `For each bulb in aGILights` loop with:
      `newGiClr = rgb(rl(7),rl(8),rl(9))` / `newGiClrF = rgb(rl(10),rl(11),rl(12))`
      `If newGiClr <> giClr Or newGiClrF <> giClrF Then` ... write loop ... `End If`
    The rl(7-12) values are stable for most frames — only change during GI color transitions.
    During stable GI (most of gameplay), eliminates N×2 COM writes per 77Hz tick.
    Savings scale with aGILights bulb count; transition frames are unaffected.

15. RollingUpdate: PRE-BUILT STRING CACHE (~line 6340)
    Replaced all `"BallRoll_" & b` in RollingUpdate loop body with `BallRollStr(b)`.
    Pre-built array initialized at script load (change 5).
    Eliminates 3 string allocations per ball per tick × 77Hz.
    With 1 ball: ~231 string allocs/sec eliminated.

16. RollingUpdate: CACHE gBOT(b).z AND gBOT(b).VelZ (~line 6340)
    Added `bz = gBOT(b).z` and `bvz = gBOT(b).VelZ` at top of per-ball loop.
    Replaced all `gBOT(b).z` references with `bz`, all `gBOT(b).VelZ` / `gBOT(b).velz` with `bvz`.
    gBOT(b).z was accessed 3× per ball (lines ~6358, 6369×2); VelZ was accessed 2× per ball.
    Eliminates 4 COM reads per ball per tick at 77Hz = ~308 COM reads/sec per ball.

17. RampRollUpdate: PRE-BUILT STRING CACHE (~line 6512)
    Replaced all `"RampLoop" & x` with `RampLoopStr(x)` and `"wireloop" & x` with `WireLoopStr(x)`.
    Pre-built arrays initialized at script load (change 6).
    Eliminates up to 8 string allocations per 100ms tick during active ramp rolling.

18. WRemoveBall: PRE-BUILT STRING CACHE (~line 6489)
    Replaced `StopSound("RampLoop" & x)` and `StopSound("wireloop" & x)` with cached strings.
    Eliminates 2 string allocations per ball-removal event (per-event, not hot, but free win).

19. FlipperNudge: USE Pi_over_180 CONSTANT (~line 5012)
    Changed `dSin = Sin(degrees * Pi / 180)` → `dSin = Sin(degrees * Pi_over_180)`
    Changed `dCos = Cos(degrees * Pi / 180)` → `dCos = Cos(degrees * Pi_over_180)`
    Pi_over_180 pre-computed at module level (change 1).
    Eliminates 2 floating-point divisions per FlipperNudge call.

20. REPLACE-ALL COM READS IN FrameTimer_Timer BODY
    Applied replace_all substitutions throughout FrameTimer_Timer for all cached vars:
      gi033.GetInPlayIntensity → gi033i
      gi033.colorfull → gi033c
      libumper.GetInPlayIntensity → libui
      PoliceL22.getinplayintensity → pol22i
      f4.getinplayintensity → f4i
      f3.GetInPlayIntensity / F3.GetInPlayIntensity → f3i (both case variants)
      F5.GetInPlayIntensity → f5i
      f4.GetInPlayStateBool (= true / = false) → f4s / Not f4s
      f5.GetInPlayStateBool → f5s / Not f5s
      f2b.GetInPlayStateBool → f2bs / Not f2bs
      f1b.GetInPlayStateBool → f1bs / Not f1bs
      LeftFlipper.CurrentAngle → lfa
      RightFlipper.CurrentAngle → rfa
      Plunger.Position * 4 + ShakeStuff1 → pltz (via plpos intermediate)
    Confirmed via final verification grep: no remaining hot-path COM reads for any targeted property.

---

## SUMMARY

Total COM reads eliminated per frame (77Hz):
  - 14 cached COM reads declared once, replacing ~54 redundant reads   = ~4,158 reads/sec
  - Flasher020.opacity re-reads eliminated                             =   ~462 reads/sec
  - Plunger.Position redundant reads eliminated                        =   ~462 reads/sec
  - RollingUpdate .z / .VelZ per ball                                  =   ~308 reads/sec/ball
  TOTAL reads eliminated: ~5,390+/sec (single ball)

Total COM writes eliminated per frame (77Hz):
  - Flipper RotZ writes guarded (at rest ~80% of frames)               =   ~540 writes/sec
  - Duplicate FlipperLSh.RotZ write removed                            =    ~77 writes/sec
  - Duplicate Primitive187.transz write removed                        =    ~77 writes/sec
  - GI material string writes guarded (~11+N per frame)                =   ~847+ writes/sec
  - GI bulb color writes guarded (N×2 per frame)                       =    N×154 writes/sec
  TOTAL writes eliminated: ~1,541+ writes/sec (stable GI, flippers at rest)

String allocations eliminated:
  - BallRollStr: ~77/sec per ball in RollingUpdate
  - RampLoopStr/WireLoopStr: up to ~80/sec during ramp rolling (10Hz × up to 8)
