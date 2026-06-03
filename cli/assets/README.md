# GodoMaster

[**English**](README.en.md) | **简体中文**

基于 Godot 官方文档打造的 Claude Code 游戏开发技能包，覆盖 Godot 4.x 完整开发工作流。

## 包含内容

| 领域 | 覆盖范围 |
|------|----------|
| **项目配置** | 渲染器选择、目录结构、.gitignore、自动加载、输入映射 |
| **编辑器** | 快捷键、面板、调试器、性能监视器、远程场景树 |
| **GDScript** | 类型系统、@export、信号、移动模式、状态机、对象池 |
| **节点与场景** | 完整节点参考、场景组合、生命周期、组件模式 |
| **2D 开发** | 精灵、TileMapLayer、地形、视差滚动、2D 光照、粒子、相机 |
| **3D 开发** | 模型导入、PBR 材质、灯光、环境、雾、天空、导航 |
| **物理系统** | 碰撞层、受击箱/伤害箱、射线检测、刚体、关节 |
| **动画系统** | AnimationPlayer、Tween（链式/并行/缓动）、AnimationTree、程序化动画 |
| **UI 设计** | Control 节点、布局、锚点、主题、对话系统、背包 UI |
| **音频系统** | 音频总线、音效池、空间音频、动态音乐分层 |
| **输入系统** | Input Map、原始输入、手柄、触屏、虚拟摇杆、按键重映射 |
| **导出发布** | Windows/Mac/Linux/Web/Android/iOS、CI/CD、Steam/itch.io |
| **性能优化** | 性能分析、DrawCall、MultiMesh、遮挡剔除、对象池 |
| **文件读写** | 存档系统、JSON、ConfigFile、CSV、Resource、加密 |
| **着色器** | 2D 特效（溶解、描边、水面）、3D 材质（全息、力场）、后处理 |
| **网络联机** | ENet、RPC、MultiplayerSpawner/Synchronizer、大厅、客户端预测 |

## 安装方式

### NPM（推荐）

```bash
# 全局安装，自动复制到 ~/.claude/skills/godomaster/
npm install -g godomaster-skill

# 或者直接运行，不安装
npx godomaster-skill
```

可选项：
- `npx godomaster-skill --force` — 覆盖已有安装
- `npx godomaster-skill --dry-run` — 预览不安装

### Shell 一键安装（curl）

```bash
# 从仓库直接安装
curl -fsSL https://raw.githubusercontent.com/yanha/GodoMaster/main/install.sh | bash

# 强制重新安装
curl -fsSL https://raw.githubusercontent.com/yanha/GodoMaster/main/install.sh | bash -s -- --force
```

### 手动复制

将技能包复制到 `~/.claude/skills/godomaster/`：

```
~/.claude/skills/
└── godomaster/
    ├── SKILL.md              ← 主入口（路由 + 快速参考）
    └── references/           ← 16 个详细参考文档
        ├── 01-godot-project-setup.md
        ├── 02-godot-editor-mastery.md
        ├── ...
        └── 16-godot-networking.md
```

### Claude 插件市场

通过插件系统安装：

```json
// .claude-plugin/plugin.json
{
  "name": "godomaster",
  "skills": ["./.claude/skills/godomaster"]
}
```

## 使用方式

输入 `/godomaster` 调用主技能，或在对话中提及 Godot 相关关键词自动加载对应参考：

| 你说 | 自动加载 |
|------|----------|
| "新建一个 Godot 项目" | 项目配置 |
| "写一个角色移动脚本" | GDScript + 物理 |
| "做一个溶解着色器" | 着色器 |
| "实现存档功能" | 文件读写 |
| "优化 DrawCall" | 性能优化 |
| "怎么做多人联机" | 网络联机 |
| "搭建主菜单 UI" | UI 设计 |
| "添加背景音乐和音效" | 音频系统 |

## Agent 集成（可选）

如果你在使用 `godot-master` 等 Godot 相关的 Agent，可以让 Agent 也能调用技能包的知识库。编辑 Agent 的配置文件（如 `~/.claude/agents/godot-master.md`），在「知识范围」段落前添加：

