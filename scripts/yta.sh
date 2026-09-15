#!/usr/bin/env bash
# yta.sh - analysera en YouTube-video med Fabric.
# Exempel: ./scripts/yta.sh -p summarize "https://www.youtube.com/watch?v=..."

set -euo pipefail

PATTERN="${YTA_PATTERN:-extract_wisdom}"
LANGUAGE="${YTA_LANG:-en}"
URL=""
OUTPUT=""
EXTRA=()

usage() {
    cat <<'USAGE'
Användning: yta.sh [flaggor] <youtube-url>

  -p, --pattern <namn>   Fabric-pattern (default: extract_wisdom, se `fabric -l`)
  -g, --language <kod>   Svarsspråk, t.ex. sv (default: en)
  -o, --output <fil>     Spara svaret till fil
  -t, --timestamps       Behåll tidsstämplar i transkriptet
  -h, --help             Den här hjälpen

Miljövariabler: YTA_PATTERN, YTA_LANG sätter defaultvärdena.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--pattern)    PATTERN="${2:?--pattern kräver ett värde}"; shift 2 ;;
        -g|--language)   LANGUAGE="${2:?--language kräver ett värde}"; shift 2 ;;
        -o|--output)     OUTPUT="${2:?--output kräver ett värde}"; shift 2 ;;
        -t|--timestamps) EXTRA+=(--transcript-with-timestamps); shift ;;
        -h|--help)       usage; exit 0 ;;
        --)              shift; break ;;
        -*)              echo "Okänd flagga: $1" >&2; usage >&2; exit 1 ;;
        *)               URL="$1"; shift ;;
    esac
done

if [[ -z "$URL" ]]; then
    echo "Ingen URL angiven." >&2
    usage >&2
    exit 1
fi

FABRIC="fabric"
command -v "$FABRIC" >/dev/null 2>&1 || FABRIC="fabric-ai"
if ! command -v "$FABRIC" >/dev/null 2>&1; then
    echo "Hittar inte fabric. Se docs/fabric-youtube.md för installation." >&2
    exit 127
fi

if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "Hittar inte yt-dlp. Fabric behöver det för att hämta transkriptet." >&2
    echo "Installera med: brew install yt-dlp  (eller pipx install yt-dlp)" >&2
    exit 127
fi

if [[ -n "$OUTPUT" ]]; then
    EXTRA+=(--output "$OUTPUT")
fi

# ${EXTRA[@]+...} håller det här igång under `set -u` i bash 3.2 (macOS).
exec "$FABRIC" -y "$URL" --pattern "$PATTERN" --language "$LANGUAGE" --stream \
    ${EXTRA[@]+"${EXTRA[@]}"}
