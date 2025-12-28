import Foundation

protocol DefaultConfigurableProtocol: CallAsFunctionConfigurableProtocol, CustomConfigurableProtocol {}

extension NSObject: DefaultConfigurableProtocol {}
