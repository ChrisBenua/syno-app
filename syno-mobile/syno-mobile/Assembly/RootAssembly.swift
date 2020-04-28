import Foundation

class RootAssembly {
    lazy var coreAssembly: ICoreAssembly = CoreAssembly()
    lazy var serviceAssembly: IServiceAssembly = ServiceAssembly(coreAssembly: coreAssembly)
    lazy var presentationAssembly: IPresentationAssembly = PresentationAssembly(serviceAssembly: serviceAssembly)
}
