# Case
Case study 

## Headroom-plugin

Projektet har Headroom-pluginet aktiverat via `.claude/settings.json`
(marketplace: `headroomlabs-ai/headroom`, plugin: `headroom` v0.37.0).

Pluginet består av SessionStart- och PreToolUse-hooks som kör
`headroom init hook ensure`. Det kräver att Headroom-CLI:t finns på PATH:

```bash
uv tool install --python 3.13 "headroom-ai[all]"
# eller: pip install "headroom-ai[all]"
```

Saknas binären misslyckas hooken utan att blockera, men den loggar ett fel
vid varje Bash-anrop.
