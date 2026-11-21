import Foundation
import UIKit
import SwiftUI
import Darwin

private struct GuestPixHomeView {}

private struct ViewExistentialBox {
    var buffer0: UInt64 = 0
    var buffer1: UInt64 = 0
    var buffer2: UInt64 = 0
    var metadata: UnsafeRawPointer?
    var witness: UnsafeRawPointer?
}

private typealias GuestConstructor = () -> GuestPixHomeView
private typealias MetadataAccessor = () -> UnsafeRawPointer
private typealias ConformanceAccessor = () -> UnsafeRawPointer

private func eraseOpenedView<T: View>(_ value: T) -> AnyView {
    AnyView(value)
}

private func eraseGuestView(_ value: any View) -> AnyView {
    _openExistential(value, do: eraseOpenedView)
}

@_cdecl("PartnerSwiftBridgeMakeController")
public func PartnerSwiftBridgeMakeController(_ guestPath: UnsafePointer<CChar>) -> UnsafeMutableRawPointer? {
    guard Thread.isMainThread else { return nil }
    let path = String(cString: guestPath)
    guard let guest = dlopen(path, RTLD_NOW | RTLD_LOCAL) else {
        NSLog("[PartnerSwiftBridge] guest dlopen failed: %s", dlerror() ?? "unknown")
        return nil
    }
    guard let ctorRaw = dlsym(guest, "_$s4_10516InterPixHomeViewVACycfC"),
          let metadataRaw = dlsym(guest, "_$s4_10516InterPixHomeViewVMa"),
          let conformanceRaw = dlsym(guest, "_$s4_10516InterPixHomeViewV7SwiftUI0D0AAMc") else {
        NSLog("[PartnerSwiftBridge] InterPixHomeView symbols unavailable")
        return nil
    }
    let ctor = unsafeBitCast(ctorRaw, to: GuestConstructor.self)
    let metadataAccessor = unsafeBitCast(metadataRaw, to: MetadataAccessor.self)
    let conformanceAccessor = unsafeBitCast(conformanceRaw, to: ConformanceAccessor.self)
    let guestValue = ctor()
    let box = ViewExistentialBox(
        buffer0: 0,
        buffer1: 0,
        buffer2: 0,
        metadata: metadataAccessor(),
        witness: conformanceAccessor()
    )
    _ = guestValue
    let existential: any View = unsafeBitCast(box, to: (any View).self)
    let erased = eraseGuestView(existential)
    let controller = UIHostingController(rootView: erased)
    controller.view.backgroundColor = .clear
    return Unmanaged.passRetained(controller).toOpaque()
}
