Local voice stack for OpenClaw — whisper.cpp + Coqui TTS (scaffold)

Overview

This folder contains a non-invasive scaffold (no repo modifications) to run an entirely local (free) voice recognition and synthesis pipeline intended for OpenClaw integrations. Files are placed under ~/.openclaw/voice-local so they do not modify project repositories.

What this contains
- install.sh — helper to install dependencies and download recommended models (whisper.cpp)
- transcribe.sh — example script to transcribe a local audio file using whisper.cpp
- synthesize.sh — example script to synthesize text into speech using Coqui TTS (Python)
- server.js — minimal Express server that accepts file uploads, runs local transcription, and returns text (requires whisper.cpp installed)
- README.md (this file)

How I will proceed
- I created these scaffold files here under ~/.openclaw/voice-local.
- I will not commit anything to any project repo. Per your instruction, I will not perform any git commits without explicit permission.

Next steps for you to run locally
1. Run the installer script to build whisper.cpp and download a model:
   chmod +x ~/.openclaw/voice-local/install.sh && ~/.openclaw/voice-local/install.sh

2. Create and activate the Python virtualenv for Coqui TTS and install TTS:
   python3 -m venv ~/.uix-voice-venv
   source ~/.uix-voice-venv/bin/activate
   pip install TTS soundfile

3. Start the local voice server for testing:
   node ~/.openclaw/voice-local/server.js
   Then POST audio file (multipart/form-data key 'audio') to http://localhost:3003/transcribe

Security
- This is local-only scaffolding. Do not expose the server publicly unless you add TLS and authentication.

