---
name: lab-linter
description: Checks a lab README for typos and grammar issues. Invoke when the user says "lab check", "lint lab", or "check README".
---

# Lab linter

Check the lab `README.md` files for typos and grammar issues.

- If the user names a specific lab, check only that one.
- Otherwise check every top-level `*/README.md` (skip `.99_todos/`).
- Ignore code blocks, commands, YAML, and identifiers — only check prose.
- Report findings as `file_path:line_number` with the fix suggestion.
- Ask before changing files if this should be done

## Must not

- Do not change pinned versions (`K1_VERSION`, `KKP_INSTALLER_VERSION`, Kubernetes versions, image tags).
- Do not read, open, or grep files under `.secrets/` — passwords, SSH keys, service-account JSON are off-limits.
- Do not read, open, or grep files under `.99_todos/` 
- Do not "fix" placeholders (`TODO`, `XXXXX`, `TODO-STUDENT-EMAIL@...`) — they are intentional.
- Do not rewrite or reorder commands, YAML, or code blocks — only prose is in scope.
