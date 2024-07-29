import 'package:flutter/material.dart';
import 'db_helper.dart';

class VerseSelection {
  final BuildContext context;
  final Function(int, int?, int?) onSelect;

  VerseSelection({required this.context, required this.onSelect});

  void showBooks() async {
    final books = await BibleDatabase.instance.getBooks();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            childAspectRatio: 3, // Aspect ratio of the grid items
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showChapters(book['book_number']);
              },
              child: Card(
                child: Center(
                  child: Text(book['long_name']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showChapters(int bookNumber) async {
    final chapters = await BibleDatabase.instance.getChapters(bookNumber);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Adjust based on your preference
            childAspectRatio: 2,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showVerses(bookNumber, chapter['chapter']);
              },
              child: Card(
                child: Center(
                  child: Text('Chapter ${chapter['chapter']}'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showVerses(int bookNumber, int chapter) async {
    final verses = await BibleDatabase.instance.getVersesForBook(bookNumber);
    final chapterVerses = verses.where((verse) => verse['chapter'] == chapter).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Adjust based on your preference
            childAspectRatio: 2,
          ),
          itemCount: chapterVerses.length,
          itemBuilder: (context, index) {
            final verse = chapterVerses[index];
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onSelect(bookNumber, chapter, verse['verse']);
              },
              child: Card(
                child: Center(
                  child: Text('Verse ${verse['verse']}'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
