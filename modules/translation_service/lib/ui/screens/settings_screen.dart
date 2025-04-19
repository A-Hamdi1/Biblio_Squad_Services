import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Language Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Automatic Language Detection'),
                subtitle: const Text('Automatically detect source language'),
                value: languageProvider.isAutomaticDetection,
                onChanged: (value) {
                  languageProvider.toggleAutomaticDetection(value);
                },
              ),
              const SizedBox(height: 16),
              if (!languageProvider.isAutomaticDetection)
                ListTile(
                  title: const Text('Source Language'),
                  subtitle: Text(languageProvider.supportedLanguages[languageProvider.sourceLanguage] ?? 'Unknown'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showLanguageSelector(
                      context,
                      languageProvider,
                      true,
                    );
                  },
                ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Target Language'),
                subtitle: Text(languageProvider.supportedLanguages[languageProvider.targetLanguage] ?? 'Unknown'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showLanguageSelector(
                    context,
                    languageProvider,
                    false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageSelector(
      BuildContext context,
      LanguageProvider languageProvider,
      bool isSource,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _LanguageSelectorSheet(
              scrollController: scrollController,
              languageProvider: languageProvider,
              isSource: isSource,
            );
          },
        );
      },
    );
  }
}

class _LanguageSelectorSheet extends StatefulWidget {
  final ScrollController scrollController;
  final LanguageProvider languageProvider;
  final bool isSource;

  const _LanguageSelectorSheet({
    required this.scrollController,
    required this.languageProvider,
    required this.isSource,
  });

  @override
  _LanguageSelectorSheetState createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<_LanguageSelectorSheet> {
  late TextEditingController searchController;
  late Map<String, String> filteredLanguages;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    filteredLanguages = {...widget.languageProvider.supportedLanguages};
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            widget.isSource ? 'Select Source Language' : 'Select Target Language',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search Language',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  filteredLanguages = {...widget.languageProvider.supportedLanguages};
                } else {
                  filteredLanguages = Map.fromEntries(
                      widget.languageProvider.supportedLanguages.entries.where((entry) =>
                          entry.value.toLowerCase().contains(value.toLowerCase()))
                  );
                }
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: filteredLanguages.length,
              itemBuilder: (context, index) {
                final languageCode = filteredLanguages.keys.elementAt(index);
                final languageName = filteredLanguages.values.elementAt(index);

                if (!widget.isSource && languageCode == 'auto') {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  title: Text(languageName),
                  trailing: (widget.isSource && languageCode == widget.languageProvider.sourceLanguage) ||
                      (!widget.isSource && languageCode == widget.languageProvider.targetLanguage)
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    if (widget.isSource) {
                      widget.languageProvider.setSourceLanguage(languageCode);
                    } else {
                      widget.languageProvider.setTargetLanguage(languageCode);
                    }
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}