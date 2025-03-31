# Manul SVG Implementation Guide

This folder contains SVG files for the Manul (Pallas cat) character and its accessories.

## SVG Files Structure

- `manul_happy.svg` - The happy mood representation
- `manul_neutral.svg` - The neutral mood representation
- `manul_sad.svg` - The sad mood representation
- `manul_unhappy.svg` - The unhappy mood representation
- `hat_beanie.svg` - A beanie hat accessory
- Additional SVGs for more accessories can be added here

## Adding New SVG Files

1. Create your SVG file. Recommended dimensions are 512x512px for manul bodies and appropriate sizes for accessories.
2. Add the SVG file to this directory.
3. Create an image set in `Assets.xcassets` with the same name as your SVG file.
4. Add the SVG file to the image set.
5. Update the `Contents.json` file to set `preserves-vector-representation` to `true`.

## Adding a New Manul Mood

If you need to add a new mood:

1. Add the new mood to the `Manul.Mood` enum in `Models/Manul.swift`.
2. Create a corresponding SVG in this directory (e.g., `manul_excited.svg`).
3. Add it to `Assets.xcassets` as described above.
4. Update the `svgName` computed property in `ManulView` to return the correct SVG name for the new mood.

## Adding New Wearable Items

For new wearable items such as hats, accessories, etc:

1. Create the SVG file (e.g., `hat_santa.svg`).
2. Add it to `Assets.xcassets` as described above.
3. Update the `isWearingHat` or create a new computed property in `ManulView` to check for the new item type.
4. Add the corresponding item to the shop inventory in `Item.sampleItems`.

## SVG Creation Tips

- Keep SVGs simple to ensure good performance.
- Maintain consistent positioning relative to the manul (center point at 256,256).
- Use groups for logical organization.
- Add comments in SVG for clarity.
- Test with different scaling factors.
- Use colors that will work well with the app's theme.

## Implementation Notes

The app currently uses SwiftUI's native `Image` component to display SVG files, which offers the best performance and compatibility. While we initially had two approaches:

1. `NativeSVGImageView` - Uses SwiftUI's native `Image` with `renderingMode`.
2. `SVGImageView` - A WebKit-based fallback for more complex SVGs that need custom styling.

We found that using `Image` directly with proper modifiers (`.resizable()` and `.aspectRatio(contentMode: .fit)`) works best for our SVG files.

If you need to dynamically adjust colors in your SVGs, you can use `.renderingMode(.template)` and `.foregroundColor()` modifiers. 