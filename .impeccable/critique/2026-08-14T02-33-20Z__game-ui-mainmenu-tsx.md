---
target: 游戏整体体验审查
total_score: 19
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 3
timestamp: 2026-08-14T02-33-20Z
slug: game-ui-mainmenu-tsx
---
#### Design Health Score

| # | Heuristic | Score | Key Issue |
|---|---|---:|---|
| 1 | Visibility of System Status | 2/4 | HP、等级、波次明确，但技能冷却、金币奖励和点击反馈不可见。 |
| 2 | Match System / Real World | 2/4 | 文案易懂，但“主动技能”实际自动释放，解锁规则互相冲突。 |
| 3 | User Control and Freedom | 1/4 | 移动端没有暂停入口，购买没有确认或撤销。 |
| 4 | Consistency and Standards | 3/4 | 字体、色彩和卡片结构统一，但输入方式和按钮细节不完全一致。 |
| 5 | Error Prevention | 1/4 | 锁定角色单击即可扣币，缺少确认和重复点击保护。 |
| 6 | Recognition Rather Than Recall | 2/4 | 卡片有说明，但经验条无标签，技能状态需要玩家自行记忆。 |
| 7 | Flexibility and Efficiency | 2/4 | 支持键盘、手柄和触控移动，但菜单和升级没有键盘/手柄快捷操作。 |
| 8 | Aesthetic and Minimalist Design | 3/4 | 信息克制、层级稳定，但角色和技能界面仍过度文本化。 |
| 9 | Error Recovery | 2/4 | 暂停面板可重开或返回，但移动端难以进入，失败点击静默。 |
| 10 | Help and Documentation | 1/4 | 只有桌面控制提示，没有触屏、技能机制或首次游玩引导。 |
| **Total** | | **19/40** | **基础可用，移动闭环和规则表达需优先修正。** |

#### Design Specificity Verdict

这是一个暗色秘境、波次生存 Roguelite 原型。深青黑底、旧金点缀、等宽中文字体、几何场景和信息卡片形成了稳定的视觉语言，已经不是裸调试界面。但角色、技能和战果缺少图形资产与仪式反馈，整体仍接近高完成度开发者原型，视觉特征还没有充分服务于“秘境收割者”这个产品。

自动检测器未能运行：`detect.mjs` 报告 `bundled detector not found`，没有生成规则结果，不能把“未发现问题”误报为扫描干净。浏览器后端没有可用的游戏预览页，因此未完成截图和实际点击验证；以下结论来自源码和 Dora 运行配置证据。

#### Overall Impression

主流程“大厅 -> 角色 -> 模式 -> 战斗 -> 升级 -> 结算”是清楚的，升级三选一和战场冻结也有不错的节奏感。当前最大的机会是把“能运行的系统”变成“玩家能理解、能掌控、愿意再来一局的游戏”：先修正规则和移动端闭环，再补角色/技能视觉资产与奖励仪式。

#### What's Working

- [MainMenu.tsx](E:/game/game/ui/MainMenu.tsx:170) 的大厅、角色、模式分层清楚，模式文案能快速说明风险和时长。
- [LevelUpPanel.tsx](E:/game/game/ui/LevelUpPanel.tsx:45) 的三选一结构稳定，稀有度、名称、描述和操作位置明确，并且实际冻结战斗。
- [Scene.ts](E:/game/game/scene/Scene.ts:66) 已有祭坛、菌簇、裂纹和遗迹等方向锚点，不是纯调试网格。

#### Priority Issues

1. **[P1] 移动端主流程不闭环，窄屏布局缺少保护**

   **Why it matters:** 暂停仅绑定 Esc/手柄 Start（[Input.ts](E:/game/game/input/Input.ts:64)），触屏只有左下摇杆（[VirtualJoystick.ts](E:/game/game/ui/VirtualJoystick.ts:72)），手机玩家无法主动暂停、重开或返回大厅。HUD、暂停框和升级卡也使用固定尺寸，窄屏或低高度设备会重叠或溢出。`View.size` 还在模块加载时被捕获，旋转或调整窗口后布局不会重算（[MainMenu.tsx](E:/game/game/ui/MainMenu.tsx:10)、[HUD.ts](E:/game/game/ui/HUD.ts:64)）。

   **Fix:** 增加安全区内的暂停按钮和移动端操作提示；按 `View.size` 动态计算布局；为 HUD、暂停框、角色卡和升级卡增加横屏/窄屏断点，确保所有触控目标至少 44px。

