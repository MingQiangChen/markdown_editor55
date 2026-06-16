import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'sync_config.dart';

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

  Map<String, String> get _headers => {
    'Authorization': 'Basic ',
  };

  /// 测试连接
  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse(baseUrl),
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
        http.Request('MKCOL', Uri.parse(''))
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
        Uri.parse(''),
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
        Uri.parse(''),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return response.body;
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
        Uri.parse(''),
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
        http.Request('PROPFIND', Uri.parse(''))
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
        // 解码 URL 编码
        href = Uri.decodeFull(href);
        // 移除基础路径，只保留文件名
        if (href.startsWith(basePath)) {
          href = href.substring(basePath.length);
        }
        // 移除开头的斜杠
        if (href.startsWith('/')) {
          href = href.substring(1);
        }
        // 移除结尾的斜杠（目录）
        if (href.endsWith('/')) {
          href = href.substring(0, href.length - 1);
        }
        // 只添加非空的文件名
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
