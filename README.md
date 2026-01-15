# Service Worker Demo for WKWebView

This repository contains web pages for testing Service Worker functionality in WKWebView.

## Files

- `index.html` - Main page with Service Worker registration and console logging tests
- `sw.js` - Minimal Service Worker with basic caching
- `heavy.html` - Heavy page with 53+ CJK fonts for memory testing
- `heavy_canva_fonts.html` - Heavy page with Canva CDN fonts
- `light.html` - Light page with minimal resources

## GitHub Pages Setup

1. Push these files to your GitHub repository
2. Go to repository Settings → Pages
3. Under "Source", select the branch (usually `main` or `master`)
4. Select "/ (root)" as the folder
5. Click Save
6. Your site will be available at `https://yourusername.github.io/sw-demo/`

## iOS App Configuration

After publishing to GitHub Pages, update these files in your iOS app:

### Info.plist
Replace `yourusername.github.io` with your actual GitHub username:
```xml
<key>WKAppBoundDomains</key>
<array>
    <string>yourusername.github.io</string>
</array>
```

### ViewController.swift
Replace the URL in `loadRemoteURL()` method:
```swift
let urlString = "https://yourusername.github.io/sw-demo/"
```

## Testing

Once configured, run your iOS app and you should see:
- Console logs redirected to Xcode console with emoji prefixes (🌐, ⚠️, ❌, ℹ️, 🐛)
- Service Worker registration logs
- Memory monitoring metrics

## Service Worker Support

Service Workers require:
- HTTPS (GitHub Pages provides this automatically)
- App-Bound Domains configured in Info.plist
- `limitsNavigationsToAppBoundDomains = true` in WKWebViewConfiguration
