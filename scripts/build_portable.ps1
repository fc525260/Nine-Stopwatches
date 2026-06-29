Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutter = if ($env:FLUTTER_BIN) { $env:FLUTTER_BIN } else { $null }
if (-not $flutter) {
  $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
  $flutter = if ($flutterCommand) { $flutterCommand.Source } else { $null }
}
if (-not $flutter) {
  throw 'Flutter was not found. Add flutter to PATH or set FLUTTER_BIN to the flutter executable path.'
}

& $flutter build windows --release

$bundle = Join-Path $root 'build/windows/x64/runner/nine_stopwatches_bundle.zip'
Compress-Archive `
  -Path (Join-Path $root 'build/windows/x64/runner/Release/*') `
  -DestinationPath $bundle `
  -Force

cargo build --release --manifest-path (Join-Path $root 'rust/portable_launcher/Cargo.toml')

Copy-Item `
  -LiteralPath (Join-Path $root 'rust/portable_launcher/target/release/nine_stopwatches_portable.exe') `
  -Destination (Join-Path $root '九个秒表.exe') `
  -Force

Get-Item -LiteralPath (Join-Path $root '九个秒表.exe')
