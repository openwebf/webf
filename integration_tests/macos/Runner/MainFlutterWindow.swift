import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var originalContentSize: NSSize?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.level = NSWindow.Level.floating;

    self.originalContentSize = self.contentRect(forFrameRect: self.frame).size

    let windowChannel = FlutterMethodChannel(
      name: "webf_integration/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    windowChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let strongSelf = self else {
        result(nil)
        return
      }
      if call.method == "ensureWindowSize" {
        let args = call.arguments as? [Any]
        let width = (args?.count ?? 0) > 0 ? (args?[0] as? NSNumber)?.doubleValue ?? 0 : 0
        let height = (args?.count ?? 0) > 1 ? (args?[1] as? NSNumber)?.doubleValue ?? 0 : 0

        if width <= 0 || height <= 0 {
          result(nil)
          return
        }

        DispatchQueue.main.async {
          let currentContentSize = strongSelf.contentView?.frame.size ?? NSSize(width: 0, height: 0)
          let targetWidth = max(currentContentSize.width, CGFloat(width))
          // Add extra height to account for the app bar and window chrome so
          // `WebFTester` can fully realize the requested viewport height.
          let targetHeight = max(currentContentSize.height, CGFloat(height) + 120)
          if targetWidth != currentContentSize.width || targetHeight != currentContentSize.height {
            strongSelf.setContentSize(NSSize(width: targetWidth, height: targetHeight))
          }
          result(nil)
        }
        return
      }
      if call.method == "restoreWindowSize" {
        DispatchQueue.main.async {
          if let size = strongSelf.originalContentSize {
            strongSelf.setContentSize(size)
          }
          result(nil)
        }
        return
      }
      result(FlutterMethodNotImplemented)
    })

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
