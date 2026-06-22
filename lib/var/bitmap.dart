import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

createResizedBitmapDescriptor({
  required String assetPath,
  required double height,
}) async {
  // Load image bytes from asset
  final ByteData data = await rootBundle.load(assetPath);
  final Uint8List bytes = data.buffer.asUint8List();

  // Decode image
  final ui.Codec codec = await ui.instantiateImageCodec(
    bytes,
    targetHeight: height.toInt(),
  );

  // Get first frame (PNG is static, so only one)
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  // Convert to byte data in PNG format
  final ByteData? resizedByteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  final Uint8List resizedBytes = resizedByteData!.buffer.asUint8List();

  // Return as BitmapDescriptor
  return BitmapDescriptor.fromBytes(resizedBytes);
}
