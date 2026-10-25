import 'dart:convert';

import 'package:http/http.dart' as http;

class Release {
  final String tag;
  final String name;
  final String releasedAt;
  final List<({String name, String url})> assets;

  const Release(this.tag, this.name, this.releasedAt, this.assets);
}

Future<List<Release>> fetchReleases({http.Client? client}) async {
  final c = client ?? http.Client();
  try {
    final uri = Uri.parse(
      'https://gitlab.com/api/v4/projects/HttpAnimations%2Fsunset/releases?per_page=20',
    );
    final res = await c
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final decoded = jsonDecode(res.body);
    if (decoded is! List) return const [];
    return [
      for (final r in decoded)
        if (r is Map<String, dynamic>)
          Release(
            '${r['tag_name'] ?? ''}',
            '${r['name'] ?? ''}',
            '${r['released_at'] ?? ''}',
            [
              for (final l in r['assets']?['links'] as List? ?? const [])
                if (l is Map && l['url'] is String)
                  (name: '${l['name'] ?? l['url']}', url: '${l['url']}'),
            ],
          ),
    ];
  } finally {
    if (client == null) c.close();
  }
}
