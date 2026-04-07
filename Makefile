# Makefile — Chrono Garden code-generation helpers.
# Usage:
#   make build-runner   → single build pass (CI / after model changes)
#   make watch          → continuous watch mode (local development)
#   make clean          → wipe build_runner cache

.PHONY: build-runner watch clean

build-runner:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

clean:
	dart run build_runner clean