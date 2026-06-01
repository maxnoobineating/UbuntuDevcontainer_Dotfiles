---
name: project-context
description: ESP32 cat ventilation project and IDF toolchain setup details
metadata: 
  node_type: memory
  type: project
  originSessionId: 67fded5a-e96e-4bdc-b68a-f3d175a61b76
---

Building an ESP32-based cat ventilation controller. IDF v6.0.1, activated via `source /root/.espressif/tools/activate_idf_v6.0.1.sh`.

Clangd LSP setup: `idf.py -B build.clang reconfigure` (no `-D IDF_TOOLCHAIN=clang` — that flag picks up system clang which lacks Xtensa backend). Symlink `compile_commands.json` → `./build.clang/compile_commands.json`.

`project_setup.sh` at `/root/nand2tetris_volumn/projects/esp32/project_setup.sh` — must be `source`d, not executed, because the IDF activation script checks it's running in the current shell.

**Why:** IDF activation sets env vars that must persist in the calling shell; a subshell would discard them.
