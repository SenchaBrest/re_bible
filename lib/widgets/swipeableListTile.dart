import 'package:flutter/material.dart';
import '../touch.dart';
import 'swipe_buttons.dart';
import '../active.dart';
import 'learn.dart';

enum Direction {
  toRightForwardDirection,
  toRightBackwardDirection,
  toLeftForwardDirection,
  toLeftBackwardDirection,
  neitherDirection
}

class SwipeableListTile extends StatefulWidget {
  final Map<String, dynamic> verse;
  final int index;
  final bool active;

  const SwipeableListTile({required this.verse, super.key, required this.index, required this.active});

  @override
  _SwipeableListTileState createState() => _SwipeableListTileState();
}

class _SwipeableListTileState extends State<SwipeableListTile> with SingleTickerProviderStateMixin {
  Direction direction = Direction.neitherDirection;
  double _swipeOffset = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAdditionalButtonsVisible = false;
  final GlobalKey _tileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
  }

  void _animateToEnd(double endValue) {
    _animation = Tween<double>(begin: _swipeOffset, end: endValue).animate(_controller)
      ..addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _swipeOffset = _animation.value;
            });
          }
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
      // _isAdditionalButtonsVisible = !_isAdditionalButtonsVisible;
      _animateToEnd(0.0);
      i.add(widget.index);
    });
  }

  Offset _getElementPosition() {
    final RenderBox renderBox = _tileKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    return position;
  }

  Size _getElementSize() {
    final RenderBox renderBox = _tileKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    return size;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return SwipeableEditableTextWidget(
          key: _tileKey,
          verse: widget.verse,
          size: _getElementSize(),
          pageCount: 6,
          hiddenWordPercentages: [0, 0.20, 0.40, 0.60, 0.80, 1.00],
      );
    }
    if (i.isNotEmpty) {
      return Container(
          key: _tileKey,
          decoration: const BoxDecoration(color: Colors.black),
          child: ListTile(
            title: Text(
                '${widget.verse['verse']}. ${widget.verse['text']}',
                style: TextStyle(color: Colors.grey[900]),
            ),
            textColor: Colors.white,
          )
      );
    }

    final notifier = TouchNotifier.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      if (notifier?.touchEvent != null && _swipeOffset != 0) {
        final touchEvent = notifier!.touchEvent!;
        final touchPosition = touchEvent.localPosition;
        final listTilePosition = _getElementPosition();
        final listTileSize = _getElementSize();
        print(listTileSize);

        if (!(touchPosition.dy <= listTileSize.height + listTilePosition.dy &&
            touchPosition.dy >= listTilePosition.dy)) {
          _animateToEnd(0.0);
        }
      }

      return GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            if (direction != Direction.neitherDirection) {
              if (_swipeOffset.abs() < 350.0) {
                _swipeOffset += details.delta.dx;
                if ((direction == Direction.toLeftForwardDirection ||
                    direction == Direction.toRightBackwardDirection) &&
                    _swipeOffset > 0) {
                  _swipeOffset = 0;
                } else if ((direction == Direction.toRightForwardDirection ||
                    direction == Direction.toLeftBackwardDirection) &&
                    _swipeOffset < 0) {
                  _swipeOffset = 0;
                }
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
          final velocity = details.velocity.pixelsPerSecond.dx;
          if (direction == Direction.toLeftForwardDirection) {
            if (velocity <= 0) {
              _animateToEnd(-300.0);
            } else {
              _animateToEnd(0.0);
            }
          } else if (direction == Direction.toLeftBackwardDirection) {
            if (velocity >= 0) {
              _animateToEnd(300.0);
            } else {
              _animateToEnd(0.0);
            }
          } else if (direction == Direction.toRightForwardDirection) {
            if (velocity >= 0) {
              _animateToEnd(300.0);
            }
            else {
              _animateToEnd(0.0);
            }
          } else if (direction == Direction.toRightBackwardDirection) {
            if (velocity <= 0) {
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
                          ? buildAdditionalSwipeActionLeft(_swipeOffset)
                          : buildSwipeActionLeft(_swipeOffset, _onSwipeButtonPressed)),
                    if (_swipeOffset < 0)
                      ...(_isAdditionalButtonsVisible
                          ? buildAdditionalSwipeActionRight(_swipeOffset)
                          : buildSwipeActionRight(_swipeOffset, _onSwipeButtonPressed)),
                  ],
                ),
              ),
            Transform.translate(
              offset: Offset(_swipeOffset, 0),
              child: Container(
                key: _tileKey,
                decoration: const BoxDecoration(color: Colors.black),
                child: ListTile(
                  title: Text(
                    '${widget.verse['verse']}. ${widget.verse['text']}',
                    textAlign: TextAlign.justify,
                  ),
                  textColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
