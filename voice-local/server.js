#!/usr/bin/env node
const express = require('express');
const multer = require('multer');
const { execFile } = require('child_process');
const path = require('path');
const fs = require('fs');

const upload = multer({ dest: '/tmp/voice-upload' });
const app = express();
const PORT = process.env.VOICE_PORT || 3003;

app.post('/transcribe', upload.single('audio'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'no file' });
  const filePath = path.resolve(req.file.path);
  const baseDir = path.resolve(process.env.HOME || '~', '.openclaw', 'voice-local');
  const whisperBin = path.join(baseDir, 'whisper.cpp', 'main');
  const modelPath = process.env.WHISPER_MODEL || path.join(process.env.HOME || '~', '.whisper', 'tiny.en.ggmlv3.q4_0.bin');

  if (!fs.existsSync(whisperBin)) {
    return res.status(500).json({ error: 'whisper binary not found. Run install.sh' });
  }

  const args = ['-m', modelPath, '-f', filePath, '-otxt'];
  execFile(whisperBin, args, (err, stdout, stderr) => {
    if (err) {
      console.error('whisper error', err, stderr);
      return res.status(500).json({ error: 'transcription failed', details: stderr });
    }
    const txtPath = filePath + '.txt';
    if (fs.existsSync(txtPath)) {
      const text = fs.readFileSync(txtPath, 'utf8');
      return res.json({ transcript: text });
    }
    return res.json({ transcript: stdout || stderr });
  });
});

app.listen(PORT, () => console.log(`Voice-local server listening on ${PORT}`));
