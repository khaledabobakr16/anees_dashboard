import 'package:flutter/material.dart';

class ImageAsset extends StatelessWidget {
  const ImageAsset({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.color,
    this.boxFit = BoxFit.cover,
    this.colorBlendMode,
  });

  final String? imagePath;
  final BoxFit? boxFit;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  @override
  Widget build(BuildContext context) {
    return (imagePath != null && imagePath!.isNotEmpty)
        ? Image.asset(
            imagePath!,
            fit: boxFit!,
            width: width,
            height: height,
            color: color,
            colorBlendMode: colorBlendMode,
            filterQuality: FilterQuality.high,
          )
        : const SizedBox(
            height: 0,
          );
  }
}
