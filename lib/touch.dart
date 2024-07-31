import 'package:flutter/cupertino.dart';

class TouchNotifier extends InheritedWidget {
  final PointerDownEvent? touchEvent;

  TouchNotifier({required this.touchEvent, required Widget child}) : super(child: child);

  static TouchNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TouchNotifier>();
  }

  @override
  bool updateShouldNotify(TouchNotifier oldWidget) {
    return oldWidget.touchEvent != touchEvent;
  }
}

