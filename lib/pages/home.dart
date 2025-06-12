import 'package:flutter/material.dart';
import 'package:school_forum/api/post.dart';
import 'package:school_forum/pages/add.dart';
import 'package:school_forum/pages/post.dart';
import 'package:school_forum/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PostModel> _posts = [];
  bool _loading = false;

  final List<Map<String, dynamic>> _postTypes = [
    {'name': '交友互配', 'icon': Icons.people, 'color': Color(0xFFFF6B6B)},
    {'name': '二手交易', 'icon': Icons.shopping_bag, 'color': Color(0xFF4ECDC4)},
    {'name': '学习交流', 'icon': Icons.school, 'color': Color(0xFF45B7D1)},
    {'name': '活动通知', 'icon': Icons.event, 'color': Color(0xFFFFA726)},
    {'name': '求助问答', 'icon': Icons.help, 'color': Color(0xFF9C27B0)},
    {'name': '其他', 'icon': Icons.more_horiz, 'color': Color(0xFF78909C)},
  ];

  void _showPostTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.primaryContainer,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 标题
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '选择帖子类型',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                // 类型网格
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3,
                          ),
                      itemCount: _postTypes.length,
                      itemBuilder: (context, index) {
                        final postType = _postTypes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddPage(selectedTag: postType['name']),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: postType['color'].withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  postType['icon'],
                                  color: postType['color'],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  postType['name'],
                                  style: context.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _loading = true;
    });
    try {
      _posts = await PostApi.getAllPosts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载帖子失败: $e'),
            backgroundColor: context.colorScheme.errorContainer,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('赞噢校园集市', style: context.textTheme.headlineMedium),
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _posts.isEmpty
                      ? Center(
                        child: Text(
                          '暂无帖子',
                          style: context.textTheme.labelLarge,
                        ),
                      )
                      : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _posts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildPostItem(_posts[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostTypeSelector,
        child: Icon(Icons.add, color: context.colorScheme.onPrimaryContainer),
      ),
    );
  }

  Widget _buildPostItem(PostModel post) {
    return GestureDetector(
      onTap:
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostPage(post: post)),
            ),
          },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息行
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.colorScheme.onPrimary,
                  child: Text(
                    post.user.username[0],
                    style: context.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.user.username,
                            style: context.textTheme.labelLarge,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.tag,
                              style: context.textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        post.createTime,
                        style: context.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: context.colorScheme.onPrimary),
              ],
            ),
            const SizedBox(height: 12),
            // 帖子内容
            Text(post.content, style: context.textTheme.bodyMedium),
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    post.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.broken_image,
                        color: context.colorScheme.error,
                      );
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            // 底部操作栏
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: context.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const Spacer(),

                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      post.likeCount > 0
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          post.likeCount > 0
                              ? context.colorScheme.primary
                              : context.colorScheme.surface,
                      size: 20,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await PostApi.likePost(post.id);
                      setState(() {
                        post.likeCount++;
                      });
                    } catch (e) {
                      if (!mounted) return;
                      setState(() {
                        post.likeCount =
                            post.likeCount > 0 ? post.likeCount - 1 : 0;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('点赞失败: $e'),
                          backgroundColor: context.colorScheme.error,
                        ),
                      );
                    }
                  },
                ),
                Text(
                  post.likeCount > 0 ? '${post.likeCount} 赞' : '赞',
                  style: context.textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
