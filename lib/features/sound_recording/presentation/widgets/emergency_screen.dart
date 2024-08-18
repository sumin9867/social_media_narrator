import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:social_media_narrator/core/utils.dart';

class EmergencyScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onTimeout;

  const EmergencyScreen({
    super.key,
    required this.onCancel,
    required this.onTimeout,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late Timer _timer;
  int _countdown = 6; // Countdown time in seconds

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer.cancel();
          _handleTimeout();
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _handleTimeout() async {
    try {
      await Utils.makePhoneCall('9867811182');
      await Utils.sendSMS(
        phoneNumber: '9867811182',
        message: 'Emergency detected! Please take action.',
      );
    } catch (e) {
      log(e.toString());
    }
    widget.onTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Emergency Detected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Taking action in $_countdown seconds...',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _timer.cancel();
                widget.onCancel();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
