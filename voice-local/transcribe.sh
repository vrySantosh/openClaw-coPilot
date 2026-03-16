#!/usr/bin/env bash
set -euo pipefail

AUDIO_FILE="${1:-}"
if [ -z "$AUDIO_FILE" ]; then
  echo "Usage: $0 /path/to/audio.wav"
  exit 1
fi

BASE_DIR="$HOME/.openclaw/voice-local"
WHISPER_DIR="$BASE_DIR/whisper.cpp"
MODEL="~/.whisper/tiny.en.ggmlv3.q4_0.bin"

if [ ! -f "$WHISPER_DIR/main" ] && [ ! -f "$WHISPER_DIR/main.exe" ]; then
  echo "whisper.cpp not built or main binary missing. Run ~/.openclaw/voice-local/install.sh first."
  exit 1
fi

"$WHISPER_DIR/main" -m "$MODEL" -f "$AUDIO_FILE" -otxt

echo "Transcription complete."
