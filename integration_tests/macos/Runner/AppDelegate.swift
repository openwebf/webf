import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    // Disable state restoration for integration tests so window size/position
    // changes during runs (e.g. viewport resize for media-query tests) do not
    // persist to the next run.
    return false
  }
}
