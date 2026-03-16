#!/usr/bin/env bash
set -euo pipefail

TEXT="${1:-}"
OUT="${2:-out.wav}"

if [ -z "$TEXT" ]; then
  echo "Usage: $0 \"text to speak\" [out.wav]"
  exit 1
fi

VENV="$HOME/.uix-voice-venv"
if [ ! -d "$VENV" ]; then
  echo "Virtualenv not found. Create and install TTS per README."
  exit 1
fi

source "$VENV/bin/activate"
python - <<PY
from TTS.api import TTS
models = TTS.list_models()
if not models:
    print('No models available. Install or download a Coqui model first.')
    raise SystemExit(1)
model_name = models[0]
print('Using TTS model:', model_name)
model = TTS(model_name)
model.tts_to_file(text='''${TEXT}''', file_path='${OUT}')
PY

echo "Synthesized to ${OUT}"
