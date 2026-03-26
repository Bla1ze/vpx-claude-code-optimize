Batman66 (Batman 66 Premium) — Applied Optimization Changes
============================================================
Format matches dhChanges.txt. Each entry: what changed, where, why, quantified savings.

---

1. PRE-BUILT SOUND STRINGS (near line ~14365)
   Added `BallRollStr(11)` = "fx_ballrolling0".."fx_ballrolling11" and
   `MetalRollStr(11)` = "fx_metalrolling0".."fx_metalrolling11" at script load.
   Eliminates all string concatenation in RollingUpdate.
   With 3 balls at 60Hz: ~1,080 string allocs/sec eliminated.

2. PRE-COMPUTED SHADOW CONSTANTS (near line ~14365)
   Added `tableHalfWidth = tablewidth / 2` and `BS_d6 = BallSize / 6` at module level.
   Eliminates 3 constant divisions per ball per tick in BallShadowUpdate.
   At 60Hz × 3 balls: ~540 divisions/sec eliminated.

3. PRE-BUILT FLASHER MATERIAL STRINGS (near line ~14365)
   Added `FlasherMatStr(20)` = "Flashermaterial0".."Flashermaterial20" at script load.
   Eliminates `"Flashermaterial" & nr` string concatenation per flasher per fade tick.

4. AudioFade/AudioPan — REPLACE ^10 WITH REPEATED SQUARING + ADD XY VARIANTS (line ~14271)
   Replaced `tmp ^10` with `t2=tmp*tmp : t4=t2*t2 : t8=t4*t4 : result=t8*t2`
   (3 multiplications instead of generic VBS exponentiation dispatch).
   Added `AudioFadeXY(y)` and `AudioPanXY(x)` variants accepting pre-cached scalars.
   AudioFade/AudioPan now delegate to XY variants internally.
   Pan now delegates to AudioPanXY.
   Used cached `tablewidth`/`tableheight` instead of `table1.width`/`table1.height`.
   Removed unnecessary `On Error Resume Next` from AudioFade/AudioPan.
   Also replaced `ball.VelX ^2` with `ball.VelX * ball.VelX` in BallVel.
   Also replaced `BallVel(ball) ^2` with `v * v` in Vol.

5. RollingUpdate REWRITE (line ~14380)
   - Cache `UBound(BOT)` into local `ub`. Eliminates 2 redundant UBound calls/tick.
   - Cache `BOT(b).x`, `.y`, `.z`, `.VelX`, `.VelY`, `.VelZ`, `.radius` into locals
     at top of each ball iteration. Eliminates ~10 COM reads per ball per tick.
   - Compute `velSq = bvx*bvx + bvy*bvy` once; derive vol as `Csng(velSq/2000)`
     (no SQR needed for Vol) and pitch as `vel * 20` from `vel = INT(SQR(velSq))`.
     Eliminates 3 redundant BallVel computations per ball per tick (Vol, Pitch, Pan each
     called BallVel internally).
   - Use `AudioPanXY(bx)` and `AudioFadeXY(by)` with cached scalars — computed once
     per ball, reused for both rolling sound and drop sound.
   - Use pre-built `BallRollStr(b)` and `MetalRollStr(b)` instead of string concat.
   - BUG FIX: panVal/fadeVal computed before the `vel > 1` check so drop sounds
     always have valid values.
   Total per ball per tick: ~10 COM reads eliminated, ~3 BallVel calls eliminated,
   ~4 string allocs eliminated.
   At 60Hz × 3 balls: ~1,800 COM reads/sec, ~540 BallVel/sec, ~720 string allocs/sec eliminated.

6. FlipperTricks TIMER 1ms → 10ms (line ~22469)
   Changed `RightFlipper.timerinterval = 1` to `RightFlipper.timerinterval = 10`.
   Reduces call frequency from 1000/sec to 100/sec — 90% reduction.
   Eliminates ~3,600 function calls/sec (2 FlipperTricks + 2 FlipperNudge × 900 saved calls).
   Single biggest per-tick win on this table.

