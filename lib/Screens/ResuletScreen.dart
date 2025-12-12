// import 'package:flutter/material.dart';
// import 'package:irassimant/main.dart';

// class ResultScreen extends StatefulWidget {
//   final List<String> documents;

//   const ResultScreen({super.key, required this.documents});

//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen> {
//   String? _selectedTerm1;
//   String? _selectedTerm2;
//   String _selectedOperator = 'AND';
//   List<int> _queryResults = [];
//   String _queryProcess = '';
//   bool _showResults = false;

//   @override
//   Widget build(BuildContext context) {
//     final cleanedDocs =
//         widget.documents.map((d) => d.trim().toLowerCase()).toList();
//     final terms = _extractTerms(cleanedDocs);
//     final incidenceMatrix = _buildIncidenceMatrix(terms, cleanedDocs);
//     final invertedIndex = _buildInvertedIndex(terms, cleanedDocs);

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           "Information Retrieval Results",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//           ),
//         ),
//         backgroundColor: MycolorApp[0],
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               MycolorApp[0].withOpacity(0.05),
//               Colors.grey[50]!,
//             ],
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildStatsCard(cleanedDocs.length, terms.length),
//               const SizedBox(height: 24),

//               // Boolean Query Section
//               _buildSectionHeader(
//                 icon: Icons.search_rounded,
//                 title: "Boolean Query Search",
//                 subtitle: "Select terms and operation",
//                 color: Colors.deepPurple,
//               ),
//               const SizedBox(height: 16),
//               _buildQueryCard(
//                   terms, invertedIndex, cleanedDocs, incidenceMatrix),
//               const SizedBox(height: 32),

//               _buildSectionHeader(
//                 icon: Icons.grid_on_rounded,
//                 title: "Term-Document Count Matrix",
//                 subtitle: "Term-Document Incidence Matrix",
//                 color: MycolorApp[0],
//               ),
//               const SizedBox(height: 16),
//               _buildMatrixCard(terms, incidenceMatrix, MycolorApp),
//               const SizedBox(height: 32),
//               _buildSectionHeader(
//                 icon: Icons.storage_rounded,
//                 title: "Inverted Index",
//                 subtitle: "Term to Document Mapping",
//                 color: MycolorApp[1],
//               ),
//               const SizedBox(height: 16),
//               _buildInvertedCard(invertedIndex, MycolorApp),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQueryCard(
//       List<String> terms,
//       Map<String, List<int>> invertedIndex,
//       List<String> docs,
//       Map<String, List<int>> matrix) {
//     return Card(
//       elevation: 3,
//       shadowColor: Colors.deepPurple.withOpacity(0.3),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Boolean Queries',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.deepPurple,
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Term 1 Selection
//             _buildTermSelector(
//               label: 'Select First Term',
//               value: _selectedTerm1,
//               terms: terms,
//               onChanged: (val) => setState(() => _selectedTerm1 = val),
//             ),
//             const SizedBox(height: 16),

//             // Operator Selection
//             _buildOperatorSelector(),
//             const SizedBox(height: 16),

//             // Term 2 Selection (only for AND/OR)
//             if (_selectedOperator != 'NOT')
//               _buildTermSelector(
//                 label: 'Select Second Term',
//                 value: _selectedTerm2,
//                 terms: terms,
//                 onChanged: (val) => setState(() => _selectedTerm2 = val),
//               ),

//             const SizedBox(height: 20),

//             // Search Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _canSearch()
//                     ? () {
//                         setState(() {
//                           _processQueryWithVisualization(
//                               invertedIndex, docs.length, matrix);
//                         });
//                       }
//                     : null,
//                 icon: const Icon(Icons.play_arrow_rounded),
//                 label:
//                     const Text('Execute Query', style: TextStyle(fontSize: 16)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   disabledBackgroundColor: Colors.grey[300],
//                 ),
//               ),
//             ),

//             // Results Display
//             if (_showResults) ...[
//               const SizedBox(height: 24),
//               const Divider(thickness: 2),
//               const SizedBox(height: 20),

//               // Query Display
//               _buildQueryDisplay(),
//               const SizedBox(height: 16),

//               // Process Visualization
//               _buildProcessVisualization(),
//               const SizedBox(height: 16),

