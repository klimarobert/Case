#!/bin/bash
# SessionStart hook: make sure the Headroom CLI exists before the headroom
# plugin's own hooks shell out to `headroom init hook ensure`.
# Without it that command fails on every Bash tool call — non-blocking, but noisy.
set -euo pipefail

# Only needed in Claude Code on the web; local machines install headroom once by hand.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# uv installs here; keep it on PATH for this run and for the rest of the session.
export PATH="$HOME/.local/bin:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$CLAUDE_ENV_FILE"
fi

if command -v headroom >/dev/null 2>&1; then
  exit 0
fi

# Base package only. It is all the plugin hooks need and installs in ~5s, where
# headroom-ai[all] takes ~30s. Swap in "headroom-ai[all]" if you start using the
# MCP server (`headroom mcp install`) or the compression proxy (`headroom wrap`).
if command -v uv >/dev/null 2>&1; then
  uv tool install --python 3.13 headroom-ai >/dev/null 2>&1 || true
else
  pip install --user --quiet headroom-ai >/dev/null 2>&1 || true
fi

# A failed install must not fail the session — that would be the noise we are
# removing. Report once and let the plugin hooks no-op.
if ! command -v headroom >/dev/null 2>&1; then
  echo "session-start: could not install headroom-ai; headroom plugin hooks will no-op" >&2
fi

exit 0