```markdown
## 知识库

当需要查阅详细技术参考时，读取以下 GodoMaster 技能包文件：

- **主入口**：`~/.claude/skills/godomaster/SKILL.md`（路由索引 + 快速参考）
- **参考文档目录**：`~/.claude/skills/godomaster/references/`，共 16 个模块

| 文件 | 内容 |
|------|------|
| `01-godot-project-setup.md` | 项目配置、渲染器、目录结构、自动加载 |
| `02-godot-editor-mastery.md` | 编辑器快捷键、面板、调试工具 |
| `03-gdscript-pro.md` | GDScript 类型系统、信号、状态机、对象池 |
| `04-godot-nodes-scenes.md` | 节点参考、场景组合、生命周期、组件模式 |
| `05-godot-2d-fundamentals.md` | 精灵、TileMap、视差、2D 光照、相机 |
| `06-godot-3d-fundamentals.md` | 模型导入、PBR 材质、灯光、环境、导航 |
| `07-godot-physics.md` | 碰撞层、受击箱、射线检测、刚体、关节 |
| `08-godot-animation.md` | AnimationPlayer、Tween、AnimationTree |
| `09-godot-ui-design.md` | Control 节点、布局、锚点、主题、对话系统 |
| `10-godot-audio.md` | 音频总线、音效池、空间音频、动态音乐 |
| `11-godot-input-system.md` | Input Map、手柄、触屏、按键重映射 |
| `12-godot-export-deploy.md` | 导出预设、CI/CD、Steam/itch.io |
| `13-godot-performance.md` | 性能分析、DrawCall、MultiMesh、对象池 |
| `14-godot-file-io.md` | 存档系统、JSON、ConfigFile、加密 |
| `15-godot-shaders.md` | 画布着色器、空间着色器、后处理 |
| `16-godot-networking.md` | ENet、RPC、同步器、大厅、客户端预测 |
```

配置完成后，Agent 在回答 Godot 问题时会自动查阅这些参考文档，与 Skill 共用同一套知识库。

## 项目结构

```
GodoMaster/
├── skill.json                    # 技能元数据
├── README.md                     # 中文文档（主页）
├── README.en.md                  # 英文文档
├── CLAUDE.md                     # 项目指引
├── install.sh                    # Shell 安装脚本
├── .gitignore
├── .claude-plugin/
│   ├── plugin.json               # 插件配置
│   └── marketplace.json          # 市场上架配置
├── .claude/skills/godomaster/
│   ├── SKILL.md                  # 主技能（路由 + 快速参考）
│   └── references/               # 16 个详细参考文档
│       ├── 01-godot-project-setup.md     # 项目配置
│       ├── 02-godot-editor-mastery.md    # 编辑器精通
│       ├── 03-gdscript-pro.md            # GDScript 进阶
│       ├── 04-godot-nodes-scenes.md      # 节点与场景
│       ├── 05-godot-2d-fundamentals.md   # 2D 基础
│       ├── 06-godot-3d-fundamentals.md   # 3D 基础
│       ├── 07-godot-physics.md           # 物理系统
│       ├── 08-godot-animation.md         # 动画系统
│       ├── 09-godot-ui-design.md         # UI 设计
│       ├── 10-godot-audio.md             # 音频系统
│       ├── 11-godot-input-system.md      # 输入系统
│       ├── 12-godot-export-deploy.md     # 导出发布
│       ├── 13-godot-performance.md       # 性能优化
│       ├── 14-godot-file-io.md           # 文件读写
│       ├── 15-godot-shaders.md           # 着色器
│       └── 16-godot-networking.md        # 网络联机
├── cli/
│   ├── package.json              # NPM 包配置
│   ├── bin/install.js            # 安装脚本
│   └── assets/                   # 技能文件
└── src/godomaster/               # 源码目录（未来扩展）
    ├── data/                     # 数据文件
    └── templates/                # 模板文件
```

## 快速参考

### GDScript 基础结构

```gdscript
extends CharacterBody2D
class_name Player

const SPEED := 300.0
signal health_changed(new_health: int)

@export var max_health := 100
@onready var sprite := $Sprite2D

var health: int
var velocity := Vector2.ZERO

func _ready() -> void:
    health = max_health

func _physics_process(delta: float) -> void:
    var direction := Input.get_axis("move_left", "move_right")
    velocity.x = direction * speed
    move_and_slide()
```

### 常用节点组合

```
Player (CharacterBody2D)
├── CollisionShape2D
├── Sprite2D / AnimatedSprite2D
├── AnimationPlayer
├── Camera2D
├── Hitbox (Area2D) → CollisionShape2D
└── Hurtbox (Area2D) → CollisionShape2D

HUD (CanvasLayer)
├── MarginContainer
│   ├── HealthBar (TextureProgressBar)
│   └── ScoreLabel (Label)
```

### 渲染器选择

| 渲染器 | 适用场景 |
|--------|----------|
| **Forward+** | 桌面端，高画质 |
| **Mobile** | 中端设备，画质与性能平衡 |
| **Compatibility** | 低端设备、Web、老旧硬件 |

### 碰撞层规划

```
Layer 1: 玩家      Mask: 2,3,4
Layer 2: 墙壁      Mask: (无)
Layer 3: 敌人      Mask: 1,2
Layer 4: 拾取物    Mask: 1
```

## 许可证

MIT
