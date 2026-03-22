# VPX Script Performance Optimizer

A collection of optimized Visual Pinball X (VPX) table scripts and the methodology used to produce them. Each table's VBScript has been systematically profiled and rewritten to reduce per-frame CPU cost in VPX's real-time game loop.

## Why This Exists

VPX runs VBScript in an interpreted, single-threaded engine with no JIT compiler. The frame budget is ~16ms at 60 FPS, and every per-frame operation is multiplied by ball count, light count, and source count. Common VBScript patterns — Dictionary lookups, COM property reads, string concatenation, unnecessary object allocation — add up fast in hot loops that execute thousands of times per second for things like ball shadows, rolling sounds, flipper correction, and light sequencing.

This project applies a repeatable optimization methodology across multiple tables to eliminate these bottlenecks.


Each folder contains:
- The optimized `.vbs` script
- `*-optimization-targets.md` — ranked list of hot paths and proposed changes before coding
- `*-applied-changes.md` — detailed changelog of every optimization with line references and per-tick savings

## Optimization Methodology

Optimizations are applied in priority order, targeting hot paths first:

1. **Find the hot loops** — Timer subs (`_Timer`), `Update`, `RollingUpdate`, `DynamicBSUpdate`, and anything called at 10ms+ frequency. Init code and event handlers are ignored.
2. **Dictionary to indexed arrays** — Replace `Scripting.Dictionary` `.Exists()` / `.Item()` in hot loops with pre-resolved integer indices.
3. **COM property caching** — Cache `gBOT(x).X`, `.Y`, `.Z`, `.visible`, `.color` into local variables instead of reading across the VBS/VPX COM boundary multiple times per iteration.
4. **String elimination** — Remove `Split()`, string concatenation (`&`), and `TypeName()` from timers. Pre-build strings into arrays at init.
5. **Guard redundant writes** — Only write COM properties (`.visible`, `.color`) when the value actually changes.
6. **Object allocation** — Move `(new ClassName)` out of per-tick code into pre-allocated caches at init.
7. **Eager initialization** — Trace cache population call chains; move lazy init that runs during gameplay to script load or `Table1_Init`.

## Reference Files

- **`optimization-guide.txt`** — General VPX/VBS optimization principles and what to look for
- **`distilled-guidance.txt`** — Condensed technical reference with specific fix patterns and code examples
- **`dhChanges.txt`** — Detailed changelog from the original darkchaos.vbs optimization pass that established the methodology
- **`prompt.txt`** — The prompt used with Claude Code to analyze and optimize each table
- **`CLAUDE.md`** — Project instructions including VBScript language traps, GLF framework rules, and the darkchaos.vbs-specific mode/lighting documentation

## Key VBScript Traps

These cause runtime errors or silent data corruption and are documented in detail in `CLAUDE.md`:

- **Variant array self-reference bug** — `arr(i) = Array(arr(i)(0), ...)` can clear the destination before reading the source. Always cache into a local first.
- **Arrays are value types in Variants** — `x = someArray(i)` copies; modifying `x` doesn't modify the original.
- **Dictionary is expensive in hot loops** — `.Exists()` + `.Item()` is two hash lookups per call. At 90+ lights per 10ms tick, this dominates CPU.

## Usage

To apply these optimizations to your own table:

1. Extract the `.vbs` script from your `.vpx` file
2. Place it in a new folder alongside the reference files
3. Use the prompt in `prompt.txt` with Claude Code to analyze and optimize the script
4. Review the generated optimization targets, then apply changes
5. Test in VPX — start a game, verify shadows/lighting/sounds/flippers behave correctly

## Credits

- **r2z2.** — Created all the Claude command functions and checks that power this optimization workflow
