import 'dart:io';

import 'package:school_forum/api/supabase.dart';

const String bucketName = 'post-images';

class PostModel {
  int? id;
  final String avatar;
  final String username;
  final String tag;
  final String timeAgo;
  final String content;
  final List<String> images;
  int likeCount;

  PostModel({
    this.id,
    required this.avatar,
    required this.username,
    required this.tag,
    required this.timeAgo,
    required this.content,
    required this.images,
    this.likeCount = 0,
  });
}

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
        id: item['id'],
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

  static Future<List<PostModel>> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final res = await supabase
        .from('posts')
        .select()
        .or('content.ilike.%$query%,username.ilike.%$query%,tag.ilike.%$query%')
        .order('created_at', ascending: false);

    return (res as List).map((item) {
      return PostModel(
        id: item['id'],
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

  static Future<void> likePost(int postId) async {
    final res =
        await supabase
            .from('posts')
            .select('like_count')
            .eq('id', postId)
            .single();
    final current = res['like_count'] ?? 0;
    await supabase
        .from('posts')
        .update({'like_count': current + 1})
        .eq('id', postId);
  }

  static Future<String> uploadImageToSupabase(
    String filePath,
    String fileName,
  ) async {
    final file = File(filePath);
    await supabase.storage.from(bucketName).upload(fileName, file);

    final url = supabase.storage.from(bucketName).getPublicUrl(fileName);

    return url;
  }
}
