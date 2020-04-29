import Foundation

/// Assembly for storing `ICoreAssembly`, `IServiceAssembly`, `IPresentationAssembly`
class RootAssembly {
    lazy var coreAssembly: ICoreAssembly = CoreAssembly()
    lazy var serviceAssembly: IServiceAssembly = ServiceAssembly(coreAssembly: coreAssembly)
    lazy var presentationAssembly: IPresentationAssembly = PresentationAssembly(serviceAssembly: serviceAssembly)
}
