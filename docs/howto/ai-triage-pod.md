# How-To: Triage a Kubernetes Pod with ai-triage-pod

`ai-triage-pod` collects `kubectl describe pod` and recent log lines, then passes the combined context to `ai-review`. It is the generic `rigor-cli` equivalent of a pod-specific Copilot triage wrapper.

---

## Usage

```bash
bin/ai-triage-pod <namespace> <pod-name>
bin/ai-triage-pod -f notes.txt
bin/ai-triage-pod -f - < notes.txt
printf 'extra context' | bin/ai-triage-pod <namespace> <pod-name>
```

Optional inputs are appended to the generated triage prompt:

- `-f, --context-file FILE` appends the contents of `FILE`
- `-f -` reads stdin and skips pod collection
- stdin is appended when the command receives piped input in pod-triage mode
- `AI_TRIAGE_LOG_TAIL` controls how many log lines are collected

Example:

```bash
printf 'Auth failed after LDAP rotation' \
  | AI_TRIAGE_LOG_TAIL=200 bin/ai-triage-pod identity keycloak-745b995454-h859q
bin/ai-triage-pod -f notes.txt
```

---

## What It Sends

The wrapper bundles:

1. `kubectl describe pod -n <namespace> <pod>`
2. the most recent logs for that pod
3. optional stdin context
4. optional `--context-file` contents

When `-f FILE` or `-f -` is used, pod collection is skipped and only the provided
context is sent to `ai-review`.

That bundle is then reviewed by the configured `ai-review` backend.

---

## Notes

- Requires `kubectl` on `PATH` and access to the target cluster
- `ai-triage-pod` only wraps `kubectl describe` / `kubectl logs` and forwards the collected context to `ai-review`
- AI backend selection still follows the normal `ai-review` path (`AI_REVIEW_FUNC`, `AI_REVIEW_MODEL`)
- If the pod is already gone, the describe/log output is still included so the review can diagnose the failure mode
