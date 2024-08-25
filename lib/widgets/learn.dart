import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SwipeableEditableTextWidget extends StatefulWidget {
  final Map<String, dynamic> verse;
  final Size size;
  final int pageCount;
  final List<double> hiddenWordPercentages;

  const SwipeableEditableTextWidget({
    Key? key,
    required this.verse,
    required this.size,
    this.pageCount = 3,
    required this.hiddenWordPercentages,
  }) : assert(hiddenWordPercentages.length == pageCount),
        super(key: key);

  @override
  _SwipeableEditableTextWidgetState createState() =>
      _SwipeableEditableTextWidgetState();
}

class _SwipeableEditableTextWidgetState
    extends State<SwipeableEditableTextWidget> {
  final PageController _pageController = PageController();
  late List<TextEditingController> _textControllers;
  late List<List<Color>> _textColors;
  late List<List<String>> _displayTexts;
  late List<List<bool>> _hiddenWords;
  String _defaultText = '';
  late List<int> _blinkIndices;
  late Timer _timer;
  bool _blinkVisible = true;

  @override
  void initState() {
    super.initState();
    _defaultText = '${widget.verse['verse']}. ${widget.verse['text']}';

    _textControllers = List.generate(widget.pageCount, (_) => TextEditingController());
    _textColors = List.generate(
      widget.pageCount,
          (_) => List.generate(_defaultText.length, (_) => Colors.white),
    );
    _displayTexts = List.generate(
      widget.pageCount,
          (_) => List.generate(_defaultText.length, (i) => _defaultText[i]),
    );
    _blinkIndices = List.generate(widget.pageCount, (_) => 0);

    _hiddenWords = List.generate(
      widget.pageCount,
          (index) => _getHiddenWordsList(_defaultText, widget.hiddenWordPercentages[index]),
    );

    _applyHiddenWords();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _blinkVisible = !_blinkVisible;
      });
    });
  }

  List<bool> _getHiddenWordsList(String text, double percentage) {
    final words = text.split(' ');
    final hiddenCount = (words.length * percentage).round();
    final hiddenWords = List<bool>.filled(words.length, false);
    final random = Random();

    for (int i = 0; i < hiddenCount; i++) {
      int index;
      do {
        index = random.nextInt(words.length);
      } while (hiddenWords[index]);
      hiddenWords[index] = true;
    }

    final hiddenList = <bool>[];
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      hiddenList.addAll(List<bool>.filled(word.length, hiddenWords[i]));
      if (i < words.length - 1) {
        hiddenList.add(false); // space between words
      }
    }

    return hiddenList;
  }

  void _applyHiddenWords() {
    for (int pageIndex = 0; pageIndex < widget.pageCount; pageIndex++) {
      for (int i = 0; i < _defaultText.length; i++) {
        if (_hiddenWords[pageIndex][i]) {
          _displayTexts[pageIndex][i] = _defaultText[i];
          _textColors[pageIndex][i] = Colors.black;
        }
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String inputText, int index) {
    setState(() {
      _textColors[index] = List.generate(
        _defaultText.length,
            (i) {
          if (i < inputText.length) {
            if (inputText[i] == _defaultText[i]) {
              _displayTexts[index][i] = _defaultText[i];
              return Colors.green;
            } else {
              _displayTexts[index][i] = inputText[i];
              return Colors.red;
            }
          } else if (_hiddenWords[index][i]) {
            _displayTexts[index][i] = _defaultText[i];
            return Colors.black;
          } else {
            _displayTexts[index][i] = _defaultText[i];
            return Colors.white;
          }
        },
      );

      _blinkIndices[index] = inputText.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: widget.size.width,
          height: widget.size.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.pageCount,
            itemBuilder: (context, index) {
              return Container(
                decoration: const BoxDecoration(color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: List.generate(
                            _defaultText.length,
                                (i) => TextSpan(
                              text: _displayTexts[index][i],
                              style: TextStyle(
                                color: i == _blinkIndices[index] && _blinkVisible && !_hiddenWords[index][i]
                                    ? Colors.grey
                                    : _textColors[index][i],
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: TextField(
                          controller: _textControllers[index],
                          style: const TextStyle(
                            color: Colors.transparent,
                            fontSize: 18,
                            height: 1.2,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          maxLines: null,
                          maxLength: _defaultText.length,
                          cursorColor: Colors.transparent,
                          onChanged: (text) => _onTextChanged(text, index),
                          showCursor: false,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.pageCount,
                effect: const WormEffect(
                  dotColor: Colors.grey,
                  activeDotColor: Colors.white,
                  radius: 8,
                  dotWidth: 8,
                  dotHeight: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}