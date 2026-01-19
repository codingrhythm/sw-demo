import UIKit
import WebKit

class ViewController: UIViewController {

    private var launchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // Create launch button
        launchButton = UIButton(type: .system)
        launchButton.setTitle("Launch WebView Test", for: .normal)
        launchButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        launchButton.backgroundColor = .systemBlue
        launchButton.setTitleColor(.white, for: .normal)
        launchButton.layer.cornerRadius = 12
        launchButton.translatesAutoresizingMaskIntoConstraints = false
        launchButton.addTarget(self, action: #selector(launchWebView), for: .touchUpInside)

        view.addSubview(launchButton)

        NSLayoutConstraint.activate([
            launchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            launchButton.widthAnchor.constraint(equalToConstant: 250),
            launchButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        print("🚀 ViewController loaded, ready to launch WebView")
    }

    @objc func launchWebView() {
        let webViewController = WebViewViewController()
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true) {
            print("📱 WebView presented")
        }
    }
}

class WebViewViewController: UIViewController {

    private var webView: WKWebView!
    private var memoryTimer: Timer?

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()

        // Add message handlers
        webConfiguration.userContentController.add(self, name: "memoryReport")
        webConfiguration.userContentController.add(self, name: "consoleLog")

        // Inject console logging script BEFORE creating webView
        let consoleScript = createConsoleLoggingScript()
        webConfiguration.userContentController.addUserScript(consoleScript)

        // Inject memory monitoring script
        let memoryScript = createMemoryMonitoringScript()
        webConfiguration.userContentController.addUserScript(memoryScript)

        // Enable Service Workers via App-Bound Domains
        // This requires WKAppBoundDomains in Info.plist
        webConfiguration.limitsNavigationsToAppBoundDomains = true
        print("🔐 App-Bound Domains enabled for Service Worker support")

        // Allow local files to access remote resources (needed for loading fonts from Canva CDN)
        webConfiguration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        webConfiguration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.isInspectable = true

        // Create a container view to hold navigation bar and webview
        let containerView = UIView()
        view = containerView

        // Set up navigation bar
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(navigationBar)

        // Set up webview
        webView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(webView)

