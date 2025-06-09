DROP TABLE IF EXISTS public.comments;
DROP TABLE IF EXISTS public.posts;
DROP TABLE IF EXISTS public.users;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT '初中生',
    avatar VARCHAR(255) DEFAULT 'https://placehold.co/100x100/png'
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tag VARCHAR(50) DEFAULT '学习',
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    images TEXT[] DEFAULT '{}',
    like_count INTEGER DEFAULT 0,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);
CREATE POLICY "Allow all operations on posts" ON posts FOR ALL USING (true);
CREATE POLICY "Allow all operations on comments" ON comments FOR ALL USING (true);

ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE posts_id_seq RESTART WITH 1;
ALTER SEQUENCE comments_id_seq RESTART WITH 1;
-- 插入数据

-- 插入示例用户数据
INSERT INTO users (username, email, role, avatar) VALUES
('张小明', 'zhangxiaoming@example.com', '初中生', 'https://placehold.co/100x100/png'),
('李华', 'lihua@example.com', '高中生', 'https://placehold.co/100x100/png'),
('王小红', 'wangxiaohong@example.com', '大学生', 'https://placehold.co/100x100/png'),
('陈老师', 'chenlao@example.com', '老师', 'https://placehold.co/100x100/png'),
('刘同学', 'liutongxue@example.com', '初中生', 'https://placehold.co/100x100/png');

-- 插入示例帖子数据
INSERT INTO posts (user_id, title, content, images, like_count) VALUES
(1, '我的数学学习心得', '最近在学习数学，发现做题的时候要多思考，不能只是机械地套公式。分享一些我的学习方法...', ARRAY['https://placehold.co/400x300/png', 'https://placehold.co/400x300/png'], 15),
(2, '物理实验很有趣', '今天做了一个关于光学的实验，发现了很多有趣的现象。光的折射真的很神奇！', ARRAY['https://placehold.co/500x400/png'], 23),
(3, '大学生活分享', '刚开始大学生活，感觉和高中很不一样。这里有更多的自由，但也需要更多的自律。', ARRAY[]::TEXT[], 8),
(4, '如何提高学习效率', '作为老师，我想分享一些提高学习效率的方法。首先是要制定合理的学习计划...', ARRAY['https://placehold.co/600x400/png'], 45),
(1, '今天的英语课', '英语老师教了我们一些实用的口语表达，感觉很有用。Practice makes perfect!', ARRAY['https://placehold.co/300x200/png'], 12),
(5, '化学实验注意事项', '做化学实验的时候一定要注意安全，保护好自己。今天差点出事故...', ARRAY['https://placehold.co/400x300/png', 'https://placehold.co/400x300/png'], 30);

-- 插入示例评论数据
INSERT INTO comments (post_id, user_id, content) VALUES
(1, 2, '说得很对！我也觉得数学需要多思考，不能死记硬背。'),
(1, 3, '有什么具体的学习方法可以分享吗？'),
(1, 4, '作为老师，我很赞同你的观点。继续保持这种学习态度！'),
(2, 1, '物理实验确实很有趣，我也喜欢做实验。'),
(2, 5, '光学是物理中很重要的一部分，要好好学习。'),
(3, 2, '大学生活确实需要更多自律，加油！'),
(4, 1, '老师的建议很实用，谢谢分享！'),
(4, 3, '制定学习计划确实很重要，我要试试看。'),
(4, 5, '老师讲得太好了，受益匪浅。'),
(5, 2, 'Practice makes perfect! 这句话说得太对了。'),
(6, 1, '安全第一！做实验一定要小心。'),
(6, 4, '实验安全确实很重要，同学们都要注意。');