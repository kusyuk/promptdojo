import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/watsonx_service.dart';

class WatsonxHealthNotifier extends StateNotifier<AsyncValue<bool>> {
  WatsonxHealthNotifier() : super(const AsyncValue.loading()) {
    checkHealth();
  }

  Future<void> checkHealth() async {
    try {
      final service = WatsonxService();
      final isHealthy = await service.checkHealth();
      state = AsyncValue.data(isHealthy);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setUnhealthy() {
    state = const AsyncValue.data(false);
  }
}

/// Provider that performs a health check on the Watsonx AI service.
///
/// Returns true if the service is available and configured correctly.
/// Returns false if the sandbox session has expired or the API key is invalid.
final watsonxHealthProvider =
    StateNotifierProvider<WatsonxHealthNotifier, AsyncValue<bool>>((ref) {
      return WatsonxHealthNotifier();
    });
