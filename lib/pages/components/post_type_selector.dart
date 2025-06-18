import 'package:flutter/material.dart';
import 'package:school_forum/pages/add.dart';
import 'package:school_forum/theme.dart';

final List<Map<String, dynamic>> postTypes = [
  {'name': '交友互配', 'icon': Icons.people, 'color': Color(0xFFFF6B6B)},
  {'name': '二手交易', 'icon': Icons.shopping_bag, 'color': Color(0xFF4ECDC4)},
  {'name': '学习交流', 'icon': Icons.school, 'color': Color(0xFF45B7D1)},
  {'name': '活动通知', 'icon': Icons.event, 'color': Color(0xFFFFA726)},
  {'name': '求助问答', 'icon': Icons.help, 'color': Color(0xFF9C27B0)},
  {'name': '其他', 'icon': Icons.more_horiz, 'color': Color(0xFF78909C)},
];

class PostTypeSelector extends StatelessWidget {
  const PostTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                ),
                itemCount: postTypes.length,
                itemBuilder: (context, index) {
                  final postType = postTypes[index];
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
                        color: context.colorScheme.surfaceBright,
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
    );
  }
}
