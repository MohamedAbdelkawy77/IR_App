import 'package:flutter/material.dart';
import 'package:irassimant/main.dart';

class BooleanRetrievalResult extends StatefulWidget {
  const BooleanRetrievalResult({
    super.key,
    required this.documents,
  });

  final List<String> documents;

  @override
  State<BooleanRetrievalResult> createState() => _BooleanRetrievalResultState();
}

class _BooleanRetrievalResultState extends State<BooleanRetrievalResult> {
  final TextEditingController _queryController = TextEditingController();
  bool isProcessing = false;
  String? currentQuery;
  QueryType? queryType;
  List<int> matchingDocuments = [];
  Map<String, List<int>> invertedIndex = {};
  Map<String, Map<int, List<int>>> positionalIndex = {};
  String? errorMessage;

  // Term selection
  List<String> selectedTerms = [];
  String selectedOperator = 'AND';
  bool isManualMode = true;

  // Phrase query details
  List<String>? phraseTerms;
  int? phraseLength;

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
    Map<String, Map<int, List<int>>> posIndex = {};

    for (int i = 0; i < widget.documents.length; i++) {
      int docId = i + 1;
      String document = widget.documents[i];
      List<String> tokens = document
          .toLowerCase()
          .replaceAll(RegExp(r'[^\u0600-\u06FF\w\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
          .toList();

      for (int position = 0; position < tokens.length; position++) {
        String term = tokens[position];

        if (!invIndex.containsKey(term)) {
          invIndex[term] = [];
        }
        if (!invIndex[term]!.contains(docId)) {
          invIndex[term]!.add(docId);
        }

        if (!posIndex.containsKey(term)) {
          posIndex[term] = {};
        }
        if (!posIndex[term]!.containsKey(docId)) {
          posIndex[term]![docId] = [];
        }
        posIndex[term]![docId]!.add(position);
      }
    }

    setState(() {
      invertedIndex = invIndex;
      positionalIndex = posIndex;
    });
  }

  void _buildQueryFromSelection() {
    if (selectedTerms.isEmpty) return;

    String query;
    if (selectedTerms.length == 1) {
      query = selectedTerms[0];
    } else {
      query = selectedTerms.join(' $selectedOperator ');
    }

    setState(() {
      _queryController.text = query;
    });
  }

  Future<void> _executeQuery() async {
    String query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        errorMessage = "Please enter a query";
      });
      return;
    }

    setState(() {
      isProcessing = true;
      errorMessage = null;
      currentQuery = query;
      matchingDocuments = [];
      phraseTerms = null;
      phraseLength = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Detect query type
      if (query.contains('"')) {
        // Validate phrase query
        String phrase = query.replaceAll('"', '').toLowerCase().trim();
        List<String> terms = phrase.split(RegExp(r'\s+'));

        if (terms.length < 2 || terms.length > 3) {
          setState(() {
            errorMessage =
                "Phrase queries must contain 2 or 3 words. Found: ${terms.length} word(s)";
            isProcessing = false;
          });
          return;
        }

        queryType = QueryType.phrase;
        phraseTerms = terms;
        phraseLength = terms.length;
        matchingDocuments = _processPhraseQuery(query);
      } else if (query.toUpperCase().contains(' AND ')) {
        queryType = QueryType.booleanAnd;
        matchingDocuments = _processBooleanAND(query);
      } else if (query.toUpperCase().contains(' OR ')) {
        queryType = QueryType.booleanOr;
        matchingDocuments = _processBooleanOR(query);
      } else if (query.toUpperCase().contains(' NOT ')) {
        queryType = QueryType.booleanNot;
        matchingDocuments = _processBooleanNOT(query);
      } else {
        queryType = QueryType.single;
        matchingDocuments = _processSingleTerm(query);
      }

      matchingDocuments.sort();
    } catch (e) {
      errorMessage = "Error processing query: $e";
    }

    setState(() {
      isProcessing = false;
    });
  }

  List<int> _processSingleTerm(String query) {
    String term = query.toLowerCase().trim();
    return invertedIndex[term] ?? [];
  }

  List<int> _processBooleanAND(String query) {
    List<String> terms = query
        .toUpperCase()
        .split(' AND ')
        .map((t) => t.trim().toLowerCase())
        .toList();

    if (terms.isEmpty) return [];

    Set<int> result = Set<int>.from(invertedIndex[terms[0]] ?? []);

    for (int i = 1; i < terms.length; i++) {
      Set<int> termDocs = Set<int>.from(invertedIndex[terms[i]] ?? []);
      result = result.intersection(termDocs);
    }

    return result.toList();
  }

  List<int> _processBooleanOR(String query) {
    List<String> terms = query
        .toUpperCase()
        .split(' OR ')
        .map((t) => t.trim().toLowerCase())
        .toList();

    Set<int> result = {};

    for (String term in terms) {
      result.addAll(invertedIndex[term] ?? []);
    }

    return result.toList();
  }

  List<int> _processBooleanNOT(String query) {
    List<String> parts = query.toUpperCase().split(' NOT ');
    if (parts.length != 2) return [];

    String includeTerm = parts[0].trim().toLowerCase();
    String excludeTerm = parts[1].trim().toLowerCase();

    Set<int> includeSet = Set<int>.from(invertedIndex[includeTerm] ?? []);
    Set<int> excludeSet = Set<int>.from(invertedIndex[excludeTerm] ?? []);

    return includeSet.difference(excludeSet).toList();
  }

  List<int> _processPhraseQuery(String query) {
    String phrase = query.replaceAll('"', '').toLowerCase().trim();
    List<String> terms = phrase.split(RegExp(r'\s+'));

    if (terms.isEmpty || terms.length < 2 || terms.length > 3) return [];

    Set<int> candidateDocs = Set<int>.from(invertedIndex[terms[0]] ?? []);

    List<int> result = [];

    for (int docId in candidateDocs) {
      if (_isPhraseInDocument(terms, docId)) {
        result.add(docId);
      }
    }

    return result;
  }

  bool _isPhraseInDocument(List<String> terms, int docId) {
    List<int> firstTermPositions = positionalIndex[terms[0]]?[docId] ?? [];

    for (int startPos in firstTermPositions) {
      bool phraseFound = true;

      for (int i = 1; i < terms.length; i++) {
        int expectedPos = startPos + i;
        List<int> termPositions = positionalIndex[terms[i]]?[docId] ?? [];

        if (!termPositions.contains(expectedPos)) {
          phraseFound = false;
          break;
        }
      }

      if (phraseFound) return true;
    }

    return false;
  }

  void _showTermSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _TermSelectionDialog(
        allTerms: invertedIndex.keys.toList()..sort(),
        selectedTerms: selectedTerms,
        onTermsSelected: (terms) {
          setState(() {
            selectedTerms = terms;
            _buildQueryFromSelection();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Boolean & Phrase Retrieval',
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
            _buildInfoCard(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 20),
            _buildModeToggle(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 20),
            if (!isManualMode) ...[
              _buildTermSelectionSection(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],
            if (isManualMode) ...[
              _buildExamplesCard(isSmallScreen),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],
            _buildQuerySection(isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 20),
            if (currentQuery != null) ...[
              _buildResultsSection(isSmallScreen),
            ],
            const SizedBox(height: 20),
            _buildInvertedIndexMatrix(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isManualMode = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
                decoration: BoxDecoration(
                  color: isManualMode ? maincolor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Manual Entry',
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 14,
                      fontWeight: FontWeight.bold,
                      color: isManualMode ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isManualMode = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
                decoration: BoxDecoration(
                  color: !isManualMode ? maincolor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Select Terms',
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 14,
                      fontWeight: FontWeight.bold,
                      color:
                          !isManualMode ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSelectionSection(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build Your Query',
          style: TextStyle(
            fontSize: isSmall ? 16 : 18,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Boolean Operator:',
                style: TextStyle(
                  fontSize: isSmall ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['AND', 'OR', 'NOT'].map((op) {
                  return ChoiceChip(
                    label: Text(op),
                    selected: selectedOperator == op,
                    onSelected: (selected) {
                      setState(() {
                        selectedOperator = op;
                        _buildQueryFromSelection();
                      });
                    },
                    selectedColor: maincolor,
                    labelStyle: TextStyle(
                      color: selectedOperator == op
                          ? Colors.white
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Terms (${selectedTerms.length}):',
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (selectedTerms.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTerms.clear();
                          _queryController.clear();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              selectedTerms.isEmpty
                  ? Text(
                      'No terms selected',
                      style: TextStyle(
                        fontSize: isSmall ? 11 : 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedTerms.map((term) {
                        return Chip(
                          label: Text(term),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              selectedTerms.remove(term);
                              _buildQueryFromSelection();
                            });
                          },
                          backgroundColor: maincolor.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: maincolor,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showTermSelectionDialog,
            icon: const Icon(Icons.list, color: Colors.white),
            label: const Text(
              'Select Terms from Index',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: maincolor.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
          Icon(Icons.info_outline,
              color: Colors.blue.shade700, size: isSmall ? 24 : 28),
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

  Widget _buildExamplesCard(bool isSmall) {
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
              Icon(Icons.lightbulb_outline,
                  color: Colors.orange.shade700, size: isSmall ? 20 : 24),
              const SizedBox(width: 8),
              Text(
                'Query Examples',
                style: TextStyle(
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExampleItem('Single Term:', 'apple', Colors.blue, isSmall),
          _buildExampleItem(
              'Boolean AND:', 'apple AND orange', Colors.green, isSmall),
          _buildExampleItem(
              'Boolean OR:', 'apple OR banana', Colors.purple, isSmall),
          _buildExampleItem(
              'Boolean NOT:', 'apple NOT red', Colors.red, isSmall),
          _buildExampleItem(
              '2-Word Phrase:', '"red apple"', Colors.orange, isSmall),
          _buildExampleItem(
              '3-Word Phrase:', '"fresh red apple"', Colors.teal, isSmall),
        ],
      ),
    );
  }

  Widget _buildExampleItem(
      String label, String example, Color color, bool isSmall) {
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
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                example,
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  fontFamily: 'monospace',
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuerySection(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isManualMode ? 'Enter Your Query' : 'Generated Query',
          style: TextStyle(
            fontSize: isSmall ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _queryController,
          readOnly: !isManualMode,
          decoration: InputDecoration(
            hintText: 'e.g., "red apple" or apple AND orange',
            prefixIcon: Icon(Icons.search, color: maincolor),
            suffixIcon: _queryController.text.isNotEmpty && isManualMode
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _queryController.clear();
                        currentQuery = null;
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
            filled: !isManualMode,
            fillColor: !isManualMode ? Colors.grey.shade100 : null,
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (value) => _executeQuery(),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : _executeQuery,
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
              isProcessing ? 'Searching...' : 'Search',
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
                          'Type: ${_getQueryTypeName()}',
                          style: TextStyle(
                            fontSize: isSmall ? 11 : 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (phraseLength != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Phrase Length: $phraseLength word${phraseLength! > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: isSmall ? 11 : 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          matchingDocuments.isEmpty ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${matchingDocuments.length} found',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (matchingDocuments.isEmpty)
          _buildNoResultsCard(isSmall)
        else
          ...matchingDocuments.map(
            (docId) => _buildDocumentCard(docId, isSmall),
          ),
      ],
    );
  }

  String _getQueryTypeName() {
    switch (queryType) {
      case QueryType.single:
        return 'Single Term';
      case QueryType.booleanAnd:
        return 'Boolean AND';
      case QueryType.booleanOr:
        return 'Boolean OR';
      case QueryType.booleanNot:
        return 'Boolean NOT';
      case QueryType.phrase:
        return 'Phrase Query (${phraseLength ?? 0} words)';
      default:
        return 'Unknown';
    }
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
            Icon(Icons.search_off,
                size: isSmall ? 48 : 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No documents found',
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              phraseLength != null
                  ? 'The exact phrase was not found in any document'
                  : 'Try a different query',
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

  Widget _buildInvertedIndexMatrix(bool isSmall) {
    List<String> allTerms = invertedIndex.keys.toList()..sort();
    int numDocs = widget.documents.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Boolean Retrieval Model - Inverted Index Matrix',
          style: TextStyle(
            fontSize: isSmall ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  maincolor.withOpacity(0.1),
                ),
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                columnSpacing: isSmall ? 30 : 50,
                dataRowHeight: isSmall ? 40 : 48,
                headingRowHeight: isSmall ? 45 : 56,
                columns: [
                  DataColumn(
                    label: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Term',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 13 : 14,
                          color: maincolor,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(numDocs, (index) {
                    return DataColumn(
                      label: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Doc${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 13 : 14,
                            color: maincolor,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                rows: allTerms.map((term) {
                  List<int> termDocs = invertedIndex[term] ?? [];

                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            term,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmall ? 12 : 13,
                              color: Colors.grey.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      ...List.generate(numDocs, (index) {
                        int docId = index + 1;
                        bool isPresent = termDocs.contains(docId);

                        return DataCell(
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? Colors.green.shade100
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPresent ? '1' : '0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmall ? 13 : 14,
                                  color: isPresent
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline,
                  size: isSmall ? 16 : 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Legend: ',
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '= Term present',
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '0',
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '= Term absent',
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(int docId, bool isSmall) {
    int arrayIndex = docId - 1;

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
                Icon(Icons.check_circle,
                    color: Colors.green.shade700, size: isSmall ? 20 : 24),
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
              widget.documents[arrayIndex],
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

class _TermSelectionDialog extends StatefulWidget {
  final List<String> allTerms;
  final List<String> selectedTerms;
  final Function(List<String>) onTermsSelected;

  const _TermSelectionDialog({
    required this.allTerms,
    required this.selectedTerms,
    required this.onTermsSelected,
  });

  @override
  State<_TermSelectionDialog> createState() => _TermSelectionDialogState();
}

class _TermSelectionDialogState extends State<_TermSelectionDialog> {
  late List<String> _selectedTerms;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTerms = List.from(widget.selectedTerms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredTerms {
    if (_searchQuery.isEmpty) {
      return widget.allTerms;
    }
    return widget.allTerms
        .where(
            (term) => term.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Terms',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedTerms.length} term(s) selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search terms...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTerms.isEmpty
                  ? Center(
                      child: Text(
                        'No terms found',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTerms.length,
                      itemBuilder: (context, index) {
                        final term = _filteredTerms[index];
                        final isSelected = _selectedTerms.contains(term);

                        return CheckboxListTile(
                          title: Text(
                            term,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedTerms.add(term);
                              } else {
                                _selectedTerms.remove(term);
                              }
                            });
                          },
                          activeColor: maincolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_selectedTerms.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTerms.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onTermsSelected(_selectedTerms);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maincolor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum QueryType {
  single,
  booleanAnd,
  booleanOr,
  booleanNot,
  phrase,
}
