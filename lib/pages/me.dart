import 'package:flutter/material.dart';
import 'package:school_forum/api/local_storage.dart';
import 'package:school_forum/api/user.dart';
import 'package:school_forum/main.dart';
import 'package:school_forum/theme.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  UserModel? user;
  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final loggedIn = await LocalStorage.isLoggedIn();
      if (loggedIn) {
        final userData = await LocalStorage.getUser();
        setState(() {
          isLoggedIn = loggedIn;
          user = userData;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoggedIn = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _generateAvatarUrl(String? username) {
    // 使用DiceBear API生成随机头像
    final seed = username ?? 'default';
    return 'https://api.dicebear.com/7.x/avataaars/png?seed=$seed&size=120';
  }

  Future<void> _logout() async {
    await LocalStorage.clear();
    setState(() {
      isLoggedIn = false;
      user = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已退出登录'),
          backgroundColor: Color(0xFF00D4AA),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: context.colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Text('请先登录', style: context.textTheme.headlineMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 用户信息卡片
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainer,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 头像
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        _generateAvatarUrl(user?.username),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 用户名
                    Text(
                      user!.username,
                      style: context.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    // 邮箱
                    Text(user!.email, style: context.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),

          // 功能菜单
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.edit,
                  title: '编辑资料',
                  onTap: () {
                    // 导航到编辑资料页面
                  },
                ),
                _buildMenuItem(
                  icon: Icons.favorite,
                  title: '我的收藏',
                  onTap: () {
                    // 导航到收藏页面
                  },
                ),
                _buildMenuItem(
                  icon: Icons.article,
                  title: '我的帖子',
                  onTap: () {
                    // 导航到我的帖子页面
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: '设置',
                  onTap: () {
                    // 导航到设置页面
                  },
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  onTap: () {
                    // 导航到帮助页面
                  },
                ),
                const SizedBox(height: 16),
                // 退出登录按钮
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: _logout,
                    child: Text('退出登录', style: context.textTheme.bodyMedium),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: context.colorScheme.secondary),
        title: Text(title, style: context.textTheme.bodyMedium),
        trailing: Icon(
          Icons.chevron_right,
          color: context.colorScheme.secondary,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: context.colorScheme.primary,
                ),
              )
              : isLoggedIn
              ? _buildUserProfile()
              : _buildLoginPrompt(),
    );
  }
}
