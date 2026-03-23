import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Quick network diagnostic screen
class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  String _result = 'Tap button to test network';
  bool _isLoading = false;

  Future<void> _testNetwork() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing...';
    });

    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
          .timeout(const Duration(seconds: 10));

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          _result = '✅ SUCCESS!\n\nNetwork is working.\nStatus: ${response.statusCode}\nResponse: ${response.body.substring(0, 100)}...';
        } else {
          _result = '❌ FAILED\n\nStatus code: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '❌ ERROR\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _testNetwork,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Test Network Connection'),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _result,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
