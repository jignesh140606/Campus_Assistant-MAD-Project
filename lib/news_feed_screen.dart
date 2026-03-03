import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/post_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API constant
// ─────────────────────────────────────────────────────────────────────────────
const _kApiUrl = 'https://jsonplaceholder.typicode.com/posts';

// ─────────────────────────────────────────────────────────────────────────────
// News Feed Screen  –  Lab 9: API Integration (GET Request & Data Display)
// ─────────────────────────────────────────────────────────────────────────────
class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  // ----- state ---------------------------------------------------------------
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ----- lifecycle -----------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // ----- API call ------------------------------------------------------------
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(_kApiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final posts = jsonData.map((e) => Post.fromJson(e)).toList();
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Server error: ${response.statusCode}. Please try again.';
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Unable to fetch data.\n'
            'Check your internet connection and try again.\n\n'
            'Details: $e';
        _isLoading = false;
      });
    }
  }

  // ----- build ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('News Feed'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchPosts,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    // ── Loading state ────────────────────────────────────────────────────────
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching posts…', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // ── Error state ──────────────────────────────────────────────────────────
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetchPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty state ──────────────────────────────────────────────────────────
    if (_posts.isEmpty) {
      return const Center(
        child: Text('No posts found.', style: TextStyle(color: Colors.grey)),
      );
    }

    // ── Success state ─────────────────────────────────────────────────────────
    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: _posts.length,
        itemBuilder: (context, index) => _PostCard(post: _posts[index]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ID badge ────────────────────────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${post.id}',
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
