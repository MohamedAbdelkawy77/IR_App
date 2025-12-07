import 'package:flutter/material.dart';
import 'package:irassimant/main.dart';

class IndexConstructionResult extends StatefulWidget {
  const IndexConstructionResult({
    super.key,
    required this.documents,
  });

  final List<String> documents;

  @override
  State<IndexConstructionResult> createState() => _IndexConstructionResultState();
}

class _IndexConstructionResultState extends State<IndexConstructionResult> {
  bool isProcessing = true;
  Map<String, List<int>> invertedIndex = {};
  Map<String, Map<int, List<int>>> positionalIndex = {};
  int totalTerms = 0;
  int uniqueTerms = 0;

  @override
  void initState() {
    super.initState();
    _buildIndexes();
  }

  Future<void> _buildIndexes() async {
    setState(() => isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 500));

    // Build Inverted Index and Positional Index
    Map<String, List<int>> invIndex = {};
    Map<String, Map<int, List<int>>> posIndex = {};
    int termCount = 0;

    for (int docId = 0; docId < widget.documents.length; docId++) {
      String document = widget.documents[docId];
      
      // Tokenize: split by whitespace and convert to lowercase
      List<String> tokens = document
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
          .toList();

      termCount += tokens.length;

      // Build indexes
      for (int position = 0; position < tokens.length; position++) {
        String term = tokens[position];

        // Inverted Index: term -> list of document IDs
        if (!invIndex.containsKey(term)) {
          invIndex[term] = [];
        }
        if (!invIndex[term]!.contains(docId)) {
          invIndex[term]!.add(docId);
        }

        // Positional Index: term -> {docId -> [positions]}
        if (!posIndex.containsKey(term)) {
          posIndex[term] = {};
        }
        if (!posIndex[term]!.containsKey(docId)) {
          posIndex[term]![docId] = [];
        }
        posIndex[term]![docId]!.add(position);
      }
    }

    // Sort document IDs for better display
    invIndex.forEach((term, docIds) {
      docIds.sort();
    });

    setState(() {
      invertedIndex = invIndex;
      positionalIndex = posIndex;
      totalTerms = termCount;
      uniqueTerms = invIndex.length;
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
          'Index Construction Results',
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
      body: isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: maincolor),
                  const SizedBox(height: 20),
                  Text(
                    'Building indexes...',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Terms',
                          totalTerms.toString(),
                          Icons.text_fields,
                          Colors.blue,
                          isSmallScreen,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 16),
                      Expanded(
                        child: _buildStatCard(
                          'Unique Terms',
                          uniqueTerms.toString(),
                          Icons.stars,
                          Colors.purple,
                          isSmallScreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Documents',
                          widget.documents.length.toString(),
                          Icons.description,
                          Colors.green,
                          isSmallScreen,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 16),
                      Expanded(
                        child: _buildStatCard(
                          'Avg Terms/Doc',
                          widget.documents.isEmpty
                              ? '0'
                              : (totalTerms / widget.documents.length)
                                  .toStringAsFixed(1),
                          Icons.analytics,
                          Colors.orange,
                          isSmallScreen,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Inverted Index Section
                  _buildSectionHeader(
                    'Inverted Index',
                    Icons.list_alt,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  _buildInvertedIndexCard(isSmallScreen),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Positional Index Section
                  _buildSectionHeader(
                    'Positional Index',
                    Icons.location_on,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  _buildPositionalIndexCard(isSmallScreen),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isSmall,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmall ? 24 : 32),
          SizedBox(height: isSmall ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isSmall) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: maincolor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: maincolor, size: isSmall ? 20 : 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildInvertedIndexCard(bool isSmall) {
    if (invertedIndex.isEmpty) {
      return _buildEmptyCard('No terms found', isSmall);
    }

    return Container(
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
        children: invertedIndex.entries.take(50).map((entry) {
          return Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: maincolor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: isSmall ? 14 : 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.value.map((docId) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'Doc $docId',
                          style: TextStyle(
                            fontSize: isSmall ? 11 : 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPositionalIndexCard(bool isSmall) {
    if (positionalIndex.isEmpty) {
      return _buildEmptyCard('No positional data found', isSmall);
    }

    return Container(
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
        children: positionalIndex.entries.take(50).map((entry) {
          String term = entry.key;
          Map<int, List<int>> docPositions = entry.value;

          return Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  term,
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: maincolor,
                  ),
                ),
                const SizedBox(height: 8),
                ...docPositions.entries.map((docEntry) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Doc ${docEntry.key}',
                            style: TextStyle(
                              fontSize: isSmall ? 11 : 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: docEntry.value.map((pos) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'pos:$pos',
                                  style: TextStyle(
                                    fontSize: isSmall ? 10 : 11,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyCard(String message, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}