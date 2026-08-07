# NovaSuite Multi-Platform Release Build Script
Write-Host "🚀 Building NovaSuite Multi-Platform Release Builds..." -ForegroundColor Green

# 1. Clean workspace
Write-Host "🧹 Cleaning Flutter build cache..." -ForegroundColor Yellow
flutter clean

# 2. Get pub dependencies
Write-Host "📦 Fetching Pub dependencies..." -ForegroundColor Yellow
flutter pub get

# 3. Analyze Code Quality
Write-Host "🔍 Running Static Analysis..." -ForegroundColor Yellow
flutter analyze apps/novasuite_admin

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Static Analysis failed! Please resolve errors before compiling release builds." -ForegroundColor Red
    exit 1
}

# 4. Build Web Target (WebAssembly / CanvasKit Engine)
Write-Host "🌐 Compiling Web Release (Wasm / CanvasKit Engine)..." -ForegroundColor Cyan
Push-Location apps/novasuite_admin
flutter build web --release --wasm

# 5. Build Android APK (Native ARM64 Release)
Write-Host "📱 Compiling Android Release APK..." -ForegroundColor Cyan
flutter build apk --release

# 6. Build Windows Desktop Target (Native x64 Release)
Write-Host "💻 Compiling Windows Desktop Release..." -ForegroundColor Cyan
flutter build windows --release
Pop-Location

Write-Host "✅ All NovaSuite Release Builds Compiled Successfully!" -ForegroundColor Green
