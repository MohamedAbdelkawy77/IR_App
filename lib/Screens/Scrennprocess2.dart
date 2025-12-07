import 'package:flutter/material.dart';
import 'package:irassimant/main.dart';

class DocumentProcessingResult extends StatefulWidget {
  const DocumentProcessingResult({
    super.key,
    required this.documents,
  });

  final List<String> documents;

  @override
  State<DocumentProcessingResult> createState() =>
      _DocumentProcessingResultState();
}

class _DocumentProcessingResultState extends State<DocumentProcessingResult> {
  bool isProcessing = true;
  List<DocumentProcessingData> processedDocuments = [];
  int totalOriginalTokens = 0;
  int totalAfterStopwords = 0;
  int totalAfterStemming = 0;
  
  // Common English stop words
  final Set<String> stopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from',
    'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the',
    'to', 'was', 'will', 'with', 'the', 'this', 'but', 'they', 'have',
    'had', 'what', 'when', 'where', 'who', 'which', 'why', 'how', 'all',
    'each', 'every', 'both', 'few', 'more', 'most', 'other', 'some', 'such',
    'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very',
    'can', 'just', 'should', 'now', 'i', 'you', 'we', 'me', 'my', 'your',
    'our', 'their', 'his', 'her', 'him', 'them', 'us', 'am', 'been', 'being',
  };

  @override
  void initState() {
    super.initState();
    _processDocuments();
  }

  Future<void> _processDocuments() async {
    setState(() => isProcessing = true);

    await Future.delayed(const Duration(milliseconds: 500));

    List<DocumentProcessingData> processed = [];
    int origTokens = 0;
    int afterStop = 0;
    int afterStem = 0;

    for (int i = 0; i < widget.documents.length; i++) {
      String doc = widget.documents[i];

      // Step 1: Tokenization
      List<String> tokens = _tokenize(doc);
      origTokens += tokens.length;

      // Step 2: Stop word removal
      List<String> afterStopwords = _removeStopWords(tokens);
      afterStop += afterStopwords.length;

      // Step 3: Stemming
      List<String> stemmed = _applyStemming(afterStopwords);
      afterStem += stemmed.length;

      processed.add(DocumentProcessingData(
        docId: i,
        originalText: doc,
        tokens: tokens,
        afterStopwords: afterStopwords,
        stemmed: stemmed,
      ));
    }

    setState(() {
      processedDocuments = processed;
      totalOriginalTokens = origTokens;
      totalAfterStopwords = afterStop;
      totalAfterStemming = afterStem;
      isProcessing = false;
    });
  }

  // Tokenization: split by whitespace and punctuation
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  // Stop word removal
  List<String> _removeStopWords(List<String> tokens) {
    return tokens.where((token) => !stopWords.contains(token)).toList();
  }

  // Porter Stemmer Algorithm (simplified version)
  List<String> _applyStemming(List<String> tokens) {
    return tokens.map((token) => _stem(token)).toList();
  }

  String _stem(String word) {
    if (word.length <= 2) return word;

    // Step 1: Remove common suffixes
    if (word.endsWith('ing') && word.length > 5) {
      return word.substring(0, word.length - 3);
    }
    if (word.endsWith('ed') && word.length > 4) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('ly') && word.length > 4) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('ies') && word.length > 5) {
      return word.substring(0, word.length - 3) + 'y';
    }
    if (word.endsWith('es') && word.length > 4) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('s') && word.length > 3 && !word.endsWith('ss')) {
      return word.substring(0, word.length - 1);
    }
    if (word.endsWith('tion') && word.length > 6) {
      return word.substring(0, word.length - 4);
    }
    if (word.endsWith('ation') && word.length > 7) {
      return word.substring(0, word.length - 5);
    }
    if (word.endsWith('er') && word.length > 4) {
      return word.substring(0, word.length - 2);
    }
    if (word.endsWith('est') && word.length > 5) {
      return word.substring(0, word.length - 3);
    }

    return word;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Document Processing Results',
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
                    'Processing documents...',
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
                  // Statistics Overview
                  _buildStatisticsSection(isSmallScreen),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Processing Pipeline
                  _buildSectionHeader(
                    'Processing Pipeline',
                    Icons.account_tree,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  _buildPipelineCard(isSmallScreen),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Processed Documents
                  _buildSectionHeader(
                    'Processed Documents',
                    Icons.description,
                    isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  ...processedDocuments.map(
                    (doc) => _buildDocumentCard(doc, isSmallScreen),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsSection(bool isSmall) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Original Tokens',
                totalOriginalTokens.toString(),
                Icons.text_fields,
                Colors.blue,
                isSmall,
              ),
            ),
            SizedBox(width: isSmall ? 8 : 16),
            Expanded(
              child: _buildStatCard(
                'After Stop Words',
                totalAfterStopwords.toString(),
                Icons.filter_list,
                Colors.orange,
                isSmall,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmall ? 8 : 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'After Stemming',
                totalAfterStemming.toString(),
                Icons.compress,
                Colors.green,
                isSmall,
              ),
            ),
            SizedBox(width: isSmall ? 8 : 16),
            Expanded(
              child: _buildStatCard(
                'Reduction %',
                totalOriginalTokens > 0
                    ? '${((1 - totalAfterStemming / totalOriginalTokens) * 100).toStringAsFixed(1)}%'
                    : '0%',
                Icons.trending_down,
                Colors.purple,
                isSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPipelineCard(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.indigo.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade300, width: 2),
      ),
      child: Column(
        children: [
          _buildPipelineStep(
            '1',
            'Tokenization',
            'Split text into tokens',
            Colors.blue,
            isSmall,
          ),
          _buildArrow(isSmall),
          _buildPipelineStep(
            '2',
            'Stop Word Removal',
            'Remove common words',
            Colors.orange,
            isSmall,
          ),
          _buildArrow(isSmall),
          _buildPipelineStep(
            '3',
            'Stemming',
            'Reduce words to root form',
            Colors.green,
            isSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineStep(
    String number,
    String title,
    String description,
    Color color,
    bool isSmall,
  ) {
    return Row(
      children: [
        Container(
          width: isSmall ? 40 : 50,
          height: isSmall ? 40 : 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
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

  Widget _buildArrow(bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8),
      child: Row(
        children: [
          SizedBox(width: isSmall ? 18 : 23),
          Icon(
            Icons.arrow_downward,
            color: Colors.indigo.shade400,
            size: isSmall ? 20 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentProcessingData doc, bool isSmall) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 12 : 16),
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
          // Document Header
          Container(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            decoration: BoxDecoration(
              color: maincolor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.description, color: maincolor, size: isSmall ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'Document ${doc.docId}',
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: maincolor,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(isSmall ? 10 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original Text
                _buildProcessingStage(
                  'Original Text',
                  doc.originalText,
                  Colors.grey.shade700,
                  isSmall,
                ),
                const SizedBox(height: 12),

                // Tokenized
                _buildTokenList(
                  'Tokenized (${doc.tokens.length})',
                  doc.tokens,
                  Colors.blue,
                  isSmall,
                ),
                const SizedBox(height: 12),

                // After Stop Words
                _buildTokenList(
                  'After Stop Words (${doc.afterStopwords.length})',
                  doc.afterStopwords,
                  Colors.orange,
                  isSmall,
                ),
                const SizedBox(height: 12),

                // Stemmed
                _buildTokenList(
                  'After Stemming (${doc.stemmed.length})',
                  doc.stemmed,
                  Colors.green,
                  isSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStage(
    String label,
    String text,
    Color color,
    bool isSmall,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTokenList(
    String label,
    List<String> tokens,
    Color color,
    bool isSmall,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tokens.map((token) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                token,
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
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
}

// Data class to hold processing results
class DocumentProcessingData {
  final int docId;
  final String originalText;
  final List<String> tokens;
  final List<String> afterStopwords;
  final List<String> stemmed;

  DocumentProcessingData({
    required this.docId,
    required this.originalText,
    required this.tokens,
    required this.afterStopwords,
    required this.stemmed,
  });
}