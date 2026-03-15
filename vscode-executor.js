#!/usr/bin/env node

/**
 * VS Code Remote Executor for OpenClaw
 * Executes commands on Mac VS Code from remote (WhatsApp/Telegram)
 * 
 * Usage: node vscode-executor.js "command here"
 */

const { exec, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

class VSCodeExecutor {
  constructor() {
    this.homeDir = process.env.HOME;
    this.vscodeDir = path.join(this.homeDir, '.openclaw/vscode-workspace');
    this.logFile = path.join(this.homeDir, '.openclaw/executor-log.txt');
    this.ensureDirectories();
  }

  ensureDirectories() {
    if (!fs.existsSync(this.vscodeDir)) {
      fs.mkdirSync(this.vscodeDir, { recursive: true });
    }
  }

  log(message) {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${message}\n`;
    console.log(logMessage);
    fs.appendFileSync(this.logFile, logMessage);
  }

  /**
   * Execute shell command
   */
  async executeCommand(command) {
    return new Promise((resolve) => {
      this.log(`Executing: ${command}`);
      
      exec(command, { 
        timeout: 30000,
        maxBuffer: 10 * 1024 * 1024 
      }, (error, stdout, stderr) => {
        if (error) {
          const result = {
            success: false,
            error: error.message,
            stderr: stderr || '',
            stdout: stdout || ''
          };
          this.log(`Error: ${error.message}`);
          resolve(result);
        } else {
          const result = {
            success: true,
            stdout: stdout.trim(),
            stderr: stderr.trim()
          };
          this.log(`Success. Output: ${result.stdout}`);
          resolve(result);
        }
      });
    });
  }

  /**
   * Create a file
   */
  async createFile(filename, content) {
    try {
      const filePath = path.join(this.vscodeDir, filename);
      fs.writeFileSync(filePath, content);
      this.log(`File created: ${filePath}`);
      return {
        success: true,
        file: filePath,
        message: `Created file: ${filename}`
      };
    } catch (error) {
      this.log(`File creation failed: ${error.message}`);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * List files in workspace
   */
  async listFiles() {
    try {
      const files = fs.readdirSync(this.vscodeDir);
      this.log(`Listed ${files.length} files`);
      return {
        success: true,
        files: files,
        directory: this.vscodeDir
      };
    } catch (error) {
      this.log(`List files failed: ${error.message}`);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Open file in VS Code
   */
  async openInVSCode(filename) {
    try {
      const filePath = path.join(this.vscodeDir, filename);
      const command = `open -a "Visual Studio Code" "${filePath}"`;
      await this.executeCommand(command);
      this.log(`Opened in VS Code: ${filename}`);
      return {
        success: true,
        message: `Opened ${filename} in VS Code`
      };
    } catch (error) {
      this.log(`Open VS Code failed: ${error.message}`);
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Parse and execute OpenClaw instructions
   */
  async handleInstruction(userMessage) {
    this.log(`\n=== New Instruction ===\n${userMessage}\n`);
    
    // Simple command parser
    const msg = userMessage.toLowerCase();

    // Create file: "create file [filename]" or "create [filename]"
    if (msg.includes('create') && msg.includes('file')) {
      // Match patterns like: create file test.js, create file "test.js", create file called test.js
      const match = userMessage.match(/(?:create\s+file|create)\s+(?:called\s+)?["']?([^\s"']+)["']?/i);
      if (match && match[1]) {
        const filename = match[1];
        return await this.createFile(filename, `// Created by OpenClaw\n// ${new Date().toISOString()}\n`);
      }
    }

    // List files: "list files", "show files", "list"
    if ((msg.includes('list') || msg.includes('show')) && (msg.includes('files') || msg === 'list')) {
      return await this.listFiles();
    }

    // Open in VS Code: "open [filename] in vscode"
    if (msg.includes('open') && (msg.includes('vscode') || msg.includes('code'))) {
      const match = userMessage.match(/open\s+["']?([^\s"']+)["']?/i);
      if (match && match[1]) {
        return await this.openInVSCode(match[1]);
      }
    }

    // Execute shell command: "run [command]" or "execute [command]"
    if (msg.includes('run') || msg.includes('execute')) {
      const match = userMessage.match(/(?:run|execute)\s+["']?([^"']+)["']?/i);
      if (match && match[1]) {
        const cmd = match[1].replace(/["']/g, '');
        return await this.executeCommand(cmd);
      }
    }

    // Get status: "status", "health", "ping"
    if (msg.includes('status') || msg.includes('health') || msg.includes('ping')) {
      return {
        success: true,
        status: 'operational',
        workspace: this.vscodeDir,
        logFile: this.logFile,
        workspaceFiles: fs.readdirSync(this.vscodeDir).length
      };
    }

    return {
      success: false,
      error: 'No valid instruction recognized. Examples: "create file test.js", "list files", "open test.js in vscode", "run ls -la"'
    };
  }
}

// Main execution
async function main() {
  const executor = new VSCodeExecutor();
  const instruction = process.argv.slice(2).join(' ');

  if (!instruction) {
    console.error('Usage: node vscode-executor.js "your instruction"');
    console.error('Examples:');
    console.error('  node vscode-executor.js "create file hello.js"');
    console.error('  node vscode-executor.js "list files"');
    console.error('  node vscode-executor.js "status"');
    process.exit(1);
  }

  const result = await executor.handleInstruction(instruction);
  console.log(JSON.stringify(result, null, 2));
  process.exit(result.success ? 0 : 1);
}

module.exports = { VSCodeExecutor };
main().catch(err => {
  console.error(err);
  process.exit(1);
});
