# Project Memory — ThreePiecesSystem (OSTEP)

## Active homework: threads-lock-based-concurrent-DS
Path: `ostep-homework/threads-lock-based-concurrent-DS/`

### What's been done
- `syncList.c`: doubly linked list with custom RangeLock (interval-based fine-grained locking). Considered complete/abandoned as a learning exercise.
- `approximate.c`: approximate counter benchmark with TSC timing, done.
- Q4 (hand-over-hand list), Q5/Q6 (B-tree or other DS with locking strategies) still to do.

### Key design insight from syncList
The hardest problem was `rangeLock_resize()`: when a list insert/delete happens, ALL registered range locks must have their indices shifted to maintain the index→item invariant. This required walking the full range array under mutex — a fundamental tension with fine-grained locking.

**Lesson**: fine-grained locking for linked lists usually isn't worth it. Hand-over-hand (lock coupling) is simpler and still loses to coarse lock in most benchmarks due to cache coherence overhead.

### Next DS candidate: B-tree
- Internal nodes = disk pages (or memory blocks); keys sorted within node
- B+ tree variant: internal nodes routing only, values at leaves, leaves linked for range scan
- Good for concurrent locking because subtrees are structurally independent
- Locking strategies to compare: single coarse lock (Q5) vs lock coupling root→leaf (Q6)

### User style
- Likes thinking through ideas even when impractical ("it's fun to think about")
- Learns by connecting new concepts to things already understood (asked B-tree → page directory analogy, MongoDB → "just relational with single table")
- Concise, conversational tone preferred
