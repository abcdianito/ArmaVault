import 'package:flutter/material.dart';
import 'services/wikipedia_services.dart';

class WikipediaTestScreen extends StatefulWidget {
  const WikipediaTestScreen({super.key});

  @override
  State<WikipediaTestScreen> createState() => _WikipediaTestScreenState();
}

class _WikipediaTestScreenState extends State<WikipediaTestScreen> {
  final TextEditingController _controller =
      TextEditingController(text: 'M16A2');

  bool _loading = false;
  Map<String, dynamic>? _data;
  String? _error;

  Future<void> _searchWikipedia() async {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _data = null;
      _error = null;
    });

    final result = await WikipediaService.getFirearmInfo(name);

    setState(() {
      _loading = false;

      if (result != null) {
        _data = result;
      } else {
        _error = 'No Wikipedia article found.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _data?['thumbnail']?['source'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wikipedia API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Firearm Model',
                hintText: 'Example: M16A2',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _searchWikipedia,
                child: const Text('Fetch from Wikipedia'),
              ),
            ),

            const SizedBox(height: 20),

            if (_loading)
              const CircularProgressIndicator(),

            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),

            if (_data != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        Image.network(
                          imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),

                      const SizedBox(height: 16),

                      Text(
                        _data!['title'] ?? 'No title',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _data!['description'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _data!['extract'] ?? 'No summary available.',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}