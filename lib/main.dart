import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'widgets/swipeableListTile.dart';
import 'verse_selection.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BibleApp(),
    );
  }
}

class BibleApp extends StatefulWidget {
  @override
  _BibleAppState createState() => _BibleAppState();
}

class _BibleAppState extends State<BibleApp> {


  List<Map<String, dynamic>>? verses;
  var books;
  int currentBookNumber = 10; // Default to the first book (Genesis)
  int startingVerseIndex = 0; // Default to the beginning of the chapter
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();

  String _currentVerseLabel = 'Выберите стих'; // Label for the current verse

  @override
  void initState() {
    super.initState();
    _loadVerses(currentBookNumber);
    _loadBooks();

    _positionsListener.itemPositions.addListener(() {
      final visibleItems = _positionsListener.itemPositions.value;
      if (visibleItems.isNotEmpty) {
        final firstVisibleItem = visibleItems.first;
        final firstVisibleIndex = firstVisibleItem.index;
        if (verses != null && firstVisibleIndex < verses!.length) {
          final verse = verses![firstVisibleIndex];
          _updateCurrentVerseLabel(currentBookNumber, verse['chapter'], verse['verse']);
        }
      }
    });
  }

  Future<void> _loadBooks() async {
    // books = await BibleDatabase.instance.getBooks();
    print(books);
  }


  Future<void> _loadVerses(int bookNumber, [int? chapter, int? verse]) async {
    final data = await BibleDatabase.instance.getVersesForBook(bookNumber);
    setState(() {
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
          duration: const Duration(milliseconds: 4500),
        );
      }
    });
  }

  void _updateCurrentVerseLabel(int bookNumber, int chapter, int verse) {
    setState(() {
      // print(books[currentBookNumber]);

      // _currentVerseLabel = '${books[currentBookNumber]['short_name']}, Глава $chapter, Стих $verse';
      _currentVerseLabel = 'Глава $chapter, Стих $verse';

    });
  }

  void _onSelectVerse(int bookNumber, int? chapter, int? verse) {
    _loadVerses(bookNumber, chapter, verse);
  }

  @override
  Widget build(BuildContext context) {
    final verseSelection = VerseSelection(
      context: context,
      onSelect: _onSelectVerse,
    );

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: verseSelection.showBooks,
          child: Text(
            _currentVerseLabel,
            style: TextStyle(
              // decoration: TextDecoration.underline,
              color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              SwipeableListTile(
                verse: verse,
              ),
            ],
          );
        },
      ),
    );
  }
}
