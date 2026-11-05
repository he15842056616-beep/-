import SwiftUI
import WebKit

@main
struct AboutSimApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                WebContainer().ignoresSafeArea()
            }
        }
    }
}

struct WebContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.userContentController.add(context.coordinator, name: "saveImage")
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.scrollView.backgroundColor = .clear
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            wv.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "saveImage",
                  let text = message.body as? String,
                  let comma = text.firstIndex(of: ","),
                  let data = Data(base64Encoded: String(text[text.index(after: comma)...])),
                  let image = UIImage(data: data) else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saved(_:didFinishSavingWithError:contextInfo:)), nil)
        }

        @objc func saved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            let alert = UIAlertController(title: error == nil ? "已保存到相册" : "保存失败，请在设置里允许添加照片", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default))
            let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
            scene?.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
}
