#!/bin/bash
echo "Building Crypto Scanner for Windows..."

echo
echo "Building Tray Process..."
flutter build windows --target=lib/tray_main.dart --release
cp "build/windows/x64/runner/Release/prueba_exeos.exe" "crypto_scanner.exe"

echo
echo "Build completed!"
echo "Executable: crypto_scanner.exe"
echo
echo "To run: ./crypto_scanner.exe"
echo "The app will run in system tray."
echo "Right-click tray icon and select 'Mostrar UI' to open."
echo