import 'package:flutter/material.dart';
import 'package:school_forum/api/local_storage.dart';
import 'package:school_forum/api/post.dart';
import 'package:school_forum/theme.dart';

class PostPage extends StatefulWidget {
  final PostModel post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> comments = [];
  bool isLoading = false;
  bool isSubmittingComment = false;
  late PostModel currentPost;
  final currentUser = LocalStorage.getUser();

  @override
  void initState() {
    super.initState();
    currentPost = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });
    try {
      final loadComments = await CommentApi.getPostComments(widget.post.id);
      setState(() {
        comments = loadComments;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载评论失败: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('评论内容不能为空')));
      return;
    }
    setState(() {
      isSubmittingComment = true;
    });

    try {
      final userID = await LocalStorage.getUserId();
      final newComment = await CommentApi.createComment(
        postId: widget.post.id,
        userId: userID!,
        content: _commentController.text.trim(),
      );
      if (mounted && newComment != null) {
        setState(() {
          comments.insert(0, newComment);
          _commentController.clear();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('评论提交成功')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('评论提交失败')));
      }
    } finally {
      setState(() {
        isSubmittingComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帖子详情')),
      body: Column(
        children: [
          // 帖子内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 帖子头部信息
                  _buildPostHeader(),
                  const SizedBox(height: 16),

                  // 帖子标题
                  Text(currentPost.title, style: context.textTheme.titleMedium),
                  const SizedBox(height: 12),

                  // 帖子内容
                  Text(
                    currentPost.content,
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // 帖子图片
                  if (currentPost.images.isNotEmpty) _buildImageGallery(),

                  const SizedBox(height: 16),

                  // 点赞按钮
                  _buildLikeSection(),

                  const Divider(height: 32),

                  // 评论标题
                  Text(
                    '评论 (${comments.length})',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // 评论列表
                  _buildCommentsList(),
                ],
              ),
            ),
          ),

          // 发表评论区域
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage:
              currentPost.user.avatar != null
                  ? NetworkImage(currentPost.user.avatar!)
                  : null,
          child:
              currentPost.user.avatar == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentPost.user.username,
                style: context.textTheme.bodyLarge,
              ),
              Text(
                PostApi.formatTimeAgo(currentPost.createTime),
                style: context.textTheme.labelMedium,
              ),
            ],
          ),
        ),
        Chip(
          label: Text(currentPost.tag),
          backgroundColor: context.colorScheme.secondaryContainer,
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: currentPost.images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                currentPost.images[index],
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: 200,
                    color: context.colorScheme.errorContainer,
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLikeSection() {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.thumb_up_outlined),
          color: context.colorScheme.secondary,
        ),
        Text('${currentPost.likeCount}'),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (comments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('暂无评论，快来发表第一条评论吧！', style: context.textTheme.bodyLarge),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return _buildCommentItem(comment);
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage:
                comment.user.avatar != null
                    ? NetworkImage(comment.user.avatar!)
                    : null,
            child:
                comment.user.avatar == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.user.username,
                      style: context.textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      PostApi.formatTimeAgo(comment.createTime),
                      style: context.textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: context.colorScheme.surfaceContainer),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '写下你的评论...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: context.colorScheme.outline),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: isSubmittingComment ? null : _submitComment,
              icon:
                  isSubmittingComment
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.send),
              color: context.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
