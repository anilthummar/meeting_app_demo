import 'package:flutter/material.dart';

class LocalPreviewView extends StatelessWidget {
  const LocalPreviewView({super.key, required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: enabled ? Colors.black54 : Colors.grey.shade800,
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Icon(
        enabled ? Icons.videocam : Icons.videocam_off,
        color: Colors.white54,
        size: 28,
      ),
    );
  }
}
