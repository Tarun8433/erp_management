import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:erp_management/core/constants/app_colors.dart';

class CustomCameraPage extends StatefulWidget {
  const CustomCameraPage({super.key});
  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage> {
  CameraController? _controller;
  Future<void>? _initFuture;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _capturing = false;
  bool _torchOn = false;
  double _maxZoom = 1.0;
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    _cameras = await availableCameras();
    final backIndex = _cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    _cameraIndex = backIndex >= 0 ? backIndex : 0;
    final cam = _cameras[_cameraIndex];
    _controller = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    _maxZoom = await _controller!.getMaxZoomLevel();
    _zoom = await _controller!.getMinZoomLevel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    if (_cameras.isEmpty) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    final cam = _cameras[_cameraIndex];
    await _controller?.dispose();
    _controller = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    _maxZoom = await _controller!.getMaxZoomLevel();
    _zoom = await _controller!.getMinZoomLevel();
    if (_torchOn) await _controller!.setFlashMode(FlashMode.torch);
    setState(() {});
  }

  Future<void> _toggleTorch() async {
    if (!(_controller?.value.isInitialized ?? false)) return;
    _torchOn = !_torchOn;
    await _controller!.setFlashMode(_torchOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _capture() async {
    if (!(_controller?.value.isInitialized ?? false)) return;
    setState(() {
      _capturing = true;
    });
    try {
      final x = await _controller!.takePicture();
      final f = File(x.path);
      if (!mounted) return;
      Navigator.of(context).pop<File>(f);
    } catch (_) {
      setState(() {
        _capturing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.white),
              );
            }
            if (!(_controller?.value.isInitialized ?? false)) {
              return Center(
                child: Text(
                  'Camera not available',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onDoubleTap: _switchCamera,
                    child: CameraPreview(_controller!),
                  ),
                ),
                Positioned.fill(child: _GridOverlay()),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _CircleButton(
                        icon: _torchOn ? Icons.flash_on : Icons.flash_off,
                        onTap: _toggleTorch,
                      ),
                      _CircleButton(
                        icon: Icons.cameraswitch,
                        onTap: _switchCamera,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 100,
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: _zoom,
                          min: 1.0,
                          max: _maxZoom,
                          activeColor: AppColors.white,
                          inactiveColor: AppColors.white20,
                          onChanged: (v) async {
                            _zoom = v;
                            await _controller!.setZoomLevel(v);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Center(
                    child: _ShutterButton(
                      enabled: !_capturing,
                      onTap: _capture,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white20),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _ShutterButton({required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 4),
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? AppColors.white : AppColors.white20,
          ),
        ),
      ),
    );
  }
}

class _GridOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _GridPainter()));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white20
      ..strokeWidth = 1;
    final thirdW = size.width / 3;
    final thirdH = size.height / 3;
    canvas.drawLine(Offset(thirdW, 0), Offset(thirdW, size.height), paint);
    canvas.drawLine(
      Offset(thirdW * 2, 0),
      Offset(thirdW * 2, size.height),
      paint,
    );
    canvas.drawLine(Offset(0, thirdH), Offset(size.width, thirdH), paint);
    canvas.drawLine(
      Offset(0, thirdH * 2),
      Offset(size.width, thirdH * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
