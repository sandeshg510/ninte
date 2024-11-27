import 'dart:io';

void main() {
  final Directory libDir = Directory('lib');
  final String importStatement = "import 'package:ninte/presentation/theme/app_theme.dart';";
  
  void processFile(File file) {
    if (!file.path.endsWith('.dart')) return;
    
    // Skip app_theme.dart itself
    if (file.path.endsWith('app_theme.dart')) return;
    
    final content = file.readAsStringSync();
    
    // Check if file uses AppColors
    if (content.contains('AppColors.') && !content.contains(importStatement)) {
      // Find the last import statement
      final lines = content.split('\n');
      int lastImportIndex = -1;
      
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().startsWith('import ')) {
          lastImportIndex = i;
        }
      }
      
      // Insert the import after the last import statement
      if (lastImportIndex >= 0) {
        lines.insert(lastImportIndex + 1, importStatement);
        
        // Write back to file
        file.writeAsStringSync(lines.join('\n'));
        print('Added import to ${file.path}');
      }
    }
  }
  
  void processDirectory(Directory dir) {
    for (var entity in dir.listSync()) {
      if (entity is File) {
        processFile(entity);
      } else if (entity is Directory) {
        processDirectory(entity);
      }
    }
  }
  
  processDirectory(libDir);
  print('Import statements added successfully!');
} 