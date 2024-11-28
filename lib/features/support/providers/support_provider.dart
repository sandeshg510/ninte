import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/support_service.dart';

final supportServiceProvider = Provider<SupportService>((ref) {
  return SupportService();
}); 