import 'package:flutter/material.dart';
import 'package:irassimant/CustomWidgets/CustomCategoryWidget.dart';
import 'package:irassimant/Screens/ScreenProcess1.dart';
import 'package:irassimant/Screens/Screenprocess3.dart';
import 'package:irassimant/Screens/Scrennprocess2.dart';
import 'package:irassimant/Screens/screenProcess4.dart';
import 'package:irassimant/main.dart';

class Choosencategoryscreen extends StatefulWidget {
  const Choosencategoryscreen({super.key, required this.documents});
  final List<String> documents;

  @override
  State<Choosencategoryscreen> createState() => _ChoosencategoryscreenState();
}

class _ChoosencategoryscreenState extends State<Choosencategoryscreen> {
  int selectedCategory = 0;
  bool isProcessing = false;

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Index Construction',
      'subtitle': 'Build Inverted & Positional Index',
      'icon': Icons.list_alt,
    },
    {
      'title': 'Document Processing',
      'subtitle': 'Tokenizing, Stop Words & Stemming',
      'icon': Icons.description,
    },
    {
      'title': 'Boolean & Phrase Retrieval',
      'subtitle': 'Query Processing & Search',
      'icon': Icons.search,
    },
    {
      'title': 'Phonetic Search',
      'subtitle': 'Soundex Algorithm',
      'icon': Icons.search_rounded,
    },
  ];

  Future<void> _handleContinue() async {
    setState(() {
      isProcessing = true;
    });

    // Show loading for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate based on selected category
    Widget? destinationScreen;

    if (selectedCategory == 0) {
      destinationScreen = IndexConstructionResult(
        documents: widget.documents,
      );
    } else if (selectedCategory == 1) {
      destinationScreen = DocumentProcessingResult(
        documents: widget.documents,
      );
    } else if (selectedCategory == 2) {
      destinationScreen = BooleanRetrievalResult(documents: widget.documents);
    } else if (selectedCategory == 3) {
      destinationScreen = PhoneticSearchResult(
        documents: widget.documents,
      );
    }

    if (destinationScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destinationScreen!),
      ).then((_) {
        // Reset loading state when returning
        if (mounted) {
          setState(() {
            isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: Text(
              "Select Process Type",
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: maincolor,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    maincolor,
                    maincolor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Document info card
              Container(
                margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.description,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Documents Ready',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.documents.length} document(s) loaded',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.documents.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Grid of categories
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 2,
                      childAspectRatio: isSmallScreen ? 0.95 : 1,
                      crossAxisSpacing: isSmallScreen ? 12 : 16,
                      mainAxisSpacing: isSmallScreen ? 12 : 16,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Customcategorywidget(
                        Choosen: selectedCategory == index,
                        title: categories[index]['title'],
                        icon: categories[index]['icon'],
                        onTap: () {
                          setState(() {
                            selectedCategory = index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isProcessing ? null : _handleContinue,
            backgroundColor: isProcessing ? Colors.grey : maincolor,
            icon: Icon(
              isProcessing ? Icons.hourglass_empty : Icons.arrow_forward,
              color: Colors.white,
            ),
            label: Text(
              isProcessing ? 'Processing...' : 'Continue',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Loading Overlay
        if (isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated circular progress
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(maincolor),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Process title
                    Text(
                      categories[selectedCategory]['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Loading message
                    Text(
                      'Preparing documents...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Progress dots animation
                    _BuildLoadingDots(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Animated loading dots
class _BuildLoadingDots extends StatefulWidget {
  @override
  State<_BuildLoadingDots> createState() => _BuildLoadingDotsState();
}

class _BuildLoadingDotsState extends State<_BuildLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            double delay = index * 0.2;
            double value = (_controller.value - delay) % 1.0;
            double opacity = value < 0.5 ? value * 2 : (1 - value) * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: maincolor.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
