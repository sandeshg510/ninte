import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sound_service.dart';

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
}); 