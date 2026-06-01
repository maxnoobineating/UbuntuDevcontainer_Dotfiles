---
name: dotfile-env-setup
description: "Current dotfile/provisioning architecture, esp32 ESP-IDF env, and the migration goals being planned"
metadata: 
  node_type: memory
  type: project
  originSessionId: 833425ea-99b9-4a53-8a30-bed9645f60d9
---

**Current dotfile management:** Atlassian bare-repo pattern. Bare repo at `~/.cfg`, alias `dotfile='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'` (in both .zshrc and .bashrc). Remote: github.com/maxnoobineating/UbuntuDevcontainer_Dotfiles. ~111 files tracked. `status.showUntrackedFiles no`.

**Bootstrap:** a GitHub gist script (`~/e42e875d0360dec9122ab5d088e66fd0/Ubuntu_Devcontainer_dotfile_setup.sh`) run via `/bin/zsh <(curl ...)`. Imperatively installs node/nvm, oh-my-zsh+p10k+plugins, vim (compiled from source), universal-ctags, gh CLI, tmux, python tooling, C/C++ tooling (pwndbg, valgrind, nasm), then clones+checks-out dotfiles, backing up conflicts to `~/config-backup`.

**RUNTIME TOPOLOGY (confirmed 2026-05-27):** The working dev env is itself a **Docker container** (`/.dockerenv` present, hostname 8eb3d9f41963). Root `/` is an **overlay (ephemeral writable layer)** — anything installed into `$HOME` that isn't in a Dockerfile is LOST on container recreate. `~/nand2tetris_volumn` is a **separate persistent disk** (`/dev/sdc`, ext4) — project source survives rebuilds. `docker` CLI is NOT available inside the container; image builds happen on the Windows host.

**Host-side control layer:** `~/nand2tetris_volumn/projects/esp32/Docker_images_utils.ps1` — a PowerShell `DevContainer` class (loaded from Windows `$PROFILE`). Already implements the layered architecture: `ubuntu-base-image` ← `dockerfile_base.dockerfile`; `ubuntu-devcontainer` (adds dotfiles/pkgs) ← `dotfile_setup.dockerfile`; `development/dev_sidequest:latest` (project image) ; `dockerfileUpdate.dockerfile` for updates. **These build dockerfiles are NOT in the WSL filesystem or the dotfile repo — they live on the Windows host (not version-controlled with everything else = a portability gap).** The class also: mounts the single `nand2tetris_volumn` volume to `/root/nand2tetris_volumn` (shared across all project containers), maps ports, runs `dotfile pull` inside the container on start (live config sync ✓), bridges clipboard host↔container via `/mnt/c/clipboard.txt` + `clip.exe` polling (matches `pwdc`/`ipwritefile.py`), and does **USB hotplug for flashing already solved** via usbipd-win + `--device-cgroup-rule 'c 188:* rmw'` (ttyUSB) / `'c 166:* rmw'` (ttyACM) + `mknod` on attach. So WSL2 USB flashing is DONE, not a todo.

**esp32 project** (`~/nand2tetris_volumn/projects/esp32`): ESP-IDF v6.0.1, installed **today via `eim` (Espressif Installation Manager, /usr/bin/eim) into `~/.espressif` (8.7 GB) — i.e. into the ephemeral overlay layer, captured by NO Dockerfile.** `idf.py` not on PATH (needs `source ~/.espressif/tools/activate_idf_v6.0.1.sh`). `eim_config.toml` pins versions and IS effectively a declarative recipe for the IDF install. Stub `Dockerfile` (`FROM my-dev-image:latest`, wrong libpython3.9 pin) is disconnected from the ps1 system. **THE CORE GAP:** esp-idf currently lives where it will be lost on rebuild; it needs to either be baked into the esp32 image (cleanest: `FROM espressif/idf:v6.0.1`, official) or installed onto the persistent `/dev/sdc` volume (point IDF_TOOLS_PATH there).

**Pain points identified:** host is polluted (go, nvm, deno, brew, .espressif, pwndbg, stray Python-3.12 source tree, etc.); provisioning is imperative/fragile/unpinned; `~/pkglist` referenced by installPackages.sh doesn't exist; provisioning split across gist + dotfiles repo.

**Migration goals (2026-05-27, planning stage — not yet executed):**
1. vim → nvim.
2. Comprehensive dotfile sync to port env to other devices without losing tooling.
3. Per-project containerized envs (e.g. esp32) mounted under `~/nand2tetris_volumn`, not a shared hot pot.
4. Portability via Dockerfile/recipe (not whole-image), with main-env changes flowing back into the recipe.

**Why:** Avoid dependency hot-pot; reproducible portable env. **How to apply:** favor layered approach — live git-synced dotfiles vs declarative Dockerfile/provision for system tooling; recommend official `espressif/idf:v6.0.1` image over 8.7GB host install; note WSL2 USB flashing needs usbipd-win.