        // Layout constraints
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            webView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Create navigation item with buttons
        let navigationItem = UINavigationItem(title: "WebView")

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeWebView))
        navigationItem.leftBarButtonItem = closeButton

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWebView))
        navigationItem.rightBarButtonItem = refreshButton

        navigationBar.setItems([navigationItem], animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Monitor memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(memoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        // Test that native logging works
        print("🚀 WebViewViewController loaded, console redirection active")

        // Load from remote URL
        loadRemoteURL()

        // Start periodic memory checks
        startMemoryMonitoring()
    }

    @objc func refreshWebView() {
        print("🔄 Refreshing WebView...")
        webView.reload()
    }

    @objc func closeWebView() {
        print("🔴 Closing WebView...")

        // Stop memory monitoring
        memoryTimer?.invalidate()
        memoryTimer = nil

        // Clean up webview
        webView.stopLoading()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "memoryReport")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "consoleLog")

        dismiss(animated: true) {
            print("🔴 WebView dismissed")
            // Log memory after dismissal
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.logSystemMemory()
                print("💾 Memory logged 1 second after dismissal")
            }
        }
    }

    deinit {
        memoryTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        print("🗑️ WebViewViewController deallocated")
    }

    func createConsoleLoggingScript() -> WKUserScript {
        let jsCode = """
        (function() {
            const originalLog = console.log;
            const originalWarn = console.warn;
            const originalError = console.error;
            const originalInfo = console.info;
            const originalDebug = console.debug;

            function sendToNative(level, args) {
                try {
                    const message = Array.from(args).map(arg => {
                        if (typeof arg === 'object') {
                            try {
                                return JSON.stringify(arg);
                            } catch (e) {
                                return String(arg);
                            }
                        }
                        return String(arg);
                    }).join(' ');

                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.consoleLog) {
                        window.webkit.messageHandlers.consoleLog.postMessage({
                            level: level,
                            message: message
                        });
                    }
                } catch (e) {
                    // Fail silently if message handler isn't available
                }
            }

            console.log = function() {
                originalLog.apply(console, arguments);
                sendToNative('log', arguments);
            };

            console.warn = function() {
                originalWarn.apply(console, arguments);
                sendToNative('warn', arguments);
            };

            console.error = function() {
                originalError.apply(console, arguments);
                sendToNative('error', arguments);
            };

            console.info = function() {
                originalInfo.apply(console, arguments);
                sendToNative('info', arguments);
            };

            console.debug = function() {
                originalDebug.apply(console, arguments);
                sendToNative('debug', arguments);
            };

            // Send a test message to verify it's working
            console.log('Console redirection initialized');
        })();
        """

        return WKUserScript(source: jsCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    }

    func createMemoryMonitoringScript() -> WKUserScript {
        let jsCode = """
        setInterval(() => {
            // performance.memory is not available in Safari/WebKit
            // Instead, report DOM node count and basic page metrics
            const memoryInfo = {
                domNodes: document.getElementsByTagName('*').length,
                images: document.images.length,
                scripts: document.scripts.length,
                stylesheets: document.styleSheets.length,
                timestamp: Date.now()
            };

            window.webkit.messageHandlers.memoryReport.postMessage(memoryInfo);
        }, 2000);
        """

        return WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    func startMemoryMonitoring() {
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.logSystemMemory()
        }
    }

    func logSystemMemory() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        if kerr == KERN_SUCCESS {
            let usedMemory = Double(info.resident_size) / 1048576.0 // MB
            print("📊 App Memory: \(String(format: "%.2f", usedMemory)) MB")
        }

        // Use footprint API to get more accurate memory usage
        var footprint: task_vm_info_data_t = task_vm_info_data_t()
        var footprintCount = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)

        let footprintResult = withUnsafeMutablePointer(to: &footprint) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(TASK_VM_INFO),
                         $0,
                         &footprintCount)
            }
        }

        if footprintResult == KERN_SUCCESS {
            let footprintMB = Double(footprint.phys_footprint) / 1048576.0
            print("👣 Memory Footprint: \(String(format: "%.2f", footprintMB)) MB")
        }

        let available = os_proc_available_memory()
        if available > 0 {
            print("💾 System Available: \(available / 1048576) MB")
        } else {
            print("💾 System Available: N/A (Simulator)")
        }
    }

    @objc func memoryWarning() {
        print("⚠️ MEMORY WARNING RECEIVED!")
        logSystemMemory()
    }

    private func loadRemoteURL() {
        let urlString = "https://codingrhythm.github.io/sw-demo/"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        webView.load(request)
        print("📱 Loading from remote URL: \(url)")
    }
}

extension WebViewViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "memoryReport", let body = message.body as? [String: Any] {
            let domNodes = body["domNodes"] as? Int ?? 0
            let images = body["images"] as? Int ?? 0
            let scripts = body["scripts"] as? Int ?? 0
            let stylesheets = body["stylesheets"] as? Int ?? 0

            print("📄 WebView DOM - Nodes: \(domNodes) | Images: \(images) | Scripts: \(scripts) | Stylesheets: \(stylesheets)")
        } else if message.name == "consoleLog", let body = message.body as? [String: Any] {
            let level = body["level"] as? String ?? "log"
            let logMessage = body["message"] as? String ?? ""

            let prefix: String
            switch level {
            case "error":
                prefix = "❌"
            case "warn":
                prefix = "⚠️"
            case "info":
                prefix = "ℹ️"
            case "debug":
                prefix = "🐛"
            default:
                prefix = "🌐"
            }

            print("\(prefix) JS \(level.uppercased()): \(logMessage)")
        }
    }
}
