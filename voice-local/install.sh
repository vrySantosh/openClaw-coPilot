#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$HOME/.openclaw/voice-local"
WHISPER_DIR="$BASE_DIR/whisper.cpp"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

echo "Installing dependencies (you may need to run these commands manually depending on your OS)..."

if [[ "$(uname)" == "Darwin" ]]; then
  echo "macOS detected. Ensure Homebrew is installed."
  brew install cmake git python@3.11 || true
else
  echo "Linux detected. Ensure git, cmake, make, python3, pip are installed."
fi

if [ ! -d "$WHISPER_DIR" ]; then
  git clone https://github.com/ggerganov/whisper.cpp.git "$WHISPER_DIR"
else
  echo "whisper.cpp already exists at $WHISPER_DIR"
fi

pushd "$WHISPER_DIR"
make -j$(nproc || sysctl -n hw.ncpu || echo 2)
popd

echo "Download a small model (tiny.en recommended for English):"
echo "  mkdir -p ~/.whisper && cd ~/.whisper"
echo "  curl -L -o tiny.en.ggmlv3.q4_0.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/models/ggml-tiny.en.bin"

echo "Coqui TTS setup (manual steps):"
echo "  python3 -m venv ~/.uix-voice-venv"
echo "  source ~/.uix-voice-venv/bin/activate"
echo "  pip install TTS soundfile"

echo "Install complete (scaffold only). See $BASE_DIR/README.md for usage."
