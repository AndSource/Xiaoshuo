# 核心原则

- 中文回答
- Claude 4并行优先
- 官方Subagents标准
- MCP工具优先
- 时间感知优先

# 复杂度决策

```python
if 文件数 < 3 and 代码行数 < 200:
    使用 Claude 4 并行模式 + 基础MCP工具
elif 文件数 <= 10 and 需要专业协作:
    使用 官方Subagents + 核心MCP工具  
else:
    使用 Opus 4 + 完整MCP生态
```

# 工具优先级

## 基础层 (必须)

- Read, Write, Edit, Grep, Glob, Bash, TodoWrite

## MCP层 (优先使用)

- mcp__Context7: 实时文档查询
- mcp__fetch: 网络资源获取
- mcp__sequential-thinking: 复杂逻辑分析
- mcp__chrome-mcp-stdio: 浏览器自动化
- mcp__Playwright: 跨浏览器测试
- mcp__tavily: 搜索和内容提取
- mcp__desktop-commander: 系统操作

## 受限工具

- ⚠️ WebFetch → ✅ mcp__fetch (WebFetch可用但MCP更优)
- ⚠️ WebSearch → ✅ mcp__tavily__tavily-search (WebSearch可用但MCP更优)

# Subagents配置

## 创建方式

- 命令: `/agents`
- 存储: `.claude/agents/{name}.md`
- 格式: YAML frontmatter + Markdown

## 调用语法

- 自动委派: 基于description字段智能匹配
- 显式调用: 
  - `Use the {agent-name} subagent to {task}`
  - `Have the {agent-name} subagent {action}`
  - `Ask the {agent-name} subagent to {request}`
- 链式调用: `First use the analyzer subagent, then use the optimizer subagent`

## 创建策略

- 项目特定: 基于当前项目技术栈和需求自动生成
- 单一职责: 每个agent专注一个明确任务
- Claude生成: 先用Claude生成基础结构，再个性化定制
- 描述优化: 在description中使用"PROACTIVELY"或"MUST BE USED"提高自动使用率
- 并行优化: 在系统提示中注入Claude 4并行工具调用指导，确保subagents也能享受78%性能提升

# 执行规则

## 必须执行

1. 获取当前时间: `mcp__mcp-server-time`
2. 并行工具调用: 同时执行独立操作
3. 验证API真实性: 通过Context7确认
4. 配置质量Hooks: PreToolUse + PostToolUse

## 并行场景

- 多文件读取 → 同时Read
- 多关键词搜索 → 同时Grep  
- 多命令执行 → 同时Bash
- 多资源获取 → 同时MCP工具

## 禁止行为

- 串行执行可并行操作
- 虚构API或配置信息
- 跳过时间感知步骤
- 使用被禁用的内置工具

# Hooks配置

```json
{
  "hooks": {
    "PreToolUse": {
      "Bash": "git status --porcelain",
      "Edit": "cp $CLAUDE_FILE $CLAUDE_FILE.backup"
    },
    "PostToolUse": {
      "Edit": "npm run lint --fix 2>/dev/null || true",
      "Write": "npm run typecheck 2>/dev/null || true"
    }
  },
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git *)", "Edit(*)", "Write(*)"],
    "defaultMode": "acceptEdits"
  }
}
```

# MCP服务器配置

```bash
# SSE (推荐)
claude mcp add --transport sse docs-server https://api.example.com/sse

# HTTP  
claude mcp add --transport http api-server https://api.example.com/mcp

# 本地stdio
claude mcp add local-tools -- npx @local/mcp-server
```

# 项目初始化流程

1. `mcp__mcp-server-time`: 获取当前时间
2. 并行项目分析: Read + Grep + Glob
3. 技术栈识别: 基于依赖和文件模式
4. Subagents匹配: 检查`.claude/agents/`目录
5. 创建缺失专家: 使用`/agents`命令，自动注入并行工具调用优化指导
6. 配置Hooks管道: 基于项目类型设置