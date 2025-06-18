import 'package:flutter/material.dart';
import 'package:school_forum/api/post.dart'; // 假设 PostModel 在这里
import 'package:school_forum/theme.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int _likeCount;
  bool _isLiked = false;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      if (_isLiked) {
        _likeCount--;
      } else {
        _likeCount++;
      }
      _isLiked = !_isLiked;
    });

    try {
      await PostApi.likePost(widget.post.id);
    } catch (e) {
      setState(() {
        if (_isLiked) {
          _likeCount--;
        } else {
          _likeCount++;
        }
        _isLiked = !_isLiked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainer,
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
                    widget.post.user.username[0],
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
                            widget.post.user.username,
                            style: context.textTheme.labelLarge,
                          ),
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
                              widget.post.tag,
                              style: context.textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        PostApi.formatTimeAgo(widget.post.createTime),
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
            Text(widget.post.content, style: context.textTheme.bodyMedium),
            if (widget.post.images.isNotEmpty) ...[
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
                itemCount: widget.post.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.post.images[index],
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
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: context.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color:
                        _isLiked
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: _handleLike,
                ),
                Text(
                  _likeCount > 0 ? '$_likeCount 赞' : '赞',
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
