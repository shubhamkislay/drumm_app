import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class DebouncedBrightnessProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Holds the debounced (stable) brightness value.
  Brightness _stableBrightness;

  Timer? _debounceTimer;

  DebouncedBrightnessProvider()
      : _stableBrightness = PlatformDispatcher.instance.platformBrightness {
    // Register this object as an observer.
    WidgetsBinding.instance.addObserver(this);
  }

  Brightness get stableBrightness => _stableBrightness;

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    // Cancel any previous debounce timer.
    _debounceTimer?.cancel();

    // Start a debounce timer (e.g. 200 milliseconds).
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // Use PlatformDispatcher to get the current brightness.
      final newBrightness = PlatformDispatcher.instance.platformBrightness;
      if (newBrightness != _stableBrightness) {
        _stableBrightness = newBrightness;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    super.dispose();
  }
}
