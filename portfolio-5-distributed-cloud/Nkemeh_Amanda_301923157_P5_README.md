# Portfolio 5 Distributed and Cloud Database Exercise

## Current setup

This is a discussion of a proposed distributed setup for the clinic's MongoDB event records. The practical work runs one MongoDB server and one PostgreSQL server in the same Codespace. No replica set, sharding or failover test is configured, and Codespaces does not provide multiple copies on separate servers.

## Proposed replication

Replication keeps copies of the same data on different database servers. A proposed MongoDB replica set has three voting, data-holding members:

| Member | Starting role | Location |
| --- | --- | --- |
| A | Primary: accepts event writes | Host 1 |
| B | Secondary: copies event changes | Host 2 |
| C | Secondary: copies event changes | Host 3 |

The hosts are placed in separate failure zones, so one host or zone failure does not remove all copies. When Amina Bello's completed-visit event E002 is written to the primary, the secondaries copy it asynchronously. A secondary can therefore briefly have older event data. [Replication](https://www.mongodb.com/docs/manual/replication/)

## Failure and consistency

If A fails, the two remaining members can elect an eligible secondary as the new primary, provided they can communicate and form a majority. Writes pause during the election, so failover is not instant. If only one of the three voting members is reachable, there is no majority and no writable primary. [Elections](https://www.mongodb.com/docs/v8.0/core/replica-set-elections/)

For important events such as E002, the proposal uses majority write acknowledgement: at least two of the three voting members must confirm the write. This protects against losing an acknowledged event if one member fails, but it adds waiting and needs a reachable majority. Recent-event queries should use the primary, and secondary reports may lag. Current appointment availability still comes from PostgreSQL and its transaction rules, not from a possibly stale event copy. [Write concern](https://www.mongodb.com/docs/v8.0/reference/write-concern/)

## Sharding and cloud deployment

Sharding splits records across groups of servers, while replication copies the same records. Four example events do not justify sharding. If event volume outgrew one replica set, the shard key would need evidence from query patterns and data distribution. No sharding is implemented here. [Sharding](https://www.mongodb.com/docs/manual/sharding/)

A cloud version could use a managed MongoDB service such as Atlas. It would need authentication, encryption, restricted network access and tested backup and restore. [Backup and restore](https://www.mongodb.com/docs/atlas/backup-restore-cluster/) The cost is higher than one Codespace server, and real patient data would need stricter access control than this fictional data. MongoDB replication does not replicate PostgreSQL, so PostgreSQL would need its own replication and backup, and the two databases would not synchronise automatically.

In simple terms: the primary takes writes, secondaries keep copies, failover changes the primary after a failure, and sharding divides records rather than copying the whole set.