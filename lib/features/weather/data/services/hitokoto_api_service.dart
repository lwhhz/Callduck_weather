import 'dart:convert';
import 'package:http/http.dart' as http;

class HitokotoApiService {
  static const String apiUrl = 'https://api.xygeng.cn/one';

  Future<Hitokoto> getHitokoto() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode != 200) {
      throw Exception('请求失败，状态码: ${response.statusCode}');
    }

    final result = json.decode(response.body);
    final data = result['data'];
    
    if (data == null) {
      throw Exception('无效的响应数据');
    }
    
    return Hitokoto(
      id: data['id'] ?? 0,
      content: data['content'] ?? '每日一句加载失败',
      from: data['origin'] ?? '未知',
      fromWho: data['name'] ?? '',
      type: data['tag'] ?? 'a',
      creator: data['name'] ?? '未知',
    );
  }
}

class Hitokoto {
  final int id;
  final String content;
  final String from;
  final String fromWho;
  final String type;
  final String creator;

  Hitokoto({
    required this.id,
    required this.content,
    required this.from,
    required this.fromWho,
    required this.type,
    required this.creator,
  });
}
