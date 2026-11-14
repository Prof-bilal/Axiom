# Valkey (Redis-compatible)

## When to use
- You need a fast in-memory cache in front of a slower database.
- You need session storage, leaderboards, or counters that must respond in milliseconds.
- You need lightweight messaging with Pub/Sub or streams between services.
- Existing Redis client libraries and tools must keep working without code changes.

## How it works
- Data is stored as key-value pairs in RAM, with optional disk persistence and replication.
- Values can be strings, hashes, lists, sets, sorted sets, or streams.
- Keys can have a TTL and are removed automatically when they expire.
- With a fixed memory limit, an LRU eviction policy removes keys to make room, so data can disappear.
- Administration covers persistence, replication, Sentinel, Cluster, and ACL/TLS security.

## Not for
- Primary storage for data that must always be kept without configuring persistence and eviction carefully.
- Not found: no source gave a dataset-size limit; the in-memory model is the main constraint.

## Sources
- https://valkey.io/topics/
- https://redis.io/blog/what-is-valkey/
