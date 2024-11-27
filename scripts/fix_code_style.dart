import 'dart:io';

void main() async {
  // Run flutter format
  await Process.run('flutter', ['format', '.']);
  
  // Run dart fix
  await Process.run('dart', ['fix', '--apply']);
  
  // Run flutter analyze
  final result = await Process.run('flutter', ['analyze']);
  print(result.stdout);
} 