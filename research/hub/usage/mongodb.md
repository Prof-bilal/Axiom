# MongoDB Community

## When to use
- Your application data is naturally shaped like JSON-style objects and you want to avoid mapping them to rigid tables.
- Your data model changes often, and you need a flexible schema that does not require downtime for each change.
- You need one database that handles document queries, aggregation, full-text, geospatial, or time-series workloads.
- You are building a prototype that may later need replication or horizontal scaling.

## How it works
- Data is stored as documents: field-value pairs that can nest objects and arrays.
- Documents are grouped into collections, which play the role of tables but do not enforce a fixed schema.
- Replica sets provide automatic failover and redundant copies of data.
- Sharding spreads a collection across machines using a shard key. Multi-document transactions are supported.

## Not for
- Not found: the official introduction does not list cases where MongoDB is a poor fit.
- Not found: no comparison with relational databases was on the pages used.

## Sources
- https://www.mongodb.com/docs/manual/introduction/
- https://www.mongodb.com/docs/current/
