import 'package:flutter/material.dart';
import 'package:irassimant/main.dart';

class Customcategorywidget extends StatefulWidget {
  const Customcategorywidget({
    super.key,
    required this.Choosen,
    this.title = "Description of process",
    this.icon = Icons.list_alt,
    this.onTap,
  });

  final bool Choosen;
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<Customcategorywidget> createState() => _CustomcategorywidgetState();
}

class _CustomcategorywidgetState extends State<Customcategorywidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing based on screen width
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600 && screenWidth < 900;
    final isExtraLarge = screenWidth >= 900;

    // Dynamic padding
    final containerPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
            ? 16.0
            : isLargeScreen
                ? 20.0
                : 24.0;

    // Dynamic icon size
    final iconSize = isSmallScreen
        ? 32.0
        : isMediumScreen
            ? 36.0
            : isLargeScreen
                ? 40.0
                : 48.0;

    // Dynamic icon padding
    final iconPadding = isSmallScreen
        ? 12.0
        : isMediumScreen
            ? 14.0
            : isLargeScreen
                ? 16.0
                : 18.0;

    // Dynamic text size
    final titleFontSize = isSmallScreen
        ? 13.0
        : isMediumScreen
            ? 14.0
            : isLargeScreen
                ? 16.0
                : 18.0;

    // Dynamic spacing
    final verticalSpacing = isSmallScreen
        ? 8.0
        : isMediumScreen
            ? 10.0
            : isLargeScreen
                ? 12.0
                : 14.0;

    // Dynamic border width
    final borderWidth = widget.Choosen
        ? (isSmallScreen ? 2.0 : 3.0)
        : (isSmallScreen ? 1.5 : 2.0);

    // Dynamic border radius
    final borderRadius = isSmallScreen
        ? 15.0
        : isMediumScreen
            ? 18.0
            : 20.0;

    // Dynamic shadow
    final shadowBlur = widget.Choosen
        ? (isSmallScreen ? 15.0 : 20.0)
        : (isSmallScreen ? 8.0 : 10.0);

    final shadowOffset = widget.Choosen
        ? (isSmallScreen ? 6.0 : 8.0)
        : (isSmallScreen ? 3.0 : 4.0);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(containerPadding),
          decoration: BoxDecoration(
            gradient: widget.Choosen
                ? LinearGradient(
                    colors: [
                      MycolorApp[1],
                      MycolorApp[1].withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade200,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: widget.Choosen ? MycolorApp[1] : Colors.grey.shade400,
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.Choosen
                    ? MycolorApp[1].withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                blurRadius: shadowBlur,
                offset: Offset(0, shadowOffset),
                spreadRadius: widget.Choosen ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: widget.Choosen
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.Choosen
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: iconSize,
                  color: widget.Choosen ? Colors.white : MycolorApp[3],
                ),
              ),
              SizedBox(height: verticalSpacing),
              // Title text
              Flexible(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: widget.Choosen ? Colors.white : Colors.black87,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),
              ),
              // Checkmark indicator
              if (widget.Choosen) ...[
                SizedBox(height: verticalSpacing),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Text(
                        'Selected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Updated screen with responsive grid layout
class Choosencategoryscreen extends StatefulWidget {
  const Choosencategoryscreen({super.key});

  @override
  State<Choosencategoryscreen> createState() => _ChoosencategoryscreenState();
}

class _ChoosencategoryscreenState extends State<Choosencategoryscreen> {
  int selectedCategory = 0;

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Text Analysis',
      'icon': Icons.text_fields,
    },
    {
      'title': 'Document Process',
      'icon': Icons.description,
    },
    {
      'title': 'Data Export',
      'icon': Icons.upload_file,
    },
    {
      'title': 'Report Generation',
      'icon': Icons.assessment,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive column count
    int crossAxisCount;
    double childAspectRatio;
    double padding;
    double spacing;

    if (screenWidth < 360) {
      // Extra small phones
      crossAxisCount = 1;
      childAspectRatio = 1.5;
      padding = 12.0;
      spacing = 12.0;
    } else if (screenWidth < 600) {
      // Small phones
      crossAxisCount = 2;
      childAspectRatio = 0.95;
      padding = 16.0;
      spacing = 16.0;
    } else if (screenWidth < 900) {
      // Tablets
      crossAxisCount = 3;
      childAspectRatio = 1.0;
      padding = 20.0;
      spacing = 20.0;
    } else {
      // Large tablets and desktops
      crossAxisCount = 4;
      childAspectRatio = 1.0;
      padding = 24.0;
      spacing = 24.0;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Choose Category",
          style: TextStyle(
            fontSize: screenWidth < 360 ? 18 : 22,
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
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Selected: ${categories[selectedCategory]['title']}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
        backgroundColor: maincolor,
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          'Continue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth < 360 ? 14 : 16,
          ),
        ),
      ),
    );
  }
}
