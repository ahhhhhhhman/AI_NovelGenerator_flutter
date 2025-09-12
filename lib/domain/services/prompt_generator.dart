import '../../utils/config_service.dart';

class PromptGenerator {
  /// 生成核心种子设定提示
  String generateCoreSeedPrompt({
    required String topic,
    required String genre,
    required int numberOfChapters,
    required int wordNumber,
    String userGuidance = '',
  }) {
    return '''作为专业作家，请用"雪花写作法"第一步构建故事核心：
主题：$topic
类型：$genre
篇幅：约$numberOfChapters章（每章$wordNumber字）

请用单句公式概括故事本质，例如：
"当[主角]遭遇[核心事件]，必须[关键行动]，否则[灾难后果]；与此同时，[隐藏的更大危机]正在发酵。"

要求：
1. 必须包含显性冲突与潜在危机
2. 体现人物核心驱动力
3. 暗示世界观关键矛盾
4. 使用25-100字精准表达

仅返回故事核心文本，不要解释任何内容。''';
  }

  /// 生成角色动力学设定提示
  String generateCharacterDynamicsPrompt({
    required String userGuidance,
    required String coreSeed,
  }) {
    return '''基于以下元素：
- 内容指导：$userGuidance
- 核心种子：$coreSeed

请设计3-6个具有动态变化潜力的核心角色，每个角色需包含：
特征：
- 背景、外貌、性别、年龄、职业等
- 暗藏的秘密或潜在弱点(可与世界观或其他角色有关)

核心驱动力三角：
- 表面追求（物质目标）
- 深层渴望（情感需求）
- 灵魂需求（哲学层面）

角色弧线设计：
初始状态 → 触发事件 → 认知失调 → 蜕变节点 → 最终状态

关系冲突网：
- 与其他角色的关系或对立点
- 与至少两个其他角色的价值观冲突
- 一个合作纽带
- 一个隐藏的背叛可能性

要求：
仅给出最终文本，不要解释任何内容。''';
  }

  /// 生成角色状态文档提示
  String generateCharacterStatePrompt({
    required String characterDynamics,
  }) {
    return '''依据当前角色动力学设定：$characterDynamics

请生成一个角色状态文档，内容格式：
例：
张三：
├──物品:
│  ├──青衫：一件破损的青色长袍，带有暗红色的污渍
│  └──寒铁长剑：一柄断裂的铁剑，剑身上刻有古老的符文
├──能力
│  ├──技能1：强大的精神感知能力：能够察觉到周围人的心中活动
│  └──技能2：无形攻击：能够释放一种无法被视觉捕捉的精神攻击
├──状态
│  ├──身体状态: 身材挺拔，穿着华丽的铠甲，面色冷峻
│  └──心理状态: 目前的心态比较平静，但内心隐藏着对柳溪镇未来掌控的野心和不安
├──主要角色间关系网
│  ├──李四：张三从小就与她有关联，对她的成长一直保持关注
│  └──王二：两人之间有着复杂的过去，最近因一场冲突而让对方感到威胁
├──触发或加深的事件
│  ├──村庄内突然出现不明符号：这个不明符号似乎在暗示柳溪镇即将发生重大事件
│  └──李四被刺穿皮肤：这次事件让两人意识到对方的强大实力，促使他们迅速离开队伍

角色名：
├──物品:
│  ├──某物(道具)：描述
│  └──XX长剑(武器)：描述
│   ...
├──能力
│  ├──技能1：描述
│  └──技能2：描述
│   ...
├──状态
│  ├──身体状态：
│  └──心理状态：描述
│    
├──主要角色间关系网
│  ├──李四：描述
│  └──王二：描述
│   ...
├──触发或加深的事件
│  ├──事件1：描述
│  └──事件2：描述
    ...

新出场角色：
- (此处填写未来任何新增角色或临时出场人物的基本信息)

要求：
仅返回编写好的角色状态文本，不要解释任何内容。''';
  }

