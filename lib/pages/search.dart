import 'package:flutter/material.dart';
import 'package:school_forum/api/post.dart';
import 'package:school_forum/theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PostModel> searchResults = [];
  bool isSearching = false;
  String? errorMessage;

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isSearching = true;
      errorMessage = null;
    });

    try {
      final results = await PostApi.searchPosts(keyword: query);
      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = '搜索失败，请稍后重试';
        isSearching = false;
        searchResults = [];
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
    if (isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
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
              errorMessage!,
              style: TextStyle(fontSize: 16, color: context.colorScheme.error),
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

    if (_searchController.text.isEmpty) {
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

    if (searchResults.isEmpty) {
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
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final post = searchResults[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow,
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.user.username,
                            style: context.textTheme.bodyLarge,
                          ),
                          if (post.tag.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.tag,
                                style: context.textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        PostApi.formatTimeAgo(post.createTime),
                        style: context.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 帖子内容
            Text(post.content, style: context.textTheme.bodyMedium),

            // 图片展示
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImageGrid(post.images),
            ],

            const SizedBox(height: 12),

            // 点赞按钮
            Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: context.colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                Text('${post.likeCount}', style: context.textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          images[0],
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: context.colorScheme.errorContainer,
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  color: context.colorScheme.onErrorContainer,
                ),
              ),
            );
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: images.length == 2 ? 2 : 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: images.length > 9 ? 9 : images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: context.colorScheme.errorContainer,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: context.colorScheme.onErrorContainer,
                  ),
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
