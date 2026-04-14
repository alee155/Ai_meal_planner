import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeActionButton extends StatefulWidget {
  const SwipeActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.thumbIcon,
    required this.trackColor,
    required this.fillColor,
    required this.thumbColor,
    required this.labelColor,
    required this.onCompleted,
  });

  final String label;
  final Widget icon;
  final Widget thumbIcon;
  final Color trackColor;
  final Color fillColor;
  final Color thumbColor;
  final Color labelColor;
  final VoidCallback onCompleted;

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _completed = false;

  late AnimationController _snapController;
  late Animation<double> _snapAnim;

  static const double _trackHeight = 64;
  static const double _thumbSize = 56;
  static const double _thumbPad = 4;

  double _trackWidth = 300;

  double get _maxDrag => _trackWidth - _thumbSize - _thumbPad * 2;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_completed) return;

    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0.0, _maxDrag);
    });

    if (_dragX >= _maxDrag * 0.95) {
      _complete();
    }
  }

  void _onDragEnd(DragEndDetails _) {
    if (_completed) return;
    _snapBack();
  }

  void _complete() {
    if (_completed) return;

    setState(() {
      _completed = true;
      _dragX = _maxDrag;
    });

    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 600), widget.onCompleted);
  }

  void _snapBack() {
    _snapAnim =
        Tween<double>(begin: _dragX, end: 0).animate(
          CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
        )..addListener(() {
          setState(() => _dragX = _snapAnim.value);
        });

    _snapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _trackWidth = constraints.maxWidth;
        final pct = _maxDrag > 0 ? _dragX / _maxDrag : 0.0;

        return SizedBox(
          height: _trackHeight,
          child: Stack(
            children: [
              // Track
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.trackColor,
                    borderRadius: BorderRadius.circular(_trackHeight / 2),
                  ),
                ),
              ),

              // Fill
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _dragX + _thumbSize + _thumbPad * 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.fillColor.withValues(alpha: 0.45),
                        widget.fillColor.withValues(alpha: 0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(_trackHeight / 2),
                  ),
                ),
              ),

              // Label
              Positioned.fill(
                child: Opacity(
                  opacity: (1.0 - pct * 2).clamp(0.0, 1.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.icon,
                        const SizedBox(width: 8),
                        Text(widget.label),
                      ],
                    ),
                  ),
                ),
              ),

              // Thumb
              if (!_completed)
                Positioned(
                  left: _thumbPad + _dragX,
                  top: _thumbPad,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(
                        color: widget.thumbColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: widget.thumbIcon),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
