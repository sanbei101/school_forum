import 'package:supabase_flutter/supabase_flutter.dart';

class PostModel {
  final String avatar;
  final String username;
  final String tag;
  final String timeAgo;
  final String content;
  final List<String> images;
  final int likeCount;

  PostModel({
    required this.avatar,
    required this.username,
    required this.tag,
    required this.timeAgo,
    required this.content,
    required this.images,
    this.likeCount = 0,
  });
}

final supabase = Supabase.instance.client;

class PostApi {
  static Future<void> createPost(PostModel post) async {
    await supabase.from('posts').insert({
      'avatar': post.avatar,
      'username': post.username,
      'tag': post.tag,
      'time_ago': post.timeAgo,
      'content': post.content,
      'images': post.images,
      'like_count': post.likeCount,
    });
  }

  static Future<List<PostModel>> getPosts() async {
    final res = await supabase.from('posts').select();
    return (res as List).map((item) {
      return PostModel(
        avatar: item['avatar'],
        username: item['username'],
        tag: item['tag'],
        timeAgo: item['time_ago'],
        content: item['content'],
        images: List<String>.from(item['images']),
        likeCount: item['like_count'] ?? 0,
      );
    }).toList();
  }
}
