import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true)
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = File(file.path).readAsStringSync();
    
    // Replace const from widgets using AppColors
    content = content.replaceAll(
      RegExp(r'const (\w+)\([^)]*AppColors\.[^)]*\)'),
      r'\1('
    );
    
    // Replace const TextStyle with AppColors
    content = content.replaceAll(
      RegExp(r'const TextStyle\([^)]*AppColors\.[^)]*\)'),
      r'TextStyle('
    );
    
    // Replace const BoxDecoration with AppColors
    content = content.replaceAll(
      RegExp(r'const BoxDecoration\([^)]*AppColors\.[^)]*\)'),
      r'BoxDecoration('
    );
    
    // Replace const Icon with AppColors
    content = content.replaceAll(
      RegExp(r'const Icon\([^)]*AppColors\.[^)]*\)'),
      r'Icon('
    );
    
    // Save file
    File(file.path).writeAsStringSync(content);
  }
  
  print('Fixed const evaluation errors in all files');
} 