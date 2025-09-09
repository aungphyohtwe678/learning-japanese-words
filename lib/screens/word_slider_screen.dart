import 'package:flutter/material.dart';
import '../models/japanese_word.dart';
import '../services/excel_service.dart';
import '../services/tts_service.dart';

class WordSliderScreen extends StatefulWidget {
  const WordSliderScreen({super.key});

  @override
  State<WordSliderScreen> createState() => _WordSliderScreenState();
}

class _WordSliderScreenState extends State<WordSliderScreen> {
  List<JapaneseWord> words = [];
  int currentIndex = 0;
  bool isLoading = true;
  String? errorMessage;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadWords();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await TTSService.initialize();
  }

  Future<void> _loadWords() async {
    try {
      final loadedWords = await ExcelService.loadJapaneseWords();
      setState(() {
        words = loadedWords;
        isLoading = false;
        if (words.isEmpty) {
          errorMessage = 'No words found in the Excel file';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading words: $e';
      });
    }
  }

  void _nextWord() {
    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
      });
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousWord() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _firstWord() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex = 0;
      });
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _lastWord() {
    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex = words.length - 1;
      });
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _speakKanji() async {
    final word = words[currentIndex];
    await TTSService.speakJapanese(word.secondColumn);
  }

  Future<void> _speakEnglish() async {
    final word = words[currentIndex];
    await TTSService.speakEnglish(word.thirdColumn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    TTSService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Japanese Vocabulary N1'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _loadWords();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            '${currentIndex + 1} / ${words.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: words.isNotEmpty
                                  ? (currentIndex + 1) / words.length
                                  : 0,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Word display area
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        itemCount: words.length,
                        itemBuilder: (context, index) {
                          final word = words[index];
                          return Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Second column (漢字 - Kanji) displayed first with big text
                                GestureDetector(
                                  onTap: _speakKanji,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            word.secondColumn,
                                            style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.volume_up,
                                          size: 32,
                                          color: Colors.blue[600],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // First column (ひらがな - Hiragana) displayed second
                                if (word.firstColumn.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      word.firstColumn,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.blue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                // Third column with TTS
                                if (word.thirdColumn.isNotEmpty)
                                  GestureDetector(
                                    onTap: _speakEnglish,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              word.thirdColumn,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.green,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Icon(
                                            Icons.volume_up,
                                            size: 20,
                                            color: Colors.green[700],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // Fourth column
                                if (word.fourthColumn.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      word.fourthColumn,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.orange,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Navigation buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // First button
                          ElevatedButton.icon(
                            onPressed: currentIndex > 0 ? _firstWord : null,
                            icon: const Icon(Icons.first_page),
                            label: const Text('First'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          // Previous button
                          ElevatedButton.icon(
                            onPressed: currentIndex > 0 ? _previousWord : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          // Next button
                          ElevatedButton.icon(
                            onPressed:
                                currentIndex < words.length - 1 ? _nextWord : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          // Last button
                          ElevatedButton.icon(
                            onPressed: currentIndex < words.length - 1 ? _lastWord : null,
                            icon: const Icon(Icons.last_page),
                            label: const Text('Last'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
