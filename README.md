# kofl

`kofl` is an OpenFL-on-Kha runtime workspace. The goal is straightforward: mirror real upstream `openfl/src/openfl`, replace the Lime runtime seam with a private Kha-backed implementation, and make existing `openfl.*` apps build against KOFL on `Windows` and `HTML5` without source changes beyond project wiring.

## Current Status

- KOFL boots and renders through a private `Sources/openfl/_internal/kha` backend layer.
- Core OpenFL-facing builds are green for both `HTML5` and `Windows`.
- A curated subset of real apps from `openfl/openfl-samples` now builds against KOFL unchanged at the app-source level.

This is no longer just a bring-up sandbox. It is now a real compatibility workspace. It is also not full OpenFL parity yet. Areas like richer `TextField` behavior, deeper input/focus semantics, and broader asset/runtime coverage still need more work.

## Repo Layout

- `Sources/openfl`
  - mirrored and adapted OpenFL public API surface
- `Sources/openfl/_internal/kha`
  - private Kha-backed runtime, rendering, input, and asset helpers
- `tests/openfl`
  - imported upstream-style OpenFL test harnesses
- `samples/openfl-samples`
  - KOFL build wrappers around real apps from `openfl/openfl-samples`
- `vendor/openfl-samples`
  - vendored upstream sample source used by the wrappers
- `Kha`
  - vendored Kha checkout used for reproducible local builds

## Main App Builds

### HTML5

```powershell
.\scripts\build-html5.ps1
```

Output:

- `C:\Users\Chris\Documents\GitHub\kofl\build\html5`

### Windows

```powershell
.\scripts\build-windows.ps1
```

Output:

- `C:\Users\Chris\Documents\GitHub\kofl\build\windows`

The scripts prefer Kha's bundled Windows Haxe toolchain when present so the "extra Haxe" environment stays local to this repo.

## Imported OpenFL Test Harnesses

KOFL now mirrors the full upstream `openfl/tests` directory structure into [tests/openfl](C:/Users/Chris/Documents/GitHub/kofl/tests/openfl). That includes the previously empty placeholder groups from upstream as well as the actively compiled suites.

The current KOFL aggregate harness can build these upstream-style suites directly through Kha:

- `application`
- `assets`
- `bitmapdata`
- `displayobject`
- `errors`
- `eventdispatcher`
- `externalinterface`
- `filesystem`
- `filters`
- `functional`
- `geom`
- `globalization`
- `graphics`
- `input`
- `loader`
- `movieclip`
- `nativewindow`
- `renderer-dom`
- `security`
- `sensors`
- `shader`
- `sharedobject`
- `socket`
- `sound`
- `stage`
- `stage3d`
- `system`
- `textfield`
- `tilemap`
- `urlloader`
- `urlrequest`
- `utils`

Build them individually with:

```powershell
.\scripts\build-openfl-test-suite.ps1 -Suite eventdispatcher -Target html5
.\scripts\build-openfl-eventdispatcher-tests-html5.ps1
.\scripts\build-openfl-graphics-tests-html5.ps1
.\scripts\build-openfl-displayobject-tests-html5.ps1
.\scripts\build-openfl-stage-tests-html5.ps1
.\scripts\build-openfl-geom-tests-html5.ps1
.\scripts\build-openfl-input-tests-html5.ps1
```

Build the whole mirrored harness with:

```powershell
.\scripts\build-openfl-all-tests-html5.ps1
```

If you resync from upstream OpenFL, refresh the mirrored test tree with:

```powershell
.\scripts\sync-openfl-tests.ps1
```

These harnesses currently validate KOFL primarily at compile/build parity, with the functional suite also serving as a real app-style smoke target. The structure stays intentionally close to upstream OpenFL so deeper runtime assertion automation can keep expanding from here.

## OpenFL Sample Compatibility Harness

KOFL now includes Kha-backed wrappers for a curated subset of real apps from [`openfl/openfl-samples`](https://github.com/openfl/openfl-samples). The sample source stays upstream-shaped; only the build wiring is swapped to KOFL/Kha.

Current sample set:

- `features/display/DrawingShapes`
- `features/display/DisplayingABitmap`
- `features/display/UsingBitmapData`
- `features/text/AddingText`
- `features/events/HandlingMouseEvents`
- `features/events/HandlingKeyboardEvents`
- `features/events/CreatingAMainLoop`
- `demos/PiratePig`

Build one sample:

```powershell
.\scripts\build-openfl-sample.ps1 -SampleRoot "samples/openfl-samples/drawing-shapes" -MainClass "Bootstrap" -OutputName "drawing-shapes" -Target "html5"
```

Build the whole sample set:

```powershell
.\scripts\build-openfl-samples-html5.ps1
.\scripts\build-openfl-samples-windows.ps1
```

Outputs land in:

- `C:\Users\Chris\Documents\GitHub\kofl\build\samples\<sample>-html5`
- `C:\Users\Chris\Documents\GitHub\kofl\build\samples\<sample>-windows`

## Current Compatibility Notes

What is working well enough to build real apps today:

- display-list startup and stage bootstrap
- basic graphics and retained display-tree rendering
- bitmap-backed drawing for common sample cases
- baseline mouse and keyboard event flow
- basic text rendering through Kha font assets
- sample asset packaging through KOFL/Kha wiring

What still needs heavier port work:

- fuller `TextField` editing and layout parity
- more exact focus and hit-testing behavior
- broader `BitmapData` API parity
- more OpenFL package coverage beyond the current app/test set
- automated runtime result execution for imported suites

## Direction

The intended end state is:

- KOFL stays private as the backend/runtime layer
- Lime-facing seams are replaced by Kha-backed services
- upstream OpenFL structure stays recognizable enough to resync over time

The next steps are to keep importing real upstream classes, remove remaining implementation drift, and grow the harness set until ordinary OpenFL apps run on KOFL with minimal project-level adaptation.
