import 'package:flutter/material.dart';
import 'package:school_forum/api/post.dart';
import 'package:school_forum/pages/components/post_card.dart';
import 'package:school_forum/pages/post.dart';
import 'package:school_forum/theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<PostModel>>? _searchFuture;

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchFuture = null;
      });
    } else {
      setState(() {
        _searchFuture = PostApi.searchPosts(keyword: query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索帖子')),
      body: Column(
        children: [
          // 搜索框区域
          Container(
            color: context.colorScheme.surface,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: '搜索帖子内容、用户名或标签...',
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colorScheme.onSurface,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: context.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: context.colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // 搜索结果区域
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // 初始或已清空
    if (_searchFuture == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: context.colorScheme.onSurface),
            const SizedBox(height: 16),
            Text('输入关键词搜索帖子', style: context.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('可搜索帖子内容、用户名或标签', style: context.textTheme.labelMedium),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: context.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '搜索失败，请稍后重试',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _performSearch(_searchController.text),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!;

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: context.colorScheme.onSurface,
                ),
                const SizedBox(height: 16),
                Text('未找到相关帖子', style: context.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('试试其他关键词', style: context.textTheme.labelMedium),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder:
              (context, index) => PostCard(
                post: posts[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostPage(post: posts[index]),
                    ),
                  );
                },
              ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
