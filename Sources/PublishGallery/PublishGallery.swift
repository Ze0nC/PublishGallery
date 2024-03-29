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
    <svg><rect width="24" rx="2" height="19"></rect><rect y="20" width="6" height="4" rx="1" x="2"></rect><rect x="9" y="20" width="6" height="4" rx="1"></rect><rect x="16" y="20" width="6" height="4" rx="1"></rect></svg>
    """
    
    internal static let plainModeSVG: String = """
    <svg><rect y="13" width="24" height="11" rx="2"></rect><rect width="24" height="11" rx="2"></rect></svg>
    """
    internal static let thumbnailModeSVG: String = """
    <svg><rect width="11" height="11" rx="2"></rect><rect x="13" width="11" height="11" rx="2"></rect><rect x="13" y="13" width="11" height="11" rx="2"></rect><rect y="13" width="11" height="11" rx="2"></rect></svg>
    """
    internal static let galleryLargeSVG: String = """
    <svg><rect y="2" width="24" height="20" rx="2"></rect></svg>
    """
    internal static let galleryMediumSVG: String = """
    <svg><rect x="2" y="4" width="20" height="16" rx="2"></rect></svg>
    """
    internal static let gallerySmallSVG: String = """
    <svg><rect x="4" y="6" width="16" height="12" rx="2"></rect></svg>
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
    
    static let regex = try! NSRegularExpression(
        pattern: "^[-\\*] \\\\gallery\\{(?<description>[^{}]*)\\}\\{(?<url>[^{}]+)\\}$",
        options: NSRegularExpression.Options.caseInsensitive
    )
    
    static func parse<S>(_ line: S) -> (path: String, description: String)? where S: StringProtocol {
        guard let match = regex.matches(in: String(line), options: .anchored, range: NSRange(location: 0, length: line.count)).first else {
            return nil
        }
        let description = line[Range(match.range(withName: "description"), in: line)!]
        let url = line[Range(match.range(withName: "url"), in: line)!]
        return (path: String(url), description: String(description))
    }
}

fileprivate func galleryCssFile() -> String {
    return try! File(path: #filePath).parent!.file(named: "gallery.css").readAsString()
}

public extension Modifier {
    static func publishGallery() -> Self {
        return Modifier(target: .lists) { html, markdown in
            let photos = markdown.split(separator: "\n").compactMap{ PublishGallery.parse($0) }
            
            guard photos.count > 0 else {
                return html
            }
            
            let id = PublishGallery.newId()
            
            return Div {
                Div().class("control-background")
                Div().class("control-background")
                
                Plot.Input(type: .radio, name: "viewmode", value: "gallery-mode")
                    .id("gallery-mode")
                    .attribute(named: "checked", value: nil, ignoreValueIfEmpty: false)
                Label("") {Node<HTML.BodyContext>.raw(PublishGallery.galleryModeSVG)}
                    .attribute(named: "for", value: "gallery-mode")
                Div().class("line")
                Plot.Input(type: .radio, name: "viewmode", value: "plain-mode")
                    .id("plain-mode")
                Label("") {Node<HTML.BodyContext>.raw(PublishGallery.plainModeSVG)}
                    .attribute(named: "for", value: "plain-mode")
                Div().class("line")
                Plot.Input(type: .radio, name: "viewmode", value: "thumbnail-mode")
                    .id("thumbnail-mode")
                Label("") {Node<HTML.BodyContext>.raw(PublishGallery.thumbnailModeSVG)}
                    .attribute(named: "for", value: "thumbnail-mode")
                
                Plot.Input(type: .radio, name: "viewsize", value: "gallery-large")
                    .id("gallery-large")
                    .attribute(named: "checked", value: nil, ignoreValueIfEmpty: false)
                Label("") {Node<HTML.BodyContext>.raw(PublishGallery.galleryLargeSVG)}
                    .attribute(named: "for", value: "gallery-large")
                Div().class("line")
                Plot.Input(type: .radio, name: "viewsize", value: "gallery-medium")
                    .id("gallery-medium")
                Label("") {Node<HTML.BodyContext>.raw(PublishGallery.galleryMediumSVG)}
                    .attribute(named: "for", value: "gallery-medium")
                Div().class("line")
                Plot.Input(type: .radio, name: "viewsize", value: "gallery-small")
                    .id("gallery-small")
                Label("") {Node<HTML.BodyContext>.raw(PublishGallery.gallerySmallSVG)}
                    .attribute(named: "for", value: "gallery-small")
                
                Div {
                    Div().class("background")
                    
                    List(photos.enumerated()) { num, photo in
                        ListItem {
                            Image(photo.path)
                            Paragraph(photo.description).class("photo-description")
                            Div {
                                Link("←", url: "#\(id)\(num == 0 ? photos.count - 1 : num - 1)")
                                Link("→", url: "#\(id)\(num == photos.count - 1 ? 0 : num + 1)")
                            }
                            .class("prevNext")
                            List(0..<photos.count) { bulletIndex in
                                Link("", url: "#\(id)\(bulletIndex)")
                                    .attribute(named: "style", value: bulletIndex == num ? "background: #fff;" : nil, ignoreValueIfEmpty: true)
                            }
                            .class("bullets")
                        }
                        .class("photo")
                        .id("\(id)\(num)")
                    }
                    .class("slider")
                }
                .class("gallery")
            }
            .class("gallery-wrapper")
            .render()
            
        }
    }
}

            
public extension Plugin {
    static func publishGallery(maxPhoto: Int = 128) throws -> Self {
        Plugin(name: "Publish Gallery") { context in
            let cssFile = try context.createOutputFile(at: "gallery.css")
            try cssFile.write(galleryCssFile())
            context.markdownParser.addModifier(
                .publishGallery()
            )
        }
    }
}

public extension Content {
    var numberOfPhotos: Int {
        self.body.html.components(separatedBy: "<li class=\"photo\"").count - 1
    }
}
