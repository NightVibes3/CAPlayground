# iOS Export Functionality Instructions

The export functionality for `.tendies` and `.ca` bundles has been implemented in `ExportService.swift`. However, to make it fully functional, you need to perform the following manual steps in your Xcode project.

## 1. Add Template Files
The `.tendies` export relies on template zip files found in the web project.
1. Locate the files in `apps/web/public/templates/`:
   - `tendies.zip`
   - `gyro-tendies.zip`
2. Drag and drop these two files into your Xcode project (e.g., into a `Resources` group).
3. Ensure "Add to targets" is checked for the **CAPlayground** app target.

## 2. Add ZipFoundation Dependency
Swift does not have a built-in high-level Zip library. `ExportService.swift` uses a wrapper `ZipUtils` that currently contains placeholder code.
1. In Xcode, go to **File > Add Packages...**
2. Enter the URL for ZIPFoundation: `https://github.com/weichsel/ZIPFoundation.git`
3. Add the package to your project.

## 3. Enable Zip Code
Once the library is added:
1. Open `CAPlayground/Services/Export/ExportService.swift`.
2. Import `ZIPFoundation` at the top of the file.
3. Update the `ZipUtils` class to use ZIPFoundation:

```swift
import ZIPFoundation

class ZipUtils {
    static func zip(directory: URL, to dest: URL) throws {
        let fileManager = FileManager.default
        try fileManager.zipItem(at: directory, to: dest)
    }
    
    static func unzip(source: URL, destination: URL) throws {
        let fileManager = FileManager.default
        try fileManager.unzipItem(at: source, to: destination)
    }
}
```

## 4. Verify Capabilities
Ensure your app has permissions to write to the temporary directory and show the Share Sheet (default iOS permissions are usually sufficient for this).

## Summary of Implementation
- **ExportService.swift**: Handles the logic for creating the folder structures and injecting CAML files into the templates.
- **EditorView.swift**: Added an "Export" button to the toolbar (square with arrow up) that triggers the export dialog.