//               // Final Results
//               _buildFinalResults(),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTermSelector({
//     required String label,
//     required String? value,
//     required List<String> terms,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[700],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.grey[50],
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: value,
//               hint: const Text('Choose a term'),
//               isExpanded: true,
//               icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
//               items: terms.map((term) {
//                 return DropdownMenuItem(
//                   value: term,
//                   child: Text(term),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOperatorSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Select Operator',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[700],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: _buildOperatorChip('AND', Icons.add_circle_outline),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: _buildOperatorChip('OR', Icons.join_inner_rounded),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: _buildOperatorChip('NOT', Icons.block_rounded),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildOperatorChip(String operator, IconData icon) {
//     final isSelected = _selectedOperator == operator;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedOperator = operator;
//           if (operator == 'NOT') {
//             _selectedTerm2 = null;
//           }
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.deepPurple : Colors.grey[100],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
//             width: 2,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Colors.white : Colors.grey[600],
//               size: 24,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               operator,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.grey[700],
//                 fontWeight: FontWeight.bold,
//                 fontSize: 13,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   bool _canSearch() {
//     if (_selectedTerm1 == null) return false;
//     if (_selectedOperator != 'NOT' && _selectedTerm2 == null) return false;
//     return true;
//   }

//   void _processQueryWithVisualization(Map<String, List<int>> invertedIndex,
//       int totalDocs, Map<String, List<int>> matrix) {
//     List<int> term1Docs = invertedIndex[_selectedTerm1!] ?? [];
//     List<int> term2Docs =
//         _selectedTerm2 != null ? (invertedIndex[_selectedTerm2!] ?? []) : [];

//     StringBuffer process = StringBuffer();

//     if (_selectedOperator == 'AND') {
//       // Show the AND process
//       List<int> term1Binary = matrix[_selectedTerm1!] ?? [];
//       List<int> term2Binary = matrix[_selectedTerm2!] ?? [];

//       process.write('($_selectedTerm1) = ${term1Binary.join(' ')} AND\n');
//       process.write('($_selectedTerm2) = ${term2Binary.join(' ')}\n\n');
//       process.write('Result = ');

//       List<int> resultBinary = [];
//       for (int i = 0; i < term1Binary.length; i++) {
//         resultBinary.add(term1Binary[i] & term2Binary[i]);
//       }
//       process.write(resultBinary.join(' '));

//       _queryResults =
//           term1Docs.where((doc) => term2Docs.contains(doc)).toList();
//     } else if (_selectedOperator == 'OR') {
//       // Show the OR process
//       List<int> term1Binary = matrix[_selectedTerm1!] ?? [];
//       List<int> term2Binary = matrix[_selectedTerm2!] ?? [];

//       process.write('($_selectedTerm1) = ${term1Binary.join(' ')} OR\n');
//       process.write('($_selectedTerm2) = ${term2Binary.join(' ')}\n\n');
//       process.write('Result = ');

//       List<int> resultBinary = [];
//       for (int i = 0; i < term1Binary.length; i++) {
//         resultBinary.add((term1Binary[i] | term2Binary[i]));
//       }
//       process.write(resultBinary.join(' '));

//       Set<int> combined = {...term1Docs, ...term2Docs};
//       _queryResults = combined.toList()..sort();
//     } else if (_selectedOperator == 'NOT') {
//       // Show the NOT process
//       List<int> term1Binary = matrix[_selectedTerm1!] ?? [];

//       process.write('NOT ($_selectedTerm1) = NOT ${term1Binary.join(' ')}\n\n');
//       process.write('Result = ');

//       List<int> resultBinary = [];
//       for (int val in term1Binary) {
//         resultBinary.add(val == 0 ? 1 : 0);
//       }
//       process.write(resultBinary.join(' '));

//       List<int> allDocs = List.generate(totalDocs, (i) => i + 1);
//       _queryResults = allDocs.where((doc) => !term1Docs.contains(doc)).toList();
//     }

//     _queryProcess = process.toString();
//     _showResults = true;
//   }

