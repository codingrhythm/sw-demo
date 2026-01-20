# Service Worker Demo for WKWebView

This repository contains web pages for testing Service Worker functionality and memory usage in WKWebView.

## Files

- `index.html` - Main page with Service Worker toggle, 40+ Canva fonts, and interactive canvas
- `sw.js` - Minimal Service Worker with basic fetch interception
- `app.js` - Canvas functionality for adding images and text elements
- `heavy_canva_fonts.html` - (Deprecated, merged into index.html)

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

## Testing with Xcode Instruments

### Memory Profiling Setup

1. **Prepare Your Device**
   - **⚠️ IMPORTANT: Force quit all other apps** on your iOS device
     - Double-click home button (or swipe up from bottom on newer devices)
     - Swipe up on all apps to close them
   - **⚠️ Ensure Safari is NOT running** - 
   - Close any other apps
   - This ensures you're measuring only your app's WebContent process with minimal interference

2. **Launch Xcode Instruments**
   - Open Xcode
   - Go to `Xcode` → `Open Developer Tool` → `Instruments`
   - Or use keyboard shortcut: `Cmd + I`

3. **Configure Instruments**
   - Select the "Activity Monitor" template
   - Choose your physical iOS device (Simulator may not show accurate WebKit process memory)
   - Click the record button (or `Cmd + R`)

4. **Filter WebKit Processes**
   - In Instruments, you'll see multiple processes
   - Look for processes named `WebContent` or `com.apple.WebKit.WebContent`
   - Click the filter icon and search for "WebKit" or "WebContent"

4. **Run the Test**
   - Launch your iOS app on the device
   - Tap the "Launch WebView Test" button
   - A new `WebKit.WebContent` process will appear in Instruments
   - This is the web content process for your WebView

5. **Test Service Worker Impact**

   **Without Service Worker:**
   - Start the app with cold launch
   - Ensure SW toggle is OFF (disabled)
   - Observe baseline memory usage of the WebContent process
   - Note memory usage as fonts load and canvas elements are added
   - Do a few page reloads to observe the memory usage

   **With Service Worker:**
   - Start the app with cold launch
   - Toggle SW to ON (this will automatically reload the page after 1.5s)
   - Observe memory usage of the WebContent process
   - Perform the same actions as above
   - Compare with baseline to see Service Worker's memory impact
   - Note: The service worker runs in the same WebContent process