  /// 生成章节蓝图提示（每30章生成一次）
  String generateChapterBlueprintPrompt({
    required String userGuidance,
    required String novelArchitecture,
    required int totalChapters,
    required String chapterList,
    required int startChapter,
    required int endChapter,
  }) {
    return '''基于以下元素：
- 内容指导：$userGuidance
- 小说架构：
$novelArchitecture

需要生成总共$totalChapters章的节奏分布，

当前已有章节目录（若为空则说明是初始生成）：
$chapterList

现在请设计第$startChapter章到第$endChapter章的节奏分布：
1. 章节集群划分：
- 每3-5章构成一个悬念单元，包含完整的小高潮
- 单元之间设置"认知过山车"（连续2章紧张→1章缓冲）
- 关键转折章需预留多视角铺垫

2. 每章需明确：
- 章节定位（角色/事件/主题等）
- 核心悬念类型（信息差/道德困境/时间压力等）
- 情感基调迁移（如从怀疑→恐惧→决绝）
- 伏笔操作（埋设/强化/回收）
- 认知颠覆强度（1-5级）

输出格式示例：
第n章 - [标题]
本章定位：[角色/事件/主题/...]
核心作用：[推进/转折/揭示/...]
悬念密度：[紧凑/渐进/爆发/...]
伏笔操作：埋设(A线索)→强化(B矛盾)...
认知颠覆：★☆☆☆☆
本章简述：[一句话概括]

第n+1章 - [标题]
本章定位：[角色/事件/主题/...]
核心作用：[推进/转折/揭示/...]
悬念密度：[紧凑/渐进/爆发/...]
伏笔操作：埋设(A线索)→强化(B矛盾)...
认知颠覆：★☆☆☆☆
本章简述：[一句话概括]

要求：
- 使用精炼语言描述，每章字数控制在100字以内。
- 合理安排节奏，确保整体悬念曲线的连贯性。
- 在生成$totalChapters章前不要出现结局章节。

仅给出最终文本，不要解释任何内容。''';
  }

  /// 生成世界构建矩阵提示
  String generateWorldBuildingPrompt({
    required String userGuidance,
    required String coreSeed,
  }) {
    return '''基于以下元素：
- 内容指导：$userGuidance
- 核心冲突："$coreSeed"

为服务上述内容，请构建三维交织的世界观：

1. 物理维度：
- 空间结构（地理×社会阶层分布图）
- 时间轴（关键历史事件年表）
- 法则体系（物理/魔法/社会规则的漏洞点）

2. 社会维度：
- 权力结构断层线（可引发冲突的阶层/种族/组织矛盾）
- 文化禁忌（可被打破的禁忌及其后果）
- 经济命脉（资源争夺焦点）

3. 隐喻维度：
- 贯穿全书的视觉符号系统（如反复出现的意象）
- 氣候/环境变化映射的心理状态
- 建筑风格暗示的文明困境

要求：
每个维度至少包含3个可与角色决策产生互动的动态元素。
仅给出最终文本，不要解释任何内容。''';
  }

  /// 生成情节架构提示
  String generatePlotArchitecturePrompt({
    required String userGuidance,
    required String coreSeed,
    required String characterDynamics,
    required String worldBuilding,
  }) {
    return '''基于以下元素：
- 内容指导：$userGuidance
- 核心种子：$coreSeed
- 角色体系：$characterDynamics
- 世界观：$worldBuilding

要求按以下结构设计：
第一幕（触发） 
- 日常状态中的异常征兆（3处铺垫）
- 引出故事：展示主线、暗线、副线的开端
- 关键事件：打破平衡的催化剂（需改变至少3个角色的关系）
- 错误抉择：主角的认知局限导致的错误反应

第二幕（对抗）
- 剧情升级：主线+副线的交叉点
- 双重压力：外部障碍升级+内部挫折
- 虚假胜利：看似解决实则深化危机的转折点
- 灵魂黑夜：世界观认知颠覆时刻

第三幕（解决）
- 代价显现：解决危机必须牺牲的核心价值
- 嵌套转折：至少包含三层认知颠覆（表面解→新危机→终极抉择）
- 余波：留下2个开放式悬念因子

每个阶段需包含3个关键转折点及其对应的伏笔回收方案。
仅给出最终文本，不要解释任何内容。''';
  }

