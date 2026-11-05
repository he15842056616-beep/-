#!/bin/bash
set -e
cd "$(dirname "$0")"
command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
mkdir -p Sources/Assets.xcassets/AppIcon.appiconset Web Config
cp AboutSimApp.swift Sources/
cp index.html Web/
cp icon.png Sources/Assets.xcassets/AppIcon.appiconset/icon.png
echo '{"info":{"author":"xcode","version":1}}' > Sources/Assets.xcassets/Contents.json
echo '{"images":[{"filename":"icon.png","idiom":"universal","platform":"ios","size":"1024x1024"}],"info":{"author":"xcode","version":1}}' > Sources/Assets.xcassets/AppIcon.appiconset/Contents.json
curl -fL https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js -o Web/html2canvas.min.js
xcodegen generate
xcodebuild -project AboutSim.xcodeproj -scheme AboutSim -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
rm -rf Payload AboutSim.ipa
mkdir Payload
cp -R build/Build/Products/Release-iphoneos/AboutSim.app Payload/
zip -qry AboutSim.ipa Payload
echo "完成：AboutSim.ipa"
