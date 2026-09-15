# Case
Case study

## Headroom-plugin

Projektet har Headroom-pluginet aktiverat via `.claude/settings.json`
(marketplace: `headroomlabs-ai/headroom`, plugin: `headroom` v0.37.0).

Pluginet är två hooks — SessionStart och PreToolUse — som kör
`headroom init hook ensure`. Kommandot kräver att Headroom-CLI:t finns på PATH.

### Startup-hook

`.claude/hooks/session-start.sh` installerar CLI:t när en websession startar,
så att plugin-hooksen slutar fela vid varje Bash-anrop. Den kör bara i remote-
sessioner (`CLAUDE_CODE_REMOTE=true`), hoppar över allt om `headroom` redan
finns, och låter aldrig ett misslyckat install fälla sessionen.

Installationen använder baspaketet `headroom-ai`, inte `headroom-ai[all]`.
Basen är allt hooksen behöver och tar ~5–15 s; `[all]` tar ~30 s och det är tid
som läggs på varje kall sessionsstart. Börjar du använda MCP-servern
(`headroom mcp install`) eller komprimeringsproxyn (`headroom wrap`) byter du
till `headroom-ai[all]` i hooken.

### Lokal maskin

Hooken rör inte din egen dator. Där installerar du en gång:

```bash
uv tool install --python 3.13 "headroom-ai[all]"
# eller: pip install "headroom-ai[all]"
```
