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
    icon: Icons.archive,
    color: Colors.blue,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
  SwipeButton(
    icon: Icons.share,
    color: Colors.green,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
  SwipeButton(
    icon: Icons.label,
    color: Colors.yellow,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
];

List<Widget> buildAdditionalSwipeActionLeft(double swipeOffset) => [
  SwipeButton(
    icon: Icons.folder,
    color: Colors.teal,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
  SwipeButton(
    icon: Icons.download,
    color: Colors.indigo,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
  SwipeButton(
    icon: Icons.copy,
    color: Colors.pink,
    scale: swipeOffset / 300,
    visible: swipeOffset >= 0,
  ),
];

List<Widget> buildSwipeActionRight(double swipeOffset, VoidCallback onSwipeButtonPressed) => [
  SwipeButton(
    icon: Icons.delete,
    color: Colors.red,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
    onPressed: onSwipeButtonPressed,
  ),
  SwipeButton(
    icon: Icons.edit,
    color: Colors.orange,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
  ),
  SwipeButton(
    icon: Icons.sunny,
    color: Colors.purple,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
  ),
];

List<Widget> buildAdditionalSwipeActionRight(double swipeOffset) => [
  SwipeButton(
    icon: Icons.save,
    color: Colors.brown,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
  ),
  SwipeButton(
    icon: Icons.email,
    color: Colors.cyan,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
  ),
  SwipeButton(
    icon: Icons.print,
    color: Colors.lime,
    scale: -swipeOffset / 300,
    visible: swipeOffset <= 0,
  ),
];
