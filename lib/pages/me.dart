import 'package:flutter/material.dart';
import 'package:school_forum/api/local_storage.dart';
import 'package:school_forum/api/user.dart';
import 'package:school_forum/main.dart';

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
          Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('请先登录', style: TextStyle(fontSize: 18, color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 头像
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          _generateAvatarUrl(user?.username),
                        ),
                        backgroundColor: Colors.grey[800],
                        onBackgroundImageError: (_, _) {},
                        child:
                            user?.username == null
                                ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 用户名
                    Text(
                      user?.username ?? '用户',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 邮箱
                    if (user?.email != null)
                      Text(
                        user!.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('退出登录', style: TextStyle(fontSize: 16)),
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
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00D4AA)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D4AA)),
              )
              : isLoggedIn
              ? _buildUserProfile()
              : _buildLoginPrompt(),
    );
  }
}
