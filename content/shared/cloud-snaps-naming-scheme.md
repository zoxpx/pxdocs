---
hidden: true
---

Cloud backups adhere to the following naming scheme: `<bucket-id>/<vol-id>-<snap-id>`.

**Example:**

* `2e4d4b67-95d7-481e-aec5-14223ac55170/56706279008755778-725134927222077463`

For incremental backups, Portworx adds the `-incr` suffix as follows: `<bucket-id>/<vol-id>-<snap-id>-incr`.

**Example:**

* `2e4d4b67-95d7-481e-aec5-14223ac55170/590114184663672482-951325819047337066-incr`

{{<info>}}
**NOTE:** To restore an incremental backup, you must restore the previous full backup and all incremental backups performed since the last full backup.
{{</info>}}
