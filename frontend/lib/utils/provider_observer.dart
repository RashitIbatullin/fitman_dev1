import 'package:flutter_riverpod/flutter_riverpod.dart';

// This is a useful debugging tool.
// It catches and prints any error that occurs within any Riverpod provider.
// Keep this file for future troubleshooting.
class SimpleProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // We can leave this empty if we only care about errors.
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    print('[ProviderObserver] Provider ${provider.name ?? provider.runtimeType} threw an error:');
    print('Error: $error');
    print('StackTrace: $stackTrace');
  }
}
