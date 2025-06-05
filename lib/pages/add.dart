import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_forum/api/local_storage.dart';
import 'package:school_forum/api/post.dart';

class AddPage extends StatefulWidget {
  final String selectedTag;

  const AddPage({super.key, required this.selectedTag});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _imageUrls = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final rawName = picked.name.replaceAll(RegExp(r'[^\w\.-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$rawName';
    final url = await PostApi.uploadImageToSupabase(picked.path, fileName);

    setState(() {
      _imageUrls.add(url);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片上传成功'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Text(
          '发布${widget.selectedTag}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _publishPost();
            },
            child: const Text(
              '发布',
              style: TextStyle(
                color: Color(0xFF00D4AA),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标签显示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.selectedTag,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),

            TextField(
              controller: _titleController,
              maxLength: 30,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '请输入标题',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            // 内容输入框
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: '分享你想说的...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            // 底部工具栏
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _pickImage();
                  },
                  icon: const Icon(Icons.photo, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _publishPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入帖子内容'), backgroundColor: Colors.red),
      );
      return;
    }
    final user = await LocalStorage.getUser();
    if (user == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('用户未登录'), backgroundColor: Colors.red),
      );
      return;
    }
    final post = PostModel(
      avatar: "123",
      username: user!.username,
      tag: widget.selectedTag,
      timeAgo: "刚刚",
      content: _contentController.text.trim(),
      images: _imageUrls,
      likeCount: 0,
    );

    PostApi.createPost(post)
        .then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('帖子发布成功'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('发布失败: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
