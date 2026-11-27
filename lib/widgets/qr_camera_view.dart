// File Path: sreerajp_authenticator/lib/widgets/qr_camera_view.dart
// Author: Sreeraj P
// Description: Camera preview that decodes QR codes with flutter_zxing. Decoding
//   runs locally, in the package's isolate. Only the package's core library is
//   imported; its old 3.x API (with readBarcodeImageUrl, its only network path)
//   is not used.

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_zxing/core.dart'
    show
        BarcodeFormat,
        BarcodeReader,
        PixelBuffer,
        ReaderOptions,
        warmUpBarcodeEngine;
import 'package:material_ui/material_ui.dart';
import 'package:sreerajp_authenticator/l10n/app_localizations.dart';

import '../utils/app_logger.dart';

/// Decides which decoded texts reach the screen.
@visibleForTesting
class QrCodeFilter {
  final bool ignoreDuplicates;
  String? _last;

  QrCodeFilter({required this.ignoreDuplicates});

  bool accept(String? text) {
    if (text == null || text.isEmpty) return false;
    if (ignoreDuplicates && text == _last) return false;
    _last = text;
    return true;
  }
}

/// Torch and camera buttons in a screen's AppBar use this.
class QrCameraController {
  _QrCameraViewState? _state;

  Future<void> toggleTorch() async => _state?._toggleTorch();

  Future<void> switchCamera() async => _state?._switchCamera();
}

class QrCameraView extends StatefulWidget {
  final ValueChanged<String> onCode;
  final QrCameraController? controller;

  /// Skip a code that is the same as the last one, so one bad QR code does not
  /// show its error on every frame. Optical sync needs every frame.
  final bool ignoreDuplicates;

  /// Replaces the camera lookup in tests.
  final Future<List<CameraDescription>> Function() loadCameras;

  const QrCameraView({
    super.key,
    required this.onCode,
    this.controller,
    this.ignoreDuplicates = true,
    this.loadCameras = availableCameras,
  });

  @override
  State<QrCameraView> createState() => _QrCameraViewState();
}

class _QrCameraViewState extends State<QrCameraView>
    with WidgetsBindingObserver {
  /// QR codes only, with the same fast settings the 3.x code used for
  /// live frames (no rotation, inversion, downscaling or extra effort).
  static const _reader = BarcodeReader(
    formats: {BarcodeFormat.qrCode},
    options: ReaderOptions(
      tryHarder: false,
      tryRotate: false,
      tryInvert: false,
      tryDownscale: false,
    ),
  );

  late final QrCodeFilter _filter = QrCodeFilter(
    ignoreDuplicates: widget.ignoreDuplicates,
  );

  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  CameraController? _camera;
  bool _decoding = false;
  bool _torchOn = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_start());
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    WidgetsBinding.instance.removeObserver(this);
    // No rebuild: setState is not allowed while the widget is being removed.
    unawaited(_closeCamera(rebuild: false));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      unawaited(_closeCamera());
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      unawaited(_openCamera());
    }
  }

  Future<void> _start() async {
    try {
      // Start the decoder early so the first frame is fast. It never fails
      // (a decoder that cannot start reports it on the first frame), so it
      // is not awaited.
      unawaited(warmUpBarcodeEngine(scanner: false));
      _cameras = await widget.loadCameras();
      if (!mounted) return;
      if (_cameras.isEmpty) {
        setState(() => _failed = true);
        return;
      }
      final back = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _cameraIndex = back < 0 ? 0 : back;
      await _openCamera();
    } catch (e) {
      _fail('Failed to start the QR camera', e);
    }
  }

  Future<void> _openCamera() async {
    if (_cameras.isEmpty || _camera != null) return;
    final camera = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _camera = camera;
    try {
      await camera.initialize();
      if (!mounted || !identical(_camera, camera)) {
        await camera.dispose();
        return;
      }
      await camera.startImageStream((image) => _decode(camera, image));
      if (mounted) setState(() => _failed = false);
    } catch (e) {
      if (identical(_camera, camera)) _camera = null;
      _fail('Failed to open the QR camera', e);
    }
  }

  /// Stops and releases the camera. [rebuild] is false only from [dispose].
  Future<void> _closeCamera({bool rebuild = true}) async {
    final camera = _camera;
    if (camera == null) return;
    _camera = null;
    _torchOn = false;
    if (rebuild && mounted) setState(() {});
    try {
      if (camera.value.isStreamingImages) await camera.stopImageStream();
    } catch (e) {
      AppLogger.error('Failed to stop the QR camera stream', e);
    }
    try {
      await camera.dispose();
    } catch (e) {
      AppLogger.error('Failed to close the QR camera', e);
    }
  }

  void _fail(String operation, Object error) {
    AppLogger.error(operation, error);
    if (mounted) setState(() => _failed = true);
  }

  Future<void> _decode(CameraController camera, CameraImage image) async {
    // A frame that arrives during decoding is dropped; the next one is used.
    if (_decoding) return;
    _decoding = true;
    try {
      // The stream uses YUV420, so the first plane is the brightness (Y)
      // plane, which is all the decoder needs.
      final luma = image.planes.first;
      final barcode = await _reader.readPixels(
        PixelBuffer(
          luma.bytes,
          width: image.width,
          height: image.height,
          rowStride: luma.bytesPerRow,
        ),
      );
      if (mounted &&
          identical(_camera, camera) &&
          barcode != null &&
          barcode.isValid) {
        final text = barcode.text;
        if (_filter.accept(text)) widget.onCode(text);
      }
    } catch (e) {
      // A bad frame is not an error the user can act on.
      AppLogger.error('Failed to decode a camera frame', e);
    } finally {
      _decoding = false;
    }
  }

  Future<void> _toggleTorch() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    try {
      await camera.setFlashMode(_torchOn ? FlashMode.off : FlashMode.torch);
      _torchOn = !_torchOn;
    } catch (e) {
      AppLogger.error('Failed to toggle the torch', e);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    await _closeCamera();
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _openCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              AppLocalizations.of(context).errorCameraUnavailable,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return const ColoredBox(color: Colors.black, child: SizedBox.expand());
    }

    final size = camera.value.previewSize!;
    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            // The app is portrait only, and previewSize is landscape.
            width: size.height,
            height: size.width,
            child: CameraPreview(camera),
          ),
        ),
      ),
    );
  }
}