7. BallShadowUpdate REWRITE (line ~14697)
   - Cache `UBound(BOT)` into local `ub`. Eliminates 2 redundant UBound calls/tick.
   - Cache `BOT(b).X`, `.Y`, `.Z` into locals `bx`, `by`, `bz`.
     Eliminates ~4 redundant COM reads per ball per tick (X read 2-3×, Y 1×, Z 1×).
   - Use pre-computed `tableHalfWidth` instead of `Table1.Width/2` (was computed 2× per ball).
   - Use pre-computed `BS_d6` instead of `Ballsize/6` (was computed 2× per ball).
   - Pre-compute `xOff = (bx - tableHalfWidth) / 7` once per ball (was computed implicitly 2×).
   At 60Hz × 3 balls: ~720 COM reads/sec + ~360 constant computations/sec eliminated.

8. FlashFlasher — CACHE ObjLevel + REPLACE ^2/^2.5/^3 + PRE-BUILT MATERIAL STRING (line ~24808)
   - Cached `ObjLevel(nr)` into local `lvl`. Was read 6× per call without caching.
   - Pre-computed `lvl2 = lvl * lvl` and `lvl3 = lvl2 * lvl`.
   - Replaced `ObjLevel(nr)^2.5` with `lvl2 * Sqr(lvl)` (2 muls + 1 sqr vs generic dispatch).
   - Replaced `ObjLevel(nr)^3` with `lvl3` (already computed).
   - Replaced `ObjLevel(nr)^2` with `lvl2` (already computed).
   - Used pre-built `FlasherMatStr(nr)` instead of `"Flashermaterial" & nr`.
   - Decay `lvl` locally then write back once: `ObjLevel(nr) = lvl`.
   Per flasher per tick: 4 exponentiation dispatches eliminated, 5 array derefs eliminated,
   1 string alloc eliminated.
   At 100Hz × 3 active flashers: ~1,200 ^n dispatches/sec + ~300 string allocs/sec eliminated.

9. FrameTimer_Timer — GUARD FLIPPER SHADOW WRITES (line ~27681)
   Added module-level `lastLFAngle`, `lastRFAngle` state tracking.
   Cached `LeftFlipper.currentangle` and `RightFlipper.currentangle` into locals.
   Guarded `FlipperLSh.RotZ` and `FlipperRSh.RotZ` writes with change detection.
   At rest (~80% of frames), eliminates 2 unconditional COM writes per frame.
   At 60Hz: up to ~96 COM writes/sec eliminated when flippers not moving.

10. LampTimer — CACHE chgLamp ARRAY DEREFS (line ~24387)
    Cached `chglamp(x, 0)` into local `lampId` and `chglamp(x, 1)` into `lampVal`.
    Each was previously read once for the Lampz.state assignment but now locals
    avoid repeated 2D array indexing overhead.

11. Distance FUNCTION — REPLACE ^2 WITH MULTIPLICATION (lines ~22461, ~22528)
    Changed `(ax - bx)^2 + (ay - by)^2` to `dx*dx + dy*dy` with cached locals.
    Distance is called from FlipperTrigger and DistanceFromFlipper (hot FlipperNudge path).
    Also fixed `sqr(tx ^2 + ty ^2)` in jVector.SetXY (line ~14628).

---

## PUP-PACK INTEGRATION PASS

12. tmrPopups_Timer — REPLACE Execute() WITH DIRECT CALL (line ~3970)
    Replaced `Execute "tmrPopupsDisplay " & i & ",False '"` with direct call
    `tmrPopupsDisplay i, False`. VBScript `Execute()` parses, tokenizes, and interprets
    the string at runtime on every call — orders of magnitude slower than a direct sub call.
    Two Execute() calls removed (lines 3970, 3974).
    While popups are animating (~10-20ms timer, up to 10 popup slots):
    eliminates 2 Execute() parse/compile cycles per completed popup per tick.
    This is the single highest-impact PuP fix.

