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
  List<PostModel> _posts = [];
  bool _loading = false;

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
                          return PostCard(
                            post: _posts[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          PostPage(post: _posts[index]),
                                ),
                              );
                            },
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
