import 'package:flutter/material.dart';
import 'package:irassimant/main.dart';

class PhoneticSearchResult extends StatefulWidget {
  const PhoneticSearchResult({
    super.key,
    required this.documents,
  });

  final List<String> documents;

  @override
  State<PhoneticSearchResult> createState() => _PhoneticSearchResultState();
}

class _PhoneticSearchResultState extends State<PhoneticSearchResult> {
  final TextEditingController _queryController = TextEditingController();
  bool isProcessing = false;
  String? currentQuery;
  String? querySoundexCode;
  List<String> matchingTerms = [];
  List<int> matchingDocuments = [];
  Map<String, String> termSoundexMap = {}; // term -> soundex code
  Map<String, List<int>> invertedIndex = {}; // term -> document IDs
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _buildIndexes();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _buildIndexes() {
    Map<String, List<int>> invIndex = {};
    Map<String, String> soundexMap = {};

    for (int docId = 0; docId < widget.documents.length; docId++) {
      String document = widget.documents[docId];
      List<String> tokens = document
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
          .toList();

      for (String term in tokens) {
        // Build inverted index
        if (!invIndex.containsKey(term)) {
          invIndex[term] = [];
        }
        if (!invIndex[term]!.contains(docId)) {
          invIndex[term]!.add(docId);
        }

        // Generate Soundex code for each term
        if (!soundexMap.containsKey(term)) {
          soundexMap[term] = _generateSoundex(term);
        }
      }
    }

    setState(() {
      invertedIndex = invIndex;
      termSoundexMap = soundexMap;
    });
  }

  String _generateSoundex(String word) {
    if (word.isEmpty) return '';

    word = word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (word.isEmpty) return '';

    // Step 1: Retain the first letter
    String soundex = word[0];

    // Soundex mapping
    Map<String, String> soundexMap = {
      'B': '1', 'F': '1', 'P': '1', 'V': '1',
      'C': '2', 'G': '2', 'J': '2', 'K': '2', 'Q': '2', 'S': '2', 'X': '2', 'Z': '2',
      'D': '3', 'T': '3',
      'L': '4',
      'M': '5', 'N': '5',
      'R': '6',
    };

    // Step 2: Convert letters to digits
    String previousCode = soundexMap[word[0]] ?? '0';
    
    for (int i = 1; i < word.length && soundex.length < 4; i++) {
      String currentCode = soundexMap[word[i]] ?? '0';
      
      // Skip vowels and H, W
      if (currentCode == '0') {
        previousCode = '0';
        continue;
      }
      
      // Skip consecutive duplicates
      if (currentCode != previousCode) {
        soundex += currentCode;
        previousCode = currentCode;
      }
    }

    // Step 3: Pad with zeros to make it 4 characters
    while (soundex.length < 4) {
      soundex += '0';
    }

    return soundex.substring(0, 4);
  }

  Future<void> _executeSearch() async {
    String query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        errorMessage = "Please enter a search term";
      });
      return;
    }

    setState(() {
      isProcessing = true;
      errorMessage = null;
      currentQuery = query;
      matchingTerms = [];
      matchingDocuments = [];
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Generate Soundex code for query
      querySoundexCode = _generateSoundex(query.toLowerCase());

      // Find all terms with matching Soundex code
      Set<String> phoneticallyMatchingTerms = {};
      for (var entry in termSoundexMap.entries) {
        if (entry.value == querySoundexCode) {
          phoneticallyMatchingTerms.add(entry.key);
        }
      }

      matchingTerms = phoneticallyMatchingTerms.toList()..sort();

      // Get all documents containing these terms
      Set<int> docIds = {};
      for (String term in phoneticallyMatchingTerms) {
        if (invertedIndex.containsKey(term)) {
          docIds.addAll(invertedIndex[term]!);
        }
      }

      matchingDocuments = docIds.toList()..sort();
    } catch (e) {
      errorMessage = "Error processing search: $e";
    }

    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Phonetic Search (Soundex)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: maincolor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [maincolor, maincolor.withOpacity(0.8)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            _buildInfoCard(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Soundex explanation
            _buildExplanationCard(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Search input section
            _buildSearchSection(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Results section
            if (currentQuery != null) ...[
              _buildResultsSection(isSmallScreen),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: isSmall ? 24 : 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documents Indexed',
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 14,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.documents.length} documents • ${invertedIndex.length} unique terms',
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: isSmall ? 20 : 24),
              const SizedBox(width: 8),
              Text(
                'How Soundex Works',
                style: TextStyle(
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Soundex is a phonetic algorithm that encodes words based on how they sound. Words that sound similar will have the same Soundex code.',
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleItem('smith → S530', 'smythe → S530', Colors.green, isSmall),
          _buildExampleItem('robert → R163', 'rupert → R163', Colors.blue, isSmall),
          _buildExampleItem('johnson → J525', 'jonson → J525', Colors.purple, isSmall),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String example1, String example2, Color color, bool isSmall) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: isSmall ? 18 : 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    example1,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontFamily: 'monospace',
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.compare_arrows, color: color, size: 16),
                  Text(
                    example2,
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 12,
                      fontFamily: 'monospace',
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Search Term',
          style: TextStyle(
            fontSize: isSmall ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _queryController,
          decoration: InputDecoration(
            hintText: 'e.g., smith, robert, johnson',
            prefixIcon: Icon(Icons.search, color: maincolor),
            suffixIcon: _queryController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _queryController.clear();
                        currentQuery = null;
                        matchingTerms = [];
                        matchingDocuments = [];
                        errorMessage = null;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: maincolor, width: 2),
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (value) => _executeSearch(),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : _executeSearch,
            icon: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.search, color: Colors.white),
            label: Text(
              isProcessing ? 'Searching...' : 'Search Phonetically',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: maincolor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Query info with Soundex code
        Container(
          padding: EdgeInsets.all(isSmall ? 12 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [maincolor.withOpacity(0.1), maincolor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: maincolor.withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: maincolor, size: isSmall ? 20 : 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Query: $currentQuery',
                          style: TextStyle(
                            fontSize: isSmall ? 13 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Soundex Code: $querySoundexCode',
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 13,
                            color: maincolor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Matching terms section
        if (matchingTerms.isNotEmpty) ...[
          Text(
            'Phonetically Similar Terms',
            style: TextStyle(
              fontSize: isSmall ? 15 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matchingTerms.map((term) {
                return Chip(
                  label: Text(term),
                  backgroundColor: Colors.green.shade50,
                  labelStyle: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(color: Colors.green.shade300),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Documents section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.description, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Matching Documents: ${matchingDocuments.length}',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (matchingDocuments.isEmpty)
          _buildNoResultsCard(isSmall)
        else
          ...matchingDocuments.map(
            (docId) => _buildDocumentCard(docId, isSmall),
          ),
      ],
    );
  }

  Widget _buildNoResultsCard(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: isSmall ? 48 : 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No phonetically similar terms found',
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(int docId, bool isSmall) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: isSmall ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'Document $docId',
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            child: Text(
              widget.documents[docId],
              style: TextStyle(
                fontSize: isSmall ? 12 : 13,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}