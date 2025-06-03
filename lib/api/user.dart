import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
  });
}

final supabase = Supabase.instance.client;

class UserApi {
  // 新增用户
  static Future<void> createUser(UserModel user) async {
    await supabase.from('users').insert({
      'username': user.username,
      'email': user.email,
      'avatar': user.avatar,
    });
  }

  // 查询用户（通过email）
  static Future<UserModel?> getUserByEmail(String email) async {
    final res =
        await supabase.from('users').select().eq('email', email).single();
    return UserModel(
      id: res['id'],
      username: res['username'],
      email: res['email'],
      avatar: res['avatar'],
    );
  }

  // 更新用户头像
  static Future<void> updateAvatar(String email, String avatar) async {
    await supabase.from('users').update({'avatar': avatar}).eq('email', email);
  }

  // 删除用户
  static Future<void> deleteUser(String email) async {
    await supabase.from('users').delete().eq('email', email);
  }
}
