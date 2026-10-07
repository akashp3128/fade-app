# Fade brand assets

Full guidelines are in [`docs/DESIGN.md`](../../docs/DESIGN.md) §2.

- `svg/`: master vector files. All letterforms are paths, with no fonts embedded.
- `png/`: raster exports (app icon 1024/512/192/180/48, Android adaptive layers @432, wordmarks @320/640/1280, favicons 16/32 + .ico, apple-touch-icon).
- `generate_brand_svgs.py`: geometry source. Regenerate with `python3 generate_brand_svgs.py svg`.

Re-export the PNGs with librsvg (`rsvg-convert -w 1024 -h 1024 svg/fade-app-icon-ios.svg -o png/fade-app-icon-1024.png`). Store icons must be flattened to RGB with no alpha.

Colors: Ink `#0B0B0C` · Fade Gold `#F5B82E` · Bone `#F6F3EC` · Brass `#7A5600`.

These files aren't registered in `pubspec.yaml`. The in-app logo is drawn in code (`lib/widgets/ui/fade_logo.dart`), so nothing here is bundled into the app binary yet.
