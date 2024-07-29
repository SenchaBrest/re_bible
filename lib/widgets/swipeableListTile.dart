import 'package:flutter/material.dart';

enum Direction {
  toRightForwardDirection,
  toRightBackwardDirection,
  toLeftForwardDirection,
  toLeftBackwardDirection,
  neitherDirection
}

class SwipeableListTile extends StatefulWidget {
  final Map<String, dynamic> verse;

  SwipeableListTile({required this.verse});

  @override
  _SwipeableListTileState createState() => _SwipeableListTileState();
}

class _SwipeableListTileState extends State<SwipeableListTile> with SingleTickerProviderStateMixin {
  Direction direction = Direction.neitherDirection;
  double _swipeOffset = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAdditionalButtonsVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
  }

  void _animateToEnd(double endValue) {
    _animation = Tween<double>(begin: _swipeOffset, end: endValue).animate(_controller)
      ..addListener(() {
        setState(() {
          _swipeOffset = _animation.value;
        });
      });
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipeButtonPressed() {
    setState(() {
      _isAdditionalButtonsVisible = !_isAdditionalButtonsVisible;
      // _animateToEnd(0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          if (direction != Direction.neitherDirection) {
            _swipeOffset += details.delta.dx;

            if (direction == Direction.toLeftForwardDirection &&
                _swipeOffset > 0) {
              _swipeOffset = 0;
            } else if (direction == Direction.toRightForwardDirection &&
                _swipeOffset < 0) {
              _swipeOffset = 0;
            }
          }
        });
      },
      onHorizontalDragStart: (details) {
        final pos = details.localPosition.dx;
        final width = context.size!.width;

        if (pos > width * 5 / 6 && _swipeOffset == 0) {
          direction = Direction.toLeftForwardDirection;
        } else if (pos < width / 6 && _swipeOffset == 0) {
          direction = Direction.toRightForwardDirection;
        } else if (_swipeOffset < 0) {
          direction = Direction.toRightBackwardDirection;
        } else if (_swipeOffset > 0) {
          direction = Direction.toLeftBackwardDirection;
        }
      },
      onHorizontalDragEnd: (details) {
        final pos = details.localPosition.dx;
        final width = context.size!.width;

        if (direction == Direction.toLeftForwardDirection) {
          if (_swipeOffset < 0) {
            _animateToEnd(-300.0);
          }
        } else if (direction == Direction.toLeftBackwardDirection) {
          if (pos > width * 5 / 6 && pos < width * 5.9 / 6) {
            _animateToEnd(300.0);
          } else {
            _animateToEnd(0.0);
          }
        } else if (direction == Direction.toRightForwardDirection) {
          if (_swipeOffset > 0) {
            _animateToEnd(300.0);
          }
        } else if (direction == Direction.toRightBackwardDirection) {
          if (pos < width * 1 / 6 && pos > width * 0.1 / 6) {
            _animateToEnd(-300.0);
          } else {
            _animateToEnd(0.0);
          }
        }
        direction = Direction.neitherDirection;
      },
      onTap: () {
        if (_swipeOffset != 0) {
          _animateToEnd(0.0);
        }
      },

      child: Stack(
        children: [
          if (_swipeOffset != 0)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: _swipeOffset > 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  if (_swipeOffset > 0)
                    ...(_isAdditionalButtonsVisible
                        ? buildAdditionalSwipeActionLeft()
                        : buildSwipeActionLeft()),
                  if (_swipeOffset < 0)
                    ...(_isAdditionalButtonsVisible
                        ? buildAdditionalSwipeActionRight()
                        : buildSwipeActionRight()),
                ],
              ),
            ),
          Transform.translate(
            offset: Offset(_swipeOffset, 0),
            child: Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: ListTile(
                title: Text('${widget.verse['verse']}. ${widget.verse['text']}'),
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildSwipeActionLeft() => [
    SwipeButton(
      icon: Icons.archive,
      color: Colors.blue,
      scale: _swipeOffset / 300,
      visible: _swipeOffset >= 0,
      onPressed: _onSwipeButtonPressed,
    ),
    SwipeButton(
      icon: Icons.share,
      color: Colors.green,
      scale: _swipeOffset / 300,
      visible: _swipeOffset >= 0,
    ),
    SwipeButton(
      icon: Icons.label,
      color: Colors.yellow,
      scale: _swipeOffset / 300,
      visible: _swipeOffset >= 0,
    ),
  ];

  List<Widget> buildAdditionalSwipeActionLeft() => [
    SwipeButton(
      icon: Icons.folder,
      color: Colors.teal,
      scale: _swipeOffset / 300,
      visible: _swipeOffset >= 0,
    ),
    SwipeButton(
      icon: Icons.download,
      color: Colors.indigo,
      scale: _swipeOffset / 300,
      visible: _swipeOffset >= 0,
    ),
    SwipeButton(
      icon: Icons.copy,
      color: Colors.pink,
      scale: _swipeOffset / 300,
      visible: _swipeOffset >= 0,
    ),
  ];

  List<Widget> buildSwipeActionRight() => [
    SwipeButton(
      icon: Icons.delete,
      color: Colors.red,
      scale: -_swipeOffset / 300,
      visible: _swipeOffset <= 0,
      onPressed: _onSwipeButtonPressed,
    ),
    SwipeButton(
      icon: Icons.edit,
      color: Colors.orange,
      scale: -_swipeOffset / 300,
      visible: _swipeOffset <= 0,
    ),
    SwipeButton(
      icon: Icons.sunny,
      color: Colors.purple,
      scale: -_swipeOffset / 300,
      visible: _swipeOffset <= 0,
    ),
  ];

  List<Widget> buildAdditionalSwipeActionRight() => [
    SwipeButton(
      icon: Icons.save,
      color: Colors.brown,
      scale: -_swipeOffset / 300,
      visible: _swipeOffset <= 0,
    ),
    SwipeButton(
      icon: Icons.email,
      color: Colors.cyan,
      scale: -_swipeOffset / 300,
      visible: _swipeOffset <= 0,
    ),
    SwipeButton(
      icon: Icons.print,
      color: Colors.lime,
      scale: -_swipeOffset / 300,
      visible: _swipeOffset <= 0,
    ),
  ];
}

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
