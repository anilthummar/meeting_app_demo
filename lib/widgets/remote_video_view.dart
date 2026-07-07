import 'package:flutter/material.dart';

class RemoteVideoView extends StatelessWidget {
  const RemoteVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black87,
      alignment: Alignment.center,
      child: const Text(
        'Remote Video',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
