import 'package:flutter/material.dart';

class SwipeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double scale;
  final bool visible;
  final VoidCallback? onPressed;

  SwipeButton({
    required this.icon,
    required this.color,
    required this.scale,
    required this.visible,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: visible && onPressed != null ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        width: visible ? 100 * scale.clamp(0.0, 2) : 0,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Center(
          child: Opacity(
            opacity: visible ? 1.0 : 0.0,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

List<Widget> buildSwipeActionLeft(double swipeOffset, VoidCallback onSwipeButtonPressed) => [
  SwipeButton(
    icon: Icons.not_interested,
    color: Colors.blue,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
  SwipeButton(
    icon: Icons.not_interested,
    color: Colors.green,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
  SwipeButton(
    icon: Icons.not_interested,
    color: Colors.yellow,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
];

List<Widget> buildSwipeActionRight(double swipeOffset, VoidCallback onSwipeButtonPressed) => [
  SwipeButton(
    icon: Icons.mark_chat_read_outlined,
    color: Colors.red,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
    onPressed: onSwipeButtonPressed,
  ),
  SwipeButton(
    icon: Icons.not_interested,
    color: Colors.orange,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
  ),
  SwipeButton(
    icon: Icons.not_interested,
    color: Colors.purple,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
  ),
];
