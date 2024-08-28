import 'package:flutter/material.dart';
import 'package:re_bible/touch.dart';
import 'db_helper.dart';
import 'widgets/swipeableListTile.dart';
import 'verse_selection.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'active.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BibleApp(),
    );
  }
}

class BibleApp extends StatefulWidget {
  const BibleApp({super.key});

  @override
  _BibleAppState createState() => _BibleAppState();
}

class _BibleAppState extends State<BibleApp> {
  List<Map<String, dynamic>>? verses;
  late Map<String, dynamic> book;
  int currentBookNumber = 10; // Default to the first book (Genesis)
  int startingVerseIndex = 0; // Default to the beginning of the chapter
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();
  String _currentVerseLabel = 'Выберите стих'; // Label for the current verse
  PointerDownEvent? _touchEvent;
  bool _isScrollLocked = false; // Flag to control scrollability

  @override
  void initState() {
    super.initState();
    _loadVerses(currentBookNumber);

    _positionsListener.itemPositions.addListener(() {
      final visibleItems = _positionsListener.itemPositions.value;
      if (visibleItems.isNotEmpty) {
        final firstVisibleItem = visibleItems.first;
        final firstVisibleIndex = firstVisibleItem.index;
        if (verses != null && firstVisibleIndex < verses!.length) {
          final verse = verses![firstVisibleIndex];
          _updateCurrentVerseLabel(verse['chapter'], verse['verse']);
        }
      }
    });
  }

  Future<void> _loadVerses(int bookNumber, [int? chapter, int? verse]) async {
    final data = await BibleDatabase.instance.getVersesForBook(bookNumber);
    final bookData = (await BibleDatabase.instance.getBookByNumber(bookNumber))[0];

    setState(() {
      book = bookData;
      verses = data;
      startingVerseIndex = 0;

      if (chapter != null && verse != null) {
        startingVerseIndex = data.indexWhere((v) => v['chapter'] == chapter && v['verse'] == verse);
        if (startingVerseIndex == -1) {
          startingVerseIndex = 0;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.isAttached) {
        _scrollController.scrollTo(
          index: startingVerseIndex,
          duration: const Duration(milliseconds: 330),
        );
      }
    });
  }

  void _updateCurrentVerseLabel(int chapter, int verse) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentVerseLabel = (chapter == 1 && verse == 1)
              ? '${book['long_name']} $chapter:$verse'
              : '${book['short_name']}. $chapter:$verse';

        });
      }
    });
  }

  void _onSelectVerse(int bookNumber, int? chapter, int? verse) {
    _loadVerses(bookNumber, chapter, verse);
  }

  void _unlockScrolling() {
    setState(() {
      _isScrollLocked = false;
      i.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final verseSelection = VerseSelection(
      context: context,
      onSelect: _onSelectVerse,
    );

    if (i.isNotEmpty) {
      _scrollController.scrollTo(
        index: i.first,
        duration: const Duration(milliseconds: 330),
      );
      _isScrollLocked = true; // Lock scrolling after initial scroll
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        setState(() {
          _touchEvent = event;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _touchEvent = null;
          });
        });
      },
      child: TouchNotifier(
        touchEvent: _touchEvent,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: GestureDetector(
              onTap: verseSelection.showBooks,
              child: !_isScrollLocked
                  ? Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _currentVerseLabel,
                  style: TextStyle(color: Colors.grey[300]),
                ),
              )
                  : Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 25.0, // Adjust icon size as needed
                  icon: Icon(Icons.close, color: Colors.grey[300]),
                  onPressed: _unlockScrolling,
                ),
              ),
            ),
            backgroundColor: Colors.black,
          ),

          backgroundColor: Colors.black,
          body: verses == null
              ? const Center(child: CircularProgressIndicator())
              : ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _positionsListener,
            physics: _isScrollLocked ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
            itemCount: verses!.length,
            itemBuilder: (context, index) {
              final verse = verses![index];
              final isFirstInChapter = index == 0 || verses![index - 1]['chapter'] != verse['chapter'];

              return Column(
                children: [
                  if (isFirstInChapter)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Глава ${verse['chapter']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: i.contains(index) ? Colors.grey[900]: Colors.white,
                        ),
                      ),
                    ),
                  SwipeableListTile(
                    verse: verse,
                    index: index,
                    active: !i.contains(index),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}