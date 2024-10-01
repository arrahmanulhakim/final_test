import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Game',
      theme: ThemeData.dark(),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _rows = 1; // Default to 1 row
  int _columns = 1; // Default to 1 column
  Set<Offset> _selectedCells = {};
  Color _selectedColor = Colors.green; // Default color for selected cells

  int get rows => _rows;
  set rows(int value) {
    setState(() {
      _rows = value.clamp(1, 10); // Minimal 1 dan maksimal 10
    });
  }

  int get columns => _columns;
  set columns(int value) {
    setState(() {
      _columns = value.clamp(1, 10); // Minimal 1 dan maksimal 10
    });
  }

  // Handle gesture swipe untuk mengatur baris dan kolom
  void _handleSwipe(DragUpdateDetails details) {
    setState(() {
      if (details.delta.dx.abs() > details.delta.dy.abs()) {
        // Horizontal swipe
        if (details.delta.dx > 0) {
          // Geser kanan: kurangi kolom
          if (columns > 1) columns--;
        } else {
          // Geser kiri: tambah kolom
          if (columns < 10) columns++;
        }
      } else {
        // Vertical swipe
        if (details.delta.dy > 0) {
          // Geser bawah: kurangi baris
          if (rows > 1) rows--;
        } else {
          // Geser atas: tambah baris
          if (rows < 10) rows++;
        }
      }
    });
  }

  void _handleTap(TapUpDetails details) {
    setState(() {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      final cellWidth = renderBox.size.width / columns;
      final cellHeight = renderBox.size.height / rows;
      final int selectedColumn = (localPosition.dx / cellWidth).floor();
      final int selectedRow = (localPosition.dy / cellHeight).floor();
      final selectedCell =
          Offset(selectedColumn.toDouble(), selectedRow.toDouble());

      if (_selectedCells.contains(selectedCell)) {
        _selectedCells.remove(selectedCell);
      } else {
        _selectedCells.add(selectedCell);
      }

      // Toggle color
      _selectedColor =
          _selectedColor == Colors.green ? Colors.red : Colors.green;

      // Debug prints
      print('Tap position: ${details.globalPosition}');
      print('Local position: $localPosition');
      print('Selected cells: $_selectedCells');
    });
  }

  void _resetSelectedCells() {
    setState(() {
      _selectedCells.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main container untuk grid
            GestureDetector(
              onPanUpdate: _handleSwipe,
              onTapUp: _handleTap,
              child: Container(
                width: 300,
                height: 300,
                color: Colors.black,
                child: CustomPaint(
                  size: Size(300, 300),
                  painter: GamePainter(
                    rows: rows,
                    columns: columns,
                    selectedCells: _selectedCells,
                    selectedColor: _selectedColor,
                  ),
                ),
              ),
            ),
            // Panah baris (axis vertikal) di kiri dan kanan
            Positioned(
              left: -60, // Di luar grid (sisi kiri)
              child: ArrowWidget(direction: 'left', number: columns),
            ),
            Positioned(
              right: -60, // Di luar grid (sisi kanan)
              child: ArrowWidget(direction: 'right', number: columns),
            ),
            // Panah kolom (axis horizontal) di atas dan bawah
            Positioned(
              top: -60, // Di luar grid (sisi atas)
              child: ArrowWidget(direction: 'up', number: rows),
            ),
            Positioned(
              bottom: -60, // Di luar grid (sisi bawah)
              child: ArrowWidget(direction: 'down', number: rows),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetSelectedCells,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class ArrowWidget extends StatelessWidget {
  final String direction;
  final int number;

  ArrowWidget({required this.direction, required this.number});

  @override
  Widget build(BuildContext context) {
    // Mengatur rotasi berdasarkan arah panah
    double rotationAngle;
    switch (direction) {
      case 'up':
        rotationAngle = 0;
        break;
      case 'down':
        rotationAngle = pi;
        break;
      case 'left':
        rotationAngle = pi / 2;
        break;
      case 'right':
        rotationAngle = -pi / 2;
        break;
      default:
        rotationAngle = 0;
    }

    return Transform.rotate(
      angle: rotationAngle,
      child: CustomPaint(
        size: Size(60, 60),
        painter: ArrowPainter(),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0) // Titik atas segitiga
      ..lineTo(0, size.height) // Kiri bawah
      ..lineTo(size.width, size.height) // Kanan bawah
      ..close(); // Menutup segitiga

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class GamePainter extends CustomPainter {
  final int rows;
  final int columns;
  final Set<Offset> selectedCells;
  final Color selectedColor;

  GamePainter({
    required this.rows,
    required this.columns,
    required this.selectedCells,
    required this.selectedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // Menggambar grid
    final gridPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= columns; i++) {
      canvas.drawLine(
        Offset(i * cellWidth, 0),
        Offset(i * cellWidth, size.height),
        gridPaint,
      );
    }
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, i * cellHeight),
        Offset(size.width, i * cellHeight),
        gridPaint,
      );
    }

    // Menggambar sel yang dipilih
    final selectedPaint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.fill;

    for (final cell in selectedCells) {
      final rect = Rect.fromLTWH(
        cell.dx * cellWidth,
        cell.dy * cellHeight,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(rect, selectedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    print('Repainting: ${oldDelegate.selectedCells} -> $selectedCells');
    return oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        !setEquals(oldDelegate.selectedCells, selectedCells) ||
        oldDelegate.selectedColor != selectedColor;
  }

  bool setEquals(Set<Offset> a, Set<Offset> b) {
    if (a.length != b.length) return false;
    for (final element in a) {
      if (!b.contains(element)) return false;
    }
    return true;
  }
}
