# 项目 12：校园生活服务 App（Flutter）

> 本文件仅描述需求，不包含任何实现代码。UI 基础 Material，不美化。

## 一、项目简介
一站式校园 App：课表、成绩、图书馆、食堂、校园卡、失物招领、社团活动、校园地图、二手交易。面向在校生的日常高频场景。

## 二、技术栈
- Flutter 3.22+ / Dart 3
- 状态：Riverpod + freezed（不可变模型）
- 路由：go_router
- 存储：Hive + shared_preferences
- 地图：flutter_map（OpenStreetMap 瓦片，Web 可用）
- 二维码：qr_flutter（校园卡付款码展示）
- Mock：本地 JSON

## 三、页面清单（≥14 页）与导航

| 序号 | 页面 | 路由 | 说明 |
|------|------|------|------|
| 1 | 启动页 | `/` | 引导 / 跳转登录 |
| 2 | 学号登录 | `/login` | 学号 + 密码 |
| 3 | 首页 | `/home` | 九宫格入口 + 今日课表摘要 |
| 4 | 课表 | `/schedule` | 周视图，左右切换周 |
| 5 | 课程详情 | `/course/:id` | 教师、教室、作业提醒 |
| 6 | 成绩查询 | `/grades` | 学期选择、GPA 汇总 |
| 7 | 成绩详情 | `/grades/:termId` | 单科分数、学分 |
| 8 | 图书馆 | `/library` | 在借/可借/search |
| 9 | 图书详情 | `/book/:id` | 借阅、预约、馆藏位置 |
| 10 | 借阅记录 | `/library/records` | 应还日期、续借 |
| 11 | 食堂菜单 | `/canteen` | 各食堂窗口、今日菜品 |
| 12 | 菜品详情 | `/dish/:id` | 营养、评价、收藏 |
| 13 | 校园卡 | `/campus-card` | 余额、消费记录 |
| 14 | 充值页 | `/campus-card/topup` | Mock 充值 |
| 15 | 失物招领 | `/lost-found` | 列表 Tab：寻物/招领 |
| 16 | 发布失物 | `/lost-found/publish` | 表单 + 图片占位 |
| 17 | 社团活动 | `/clubs` | 活动列表、报名 |
| 18 | 活动详情 | `/club/:id` | 介绍、报名人数、报名按钮 |
| 19 | 校园地图 | `/map` | 建筑标注、路径示意 |
| 20 | 二手市场 | `/market` | 商品列表 |
| 21 | 商品详情 | `/market/:id` | 联系卖家（Mock 聊天入口） |
| 22 | 发布二手 | `/market/publish` | 标题、价格、分类 |
| 23 | 消息中心 | `/messages` | 系统通知、交易消息 |
| 24 | 个人中心 | `/profile` | 学籍信息、设置入口 |

**底部导航**：首页 | 课表 | 发现(二手+社团) | 我的

## 四、核心功能需求
1. 课表：按周解析 CRON 式节次，支持添加自定义课程（本地）
2. 成绩：加权 GPA 自动计算
3. 图书馆：借书上限 5 本、续借一次规则
4. 校园卡：消费流水筛选（近 7 天/30 天）
5. 失物：状态（进行中/已解决）
6. 二手：收藏、浏览历史、简单举报
7. 地图：至少 10 个 POI 标注，点击弹出简介 BottomSheet
8. 全局搜索：跨模块搜索（课程名、书名、二手标题）

## 五、编译与调试
- `flutter run -d chrome`
- 地图在 Web 使用 flutter_map + OSM，不依赖 Google Maps
- `flutter build web`

## 六、交付物
- 完整 Flutter 工程
- `assets/mock/`：课表、成绩、图书、菜品、二手数据
- `README.md`：页面路由图（Mermaid）、运行说明

## 七、本次任务
**只列出需求和架构规划，不要写代码。**
请输出：
1. 模块划分（schedule / grades / library / canteen / card / lost_found / clubs / map / market）
2. 路由与 BottomNavigation 嵌套 ShellRoute 设计
3. 数据模型清单（≥15 个 entity）
4. 跨页面状态共享方案（如校园卡余额全局刷新）
5. 课表周视图算法要点
6. Web 兼容注意点
