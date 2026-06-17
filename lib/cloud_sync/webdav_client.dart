import 'dart:convert';
import 'package:http/http.dart' as http;

/// WebDAV 客户端
class WebDavClient {
  final String baseUrl;
  final String username;
  final String password;
  final http.Client _client;

  WebDavClient({
    required this.baseUrl,
    required this.username,
    required this.password,
  }) : _client = http.Client();

  String get _normalizedBaseUrl {
    var url = baseUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  String _buildUrl(String path) {
    if (path.startsWith('/')) {
      return '$_normalizedBaseUrl$path';
    }
    return '$_normalizedBaseUrl/$path';
  }

  Map<String, String> get _headers {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    return {
      'Authorization': 'Basic $credentials',
    };
  }

  /// 测试连接
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse(_normalizedBaseUrl),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 207;
    } catch (e) {
      return false;
    }
  }

  /// 创建目录
  Future<bool> createDirectory(String path) async {
    try {
      final response = await _client.send(
        http.Request('MKCOL', Uri.parse(_buildUrl(path)))
          ..headers.addAll(_headers),
      );
      return response.statusCode == 201 || response.statusCode == 405;
    } catch (e) {
      return false;
    }
  }

  /// 上传文件
  Future<bool> uploadFile(String remotePath, String content) async {
    try {
      final response = await _client.put(
        Uri.parse(_buildUrl(remotePath)),
        headers: {
          ..._headers,
          'Content-Type': 'text/markdown; charset=utf-8',
        },
        body: utf8.encode(content),
      );
      return response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// 下载文件
  Future<String?> downloadFile(String remotePath) async {
    try {
      final response = await _client.get(
        Uri.parse(_buildUrl(remotePath)),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除文件
  Future<bool> deleteFile(String remotePath) async {
    try {
      final response = await _client.delete(
        Uri.parse(_buildUrl(remotePath)),
        headers: _headers,
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 列出目录内容
  Future<List<String>> listDirectory(String path) async {
    try {
      final response = await _client.send(
        http.Request('PROPFIND', Uri.parse(_buildUrl(path)))
          ..headers.addAll({
            ..._headers,
            'Depth': '1',
            'Content-Type': 'application/xml',
          })
          ..body = '''<?xml version="1.0" encoding="utf-8"?>
<D:propfind xmlns:D="DAV:">
  <D:prop>
    <D:displayname/>
    <D:getlastmodified/>
  </D:prop>
</D:propfind>''',
      );

      if (response.statusCode == 207) {
        final body = await response.stream.bytesToString();
        return _parsePropfindResponse(body, path);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  List<String> _parsePropfindResponse(String xml, String basePath) {
    final files = <String>[];
    final responseRegex = RegExp(r'<D:response>(.*?)</D:response>', dotAll: true);
    final hrefRegex = RegExp(r'<D:href>(.*?)</D:href>');

    for (final match in responseRegex.allMatches(xml)) {
      final hrefMatch = hrefRegex.firstMatch(match.group(1)!);
      if (hrefMatch != null) {
        var href = hrefMatch.group(1)!;
        href = Uri.decodeFull(href);
        if (href.startsWith(basePath)) {
          href = href.substring(basePath.length);
        }
        if (href.startsWith('/')) {
          href = href.substring(1);
        }
        if (href.endsWith('/')) {
          href = href.substring(0, href.length - 1);
        }
        if (href.isNotEmpty && !href.contains('/')) {
          files.add(href);
        }
      }
    }
    return files;
  }

  void dispose() {
    _client.close();
  }
}