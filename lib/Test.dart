import 'dart:io';

void main() {
  print('📄 Number Of Documents');
  int n = int.parse(stdin.readLineSync()!);

  // قراءة المستندات
  List<String> documents = [];
  for (int i = 0; i < n; i++) {
    stdout.write('➡️ Enter the Number of Document : ${i + 1}: ');
    String doc = stdin.readLineSync()!.toLowerCase();
    documents.add(doc);
  }

  // استخراج كل الكلمات (terms)
  Set<String> terms = {};
  for (var doc in documents) {
    terms.addAll(doc.split(RegExp(r'\s+')).map((e) => e.replaceAll(RegExp(r'[^a-z]'), '')));
  }
  terms.removeWhere((term) => term.isEmpty);

  // إنشاء Term-Document Incidence Matrix
  Map<String, List<int>> matrix = {};
  for (var term in terms) {
    List<int> row = [];
    for (var doc in documents) {
      row.add(doc.contains(term) ? 1 : 0);
    }
    matrix[term] = row;
  }

  // طباعة Boolean Retrieval Matrix
  print('\n📊 --- Term-Document Incidence Matrix ---');
  stdout.write('Term'.padRight(20));
  for (int i = 1; i <= n; i++) {
    stdout.write('Doc$i '.padRight(6));
  }
  print('\n${'-' * (25 + n * 6)}');
  matrix.forEach((term, row) {
    stdout.write(term.padRight(20));
    for (var v in row) {
      stdout.write(v.toString().padRight(6));
    }
    print('');
  });

  // إنشاء Inverted Index
  Map<String, List<String>> invertedIndex = {};
  for (var term in terms) {
    List<String> docsContain = [];
    for (int i = 0; i < n; i++) {
      if (matrix[term]![i] == 1) docsContain.add('Doc${i + 1}');
    }
    invertedIndex[term] = docsContain;
  }

  // طباعة Inverted Index
  print('\n🔁 --- Inverted Index ---');
  invertedIndex.forEach((term, docs) {
    print('$term → ${docs.join(", ")}');
  });

  print('\n✅ Boolean Retrieval و Inverted Index!');
}
