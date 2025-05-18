import 'dart:async';
import 'dart:convert';
import 'package:auth_service/ui/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fuzzy/fuzzy.dart';

class SmartReplyBotScreen extends StatefulWidget {
  const SmartReplyBotScreen({super.key});

  @override
  SmartReplyBotScreenState createState() => SmartReplyBotScreenState();
}

class SmartReplyBotScreenState extends State<SmartReplyBotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final SmartReply _smartReply = SmartReply();
  final ScrollController _scrollController = ScrollController();
  List<String> _smartReplies = [];
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _visibleMessages = [];
  final Map<String, List<Map<String, dynamic>>> _bookCache = {};
  List<Map<String, dynamic>> _booksDatabase = [];
  bool _isDarkMode = false;
  bool _isBotTyping = false;
  bool _isFetchingBooks = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Timer? _debounceTimer;
  final int _messageBatchSize = 20;
  final Set<int> _newMessageIndices = {};

  List<String> _keywordDictionary = [
    'book',
    'books',
    'novel',
    'author',
    'genre',
    'horror',
    'romance',
    'sci-fi',
    'science fiction',
    'setting',
    'settings',
    'notification',
    'profile',
    'theme',
    'thanks',
    'thank you',
    'sorry',
    'hey',
    'hi',
    'hello',
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scrollController.addListener(_loadMoreMessages);
    _fetchBooks().then((_) {
      setState(() {
        _booksDatabase.forEach((book) {
          _keywordDictionary.add(book['title']!.toLowerCase());
          _keywordDictionary.add(book['author']!.toLowerCase());
        });
        _keywordDictionary = _keywordDictionary.toSet().toList();
      });
    });
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _smartReply.addMessageToConversationFromRemoteUser(
      "Welcome! Ask about books or app settings.",
      timestamp - 2000,
      "library_bot",
    );
    setState(() {
      _messages.add({
        'text': "Welcome! Ask about books or app settings.",
        'isLocalUser': false,
        'timestamp': timestamp - 2000,
      });
      _visibleMessages = _messages.take(_messageBatchSize).toList();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _smartReply.close();
    _scrollController.removeListener(_loadMoreMessages);
    _scrollController.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    if (_isListening) {
      _speech.stop();
    }
    _speech.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _loadMoreMessages() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      setState(() {
        int currentLength = _visibleMessages.length;
        _visibleMessages.insertAll(
          0,
          _messages.skip(currentLength).take(_messageBatchSize).toList(),
        );
      });
    }
  }

  Future<void> _fetchBooks({String query = 'fiction'}) async {
    setState(() => _isFetchingBooks = true);
    if (_bookCache.containsKey(query)) {
      setState(() {
        _booksDatabase = _bookCache[query]!;
        _isFetchingBooks = false;
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org/search.json?q=$query&limit=20'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['docs'] is List) {
          final List<dynamic> docs = data['docs'];
          final books = docs.map((doc) {
            return {
              'title': doc['title']?.toString() ?? 'Unknown Title',
              'author': (doc['author_name'] as List<dynamic>?)
                      ?.join(', ')
                      .toString() ??
                  'Unknown Author',
              'genre':
                  (doc['subject'] as List<dynamic>?)?.join(', ').toString() ??
                      'Fiction',
              'year': doc['first_publish_year']?.toString() ?? 'Unknown Year',
            };
          }).toList();
          setState(() {
            _booksDatabase = books;
            _bookCache[query] = books;
            _isFetchingBooks = false;
          });
        } else {
          _handleApiError('Invalid API response format.');
        }
      } else {
        _handleApiError('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      _handleApiError('Exception during API call: $e');
    }
  }

  void _handleApiError(String errorDetail) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _messages.add({
        'text': 'Error fetching books: $errorDetail. Try again later.',
        'isLocalUser': false,
        'timestamp': timestamp,
      });
      _visibleMessages.add(_messages.last);
      _newMessageIndices.add(_messages.length - 1);
      _isFetchingBooks = false;
      _scrollToBottom();
    });
    _smartReply.addMessageToConversationFromRemoteUser(
      'Error fetching books: $errorDetail. Try again later.',
      timestamp,
      "library_bot",
    );
  }

  String _correctSpelling(String input) {
    final fuzzy = Fuzzy(_keywordDictionary);
    final result = fuzzy.search(input, 3);
    print(
        'Input: $input, Matches: ${result.map((r) => "${r.item} (score: ${r.score})").toList()}');
    if (result.isNotEmpty && result.first.score > 0.6) {
      return result.first.item;
    }
    for (var keyword in _keywordDictionary) {
      if (keyword.startsWith(input)) {
        return keyword;
      }
    }
    return input;
  }

  void _startNewChat() {
    _smartReply.close();

    setState(() {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _messages = [
        {
          'text': "Welcome! Ask about books or app settings.",
          'isLocalUser': false,
          'timestamp': timestamp,
        }
      ];
      _visibleMessages = _messages.take(_messageBatchSize).toList();

      _newMessageIndices.clear();
      _newMessageIndices.add(0);

      _smartReplies = [];
      _messageController.clear();

      _isBotTyping = false;
      _isFetchingBooks = false;
    });

    _smartReply.addMessageToConversationFromRemoteUser(
      "Welcome! Ask about books or app settings.",
      DateTime.now().millisecondsSinceEpoch,
      "library_bot",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  List<String> _generateCustomSuggestions(String input) {
    final lowerInput = _correctSpelling(input.toLowerCase());
    print('Corrected Input for Suggestions: $lowerInput');

    final bool hasRecentBookQuery = _messages.isNotEmpty &&
        _messages
            .where((m) =>
                !m['isLocalUser'] &&
                (m['text'].toString().contains('book') ||
                    m['text'].toString().contains('author') ||
                    m['text'].toString().contains('genre')))
            .isNotEmpty;

    final bool hasRecentSettingsQuery = _messages.isNotEmpty &&
        _messages
            .where((m) =>
                !m['isLocalUser'] &&
                (m['text'].toString().contains('theme') ||
                    m['text'].toString().contains('profile') ||
                    m['text'].toString().contains('notification')))
            .isNotEmpty;

    List<String> suggestions = [];

    if (_messages.isNotEmpty && _messages.last['isLocalUser'] == false) {
      String lastBotMessage = _messages.last['text'].toString().toLowerCase();

      if (lastBotMessage.contains('stephen king')) {
        suggestions.add('More by Stephen King');
      } else if (lastBotMessage.contains('jane austen')) {
        suggestions.add('More by Jane Austen');
      } else if (lastBotMessage.contains('isaac asimov')) {
        suggestions.add('More by Isaac Asimov');
      }

      if (lastBotMessage.contains('horror')) {
        suggestions.add('More horror books');
      } else if (lastBotMessage.contains('romance')) {
        suggestions.add('More romance books');
      } else if (lastBotMessage.contains('sci-fi') ||
          lastBotMessage.contains('science fiction')) {
        suggestions.add('More sci-fi books');
      }

      if (lastBotMessage.contains('theme') ||
          lastBotMessage.contains('notification') ||
          lastBotMessage.contains('profile')) {
        suggestions.add('Toggle theme');
      }

      if (lastBotMessage.contains('recommend')) {
        suggestions.add('Similar books');
        suggestions.add('Different genre');
      }
    }

    if (lowerInput.contains('thanks') || lowerInput.contains('thank you')) {
      suggestions.addAll([
        'More book recommendations',
        'Search for another book',
        'Check settings'
      ]);
    } else if (lowerInput.contains('sorry')) {
      suggestions
          .addAll(['Try another book', 'Different genre', 'Toggle theme']);
    } else if (lowerInput.contains('hey') ||
        lowerInput.contains('hi') ||
        lowerInput.contains('hello')) {
      suggestions.addAll(
          ['Search for a book', 'Book recommendations', 'Check settings']);
    } else if (lowerInput.contains('book') ||
        lowerInput.contains('novel') ||
        lowerInput.contains('genre') ||
        lowerInput.contains('read') ||
        lowerInput.isEmpty) {
      if (lowerInput.contains('fiction')) {
        suggestions.addAll([
          'Science fiction books',
          'Historical fiction books',
          'Contemporary fiction'
        ]);
      } else if (lowerInput.contains('non')) {
        suggestions
            .addAll(['Biography books', 'History books', 'Self-help books']);
      } else {
        suggestions.addAll([
          'Horror books',
          'Romance books',
          'Sci-fi books',
        ]);
      }

      if (_booksDatabase.isNotEmpty) {
        final authors = _booksDatabase.map((b) => b['author']).toSet().toList();
        if (authors.isNotEmpty && authors.length >= 2) {
          suggestions.add('Books by ${authors[0]}');
          suggestions.add('Books by ${authors[1]}');
        } else if (authors.isNotEmpty) {
          suggestions.add('Books by ${authors[0]}');
        }
      } else {
        suggestions.add('Books by Stephen King');
      }
    } else if (lowerInput.contains('author')) {
      suggestions.addAll([
        'Books by Stephen King',
        'Books by Jane Austen',
        'Books by Isaac Asimov',
      ]);

      if (lowerInput.contains('king')) {
        suggestions.add('More by Stephen King');
      } else if (lowerInput.contains('austen')) {
        suggestions.add('More by Jane Austen');
      } else if (lowerInput.contains('asimov')) {
        suggestions.add('More by Isaac Asimov');
      }

      if (hasRecentBookQuery) {
        if (_messages.last['text']
            .toString()
            .toLowerCase()
            .contains('horror')) {
          suggestions.add('Horror authors');
        } else if (_messages.last['text']
            .toString()
            .toLowerCase()
            .contains('romance')) {
          suggestions.add('Romance authors');
        } else if (_messages.last['text']
            .toString()
            .toLowerCase()
            .contains('sci-fi')) {
          suggestions.add('Sci-fi authors');
        }
      }
    } else if (lowerInput.contains('setting') ||
        lowerInput.contains('theme') ||
        lowerInput.contains('app') ||
        lowerInput.contains('interface')) {
      suggestions
          .addAll(['Toggle theme', 'Check notifications', 'View profile']);

      if (hasRecentBookQuery) {
        suggestions.add('Back to books');
      }
    } else {
      suggestions.addAll([
        'Search for a book',
        'Book recommendations',
      ]);

      if (lowerInput.isNotEmpty && lowerInput.length > 2) {
        final fuzzy = Fuzzy(_keywordDictionary);
        final results = fuzzy.search(lowerInput);
        if (results.isNotEmpty && results.first.score > 0.3) {
          suggestions.add('Did you mean "${results.first.item}"?');
        } else {
          suggestions.add('Did you mean "$lowerInput books"?');
        }
      }

      if (hasRecentBookQuery) {
        suggestions.add('More book options');
      } else if (hasRecentSettingsQuery) {
        suggestions.add('More settings');
      }
    }

    return suggestions.toSet().take(4).toList();
  }

  Map<String, dynamic> _generateCustomResponse(String message) {
    String lowerMessage = message.toLowerCase();
    String correctedMessage = _correctSpelling(lowerMessage);
    print('Original: $message, Corrected: $correctedMessage');

    if (correctedMessage.contains('hey') ||
        correctedMessage.contains('hi') ||
        correctedMessage.contains('hello')) {
      return {
        'text':
            'Hello! How can I help you today with books or library settings?',
        'suggestions': _generateCustomSuggestions(correctedMessage),
      };
    }

    if (correctedMessage == 'more book recommendations') {
      return {
        'text':
            'Here are some popular books I recommend: "To Kill a Mockingbird" by Harper Lee, "1984" by George Orwell, and "The Great Gatsby" by F. Scott Fitzgerald.',
        'suggestions': ['Horror books', 'Romance books', 'Sci-fi books'],
      };
    }

    if (correctedMessage == 'check settings') {
      return {
        'text':
            'Settings: Theme is currently ${_isDarkMode ? 'Dark' : 'Light'}, notifications are enabled, and your profile is set to John Doe. What would you like to adjust?',
        'suggestions': ['Toggle theme', 'Check notifications', 'View profile'],
      };
    }

    if (correctedMessage == 'ask about authors') {
      return {
        'text':
            'I can help you find books by specific authors. Who are you interested in? For example, try asking about Stephen King, Jane Austen, or Isaac Asimov.',
        'suggestions': [
          'Books by Stephen King',
          'Books by Jane Austen',
          'Books by Isaac Asimov'
        ],
      };
    }

    if (correctedMessage == 'search for a book') {
      return {
        'text':
            'What kind of book are you looking for? You can specify a title, author, or genre.',
        'suggestions': ['Horror books', 'Romance books', 'Sci-fi books'],
      };
    }

    if (correctedMessage == 'ask for a genre') {
      return {
        'text': 'We have books in various genres. Which genre interests you?',
        'suggestions': ['Horror books', 'Romance books', 'Sci-fi books'],
      };
    }

    if (correctedMessage == 'any book recommendations?') {
      return {
        'text':
            'Based on popular reads, I recommend "The Silent Patient" by Alex Michaelides, "Where the Crawdads Sing" by Delia Owens, and "The Midnight Library" by Matt Haig.',
        'suggestions': ['Horror books', 'Romance books', 'Sci-fi books'],
      };
    }

    if (correctedMessage == 'horror books') {
      _fetchBooks(query: 'horror');
      return {
        'text': _booksDatabase.isNotEmpty
            ? "Horror books: ${_booksDatabase.take(3).map((b) => "'${b['title']}' by ${b['author']} (${b['year']})").join(', ')}."
            : "Searching for horror books... Some popular ones include 'The Shining' by Stephen King, 'Dracula' by Bram Stoker, and 'House of Leaves' by Mark Z. Danielewski.",
        'suggestions': [
          'Books by Stephen King',
          'More horror books',
          'Romance books'
        ],
      };
    }

    if (correctedMessage == 'romance books') {
      _fetchBooks(query: 'romance');
      return {
        'text': _booksDatabase.isNotEmpty
            ? "Romance books: ${_booksDatabase.take(3).map((b) => "'${b['title']}' by ${b['author']} (${b['year']})").join(', ')}."
            : "Searching for romance books... Some popular ones include 'Pride and Prejudice' by Jane Austen, 'Outlander' by Diana Gabaldon, and 'Me Before You' by Jojo Moyes.",
        'suggestions': [
          'Books by Jane Austen',
          'More romance books',
          'Sci-fi books'
        ],
      };
    }

    if (correctedMessage == 'sci-fi books') {
      _fetchBooks(query: 'science fiction');
      return {
        'text': _booksDatabase.isNotEmpty
            ? "Sci-fi books: ${_booksDatabase.take(3).map((b) => "'${b['title']}' by ${b['author']} (${b['year']})").join(', ')}."
            : "Searching for sci-fi books... Some popular ones include 'Dune' by Frank Herbert, 'Foundation' by Isaac Asimov, and 'The Hitchhiker's Guide to the Galaxy' by Douglas Adams.",
        'suggestions': [
          'Books by Isaac Asimov',
          'More sci-fi books',
          'Horror books'
        ],
      };
    }

    if (correctedMessage.startsWith('books by stephen king')) {
      _fetchBooks(query: 'author:stephen king');
      return {
        'text': _booksDatabase.isNotEmpty
            ? "Books by Stephen King: ${_booksDatabase.take(3).map((b) => "'${b['title']}' (${b['year']}, ${b['genre']})").join(', ')}."
            : "Searching for Stephen King books... Popular ones include 'The Shining', 'It', and 'The Stand'.",
        'suggestions': [
          'Horror books',
          'Books by Jane Austen',
          'More by Stephen King'
        ],
      };
    }

    if (correctedMessage.startsWith('books by jane austen')) {
      _fetchBooks(query: 'author:jane austen');
      return {
        'text': _booksDatabase.isNotEmpty
            ? "Books by Jane Austen: ${_booksDatabase.take(3).map((b) => "'${b['title']}' (${b['year']}, ${b['genre']})").join(', ')}."
            : "Searching for Jane Austen books... Popular ones include 'Pride and Prejudice', 'Emma', and 'Sense and Sensibility'.",
        'suggestions': [
          'Romance books',
          'Books by Stephen King',
          'More by Jane Austen'
        ],
      };
    }

    if (correctedMessage.startsWith('books by isaac asimov')) {
      _fetchBooks(query: 'author:isaac asimov');
      return {
        'text': _booksDatabase.isNotEmpty
            ? "Books by Isaac Asimov: ${_booksDatabase.take(3).map((b) => "'${b['title']}' (${b['year']}, ${b['genre']})").join(', ')}."
            : "Searching for Isaac Asimov books... Popular ones include 'Foundation', 'I, Robot', and 'The Gods Themselves'.",
        'suggestions': [
          'Sci-fi books',
          'Books by Stephen King',
          'More by Isaac Asimov'
        ],
      };
    }

    if (correctedMessage == 'toggle theme') {
      _toggleTheme();
      return {
        'text': 'Theme toggled to ${_isDarkMode ? 'Dark' : 'Light'} mode.',
        'suggestions': [
          'Check notifications',
          'View profile',
          'Search for a book'
        ],
      };
    }

    if (correctedMessage == 'check notifications') {
      return {
        'text':
            'Notifications are currently enabled. Would you like to change this setting?',
        'suggestions': ['Toggle theme', 'View profile', 'Search for a book'],
      };
    }

    if (correctedMessage == 'view profile') {
      return {
        'text':
            'Profile: John Doe. Email: john.doe@example.com. Preferences: Science Fiction, Mystery.',
        'suggestions': [
          'Toggle theme',
          'Check notifications',
          'Search for a book'
        ],
      };
    }

    if (correctedMessage.contains('try another book')) {
      return {
        'text':
            'Sure, I\'d be happy to suggest another book. What genre are you interested in?',
        'suggestions': ['Horror books', 'Romance books', 'Sci-fi books'],
      };
    }

    if (message.trim().split(' ').length < 2 &&
        !correctedMessage.contains('thanks') &&
        !correctedMessage.contains('sorry')) {
      return {
        'text':
            'I am not sure I understood. Did you mean "$correctedMessage"? Please clarify (e.g., a book title or genre).',
        'suggestions': _generateCustomSuggestions(correctedMessage),
      };
    }

    if (correctedMessage.contains('thanks') ||
        correctedMessage.contains('thank you')) {
      return {
        'text': 'You are very welcome! Anything else I can help with?',
        'suggestions': [
          'More book recommendations',
          'Check settings',
          'Ask about authors'
        ],
      };
    }

    if (correctedMessage.contains('sorry')) {
      return {
        'text': 'No worries at all! How can I assist you now?',
        'suggestions': ['Try another book', 'View profile', 'Toggle theme'],
      };
    }

    if (correctedMessage.contains('book') ||
        correctedMessage.contains('novel') ||
        correctedMessage.contains('author') ||
        correctedMessage.contains('genre') ||
        correctedMessage.contains('type') ||
        correctedMessage.contains('any') ||
        correctedMessage.contains('books')) {
      for (var book in _booksDatabase) {
        if (correctedMessage.contains(book['title']!.toLowerCase())) {
          return {
            'text':
                "Found '${book['title']}': Written by ${book['author']}, Genre: ${book['genre']}, Published: ${book['year']}.",
            'suggestions': [
              'More by ${book['author']}',
              'Similar books',
              'Try another book'
            ],
          };
        }
      }

      if (correctedMessage.contains('by')) {
        for (var book in _booksDatabase) {
          if (correctedMessage.contains(book['author']!.toLowerCase())) {
            return {
              'text':
                  "Books by ${book['author']}: '${book['title']}' (${book['year']}, ${book['genre']}).",
              'suggestions': [
                'More by ${book['author']}',
                'Similar genre books',
                'Search another author'
              ],
            };
          }
        }
      }

      if (correctedMessage.contains('genre') ||
          correctedMessage.contains('type') ||
          correctedMessage.contains('any') ||
          correctedMessage.contains('books')) {
        if (correctedMessage.contains('horror')) {
          _fetchBooks(query: 'horror');
          return {
            'text': _booksDatabase.isNotEmpty
                ? "Horror books: ${_booksDatabase.take(3).map((b) => "'${b['title']}' by ${b['author']} (${b['year']})").join(', ')}."
                : "Searching for horror books... Popular ones include 'The Shining', 'Dracula', and 'House of Leaves'.",
            'suggestions': [
              'Books by Stephen King',
              'More horror books',
              'Try another genre'
            ],
          };
        } else if (correctedMessage.contains('romance')) {
          _fetchBooks(query: 'romance');
          return {
            'text': _booksDatabase.isNotEmpty
                ? "Romance books: ${_booksDatabase.take(3).map((b) => "'${b['title']}' by ${b['author']} (${b['year']})").join(', ')}."
                : "Searching for romance books... Popular ones include 'Pride and Prejudice', 'Outlander', and 'Me Before You'.",
            'suggestions': [
              'Books by Jane Austen',
              'More romance books',
              'Try another genre'
            ],
          };
        } else if (correctedMessage.contains('science-fiction') ||
            correctedMessage.contains('sci-fi')) {
          _fetchBooks(query: 'science fiction');
          return {
            'text': _booksDatabase.isNotEmpty
                ? "Sci-fi books: ${_booksDatabase.take(3).map((b) => "'${b['title']}' by ${b['author']} (${b['year']})").join(', ')}."
                : "Searching for sci-fi books... Popular ones include 'Dune', 'Foundation', and 'The Hitchhiker's Guide to the Galaxy'.",
            'suggestions': [
              'Books by Isaac Asimov',
              'More sci-fi books',
              'Try another genre'
            ],
          };
        }
      }

      return {
        'text':
            'To help you find what you\'re looking for, please try a specific book title (like "Dune"), author (like "Stephen King"), or genre (like "horror books").',
        'suggestions': [
          'Horror books',
          'Romance books',
          'Sci-fi books',
          'Books by Stephen King'
        ],
      };
    }

    if (correctedMessage.contains('setting') ||
        correctedMessage.contains('notification') ||
        correctedMessage.contains('profile') ||
        correctedMessage.contains('theme')) {
      if (correctedMessage.contains('notification')) {
        return {
          'text':
              'Notifications are enabled. You will receive alerts for new book arrivals and due dates.',
          'suggestions': ['Toggle theme', 'View profile', 'Check settings'],
        };
      } else if (correctedMessage.contains('profile')) {
        return {
          'text':
              'Profile: John Doe. Email: john.doe@example.com. Preferences: Science Fiction, Mystery.',
          'suggestions': [
            'Toggle theme',
            'Check notifications',
            'Search for a book'
          ],
        };
      } else if (correctedMessage.contains('theme')) {
        return {
          'text':
              'Current theme: ${_isDarkMode ? 'Dark' : 'Light'}. Would you like to toggle it?',
          'suggestions': [
            'Toggle theme',
            'Check notifications',
            'View profile'
          ],
        };
      }
      return {
        'text':
            'App settings include: notifications, profile, and theme. What would you like to check or modify?',
        'suggestions': ['Toggle theme', 'Check notifications', 'View profile'],
      };
    }

    return {
      'text':
          'I\'m not sure I understood. Could you try asking about a specific book, author, genre, or app setting?',
      'suggestions': ['Search for a book', 'Ask for a genre', 'Check settings'],
    };
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _generateSmartReplies(text);
    });
  }

  void _generateSmartReplies(String text) async {
    List<String> suggestions = _generateCustomSuggestions(text);
    if (text.isNotEmpty) {
      _smartReply.addMessageToConversationFromLocalUser(
          text, DateTime.now().millisecondsSinceEpoch);
      final response = await _smartReply.suggestReplies();
      suggestions.addAll(response.suggestions);
    }
    setState(() {
      _smartReplies = suggestions.take(5).toList().toSet().toList();
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final messageText = _messageController.text;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      setState(() {
        _messages.add({
          'text': messageText,
          'isLocalUser': true,
          'timestamp': timestamp,
        });
        _visibleMessages.add(_messages.last);
        _newMessageIndices.add(_messages.length - 1);
        _scrollToBottom();
      });

      _animationController.forward(from: 0.0);

      setState(() {
        _isBotTyping = true;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      final response = _generateCustomResponse(messageText);
      setState(() {
        _messages.add({
          'text': response['text'],
          'isLocalUser': false,
          'timestamp': timestamp + 1000,
        });
        _visibleMessages.add(_messages.last);
        _newMessageIndices.add(_messages.length - 1);
        _isBotTyping = false;
        _smartReplies = response['suggestions'];
        _scrollToBottom();
      });

      _smartReply.addMessageToConversationFromLocalUser(messageText, timestamp);
      _smartReply.addMessageToConversationFromRemoteUser(
        response['text'],
        timestamp + 1000,
        "library_bot",
      );

      _messageController.clear();
    }
  }

  void _useSuggestion(String suggestion) {
    _messageController.text = suggestion;
    _sendMessage();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _animationController.forward(from: 0.0);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Speech recognition error: ${error.errorMsg}')),
          );
        },
        debugLogging: true,
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                _speech.stop();
                if (_messageController.text.isNotEmpty) {
                  _sendMessage();
                }
              }
            });
          },
          localeId: 'en_US',
        );
      } else {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Widget _buildSmartReplies() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _smartReplies.isEmpty ? 0 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _smartReplies
              .map((suggestion) => Semantics(
                    label: 'Suggestion: $suggestion',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ActionChip(
                        label: Text(
                          suggestion,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        backgroundColor: const Color(0xFFFF7643),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        onPressed: () => _useSuggestion(suggestion),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    if (_isFetchingBooks) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFFFF7643))),
            SizedBox(width: 10),
            Text('Fetching books...',
                style: TextStyle(color: Color(0xFFFF7643))),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Typing',
                  style: TextStyle(color: Color(0xFFFF7643), fontSize: 12),
                ),
                const SizedBox(width: 6),
                _buildDot(),
                _buildDot(delay: 200),
                _buildDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({int delay = 0}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFFFF7643),
        shape: BoxShape.circle,
      ),
      child: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: delay)),
        builder: (context, snapshot) {
          return Transform.translate(
            offset: Offset(0,
                snapshot.connectionState == ConnectionState.waiting ? 0 : -3),
            child: const SizedBox(),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isUser = message['isLocalUser'] as bool;
    final timestamp =
        DateTime.fromMillisecondsSinceEpoch(message['timestamp'] as int);
    final formattedTime = DateFormat('HH:mm').format(timestamp);
    final isNew = _newMessageIndices.contains(index);

    Widget bubble = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFF0F4F8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFF7643), Color(0xFFFFA726)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  bottomRight: isUser
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'] as String,
                    style: GoogleFonts.poppins(
                      color: isUser ? const Color(0xFF1E293B) : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedTime,
                    style: GoogleFonts.poppins(
                      color: isUser
                          ? const Color(0xFF6B7280)
                          : const Color(0xFFE5E7EB),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _newMessageIndices.remove(index);
        });
      });
      return Semantics(
        label: isUser
            ? 'Your message: ${message['text']}'
            : 'Bot response: ${message['text']}',
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: bubble,
          ),
        ),
      );
    }
    return Semantics(
      label: isUser
          ? 'Your message: ${message['text']}'
          : 'Bot response: ${message['text']}',
      child: bubble,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppHeader(
              onBackPressed: () => Navigator.pop(context),
              showBar: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_comment_outlined, size: 24),
                  tooltip: 'New Chat',
                  onPressed: _startNewChat,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: _visibleMessages.length + (_isBotTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isBotTyping && index == _visibleMessages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_visibleMessages[index], index);
                  },
                ),
              ),
              _buildSmartReplies(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onChanged: _onTextChanged,
                        decoration: InputDecoration(
                          hintText: 'Ask about books or settings...',
                          hintStyle: GoogleFonts.poppins(
                              color: const Color(0xFF6B7280)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Colors.red
                                  : const Color(0xFFFF7643),
                            ),
                            onPressed: _listen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      elevation: 0,
                      heroTag: 'send_button',
                      backgroundColor: Color(0xFFFF7643),
                      child: const Icon(
                        Icons.send,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
