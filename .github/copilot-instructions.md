## Purpose
This file gives concise, actionable guidance for AI coding agents working on the `macbook12-spi-driver` kernel module.

Keep instructions short and code-focused: show which files to read, where to run builds/tests, and which project-specific patterns to follow.

## Big picture
- **What this repo is:** Linux kernel driver modules for MacBook SPI keyboard/trackpad and iBridge (touchbar, ALS). Key modules: `applespi`, `apple-ibridge`, `apple-ib-tb`, and `apple-ib-als`.
- **Major components:**
  - `applespi.c` — SPI-based keyboard/touchpad driver (packet/message parsing, CRC checks, input device reporting).
  - `apple-ibridge.c` — iBridge MFD/HID demux driver (registers subdrivers and forwards HID callbacks).
  - `apple-ib-tb.c` / `apple-ib-als.c` — touchbar and ambient-light sensor subdrivers.
  - `applespi.h`, `apple-ibridge.h` — public kernel interfaces and data structures.

## Files to read first (order matters)
- `README.md` — project overview, supported models, DKMS and distro packaging notes.
- `Makefile` and `dkms.conf` — how modules are built/installed and which module names are expected.
- `applespi.c` — SPI protocol, message/packet formats, module params (e.g. `fnmode`, `iso_layout`) and tracepoints.
- `apple-ibridge.c` — MFD/hid demux pattern and how subdrivers register with the main driver.

## Build & test (developer workflow)
- Local build (uses kernel build system):
  - `make` — builds modules (uses `/lib/modules/$(uname -r)/build`).
  - `make clean` — clean build artifacts.
  - `make install` — runs `modules_install`.
  - `make test` — builds then `rmmod applespi` and `insmod ./applespi.ko` (use carefully on running systems).
- DKMS (Debian/Ubuntu): follow `README.md` snippet that clones into `/usr/src/applespi-0.1` and runs `dkms install -m applespi -v 0.1`. See `dkms.conf` for module list.
- RPM/akmods: referenced in `README.md` for distro packaging. If adding packaging, follow the existing `dkms.conf` module names.

## Debugging & runtime hooks
- Tracepoints: enable packet tracing via tracefs, e.g.:
  - `echo 1 | sudo tee /sys/kernel/debug/tracing/events/applespi/applespi_keyboard_data/enable`
  - trace output is in `/sys/kernel/debug/tracing/trace`.
- Touchpad dimension and tp debug via `/sys/kernel/debug/applespi/*` (see `README.md`).
- Many behaviors are controlled by kernel module parameters (defined with `module_param` in `applespi.c`) — inspect those before changing assumptions.

## Project-specific code patterns and conventions
- Kernel-space style: keep SPDX headers and use kernel APIs. Files already use `// SPDX-License-Identifier: GPL-2.0` — preserve it on new files.
- Message/packet parsing: `applespi.c` implements strict packet assembly and CRC checks (see `struct spi_packet`, `struct message`). Follow that pattern when adding protocol handling or changes.
- MFD/HID demux: `apple-ibridge.c` implements a demuxing pattern where subdrivers register with the central driver. New subdrivers should follow that registration/unregistration pattern.
- Module names and install paths: `dkms.conf` lists the exact module names (`applespi`, `apple-ibridge`, `apple-ib-tb`, `apple-ib-als`) and installs them to `/updates`. Keep those names when renaming or splitting modules.

## Risks and safety
- Changes touch input and power-management code; avoid regressions that could leave systems unresponsive. Prefer adding toggles or module params for experimental features.
- The `Makefile`'s `test` executes `rmmod/insmod` — do not run on systems where removing the driver can lock you out of input devices unless you have alternate access.

## Helpful examples to cite in PRs
- When modifying protocol handling, reference `applespi.c` packet layout and CRC handling (search for `struct spi_packet` and CRC utilities).
- When adding a new subdriver, mimic `apple-ib-tb.c` and the registration calls in `apple-ibridge.c`.

## What not to change without talking to maintainers
- Public module names in `dkms.conf` and `Makefile` object names (`obj-m += ...`).
- The tracepoint names (they are used by userspace debug flows).

## Where to ask questions / next steps
- Open an issue or PR with a small, targeted change and include: files touched, testing steps you performed (build, dkms, insmod/rmmod), and any trace output relevant to the change.

If anything here is unclear or you want this file to include more examples (e.g. common patches, a mini-debug checklist), tell me which area to expand. 
