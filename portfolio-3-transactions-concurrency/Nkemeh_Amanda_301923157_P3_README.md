# Portfolio 3 Transactions and Concurrency

## Commit and rollback

The cancellation of Ngozi Eze's appointment with Grace Adeola on 2026-12-04 at 14:00 is committed, so the status is saved as Cancelled. A repeated cancellation affects zero rows because the UPDATE only changes appointments that are still Booked. In the next transaction, a valid booking for Amina Bello on 2026-12-05 is added before an invalid status ('Pending') causes a check constraint error. ROLLBACK removes that booking, and the earlier committed cancellation remains.

## Isolation and concurrency control

Two PostgreSQL sessions use READ COMMITTED. Session A books Dr Adeola at 10:00 on 2026-12-06 for Amina without committing. Session B sees zero active bookings for that slot, then tries to book it for Chidi Okafor. B waits, and wait_event_type shows Lock. After A commits, B receives a uq_doctor_slot duplicate-key error. B rolls back, and the final query shows exactly one active booking for that slot, belonging to Amina.

## Conclusion

COMMIT saves changes and ROLLBACK undoes a transaction's unsaved changes. READ COMMITTED hides other sessions' uncommitted records, so B's count of zero did not guarantee the slot was free. The unique partial index prevents two active bookings for the same doctor and slot, even when an earlier availability check finds none. The status guard belongs to the demonstrated cancellation workflow and does not prevent every possible direct database edit.

## Files

- [Transactions](Nkemeh_Amanda_301923157_P3_Transactions.sql)
- [Session A](Nkemeh_Amanda_301923157_P3_SessionA.sql)
- [Session B](Nkemeh_Amanda_301923157_P3_SessionB.sql)
- [Screenshots](screenshots/)

## References

- PostgreSQL documentation: [Transactions](https://www.postgresql.org/docs/16/tutorial-transactions.html)
- PostgreSQL documentation: [Transaction isolation](https://www.postgresql.org/docs/16/transaction-iso.html)
- PostgreSQL documentation: [Unique indexes](https://www.postgresql.org/docs/16/indexes-unique.html)