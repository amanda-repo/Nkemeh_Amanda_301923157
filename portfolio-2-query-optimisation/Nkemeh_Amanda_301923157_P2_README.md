# Portfolio 2 Query Processing and Optimisation

## Queries and results

Three queries run on the Portfolio 1 clinic data. The first lists booked appointments with patient and doctor names and returns two rows (Chidi Okafor with Daniel Adams on 2026-12-03, and Ngozi Eze with Grace Adeola on 2026-12-04). The second uses NOT EXISTS to find doctors with no active appointment at 10:00 on 2026-12-01 and returns Grace Adeola, because Daniel Adams is already booked. The third uses a LEFT JOIN to count completed appointments per patient and returns Amina Bello 2, Chidi Okafor 1 and Ngozi Eze 0, so the patient with none is kept. The results are in the [query screenshot](screenshots/Nkemeh_Amanda_301923157_P2_QueryResults.png).

## Index comparison

The test table is p2_benchmark.appointment_history, with 100,000 made-up appointment records kept apart from the Portfolio 1 tables. The query counts appointments scheduled on 2005-01-01 and returns 24. The statement and the data stayed the same. I added a B-tree index, appointment_history_scheduled_at_idx, on scheduled_at. Each plan was run once as a warm-up and then three times for measurement.

| Measurement | Before index | After index |
| --- | --- | --- |
| Scan type | Seq Scan | Index Only Scan |
| Three execution times (ms) | 6.040, 7.208, 6.330 | 0.038, 0.039, 0.038 |
| Median time (ms) | 6.330 | 0.038 |
| Shared buffer hits, third run | 834 | 3 |

Screenshots: [before the index](screenshots/Nkemeh_Amanda_301923157_P2_BeforeIndex.png) and [after the index](screenshots/Nkemeh_Amanda_301923157_P2_AfterIndex.png).

## Performance analysis

Before the index, PostgreSQL scanned all 100,000 rows, kept 24 and removed 99,976. After the index, it jumped to the matching range and returned the same 24 rows. The median execution time fell from 6.330 ms to 0.038 ms and the buffer hits from 834 to 3. A limitation is that the table is made-up and the times come from one machine, so the exact numbers are only a guide, and the three Portfolio 1 tables are too small to need this index. An index also has a cost: it takes extra storage, and every insert, update or delete on scheduled_at must also update the index, which slows writes. It suits a column that is searched often, such as the appointment date, and not every column.

## Files

- [Queries](Nkemeh_Amanda_301923157_P2_Queries.sql)
- [Optimisation](Nkemeh_Amanda_301923157_P2_Optimisation.sql)
- [Screenshots](screenshots/)

## Reference

- PostgreSQL documentation: [Indexes](https://www.postgresql.org/docs/16/indexes.html)
- PostgreSQL documentation: [Using EXPLAIN](https://www.postgresql.org/docs/16/using-explain.html)