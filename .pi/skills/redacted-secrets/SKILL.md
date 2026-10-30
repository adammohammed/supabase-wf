---
name: redacted-secrets
description: Verify secrets exist without exposing their values. Use when the user asks to confirm a secret, token, or credential is present and configured.
---

# Redacted secrets

When asked to confirm a secret or token is available, **do not read the secret file directly and do not echo its contents**. Instead, run the appropriate check script from this skill's `scripts/` directory and report only its output.

For the GitHub PAT used by the supabase-wf remote, run:

```bash
scripts/check-gh-pat.sh
```

Report exactly what the script prints. Do not inspect `~/.config/secrets/gh_pat` yourself.
