//
//  PublishGallery.swift
//
//
//  Created by Zhijin Chen on 2020/11/03.
//

import Foundation
import Publish
import Plot
import Ink
import Files

internal struct PublishGallery {
    private static var id = -1
    
    internal static let galleryModeSVG: String = """
    <svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg"><g id="gallery-mode" stroke="none" stroke-width="1" fill-rule="evenodd"><rect id="Rectangle" x="0" y="0" width="24" height="19" rx="2"></rect><circle id="Oval" cx="12" cy="22" r="2"></circle><circle id="Oval" cx="17" cy="22" r="2"></circle><circle id="Oval" cx="7" cy="22" r="2"></circle></g></svg>
    """
    
    internal static let plainModeSVG: String = """
    <svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg"><g id="plain-mode" stroke="none" stroke-width="1" fill-rule="evenodd"><rect id="Rectangle" x="0" y="13" width="24" height="11" rx="2"></rect><rect id="Rectangle" x="0" y="0" width="24" height="11" rx="2"></rect></g></svg>
    """
    internal static let thumbnailModeSVG: String = """
    <svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg"><g id="thumbnail-mode" stroke="none" stroke-width="1" fill-rule="evenodd"><rect id="Rectangle" x="0" y="0" width="11" height="11" rx="2"></rect><rect id="Rectangle" x="13" y="0" width="11" height="11" rx="2"></rect><rect id="Rectangle" x="13" y="13" width="11" height="11" rx="2"></rect><rect id="Rectangle" x="0" y="13" width="11" height="11" rx="2"></rect></g></svg>
    """
    internal static let galleryLargeSVG: String = """
    <svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg"><g id="gallery-large" stroke="none" stroke-width="1" fill-rule="evenodd"><rect id="Rectangle" x="0" y="2" width="24" height="20" rx="2"></rect></g></svg>
    """
    internal static let galleryMediumSVG: String = """
    <svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg"><g id="gallery-medium" stroke="none" stroke-width="1" fill-rule="evenodd"><rect id="Rectangle" x="2" y="4" width="20" height="16" rx="2"></rect></g></svg>
    """
    internal static let gallerySmallSVG: String = """
    <svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg"><g id="gallery-small" stroke="none" stroke-width="1" fill-rule="evenodd"><rect id="Rectangle" x="4" y="6" width="16" height="12" rx="2"></rect></g></svg>
    """
    
    static func newId() -> String {
        func chr(_ i: Int) -> String {
            i < 10 ? "\(i)" : String(Character(UnicodeScalar(i + 65 - 9)!))
        }
        id = id + 1
        var num = id
        var result = ""
        while num > 0 {
            result += chr(num % 36)
            num = num / 36
        }
        return "G_" + String(result.reversed()) + "_"
    }
}

fileprivate func galleryCssFile() -> String {
    return try! File(path: #filePath).parent!.file(named: "gallery.css").readAsString()
}

public extension Modifier {
    static func publishGallery() -> Self {
        return Modifier(target: .lists) { html, markdown in
            
            let regex = try! NSRegularExpression(
                pattern: "^[-\\*] \\\\gallery\\{(?<description>[^{}]*)\\}\\{(?<url>[^{}]+)\\}$",
                options: NSRegularExpression.Options.caseInsensitive
            )
            let matchingResults = markdown.split(separator: "\n").map{ line -> (description: String, url: String)? in
                guard let match = regex.matches(in: String(line), options: .anchored, range: NSRange(location: 0, length: line.count)).first else {
                    return nil
                }
                
                if #available(OSX 10.15, *) {
                    let description = line[Range(match.range(withName: "description"), in: line)!]
                    let url = line[Range(match.range(withName: "url"), in: line)!]
                    return (description: String(description), url: String(url))
                } else {
                    // Fallback on earlier versions
                    fatalError("Only supports macOS 10.15 or higher")
                }
            }
            guard matchingResults.map({$0 != nil}).reduce(true, {$0 && $1}) else {
                return html
            }
            
            
            let photos = matchingResults.map { $0! }
            
            let id = PublishGallery.newId()
            return Node<HTML.BodyContext>.div(
                .class("gallery-wrapper"),
                .input(
                    .type(.radio),
                    .id("gallery-mode"),
                    .name("viewmode"),
                    .value("gallery-mode"),
                    Attribute(
                        name: "checked",
                        value: nil,
                        ignoreIfValueIsEmpty: false
                    )
                ),
                .label(
                    .for("gallery-mode"),
                    .raw(PublishGallery.galleryModeSVG)
                ),
                .input(
                    .type(.radio),
                    .id("plain-mode"),
                    .name("viewmode"),
                    .value("plain-mode")
                ),
                .label(
                    .for("plain-mode"),
                    .raw(PublishGallery.plainModeSVG)
                ),
                .input(
                    .type(.radio),
                    .id("thumbnail-mode"),
                    .name("viewmode"),
                    .value("thumbnail-mode")
                ),
                .label(
                    .for("thumbnail-mode"),
                    .raw(PublishGallery.thumbnailModeSVG)
                ),
                .input(
                    .type(.radio),
                    .id("gallery-large"),
                    .name("viewsize"),
                    .value("gallery-large"),
                    Attribute(
                        name: "checked",
                        value: nil,
                        ignoreIfValueIsEmpty: false
                    )
                ),
                .label(
                    .for("gallery-large"),
                    .raw(PublishGallery.galleryLargeSVG)
                ),
                .input(
                    .type(.radio),
                    .id("gallery-medium"),
                    .name("viewsize"),
                    .value("gallery-medium")
                ),
                .label(
                    .for("gallery-medium"),
                    .raw(PublishGallery.galleryMediumSVG)
                ),
                .input(
                    .type(.radio),
                    .id("gallery-small"),
                    .name("viewsize"),
                    .value("gallery-small")
                ),
                .label(
                    .for("gallery-small"),
                    .raw(PublishGallery.gallerySmallSVG)
                ),
                .div(
                    .class("gallery"),
                    .div(.class("background")),
                    .ul(
                        .class("slider"),
                        .forEach(zip(1...photos.count, photos)) { num, photo in
                            .li(
                                .class("photo"),
                                .id(id + "\(num)"),
                                .img(
                                    .src(photo.url)
                                ),
                                .p(
                                    .class("photo-description"),
                                    .text(photo.description)
                                ),
                                .div(
                                    .class("prevNext"),
                                    .a(
                                        .href("#\(id)\(num == 1 ? photos.count : num - 1)"),
                                        .text("←")
                                    ),
                                    .a(
                                        .href("#\(id)\(num == photos.count ? 1 : num + 1)"),
                                        .text("→")
                                    )
                                ),
                                .div(
                                    .class("bullets"),
                                    .forEach(1...photos.count) { bulletIndex in
                                        .a(
                                            .href("#\(id)\(bulletIndex)"),
                                            .if(bulletIndex == num,
                                                .attribute(named: "style", value: "background: #fff;")
                                            )
                                        )
                                    }
                                )
                            )
                        }
                    )
                )
            ).render()
            
        }
    }
}

            
public extension Plugin {
    static func publishGallery() throws -> Self {
        Plugin(name: "Publish Gallery") { context in
            let cssFile = try context.createOutputFile(at: "gallery.css")
            try cssFile.write(galleryCssFile())
            context.markdownParser.addModifier(
                .publishGallery()
            )
        }
    }
}
