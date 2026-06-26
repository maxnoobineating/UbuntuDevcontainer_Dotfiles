## Contexts
- this is claude code in Ubuntu Linux
- the system is for general programming related personal project development.
- the system is running in a docker container on windows host, main tools - zsh/tmux/vim.

## Rules
- default to direct, complete answers at full implementation depth — don't dumb down or slow the implementation to fit my level. big-picture breakdown for unfamiliar subjects, detailed for complicated ones. I'll ask when I feel lost; trust that over pre-emptive hand-holding.
- expand on a topic when there's genuine learning value (what/why/where/how/when) — as an addition alongside the direct answer, not a detour that delays the implementation.
- details on complex or domain-specific topics needs to be verified and referenced.
- the x-y question rules: infer the intend of my question to decide if clarify the problem at hand is better to solve the problem. but sometimes I'm just qurious about things, so let it slides.
- refer to [Documents](##Documents) if the description fits the use cases.
- refer to [Archive](##Archive) if the resource name fits the use cases. 
- Batch related file reads into single operations.
- only edit the memory file directly if specifically told to, otherwise any edit should route through automation script (not done).

## Reference rules
- markdown footnotes [^note] in this CLAUDE.md file is for marking the rank of a linked document:
- [^0] fetch only if explicitly asked
- [^1] fetch only if this specific file is clearly relevant
- [^2] fetch when description matches the topic at hand, higher number takes priority if both fits.
- [^3, 4, 5...] fetch when general area matches; higher number takes priority if both fits.
- at the start of each task/topic, scan all [^1+] file descriptions; fetch if they match.
- when about to advise on a topic and uncertain of my context for it, scan all [^1+] file descriptions; fetch if they match.

## Documents
> manually indexed, automatically managed sources
> under directory ~/.claude/memory_docs_live/
- [broad category of previously discussed subjects](subjects.md) [^3]
- [specific projects I am/was working on](projects.md) [^3]
- [specific tools related stuff](tools.md) [^2]
- [specific setups and preferences on vim](vim.md) [^2]
- [specific setups and preferences on shell script](shell.md) [^2]
- [specific setups and preferences on claude code](claude.md) [^3]
- [instructions on how to update memory for automated memory management](claude_memory.md) [^2]
- [specific setups, toolchains, and knowledge for languages](languages.md) [^2]
- [overall todo list](todo.md) [^2]
- [about me - don't read for any serious works, it's for casual conversation](aboutme.md) [^1]

## Archive 
> automatically indexed, manually managed sources
> under directory ~/.claude/memory_docs_archive/
> archive for static documents, follow the link if cataloged resources might be of help
> default [^0]
```json
[]
```

## Secondary Memories
> automatically indexed, automatically managed sources
> under directory ~/.claude/memory_live/
> a json dict for description to filepath mappings
> default [^4]
```json
{}
```

## Primary Memories
> always-loaded, important memories of any kind (context/rule/fact/task) worth carrying across sessions — even if only briefly important.
> a json list of [memory_string, attributes] tuples. attributes schema (standardized for automation):
> - `type`: "context" | "rule" | "fact" | "task" — kind of memory
> - `created`: "YYYY-MM-DD" — when pinned
> - `expires`: "YYYY-MM-DD" | null — demote/prune after this date; null = persistent
> - `priority`: 1-5 — higher = kept longer / wins pruning ties
> - `tags`: [string] — for grouping/retrieval
```json
[
  ["Building the global memory system: Documents in ~/.claude/memory_docs_live/, Secondary in ~/.claude/memory_live/, Primary inline here. Capture/promote automation (hooks) NOT built yet — tiers are populated manually for now.", {"type": "task", "created": "2026-06-01", "expires": null, "priority": 5, "tags": ["memory-system", "active-work"]}],
  ["Next planned project: local RAG-over-textbooks (Ollama nomic-embed-text + LanceDB + rank-bm25 hybrid 60/40, OCR fallback) exposed as an MCP stdio tool inside the existing devcontainer. Not started; Ollama not yet installed in-container.", {"type": "task", "created": "2026-06-01", "expires": null, "priority": 4, "tags": ["rag", "mcp", "next"]}]
]
```


