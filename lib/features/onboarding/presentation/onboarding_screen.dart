import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/platform/messages.g.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final NativeNotificationApi _api = NativeNotificationApi();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final connected = await _api.isListenerConnected();
    setState(() {
      _isConnected = connected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NotTik Setup')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.privacy_tip, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Welcome to NotTik',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'NotTik archives your notifications locally. It has NO internet access and sends your data nowhere. To start, it needs Notification Access permission.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isConnected)
                Column(
                  children: [
                    const Text(
                      'Permission Granted!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/dashboard');
                      },
                      child: const Text('Continue to Dashboard'),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    await _api.openNotificationSettings();
                  },
                  child: const Text('Grant Permission'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkStatus,
                child: const Text('Refresh Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