2. **[P1] 解锁规则冲突，单击直接扣除金币**

   **Why it matters:** 菜单按 300/1200 金币直接扣款（[MainMenu.tsx](E:/game/game/ui/MainMenu.tsx:21)、[MainMenu.tsx](E:/game/game/ui/MainMenu.tsx:157)），角色文案却写击杀、拾取金币、波次条件（[Characters.ts](E:/game/game/player/Characters.ts:37)），结算代码又按这些条件自动解锁（[Game.ts](E:/game/game/core/Game.ts:340)）。玩家无法理解到底是购买还是达成成就，误触还会直接损失稀缺货币。

   **Fix:** 明确“成就解锁”和“金币提前解锁”是否并行；购买与选择分成两个动作；增加确认、扣币反馈、解锁动画和重复点击锁；存档加载时校验金币和解锁列表的合法范围。

3. **[P1] 存档坏数据可能导致启动崩溃**

   **Why it matters:** [Save.ts](E:/game/game/save/Save.ts:53) 只判断 `typeof raw === 'object'`，`null` 仍会继续访问字段；`unlockedCharacters` 只判断 object，坏档传入普通对象时 `for...of` 会抛异常；`permanent`、`settings`、`stats` 也存在同样的 null 风险。用户一旦存档损坏，可能无法进入主菜单。

   **Fix:** 对根对象和嵌套对象显式排除 `null`，用 `Array.isArray` 检查数组，使用 `Number.isFinite` 和上下限归一化数值；解析失败时回退默认档并保留损坏档副本供恢复。

4. **[P2] “主动技能”与实际自动施放机制相反**

   **Why it matters:** 升级卡和技能定义写“主动技能”（[LevelUpPanel.tsx](E:/game/game/ui/LevelUpPanel.tsx:64)、[SkillDefs.ts](E:/game/game/skills/SkillDefs.ts:59)），但系统每帧自动施放并按冷却循环（[SkillSystem.ts](E:/game/game/skills/SkillSystem.ts:219)），HUD 也没有技能按钮或冷却显示。玩家会寻找不存在的施放键，或误以为自己在控制技能。

   **Fix:** 选择一个明确方向：改名为“自动技能”并增加冷却/触发提示，或提供移动端技能按钮、键盘快捷键和冷却环。

5. **[P2] 结算没有展示本局奖励和成长结果**

   **Why it matters:** [Game.ts](E:/game/game/core/Game.ts:346) 会计算金币奖励，但 [PauseMenu.tsx](E:/game/game/ui/PauseMenu.tsx:72) 只展示时间、波次、等级和击杀。玩家看不到本局获得多少金币、是否刷新纪录、离下个角色还差多少，结算情绪在最后一步泄掉。

   **Fix:** 结算面板加入本局金币、纪录变化、解锁进度和新解锁内容；把“再战一次”作为主按钮，把“返回大厅”作为次按钮。

#### Persona Red Flags

- **Alex（熟练玩家）**：菜单无法用键盘或手柄选择；升级没有数字键快捷选项；主动技能没有冷却读数和玩家控制。
- **Jordan（首次玩家）**：同时看到条件解锁和金币购买两套说法；不知道没有标签的细经验条表示什么；会把“主动技能”理解为需要寻找施放键。
- **Casey（移动玩家）**：没有暂停键；固定尺寸面板可能越过安全区；主菜单仍显示 WASD/Esc 提示；摇杆之外没有触屏操作说明。

#### Minor Observations

- 经验条只有约 6px 且没有 `EXP` 或数字标签（[HUD.ts](E:/game/game/ui/HUD.ts:88)）。
- 不可购买角色点击后静默返回，没有显示“还差多少金币”或解锁条件（[MainMenu.tsx](E:/game/game/ui/MainMenu.tsx:157)）。
- `Boss` 与全中文界面混用，建议统一为“首领”或在首次出现时双语标注。
- 伤害统计在护盾减伤或无效命中时仍按原始伤害累计（[DamageSystem.ts](E:/game/game/combat/DamageSystem.ts:36)），会让结算统计失真。
- 建议对每帧 `dt` 设置上限，避免窗口失焦后一次跳帧造成移动、伤害和冷却异常。

#### Questions to Consider

- 游戏是否明确锁定横屏？如果是，应在首次进入时锁定方向并针对低高度横屏做布局验收。
- “主动技能”希望玩家操作，还是希望完全自动触发？这会决定按钮、冷却和 HUD 结构。
- 角色条件解锁和金币解锁是并行路径，还是实现遗留？应只保留一套可被玩家理解的规则。
- 一局结束时，最希望玩家记住的是击杀数字，还是“我获得了什么、下一局能变强多少”？
