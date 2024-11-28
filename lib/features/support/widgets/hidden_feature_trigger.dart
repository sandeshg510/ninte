import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:developer' as dev;

class HiddenFeatureTrigger extends StatefulWidget {
  final Widget child;
  final int tapCount;
  final VoidCallback onTriggered;

  const HiddenFeatureTrigger({
    super.key,
    required this.child,
    this.tapCount = 5,
    required this.onTriggered,
  });

  @override
  State<HiddenFeatureTrigger> createState() => _HiddenFeatureTriggerState();
}

class _HiddenFeatureTriggerState extends State<HiddenFeatureTrigger> {
  int _taps = 0;
  Timer? _resetTimer;

  void _handleTap() {
    dev.log('Tap detected! Current count: $_taps');
    _resetTimer?.cancel();
    HapticFeedback.lightImpact();
    
    setState(() => _taps++);

    if (_taps >= widget.tapCount) {
      dev.log('Trigger threshold reached!');
      HapticFeedback.mediumImpact();
      widget.onTriggered();
      _taps = 0;
    } else {
      _resetTimer = Timer(const Duration(seconds: 2), () {
        dev.log('Reset timer triggered');
        if (mounted) {
          setState(() => _taps = 0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,  // Important for reliable tap detection
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
} 