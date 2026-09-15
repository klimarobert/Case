# Analysera YouTube-videor med Fabric

Setup för [danielmiessler/Fabric](https://github.com/danielmiessler/Fabric) — ett CLI där du
skickar en YouTube-länk och får tillbaka en strukturerad analys från valfri LLM.

## Så funkar det

Fabric hämtar undertexterna med `yt-dlp`, kör dem genom en *pattern* (en färdig systemprompt)
och skickar resultatet till den modell du valt. Ingen YouTube-nyckel behövs för själva
transkriptet.

## 1. Installera Fabric

**macOS**

```bash
brew install fabric-ai
echo "alias fabric='fabric-ai'" >> ~/.zshrc   # Homebrew-paketet heter fabric-ai
```

**Windows**

```powershell
winget install danielmiessler.Fabric
```

**Linux / valfritt OS**

```bash
curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash
```

Har du Go installerat går det också med
`go install github.com/danielmiessler/fabric/cmd/fabric@latest`.

## 2. Installera yt-dlp

Det här är det enda extra beroendet, och utan det säger Fabric bara ifrån direkt.

```bash
brew install yt-dlp        # macOS
winget install yt-dlp      # Windows
pipx install yt-dlp        # fungerar överallt
```

Ska du använda `--visual` (OCR på bildrutor ur videon) behöver du även `ffmpeg` och
`tesseract`. Hoppa över det tills du vet att du vill ha det.

## 3. Konfigurera

```bash
fabric --setup
```

Välj leverantör och klistra in din API-nyckel. Anthropic, OpenAI, Gemini och lokala modeller
via Ollama fungerar alla. Lämna YouTube-sektionen tom om du inte vill ha kommentarer och
metadata — det är enda stället en YouTube Data API-nyckel behövs.

## 4. Kör

```bash
fabric -y "https://www.youtube.com/watch?v=..." --stream --pattern extract_wisdom
```

Eller via skriptet i det här repot, som sätter `extract_wisdom` som default och kontrollerar
att beroendena finns:

```bash
./scripts/yta.sh "https://www.youtube.com/watch?v=..."
./scripts/yta.sh -p summarize -o analys.md "https://youtu.be/..."
```

## Patterns värda att känna till

| Pattern | Ger dig |
|---|---|
| `extract_wisdom` | Standardvalet. Idéer, insikter, citat, referenser, rekommendationer. |
| `summarize` | Sammanfattning med huvudpunkter och takeaways. |
| `create_5_sentence_summary` | Fem meningar. Bra för att snabbt sålla. |
| `extract_main_idea` | Bara kärnbudskapet. |
| `extract_insights` | Tätare och mer abstrakt än extract_wisdom. |
| `extract_recommendations` | Enbart det som föreslås göras. |
| `analyze_claims` | Går igenom påståendena och väger bevisen. Nyttig på debattinnehåll. |
| `to_flashcards` | Fråga-svar-kort. |

`fabric -l` listar alla. `fabric -U` hämtar hem senaste uppsättningen.

## Praktiska flaggor

| Flagga | Vad den gör |
|---|---|
| `-y <url>` | YouTube-video eller spellista |
| `-p <pattern>` | Vilken pattern som körs |
| `-s` / `--stream` | Skriver ut svaret löpande |
| `-o <fil>` | Sparar till fil |
| `-g sv` | Svarsspråk, t.ex. svenska |
| `-m <modell>` | Byt modell för en enskild körning |
| `--transcript-with-timestamps` | Behåller tidsstämplar, bra när du vill kunna hoppa tillbaka i videon |
| `--comments` | Tar med kommentarsfältet (kräver YouTube-nyckel) |
| `--yt-dlp-args` | Skickas vidare till yt-dlp, t.ex. `--cookies-from-browser brave` |

## Om det strular

**"yt-dlp not found"** — yt-dlp ligger inte i din PATH. Vanligt efter pipx-install på macOS,
lös med `pipx ensurepath` och starta om skalet.

**Tomt eller trasigt transkript** — videon saknar undertexter, eller så blockerar YouTube
förfrågan. Testa `--yt-dlp-args="--cookies-from-browser chrome"` så går anropet med din
inloggade session. Håll också yt-dlp uppdaterat; det är den delen som går sönder oftast när
YouTube ändrar sig.

**Långa videor kostar** — ett par timmars poddavsnitt blir lätt 30 000 tokens. Kör en billig
modell för första gallringen och spara den dyra till det du faktiskt vill gräva i.
