import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Set window size and position
    self.setContentSize(NSSize(width: 1200, height: 800))
    self.center()
    
    // Set minimum window size
    self.minSize = NSSize(width: 800, height: 600)
    
    // Make window resizable
    self.styleMask.insert(.resizable)

    super.awakeFromNib()
  }
}