  /// 生成第一章草稿提示
  String generateFirstChapterDraftPrompt({
    required int novelNumber,
    required String chapterTitle,
    required String chapterRole,
    required String chapterPurpose,
    required String suspenseLevel,
    required String foreshadowing,
    required String plotTwistLevel,
    required String chapterSummary,
    required String charactersInvolved,
    required String keyItems,
    required String sceneLocation,
    required String timeConstraint,
    required String novelArchitectureText,
    required int wordNumber,
    required String userGuidance,
  }) {
    return '''即将创作：第 $novelNumber 章《$chapterTitle》
本章定位：$chapterRole
核心作用：$chapterPurpose
悬念密度：$suspenseLevel
伏笔操作：$foreshadowing
认知颠覆：$plotTwistLevel
本章简述：$chapterSummary

可用元素：
- 核心人物(可能未指定)：$charactersInvolved
- 关键道具(可能未指定)：$keyItems
- 空间坐标(可能未指定)：$sceneLocation
- 时间压力(可能未指定)：$timeConstraint

参考文档：
- 小说设定：
$novelArchitectureText

完成第 $novelNumber 章的正文，字数要求$wordNumber字，至少设计下方2个或以上具有动态张力的场景：
1. 对话场景：
   - 潜台词冲突（表面谈论A，实际博弈B）
   - 权力关系变化（通过非对称对话长度体现）

2. 动作场景：
   - 环境交互细节（至少3个感官描写）
   - 节奏控制（短句加速+比喻减速）
   - 动作揭示人物隐藏特质

3. 心理场景：
   - 认知失调的具体表现（行为矛盾）
   - 隐喻系统的运用（连接世界观符号）
   - 决策前的价值天平描写

4. 环境场景：
   - 空间透视变化（宏观→微观→异常焦点）
   - 非常规感官组合（如"听见阳光的重量"）
   - 动态环境反映心理（环境与人物心理对应）

格式要求：
- 仅返回章节正文文本；
- 不使用分章节小标题；
- 不要使用markdown格式。

额外指导(可能未指定)：$userGuidance''';
  }

  /// 生成后续章节草稿提示
  String generateNextChapterDraftPrompt({
    required String globalSummary,
    required String previousChapterExcerpt,
    required String userGuidance,
    required String characterState,
    required String shortSummary,
    required int novelNumber,
    required String chapterTitle,
    required String chapterRole,
    required String chapterPurpose,
    required String suspenseLevel,
    required String foreshadowing,
    required String plotTwistLevel,
    required String chapterSummary,
    required int wordNumber,
    required String charactersInvolved,
    required String keyItems,
    required String sceneLocation,
    required String timeConstraint,
    required int nextChapterNumber,
    required String nextChapterTitle,
    required String nextChapterRole,
    required String nextChapterPurpose,
    required String nextChapterSuspenseLevel,
    required String nextChapterForeshadowing,
    required String nextChapterPlotTwistLevel,
    required String nextChapterSummary,
  }) {
    return '''参考文档：
└── 前文摘要：
    $globalSummary

└── 前章结尾段：
    $previousChapterExcerpt

└── 用户指导：
    $userGuidance

└── 角色状态：
    $characterState

└── 当前章节摘要：
    $shortSummary

当前章节信息：
第$novelNumber章《$chapterTitle》：
├── 章节定位：$chapterRole
├── 核心作用：$chapterPurpose
├── 悬念密度：$suspenseLevel
├── 伏笔设计：$foreshadowing
├── 转折程度：$plotTwistLevel
├── 章节简述：$chapterSummary
├── 字数要求：$wordNumber字
├── 核心人物：$charactersInvolved
├── 关键道具：$keyItems
├── 场景地点：$sceneLocation
└── 时间压力：$timeConstraint

下一章节目录
第$nextChapterNumber章《$nextChapterTitle》：
├── 章节定位：$nextChapterRole
├── 核心作用：$nextChapterPurpose
├── 悬念密度：$nextChapterSuspenseLevel
├── 伏笔设计：$nextChapterForeshadowing
├── 转折程度：$nextChapterPlotTwistLevel
└── 章节简述：$nextChapterSummary

依据前面所有设定，开始完成第 $novelNumber 章的正文，字数要求$wordNumber字，
内容生成严格遵循：
-用户指导
-当前章节摘要
-当前章节信息
-无逻辑漏洞,
确保章节内容与前文摘要、前章结尾段衔接流畅、下一章目录保证上下文完整性，

格式要求：
- 仅返回章节正文文本；
- 不使用分章节小标题；
- 不要使用markdown格式。''';
  }

  /// 获取配置参数
  Map<String, dynamic> getOtherParams() {
    final config = ConfigService().getAll();
    if (config != null && config.containsKey('other_params')) {
      return Map<String, dynamic>.from(config['other_params'] as Map);
    }
    return {
      'topic': '',
      'genre': '',
      'num_chapters': 0,
      'word_number': 0,
      'user_guidance': '',
    };
  }

  /// 更新配置参数
  Future<void> updateOtherParams(Map<String, dynamic> params) async {
    for (var entry in params.entries) {
      await ConfigService().set('other_params.${entry.key}', entry.value);
    }
  }
}