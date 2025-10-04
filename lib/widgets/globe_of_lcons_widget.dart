import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class IconItem {
  final String name;
  final IconData icon;
  vector.Vector3 position;
  double scale;
  final Color color;

  IconItem({
    required this.name,
    required this.icon,
    required this.position,
    required this.color,
    this.scale = 1.0,
  });
}

class GlobeOfIconsWidget extends StatefulWidget {
  final List<IconData> icons;
  final double radius;
  final Color defaultIconColor;

  const GlobeOfIconsWidget({
    super.key,
    required this.icons,
    this.radius = 150.0,
    this.defaultIconColor = Colors.white,
  });

  @override
  State<GlobeOfIconsWidget> createState() => _GlobeOfIconsWidgetState();
}

class _GlobeOfIconsWidgetState extends State<GlobeOfIconsWidget>
    with SingleTickerProviderStateMixin {
  List<IconItem> iconItems = [];
  late AnimationController _controller;
  double _lastControllerValue = 0.0;

  // Interaction state
  Offset _lastPanPosition = Offset.zero;
  vector.Vector2 _rotationVelocity = vector.Vector2.zero();
  bool _isInteracting = false;
  DateTime? _lastInteractionTime;

  @override
  void initState() {
    super.initState();
    _initializeIcons();
    _setupAnimation();
  }

  void _initializeIcons() {
    if (widget.icons.isEmpty) return;

    iconItems = List.generate(widget.icons.length, (index) {
      final phi = math.acos(-1.0 + (2.0 * index) / widget.icons.length);
      final theta = math.sqrt(widget.icons.length * math.pi) * phi;

      final x = widget.radius * math.cos(theta) * math.sin(phi);
      final y = widget.radius * math.sin(theta) * math.sin(phi);
      final z = widget.radius * math.cos(phi);

      return IconItem(
        name: 'Icon $index',
        icon: widget.icons[index],
        position: vector.Vector3(x, y, z),
        color: widget.defaultIconColor,
      );
    });
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_performAutoRotation);

    _controller.repeat();
  }

  void _performAutoRotation() {
    if (!mounted || iconItems.isEmpty || _isInteracting) return;

    if (_lastInteractionTime != null &&
        DateTime.now().difference(_lastInteractionTime!).inMilliseconds < 500) {
      return; // Wait for interaction to settle
    }

    setState(() {
      final currentValue = _controller.value;
      final deltaValue = currentValue - _lastControllerValue;
      final adjustedDelta = deltaValue.abs() > 0.5
          ? deltaValue.sign * (1 - deltaValue.abs())
          : deltaValue;

      if (adjustedDelta.abs() > 0.0001) {
        final deltaRotation = adjustedDelta * 2 * math.pi * 0.1;
        final deltaMatrix = vector.Matrix4.rotationY(deltaRotation);

        for (var item in iconItems) {
          final transformed = deltaMatrix.transform3(item.position);
          item.position
            ..x = transformed.x
            ..y = transformed.y
            ..z = transformed.z;
        }
      }
      _lastControllerValue = currentValue;
    });
  }

  void _handlePanStart(DragStartDetails details) {
    _isInteracting = true;
    _lastPanPosition = details.localPosition;
    _controller.stop();
    _lastControllerValue = _controller.value;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!mounted || iconItems.isEmpty) return;

    setState(() {
      final delta = details.localPosition - _lastPanPosition;

      final deltaX = -delta.dy * 0.005;
      final deltaY = delta.dx * 0.005;

      final deltaMatrixX = vector.Matrix4.rotationX(deltaX);
      final deltaMatrixY = vector.Matrix4.rotationY(deltaY);
      final combinedMatrix = deltaMatrixY..multiply(deltaMatrixX);

      for (var item in iconItems) {
        final transformed = combinedMatrix.transform3(item.position);
        item.position
          ..x = transformed.x
          ..y = transformed.y
          ..z = transformed.z;
      }

      _rotationVelocity = vector.Vector2(deltaY, deltaX);
    });

    _lastPanPosition = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    _isInteracting = false;
    _lastInteractionTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (iconItems.isEmpty) {
      return SizedBox(width: widget.radius * 2, height: widget.radius * 2);
    }

    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: CustomPaint(
          painter: IconCloudPainter(
            iconItems: iconItems,
            radius: widget.radius,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class IconCloudPainter extends CustomPainter {
  final List<IconItem> iconItems;
  final double radius;

  IconCloudPainter({
    required this.iconItems,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sortedIcons = List<IconItem>.from(iconItems)
      ..sort((a, b) => b.position.z.compareTo(a.position.z));

    for (var item in sortedIcons) {
      final center = Offset(
        size.width / 2 + item.position.x,
        size.height / 2 + item.position.y,
      );

      final opacity = math.max(
        0.4,
        math.min(1.0, (item.position.z + radius) / (radius * 2)),
      );

      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(item.icon.codePoint),
          style: TextStyle(
            fontSize: 24 * item.scale,
            fontFamily: item.icon.fontFamily,
            package: item.icon.fontPackage,
            // ignore: deprecated_member_use
            color: item.color.withOpacity(opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      iconPainter.paint(
        canvas,
        center.translate(-iconPainter.width / 2, -iconPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(IconCloudPainter oldDelegate) => true;
}
