# KOFL OpenFL Tests

This folder hosts OpenFL-style tests brought into `kofl` as the port progresses.

## Current harness

`tests/openfl` now mirrors the full upstream `openfl/tests` suite layout, not just the earlier hand-imported subset. KOFL keeps Kha-specific build wiring in this repo while preserving the upstream suite organization so syncs stay practical.

Compiled suite groups currently include:

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

Upstream placeholder groups such as `filereference`, `printing`, `telemetry`, `urlstream`, and `video` are mirrored locally too, even when upstream currently provides no `Tests.hx` or `Main.hx` entrypoint for them.

## Run

```powershell
.\scripts\build-openfl-eventdispatcher-tests-html5.ps1
.\scripts\build-openfl-graphics-tests-html5.ps1
.\scripts\build-openfl-displayobject-tests-html5.ps1
.\scripts\build-openfl-stage-tests-html5.ps1
.\scripts\build-openfl-geom-tests-html5.ps1
.\scripts\build-openfl-input-tests-html5.ps1
```

These harnesses are currently used first as build/compile parity checks while the KOFL runtime seam is still being ported. The runner shape stays intentionally close to upstream OpenFL so runtime assertion coverage can expand without redoing the suite layout later.

## Sample Compatibility Harness

Alongside the unit-style suites, KOFL now includes a curated compatibility harness for real apps from `openfl/openfl-samples`.

Current sample set:

- `features/display/DrawingShapes`
- `features/display/DisplayingABitmap`
- `features/display/UsingBitmapData`
- `features/text/AddingText`
- `features/events/HandlingMouseEvents`
- `features/events/HandlingKeyboardEvents`
- `features/events/CreatingAMainLoop`
- `demos/PiratePig`

Build the full sample set with:

```powershell
.\scripts\build-openfl-samples-html5.ps1
.\scripts\build-openfl-samples-windows.ps1
```

Build one wrapped sample with:

```powershell
.\scripts\build-openfl-sample.ps1 -SampleRoot "samples/openfl-samples/pirate-pig" -MainClass "Bootstrap" -OutputName "pirate-pig" -Target "windows"
```

The intent is to keep importing upstream OpenFL test groups, keep sample apps source-compatible, and let those two harness styles pull KOFL toward real drop-in OpenFL behavior.

## Aggregate Builders

Build one mirrored suite through the generic Kha wrapper:

```powershell
.\scripts\build-openfl-test-suite.ps1 -Suite bitmapdata -Target html5
```

Build the entire mirrored HTML5 test tree:

```powershell
.\scripts\build-openfl-all-tests-html5.ps1
```

Refresh the mirrored upstream test tree from the sibling `openfl` checkout:

```powershell
.\scripts\sync-openfl-tests.ps1
```
