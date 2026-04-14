import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class VhsShaderPainter extends CustomPainter {
  const VhsShaderPainter({
    required this.shader,
    required this.scene,
    required this.intensity,
    required this.elapsedSeconds,
  });

  final ui.FragmentShader shader;
  final ui.Image scene;
  final double intensity;
  final double elapsedSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, elapsedSeconds)
      ..setFloat(1, intensity.clamp(0.0, 1.0))
      ..setFloat(2, size.width)
      ..setFloat(3, size.height)
      ..setImageSampler(0, scene);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(VhsShaderPainter old) =>
      old.intensity != intensity ||
      old.elapsedSeconds != elapsedSeconds ||
      old.scene != scene;
}

class VhsShaderWidget extends StatelessWidget {
  const VhsShaderWidget({
    required this.child,
    required this.intensity,
    required this.elapsedSeconds,
    super.key,
  });

  final Widget child;
  final double intensity;
  final double elapsedSeconds;

  static const String _shaderAsset = 'assets/shaders/vhs_rewind.frag';

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(assetKey: _shaderAsset, (
      BuildContext ctx,
      ui.FragmentShader shader,
      Widget? _,
    ) {
      return _VhsCapture(
        shader: shader,
        intensity: intensity,
        elapsedSeconds: elapsedSeconds,
        child: child,
      );
    }, child: child);
  }
}

class _VhsCapture extends StatelessWidget {
  const _VhsCapture({
    required this.shader,
    required this.intensity,
    required this.elapsedSeconds,
    required this.child,
  });

  final ui.FragmentShader shader;
  final double intensity;
  final double elapsedSeconds;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (intensity <= 0.001) return child;

    return RepaintBoundary(
      child: _ShaderOverlay(
        shader: shader,
        intensity: intensity,
        elapsedSeconds: elapsedSeconds,
        child: child,
      ),
    );
  }
}

class _ShaderOverlay extends SingleChildRenderObjectWidget {
  const _ShaderOverlay({
    required this.shader,
    required this.intensity,
    required this.elapsedSeconds,
    super.child,
  });

  final ui.FragmentShader shader;
  final double intensity;
  final double elapsedSeconds;

  @override
  RenderObject createRenderObject(BuildContext context) => _ShaderRenderObject(
    shader: shader,
    intensity: intensity,
    elapsedSeconds: elapsedSeconds,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _ShaderRenderObject renderObject,
  ) {
    renderObject
      ..shader = shader
      ..intensity = intensity
      ..elapsedSeconds = elapsedSeconds;
  }
}

class _ShaderRenderObject extends RenderProxyBox {
  _ShaderRenderObject({
    required ui.FragmentShader shader,
    required double intensity,
    required double elapsedSeconds,
  }) : _shader = shader,
       _intensity = intensity,
       _elapsedSeconds = elapsedSeconds;

  ui.FragmentShader _shader;
  double _intensity;
  double _elapsedSeconds;

  set shader(ui.FragmentShader v) {
    if (_shader == v) return;
    _shader = v;
    markNeedsPaint();
  }

  set intensity(double v) {
    if (_intensity == v) return;
    _intensity = v;
    markNeedsPaint();
  }

  set elapsedSeconds(double v) {
    if (_elapsedSeconds == v) return;
    _elapsedSeconds = v;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas offscreen = Canvas(recorder);
    final PaintingContext childCtx = PaintingContext(
      offscreen as ContainerLayer,
      offset & size,
    );
    super.paint(childCtx, offset);

    context.canvas.save();
    super.paint(context, offset);

    _shader
      ..setFloat(0, _elapsedSeconds)
      ..setFloat(1, _intensity.clamp(0.0, 1.0))
      ..setFloat(2, size.width)
      ..setFloat(3, size.height);
    
    context.canvas.restore();
  }
}