13. pUpdateScores — ADD CHANGE GUARDS (line ~27605)
    Added module-level state tracking: `pLastScores(4)`, `pLastPlayer`, `pLastBalls`,
    `pLastCredits`, `pLastPlayerCount`. On each 250ms tick, compares current values against
    cached state. If nothing changed, exits immediately — skipping all ScoreSize recalculation,
    ScoreTag JSON string building, FormatScore calls, and LabelSet COM calls.
    During steady-state gameplay (score not changing every 250ms): eliminates 4 JSON string
    builds, 2-5 FormatScore calls (each doing string manipulation), 7-12 LabelSet COM calls,
    and 5+ string concatenations per tick.
    Also cached `"Player " & CurrentPlayer+1` into local `playerStr` — reused for both
    pBackglass and pDMD LabelSet calls (was built twice).

14. tmrPupAnimation_Timer — CACHE JSON TEMPLATE CONSTANTS (line ~13022)
    Extracted the static portions of the animation JSON string into module-level Const values:
    `aniJsonPre`, `aniJsonMid`, `aniJsonPost`. The per-tick string build now concatenates
    only the 2 changing values (ani_Size, ani_y) between pre-built constant segments instead
    of rebuilding the entire 90+ character JSON string from scratch each frame.
    At ~100Hz with 2-5 active animations: reduces string allocation overhead per animation
    from ~90 chars rebuilt to ~20 chars of numeric interpolation.

---

## PUP-PACK ERROR FIXES (from runtime log analysis)

15. ADD MISSING "Player" LABEL ON pBackglass (line ~26434)
    Added `LabelNew pBackglass,"Player"` before the existing `LabelNew pBackglass,"Ball"`.
    The label was being set via `LabelSet pBackglass,"Player"` in pUpdateScores (line ~27639)
    every 250ms but was never created — only existed on pDMD (screen 1).
    Eliminates "Invalid label" PuP error on every score update.

16. ADD MISSING PopT6-8 AND PopR6-8 LABELS ON pBackglass (line ~26450, ~26462)
    Added `LabelNew` for PopT6, PopT7, PopT8 and PopR6, PopR7, PopR8.
    The popup display loop (line ~3941) iterates `For i = 0 to 7`, generating label names
    PopT1-8 and PopR1-8, but only 1-5 were created (PopL1-8 already existed).
    When popups have 6+ message lines, the missing labels caused "Invalid label" errors.

17. ADD MISSING OverMessage1-3 LABELS ON pOverVid (line ~27234)
    Added `LabelNew pOverVid,"OverMessage1/2/3"` before the existing `LabelSet` calls.
    Labels were being set during PuP init but never created, causing "Invalid label" errors.

18. FIX DUPLICATE PLAYLISTS + CASE MISMATCHES IN PUP-PACK (playlists.pup, screens.pup, triggers.pup)
    Actual directory names: `PuPVideos`, `PupBonus`, `PupFrames`.
    playlists.pup had duplicate entries with wrong casing: `PupVideos`/`PuPVideos`, `PupBonus`/`PuPBonus`,
    `PuPFrames`/`PupFrames`. Removed duplicates and fixed all entries to match actual directory names.
    Fixed across main PuP-Pack and all 4 option configurations (Option 1-4).
    Also fixed screens.pup `PuPFrames` → `PupFrames` (backglass image path) in all configs.
    Also fixed triggers.pup `PupVideos` → `PuPVideos` in all configs.
    Eliminates "Duplicate playlist" warnings at PuP startup.
    On case-sensitive Linux: fixes potential directory-not-found failures.

19. FIX PLAYLIST CASING IN VBS SCRIPT (31 occurrences)
    Changed all 31 `"PupVideos"` references to `"PuPVideos"` in Batman66_1.1.0.vbs to match
    the actual directory name and the corrected playlists.pup entry.
    Ensures case-sensitive playlist lookups succeed on Linux.

