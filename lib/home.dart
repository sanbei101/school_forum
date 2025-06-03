import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class PostModel {
  final String avatar;
  final String username;
  final String tag;
  final String timeAgo;
  final String content;
  final List<String> images;
  final int likeCount;

  PostModel({
    required this.avatar,
    required this.username,
    required this.tag,
    required this.timeAgo,
    required this.content,
    required this.images,
    this.likeCount = 0,
  });
}

final List<PostModel> basePosts = [
  PostModel(
    avatar: '🙋‍♀️',
    username: '美好的时时',
    tag: '本科生',
    timeAgo: '刚刚',
    content:
        '回忆一下植物学和植物学实验\n孟雷老师的课。宝宝们回忆一下去年考了什么好吧，题型和具体分值，要是能想起来具体的名词解释、填空选择，大题问题就更好了，留下微信号我加你给你发红包🧧',
    images: ['https://placehold.co/600x400/png'],
  ),
  PostModel(
    avatar: '🐦',
    username: '偷外卖必挂',
    tag: '硕士生',
    timeAgo: '刚刚',
    content:
        '赢赢赢。其他农大的p图冒充中农\n原来我们的小破农也是别人的白月光，期末又被压塔的背又挺起来了😩（关键是又是一个折腾yolo的还让评论区质疑我农水平了😂）',
    images: [
      'https://placehold.co/600x400/png',
      'https://placehold.co/600x400/png',
      'https://placehold.co/600x400/png',
    ],
    likeCount: 1,
  ),
  PostModel(
    avatar: '🐹',
    username: 'lzl',
    tag: '高中生',
    timeAgo: '刚刚',
    content: '求助程序设计b期末考试\n请问在哪里看考试时间呀',
    images: [],
  ),
];

final List<PostModel> posts = List.generate(
  10,
  (index) => basePosts[index % basePosts.length],
);

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                '赞噢校园集市',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: posts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildPostItem(posts[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFF00D4AA),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: '集市'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '我的',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加新帖子功能
        },
        backgroundColor: const Color(0xFF00D4AA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostItem(PostModel post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
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
                backgroundColor: Colors.grey[800],
                child: Text(post.avatar, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066CC),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      post.timeAgo,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 12),
          // 帖子内容
          Text(
            post.content,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.4,
            ),
          ),
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
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(post.images[index], fit: BoxFit.cover),
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
                color: Colors.grey[400],
                size: 20,
              ),
              const Spacer(),
              if (post.likeCount > 0) ...[
                Icon(Icons.favorite, color: Colors.red, size: 20),
                const SizedBox(width: 4),
                Text(
                  post.likeCount.toString(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ] else
                Icon(Icons.favorite_border, color: Colors.grey[400], size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
