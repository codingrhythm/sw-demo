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

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()

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

        // Load from remote URL
        loadRemoteURL()
    }

    @objc func refreshWebView() {
        print("🔄 Refreshing WebView...")
        webView.reload()
    }

    @objc func closeWebView() {
        print("🔴 Closing WebView...")

        // Clean up webview
        webView.stopLoading()

        dismiss(animated: true) {
            print("🔴 WebView dismissed")
        }
    }

    deinit {
        print("🗑️ WebViewViewController deallocated")
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