---

20. SUBSTITUTE MISSING FONTS WITH AVAILABLE ALTERNATIVES (lines ~26827, ~26888, ~26936)
    Replaced missing fonts with available ones from FONTS directory:
    - `"PKMN Pinball"` (dmdalt) → `"DotMatrix"` — retro pixel aesthetic, used for DMD splash text
    - `"Instruction"` (dmdfixed) → `"SternSystem Mono"` — fixed-width, used for overlay targets/high scores
    - `"Gameplay"` (dmddef, FullDMD mode) → `"Impact"` — already used as dmddef in LCD mode
    Changed in all 3 DMD type blocks (FullDMD, LCD, third FullDMD).
    Eliminates "Font not found" fallback on every label render for Splash, Splash3b, Splash3c,
    Back5, Middle5, Flash5, Splash7b, Splash7c labels.

## TURNTABLE & DISC PHYSICS PASS

21. DoRotate — CACHE SIN/COS PER CALL (line ~12721)
    Cached `(Rot + RotOffset) * Pi / 180` into local `angleRad`, then computed
    `sinVal = sin(angleRad)` and `cosVal = cos(angleRad)` once per call.
    DoRotate is called ~30 times from UpdateObjects per frame while turntable moves.
    At 60Hz: ~1,800 redundant trig calls/sec eliminated.

22. tmrFake_Timer — CACHE Me.Interval AND SIN/COS (line ~12740)
    Cached `Me.Interval / 1000` into local `timeScale` (was read 5× per tick).
    Cached `Sin(spinAngle)`, `Cos(spinAngle)`, `Sin(spinAngle2)`, `Cos(spinAngle2)`
    into locals `sinA`, `cosA`, `sinA2`, `cosA2`. Each was called 3× per tick.
    Eliminates 5 COM reads + 8 redundant trig calls per tick while disc spins.

23. tmrMVSelect 1ms → 10ms (lines ~6211, ~6378)
    Changed villain select scroll timer from 1ms to 10ms interval.
    Only active during villain selection screen. Scroll animation goes from 5ms to 50ms
    total (still imperceptible). Reduces SceneMinorvillainDraw calls from 1000/sec to 100/sec
    during selection, each doing 15 iterations of string concatenation + LabelSet COM calls.

---

## REMAINING PUP ISSUES (cannot fix in script)

- **FN:3 SendMSG "Not implemented"** on screens 16-19 (pMVideo/pLVideo/pRVideo/pLVideo2):
  Intentional hide/show commands in pDMDMulti2 for screen layout management.
  PuP doesn't implement FN:3 for video-type screens. Fires in bursts of 8 on mode transitions.
  Not removable without risking layout breakage on PuP versions that support it.

---

## SUMMARY

Total COM reads eliminated per frame (60Hz):
  - RollingUpdate rewrite (×3 balls)                         = ~1,800 reads/sec
  - BallShadowUpdate rewrite (×3 balls)                      =   ~720 reads/sec
  - AudioFade/AudioPan table dim caching                     =   ~200 reads/sec
  TOTAL reads eliminated: ~2,720+/sec

Function calls eliminated:
  - FlipperTricks 1ms→10ms                                   = ~3,600 calls/sec

Exponentiation dispatches eliminated:
  - AudioFade/AudioPan ^10 → repeated squaring               =   ~200+/sec
  - Vol/BallVel ^2 → multiplication                          =   ~360+/sec
  - FlashFlasher ^2/^2.5/^3 → multiplication + Sqr           = ~1,200/sec
  - Distance ^2 → multiplication (in FlipperNudge path)

String allocations eliminated:
  - BallRollStr + MetalRollStr: ~720/sec (3 balls)
  - FlasherMatStr: ~300/sec (3 active flashers)
  TOTAL string allocs eliminated: ~1,020+/sec
