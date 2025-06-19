import 'package:flutter/material.dart';
import 'package:school_forum/api/post.dart';
import 'package:school_forum/pages/components/post_card.dart';
import 'package:school_forum/pages/components/post_type_selector.dart';
import 'package:school_forum/pages/post.dart';
import 'package:school_forum/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> _postFurure;

  void _showPostTypeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const PostTypeSelector(),
    );
  }

  @override
  void initState() {
    super.initState();
    _postFurure = _fetchPosts();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _postFurure = _fetchPosts();
    });
  }

  Future<List<PostModel>> _fetchPosts() async {
    try {
      final posts = await PostApi.getAllPosts();
      return posts;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载帖子失败: $e'),
            backgroundColor: context.colorScheme.errorContainer,
          ),
        );
      }
      return Future.error(e);
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
              child: FutureBuilder(
                future: _postFurure,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('加载失败', style: context.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _onRefresh,
                            child: const Text('点击重试'),
                          ),
                        ],
                      ),
                    );
                  }

                  final posts = snapshot.data!;
                  if (posts.isEmpty) {
                    return Center(
                      child: Text(
                        '暂无帖子，快来发布第一个吧！',
                        style: context.textTheme.labelLarge,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: posts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: posts[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PostPage(post: posts[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
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
}
