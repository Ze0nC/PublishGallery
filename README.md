# PublishGallery Plugin for Publish

<p align="center">
    <img src="PublishGalleryPreview.png" width="90%" alt="PublishGalleryPreview" />
</p>

This is a pure CSS responsive gallery plugin for Publish, 100% JavaScript-free.

It supports three modes:

- Gallery mode, where photos are shown in a slide box.
- Plain mode, where photos are shown one-by-one.
- Thumbnail mode, where photos are shown as thumbnails.

And three scales:

- Large
- Medium
- Small

And it supports both light and dark mode.

## Installation

1. Add `PublishGallery` to your package. 

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/Ze0nC/PublishGallery", .branch("master"))
    ],
    targets: [
        .target(
            ...
            dependencies: [
                ...
                "PublishGallery"
            ]
        )
    ]
    ...
)
```

## Usage

1. Add `.publishGallery()` to your build pipeline.

> SwiftPygmentsPublishPlugin must be installed before addMarkdownFiles() 

```swift
import PublishGallery
...
try MyWebsite().publish(using: [
    .installPlugin(.publishGallery()),
    ...
    .addMarkdownFiles(),
    ...
])
```

2. Add `gallery.css` to header of `HTMLFactory`. 

```swift
    .head(
        for: location,
        on: context.site,
        stylesheetPaths: ["/styles.css", "/gallery.css"]    // "/styles.css" is added by default. 
    ),
```

3. Use gallery in your markdown files.

````markdown
# Gallery post

Following is the gallery:

- \gallery{description 1}{/path/to/photo1.jpg}
- \gallery{description 2}{/path/to/photo2.jpg}
- \gallery{}{/path/to/photo3.jpg}          

````
As shown in the example, photos are added as markdown list.  Each item in list contains a photo. 
It uses the following grammar: `\gallery{description}{path/to/photo}`, where the first parameter is the description of the photo, and the second parameter is path to the photo.

> Currently PublishGallery only supports at maximum one gallery per post, so you can't leave empty line between the `\gallery{}{}` entries. 

For those who are familiar to LaTeX, you may have noticed where did this grammar come from...

## More 

This plugin is in early development. You are welcomed to report issues or contribute to it. 

You may find my website using this plugin at: [czj.io](https://czj.io/en/album/).

## Acknowledgement

Thanks to John Sundell (@johnsundell) for creating [Publish](https://github.com/johnsundell/publish).