//   Widget _buildQueryDisplay() {
//     String queryText = '';
//     if (_selectedOperator == 'NOT') {
//       queryText = '($_selectedOperator $_selectedTerm1)';
//     } else {
//       queryText = '($_selectedTerm1 $_selectedOperator $_selectedTerm2)';
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue[200]!, width: 2),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.code, color: Colors.blue, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Query:',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.blue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   queryText,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProcessVisualization() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.orange[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.orange[200]!, width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.settings, color: Colors.orange[700], size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 'Process:',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.orange[700],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               _queryProcess,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontFamily: 'monospace',
//                 height: 1.6,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFinalResults() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _queryResults.isEmpty ? Colors.red[50] : Colors.green[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: _queryResults.isEmpty ? Colors.red[200]! : Colors.green[200]!,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 _queryResults.isEmpty ? Icons.cancel : Icons.check_circle,
//                 color: _queryResults.isEmpty ? Colors.red : Colors.green,
//                 size: 24,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 _queryResults.isEmpty
//                     ? 'No documents found'
//                     : 'Result: ${_queryResults.map((d) => 'Doc$d').join(', ')}',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                   color: _queryResults.isEmpty
//                       ? Colors.red[700]
//                       : Colors.green[700],
//                 ),
//               ),
//             ],
//           ),
//           if (_queryResults.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: _queryResults.map((docNum) {
//                 return Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: Colors.green,
//                       width: 2,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.description,
//                         size: 16,
//                         color: Colors.green,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         'Document $docNum',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsCard(int docCount, int termCount) {
//     return Card(
//       elevation: 300,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             colors: [
//               MycolorApp[0].withOpacity(0.8),
//               MycolorApp[1].withOpacity(0.8)
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: _buildStatItem(
//                 icon: Icons.description_rounded,
//                 label: "Documents",
//                 value: docCount.toString(),
//               ),
//             ),
//             Container(
//               width: 1,
//               height: 50,
//               color: Colors.white.withOpacity(0.3),
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 icon: Icons.text_fields_rounded,
//                 label: "Unique Terms",
//                 value: termCount.toString(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white, size: 32),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.white.withOpacity(0.9),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionHeader({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Container(
//             height: 3,
//             width: 60,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<String> _extractTerms(List<String> docs) {
//     final Set<String> terms = {};
//     for (var doc in docs) {
//       final words = doc.split(RegExp(r'[^a-zA-Z0-9]+'));
//       terms.addAll(words);
//     }
//     terms.removeWhere((t) => t.isEmpty);
//     final sortedTerms = terms.toList()..sort();
//     return sortedTerms;
//   }

//   Map<String, List<int>> _buildIncidenceMatrix(
//       List<String> terms, List<String> docs) {
//     final Map<String, List<int>> matrix = {};
//     for (var term in terms) {
//       matrix[term] = List.generate(docs.length, (index) {
//         return docs[index].contains(term) ? 1 : 0;
//       });
//     }
//     return matrix;
//   }

//   Map<String, List<int>> _buildInvertedIndex(
//       List<String> terms, List<String> docs) {
//     final Map<String, List<int>> inverted = {};
//     for (var term in terms) {
//       inverted[term] = [];
//       for (int i = 0; i < docs.length; i++) {
//         if (docs[i].contains(term)) inverted[term]!.add(i + 1);
//       }
//     }
//     return inverted;
//   }

//   Widget _buildMatrixCard(
//       List<String> terms, Map<String, List<int>> matrix, List<Color> colors) {
//     return Card(
//       elevation: 2,
//       shadowColor: colors[0].withOpacity(0.3),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white,
//         ),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Table(
//               border: TableBorder.all(
//                 color: Colors.grey[300]!,
//                 width: 1,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               columnWidths: const {0: FixedColumnWidth(140)},
//               defaultColumnWidth: const FixedColumnWidth(80),
//               children: [
//                 TableRow(
//                   decoration: BoxDecoration(
//                     color: colors[0],
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(8),
//                       topRight: Radius.circular(8),
//                     ),
//                   ),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Row(
//                         children: [
//                           Icon(Icons.label_rounded,
//                               color: Colors.white, size: 18),
//                           const SizedBox(width: 6),
//                           const Text(
//                             "Term",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     for (int i = 0; i < matrix.values.first.length; i++)
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column(
//                           children: [
//                             Icon(Icons.description,
//                                 color: Colors.white, size: 18),
//                             const SizedBox(height: 4),
//                             Text(
//                               "Doc${i + 1}",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 fontSize: 13,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//                 for (var term in terms)
//                   TableRow(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                     ),
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Text(
//                           term,
//                           style: TextStyle(
//                             color: colors[0],
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                       for (var val in matrix[term]!)
//                         Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: val == 1
//                                   ? colors[2].withOpacity(0.15)
//                                   : Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                 color: val == 1 ? colors[2] : Colors.grey[400]!,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Text(
//                               val.toString(),
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: val == 1 ? colors[2] : Colors.grey[600],
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInvertedCard(
//       Map<String, List<int>> inverted, List<Color> colors) {
//     return Card(
//       elevation: 2,
//       shadowColor: colors[1].withOpacity(0.3),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           color: Colors.white,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: inverted.entries.map((entry) {
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: colors[1].withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: colors[1].withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: colors[1],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       entry.key,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Icon(Icons.arrow_forward_rounded,
//                       color: colors[1].withOpacity(0.6), size: 20),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Wrap(
//                       spacing: 6,
//                       runSpacing: 6,
//                       children: entry.value.map((docNum) {
//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(
//                               color: colors[2].withOpacity(0.5),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.description_outlined,
//                                 size: 14,
//                                 color: colors[2],
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'Doc$docNum',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: colors[2],
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
