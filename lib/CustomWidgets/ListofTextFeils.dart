import 'package:flutter/material.dart';
import 'package:irassimant/main.dart';
import 'package:file_picker/file_picker.dart';

// Add this to your pubspec.yaml:
// dependencies:
//   syncfusion_flutter_pdf: ^24.1.41  (for PDF parsing)

import 'package:syncfusion_flutter_pdf/pdf.dart';

class GetTextfeilds extends StatefulWidget {
  const GetTextfeilds({
    super.key,
    required this.Numbers,
    required this.Documents,
  });

  final int Numbers;
  final List<String> Documents;

  @override
  State<GetTextfeilds> createState() => _GetTextfeildsState();
}

class _GetTextfeildsState extends State<GetTextfeilds> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.Numbers,
      (index) {
        final controller = TextEditingController(
          text: index < widget.Documents.length ? widget.Documents[index] : '',
        );
        controller.addListener(() => _updateDocument(index, controller.text));
        return controller;
      },
      growable: false,
    );
  }

  void _updateDocument(int index, String text) {
    if (index < widget.Documents.length) {
      widget.Documents[index] = text;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.Numbers,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Listoftextfeils(
            controller: _controllers[index],
            color: MycolorApp[index % MycolorApp.length],
            index: index,
          ),
        );
      },
    );
  }
}

class Listoftextfeils extends StatefulWidget {
  const Listoftextfeils({
    super.key,
    required this.controller,
    required this.color,
    required this.index,
  });

  final TextEditingController controller;
  final Color color;
  final int index;

  @override
  State<Listoftextfeils> createState() => _ListoftextfeilsState();
}

class _ListoftextfeilsState extends State<Listoftextfeils> {
  bool _isFileUploaded = false;
  String? _fileName;
  bool _isUploading = false;

  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> _allowedExtensions = ['txt', 'pdf'];

  Future<String?> _extractTextFromPdf(List<int> bytes) async {
    try {
      // Load PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extract text from all pages
      String text = '';
      for (int i = 0; i < document.pages.count; i++) {
        text += PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        text += '\n'; // Add line break between pages
      }
      
      // Dispose document
      document.dispose();
      
      return text.trim();
    } catch (e) {
      debugPrint('Error extracting PDF text: $e');
      return null;
    }
  }

  Future<void> _pickFile() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: false,
        withData: true, // Always use bytes for both web and mobile
      );

      if (result == null || !mounted) {
        setState(() => _isUploading = false);
        return;
      }

      final platformFile = result.files.single;
      final fileSize = platformFile.size;

      if (fileSize > _maxFileSize) {
        _showErrorSnackBar('File too large. Maximum size is 5MB');
        setState(() => _isUploading = false);
        return;
      }

      if (platformFile.bytes == null) {
        _showErrorSnackBar('Could not read file');
        setState(() => _isUploading = false);
        return;
      }

      String? content;
      final extension = platformFile.extension?.toLowerCase();

      // Handle different file types
      if (extension == 'pdf') {
        content = await _extractTextFromPdf(platformFile.bytes!);
        if (content == null) {
          _showErrorSnackBar('Could not extract text from PDF');
          setState(() => _isUploading = false);
          return;
        }
      } else if (extension == 'txt') {
        content = String.fromCharCodes(platformFile.bytes!);
      } else {
        _showErrorSnackBar('Unsupported file format');
        setState(() => _isUploading = false);
        return;
      }

      if (!mounted) return;

      widget.controller.text = content;
      setState(() {
        _fileName = platformFile.name;
        _isFileUploaded = true;
        _isUploading = false;
      });

      _showSuccessSnackBar('File "${platformFile.name}" uploaded successfully');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error reading file: ${e.toString()}');
        setState(() => _isUploading = false);
      }
    }
  }

  void _clearFile() {
    widget.controller.clear();
    setState(() {
      _isFileUploaded = false;
      _fileName = null;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: widget.controller,
          maxLines: 5,
          minLines: 3,
          validator: (val) =>
              (val?.trim().isEmpty ?? true) ? "This field is required" : null,
          decoration: InputDecoration(
            hintText: "Enter document text or upload a file (TXT, PDF)",
            icon: Icon(Icons.edit_document, color: widget.color),
            suffixIcon: _buildSuffixIcons(),
            enabledBorder: _buildBorder(
              _isFileUploaded ? Colors.green : widget.color,
              _isFileUploaded ? 2 : 1,
            ),
            focusedBorder: _buildBorder(
              _isFileUploaded ? Colors.green : widget.color,
              2,
            ),
            errorBorder: _buildBorder(Colors.red, 1),
            focusedErrorBorder: _buildBorder(Colors.red, 2),
          ),
        ),
        if (_isFileUploaded && _fileName != null) _buildFileIndicator(),
      ],
    );
  }

  Widget _buildSuffixIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFileUploaded)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            onPressed: _clearFile,
            tooltip: 'Clear file',
            splashRadius: 20,
          ),
        _UploadButton(
          onPressed: _pickFile,
          isUploading: _isUploading,
          color: widget.color,
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _buildFileIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'File: $_fileName',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.onPressed,
    required this.isUploading,
    required this.color,
  });

  final VoidCallback onPressed;
  final bool isUploading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUploading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUploading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.upload_file, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  isUploading ? 'Loading...' : 'Upload',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}