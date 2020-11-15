import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PublishGalleryTests.allTests),
    ]
}
#endif
