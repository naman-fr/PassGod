import 'package:flutter/material.dart';

class PatternLock extends StatefulWidget {
  final Function(String) onComplete;
  final bool isSetupMode;

  const PatternLock({
    Key? key,
    required this.onComplete,
    this.isSetupMode = false,
  }) : super(key: key);

  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  final List<int> _selectedPoints = [];
  final List<Offset> _points = [];
  final List<List<int>> _connections = [];
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _initializePoints();
  }

  void _initializePoints() {
    const double spacing = 80.0;
    const double startX = 40.0;
    const double startY = 40.0;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        _points.add(Offset(
          startX + (j * spacing),
          startY + (i * spacing),
        ));
      }
    }
  }

  int _getPointIndex(Offset position) {
    for (int i = 0; i < _points.length; i++) {
      if ((_points[i] - position).distance < 30) {
        return i;
      }
    }
    return -1;
  }

  void _onPanStart(DragStartDetails details) {
    final pointIndex = _getPointIndex(details.localPosition);
    if (pointIndex != -1) {
      setState(() {
        _isDrawing = true;
        _selectedPoints.add(pointIndex);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    final pointIndex = _getPointIndex(details.localPosition);
    if (pointIndex != -1 && !_selectedPoints.contains(pointIndex)) {
      setState(() {
        _selectedPoints.add(pointIndex);
        if (_selectedPoints.length > 1) {
          _connections.add([
            _selectedPoints[_selectedPoints.length - 2],
            _selectedPoints[_selectedPoints.length - 1],
          ]);
        }
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_selectedPoints.isNotEmpty) {
      final pattern = _selectedPoints.join('');
      widget.onComplete(pattern);
    }
    setState(() {
      _isDrawing = false;
      _selectedPoints.clear();
      _connections.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        size: const Size(280, 280),
        painter: PatternLockPainter(
          points: _points,
          selectedPoints: _selectedPoints,
          connections: _connections,
          isDrawing: _isDrawing,
        ),
      ),
    );
  }
}

class PatternLockPainter extends CustomPainter {
  final List<Offset> points;
  final List<int> selectedPoints;
  final List<List<int>> connections;
  final bool isDrawing;

  PatternLockPainter({
    required this.points,
    required this.selectedPoints,
    required this.connections,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw connections
    for (final connection in connections) {
      canvas.drawLine(
        points[connection[0]],
        points[connection[1]],
        paint,
      );
    }

    // Draw points
    for (int i = 0; i < points.length; i++) {
      final isSelected = selectedPoints.contains(i);
      canvas.drawCircle(
        points[i],
        isSelected ? 15.0 : 10.0,
        Paint()
          ..color = isSelected ? Colors.blue : Colors.grey
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        points[i],
        isSelected ? 15.0 : 10.0,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(PatternLockPainter oldDelegate) {
    return oldDelegate.selectedPoints != selectedPoints ||
        oldDelegate.connections != connections ||
        oldDelegate.isDrawing != isDrawing;
  }
} 