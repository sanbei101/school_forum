import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:school_forum/api/supabase.dart';
import 'package:school_forum/api/user.dart';

const String bucketName = 'post-images';

class PostModel {
  final int id;
  final UserModel user;
  final String tag;
  final String createTime;
  final String title;
  final String content;
  final List<String> images;
  final List<CommentModel> comments;
  int likeCount;

  PostModel({
    required this.id,
    required this.user,
    required this.tag,
    required this.createTime,
    required this.title,
    required this.content,
    this.images = const [],
    this.comments = const [],
    this.likeCount = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      tag: json['tag'],
      createTime: json['create_time'],
      title: json['title'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ??
          [],
      likeCount: json['like_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'tag': tag,
      'create_time': createTime,
      'title': title,
      'content': content,
      'images': images,
      'like_count': likeCount,
    };
  }
}

class CommentModel {
  final int id;
  final int postId;
  final String content;
  final String createTime;
  final UserModel user;

  CommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.createTime,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['post_id'],
      content: json['content'],
      createTime: json['create_time'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'content': content,
      'create_time': createTime,
      'user': user.toJson(),
    };
  }
}

class PostApi {
  static Future<PostModel?> createPost({
    required String userId,
    required String tag,
    required String title,
    required String content,
    List<XFile>? imageFiles,
  }) async {
    try {
      List<String> imageUrls = [];

      if (imageFiles != null) {
        for (XFile imageFile in imageFiles) {
          final rawName = imageFile.name.replaceAll(RegExp(r'[^\w\.-]'), '_');

          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$rawName';
          final uploadResult = await supabase.storage
              .from(bucketName)
              .upload(fileName, File(imageFile.path));
          if (uploadResult == '') {
            throw Exception('图片上传失败: $fileName');
          }
          final imageUrl = supabase.storage
              .from(bucketName)
              .getPublicUrl(fileName);
          imageUrls.add(imageUrl);
        }
      }

      final response =
          await supabase
              .from('posts')
              .insert({
                'user_id': userId,
                'tag': tag,
                'title': title,
                'content': content,
                'images': imageUrls,
                'create_time': DateTime.now().toIso8601String(),
              })
              .select('*, user:users(*)')
              .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('创建帖子失败: $e');
    }
  }

  static Future<List<PostModel>> getAllPosts({
    int? limit,
    int? offset,
    String? tag,
  }) async {
    try {
      final query = supabase.from('posts').select('''
          *,
          user:users(*),
          comments:comments(
            *,
            user:users(*)
          )
        ''');

      if (limit != null) {
        query.limit(limit);
      }
      if (offset != null) {
        query.range(offset, offset + (limit ?? 10) - 1);
      }
      if (tag != null && tag.isNotEmpty) {
        query.eq('tag', tag);
      }

      query.order('create_time', ascending: false);

      final response = await query;

      return (response as List<dynamic>)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } catch (e) {
      throw Exception('获取帖子列表失败: $e');
    }
  }

  static Future<PostModel?> getPostById(int postId) async {
    try {
      final response =
          await supabase
              .from('posts')
              .select('*, user:users(*), comments:comments(*)')
              .eq('id', postId)
              .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('获取帖子详情失败: $e');
    }
  }

  static Future<List<PostModel>> getUserPosts(String userId) async {
    try {
      final response = await supabase
          .from('posts')
          .select('''
            *,
            user:users(*),
            comments:comments(
              *,
              user:users(*)
            )
          ''')
          .eq('user_id', userId)
          .order('create_time', ascending: false);

      return (response as List<dynamic>)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ('获取用户帖子失败: $e');
    }
  }

  static Future<PostModel?> updatePost({
    required int postId,
    String? tag,
    String? content,
    List<String>? images,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (tag != null) updateData['tag'] = tag;
      if (content != null) updateData['content'] = content;
      if (images != null) updateData['images'] = images;

      final response =
          await supabase
              .from('posts')
              .update(updateData)
              .eq('id', postId)
              .select('*, user:users(*)')
              .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw ('更新帖子失败: $e');
    }
  }

  static Future<bool> deletePost(int postId) async {
    try {
      // 先删除相关评论
      await supabase.from('comments').delete().eq('post_id', postId);

      // 再删除帖子
      await supabase.from('posts').delete().eq('id', postId);

      return true;
    } catch (e) {
      throw ('删除帖子失败: $e');
    }
  }

  static Future<int> likePost(int postId) async {
    try {
      final response = await supabase.rpc(
        'like_post',
        params: {'post_id': postId},
      );
      return response as int;
    } catch (e) {
      throw ('点赞失败: $e');
    }
  }

  static Future<List<PostModel>> searchPosts({
    required String keyword,
    int? limit,
    int? offset,
  }) async {
    try {
      final query = supabase
          .from('posts')
          .select('''
          *,
          user:users(*),
          comments:comments(
            *,
            user:users(*)
          )
        ''')
          .textSearch('content', keyword);

      if (limit != null) {
        query.limit(limit);
      }
      if (offset != null) {
        query.range(offset, offset + (limit ?? 10) - 1);
      }

      query.order('create_time', ascending: false);

      final response = await query;

      return (response as List<dynamic>)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } catch (e) {
      throw Exception('搜索帖子失败: $e');
    }
  }
}

class CommentApi {
  static Future<CommentModel?> createComment({
    required int postId,
    required String userId,
    required String content,
  }) async {
    try {
      final response =
          await supabase
              .from('comments')
              .insert({
                'post_id': postId,
                'user_id': userId,
                'content': content,
                'create_time': DateTime.now().toIso8601String(),
              })
              .select('*, user:users(*)')
              .single();

      return CommentModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 获取帖子的评论
  static Future<List<CommentModel>> getPostComments(int postId) async {
    try {
      final response = await supabase
          .from('comments')
          .select('*, user:users(*)')
          .eq('post_id', postId)
          .order('create_time', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 更新评论
  static Future<CommentModel?> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final response =
          await supabase
              .from('comments')
              .update({'content': content})
              .eq('id', commentId)
              .select('*, user:users(*)')
              .single();

      return CommentModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 删除评论
  static Future<bool> deleteComment(int commentId) async {
    try {
      await supabase.from('comments').delete().eq('id', commentId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 获取用户的评论
  static Future<List<CommentModel>> getUserComments(String userId) async {
    try {
      final response = await supabase
          .from('comments')
          .select('*, user:users(*)')
          .eq('user_id', userId)
          .order('create_time', ascending: false);

      return (response as List<dynamic>)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
