import Foundation
import AVFoundation
import CoreImage
import IOKit
import Darwin

func report(_ value: [String: Any]) {
    let data = try! JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
    FileHandle.standardOutput.write(data + Data([10]))
}
func fail(_ message: String) -> Never {
    report(["error": message])
    exit(1)
}

let args = Array(CommandLine.arguments.dropFirst())
func option(_ name: String) -> String? {
    guard let index = args.firstIndex(of: name), index + 1 < args.count else { return nil }
    return args[index + 1]
}
let devices = AVCaptureDevice.DiscoverySession(
    deviceTypes: [.builtInWideAngleCamera, .external], mediaType: .video,
    position: .unspecified
).devices
func isLidClosed() -> Bool? {
    let root = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
    guard root != 0 else { return nil }
    defer { IOObjectRelease(root) }
    return IORegistryEntryCreateCFProperty(root, "AppleClamshellState" as CFString,
                                          kCFAllocatorDefault, 0)?.takeRetainedValue() as? Bool
}
let lidClosed = isLidClosed()
let external = devices.filter { $0.deviceType == .external }
let builtIn = lidClosed == true ? nil : devices.first(where: { $0.deviceType == .builtInWideAngleCamera })
let preferred = builtIn ?? (external.count == 1 ? external.first : nil)
if args == ["--list"] {
    report(["cameras": devices.map { ["name": $0.localizedName, "id": $0.uniqueID,
                                      "external": $0.deviceType == .external] as [String: Any] },
            "authorization": AVCaptureDevice.authorizationStatus(for: .video).rawValue,
            "lid_closed": lidClosed.map { $0 as Any } ?? NSNull(),
            "preferred_camera": preferred.map { $0.localizedName as Any } ?? NSNull()])
    exit(0)
}
guard let destination = option("--output"), destination.hasPrefix("/") else {
    fail("Usage: snapshot --list | --output /absolute/new.jpg [--camera name-or-id]")
}
let url = URL(fileURLWithPath: destination)
guard !FileManager.default.fileExists(atPath: destination) else { fail("Output already exists") }
let selected: AVCaptureDevice
if let requested = option("--camera") {
    let matches = devices.filter { $0.uniqueID == requested || $0.localizedName == requested }
    guard matches.count == 1 else { fail("Requested camera is missing or ambiguous; use --list") }
    selected = matches[0]
} else {
    if let preferred = preferred {
        selected = preferred
    } else {
        guard external.count <= 1 else { fail("Several external cameras found; select one with --camera") }
        fail(lidClosed == true ? "Mac lid is closed and no external webcam is available" : "No webcam found")
    }
}

final class Capture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    let control = DispatchQueue(label: "snapshot.session")
    let frames = DispatchQueue(label: "snapshot.frames")
    var ready = false
    var finished = false
    var timeout: DispatchWorkItem?

    func finish(_ result: [String: Any], code: Int32) {
        guard !finished else { return }
        finished = true
        timeout?.cancel()
        control.async {
            self.session.stopRunning()
            report(result)
            exit(code)
        }
    }

    func start() {
        control.async {
            do {
                let input = try AVCaptureDeviceInput(device: selected)
                self.session.beginConfiguration()
                if self.session.canSetSessionPreset(.high) { self.session.sessionPreset = .high }
                guard self.session.canAddInput(input) else { fail("Camera input unavailable") }
                self.session.addInput(input)
                let output = AVCaptureVideoDataOutput()
                output.alwaysDiscardsLateVideoFrames = true
                output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
                output.setSampleBufferDelegate(self, queue: self.frames)
                guard self.session.canAddOutput(output) else { fail("Camera output unavailable") }
                self.session.addOutput(output)
                self.session.commitConfiguration()
                self.session.startRunning()
                let timeout = DispatchWorkItem {
                    self.finish(["error": "Camera frame timed out"], code: 1)
                }
                self.timeout = timeout
                self.frames.asyncAfter(deadline: .now() + 5, execute: timeout)
            } catch { fail(error.localizedDescription) }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sample: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !finished, let buffer = CMSampleBufferGetImageBuffer(sample) else { return }
        if !ready {
            ready = true
            report(["status": "ready", "camera": selected.localizedName])
        }
        do {
            let image = CIImage(cvPixelBuffer: buffer)
            guard let data = CIContext().jpegRepresentation(of: image, colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                          options: [CIImageRepresentationOption(rawValue: "kCGImageDestinationLossyCompressionQuality"): 0.95]) else {
                finish(["error": "JPEG encoding failed"], code: 1)
                return
            }
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .withoutOverwriting)
            finish(["status": "saved", "path": url.path, "camera": selected.localizedName,
                    "width": CVPixelBufferGetWidth(buffer), "height": CVPixelBufferGetHeight(buffer)], code: 0)
        } catch { finish(["error": error.localizedDescription], code: 1) }
    }
}

let capture = Capture()
switch AVCaptureDevice.authorizationStatus(for: .video) {
case .authorized: capture.start()
case .notDetermined:
    report(["status": "permission_required", "instruction": "Allow camera access in the macOS prompt"])
    AVCaptureDevice.requestAccess(for: .video) { allowed in
        guard allowed else { fail("Camera permission denied; use Photo Booth fallback") }
        capture.start()
    }
default: fail("Camera permission denied or restricted; use Photo Booth fallback")
}
RunLoop.main.run()
