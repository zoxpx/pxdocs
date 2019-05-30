---
title: Portworx Metrics
linkTitle: Portworx Metrics
keywords: portworx, container, storage, metrics, alarms, warnings, notifications
description: How to monitor alerts with Portworx.
hidden:true
---

_Portworx_ exports the following metrics which help you monitor the health and performance of your cluster.

## Cluster stats

| Name | Type | Description | Notes |
| :--- | :--- | :--- | :--- |
| px_cluster_cpu_percent | Gauge | Average CPU usage for the PX cluster nodes | |
| px_cluster_memory_utilized_percent | Gauge | Average memory usage for the PX cluster nodes | |
| px_cluster_disk_available_bytes | Gauge | Available storage in the PX cluster | |
| px_cluster_disk_utilized_bytes | Gauge | Used storage in the PX cluster | |
| px_cluster_disk_total_bytes | Gauge | Total storage in the PX cluster | |
| px_cluster_pendingio | Gauge | Total bytes (read/write) being currently processed | |
| px_cluster_status_cluster_size | Gauge | Total cluster size | |
| px_cluster_status_nodes_offline | Gauge | Number of offline nodes | |
| px_cluster_status_nodes_online | Gauge | Number of online nodes | |
| px_cluster_status_nodes_storage_down | Gauge | Number of storage down nodes | |
| px_cluster_status_cluster_quorum | Gauge| Cluster quorum | 1 = in quorum, 0 = not in quorum |
| px_cluster_status_storage_nodes_decommissioned | Gauge | TNumber of decomissioneds torage nodes | |
| px_cluster_status_storage_nodes_online | Gauge | Number of nodes proving storage which are online | These participate in quorum |
| px_cluster_status_storage_nodes_offline | Gauge | Number of nodes proving storage which are offline | These participate in quorum |

## Node stats

| Name | Type | Description | Notes |
| :--- | :--- | :--- | :--- |
| px_network_io_bytessent | Counter | Bytes sent by this node to other nodes | |
| px_network_io_received_bytes | Counter | Bytes received by this node from other nodes | |
| px_node_status_\<node_id\>_status | Gauge | Status of \<node_id\> | 1 = online, 0 = offline |
| px_node_stats_cpu_percent_usage | Gauge | Last reported CPU usage | |
|px_node_stats_free_mem | Gauge | Amount of inactive and idle memory | As reported by /proc/vmstat |
| px_node_stats_total_mem | Gauge | Total amount of memory | As reported by /proc/vmstat |
| px_node_stats_used_mem | Gauge | Amount of used memory | Computed as `total` - `free` |

## Volume stats

| Name | Type | Description | Notes |
| :--- | :--- | :--- | :--- |
| px_volume_capacity_bytes | Gauge | Volume size |  |
| px_volume_depth_io | Gauge | Number of I/O operations being served at once | |
| px_volume_halevel | Gauge | Volume HA level | |
| px_volume_iops | Gauge | Operations per second | |
| px_volume_readthroughput | Gauge | Bytes read per second | |
| px_volume_writethroughput | Gauge | Bytes written per second | |
| px_volume_usage_bytes | Counter | Total bytes read from the volume | |
| px_volume_vol_read_latency_seconds | Gauge | Read latency in seconds | |
| px_volume_vol_reads | Counter | Number of read operations served by the volume | |
| px_volume_vol_read_bytes | Counter | Total bytes read from volume | |
| px_volume_vol_writes | Counter | nNmber of write operations served by the volume | |
| px_volume_vol_write_bytes | Counter | Total bytes written to the volume | |
| px_volume_vol_write_latency_seconds | Gauge | Write latency in seconds | |
| px_volume_currhalevel | Gauge | Number of replica's currently up | These are online and not full/down |
| px_volume_dev_depth_io | Gauge | I/Os currently in progress | As reported by the block device |
| px_volume_dev_read_latency_secs | Gauge | Read latency for block device | Computed as the total time spent reading divided by the number of reads |
| px_volume_dev_readthroughput | Gauge | Read throughput for the block device | |
| px_volume_dev_write_latency_secs | Gauge | Write latency for block device | Computed as the total time spent writing divided by the number of writes |
| px_volume_dev_write_throughput | Gauge | Write througput for the block device | |
| px_volume_iopriority | Gauge | Configured volume io_priority | 0 = low, 1 = medium, 2 = high |
| px_volume_fs_capacity_bytes_bytes | Gauge | Total size | As reported by the filesystem |
| px_volume_fs_usage_bytes_bytes | Gauge |Uused capacity | As reported by the filesystem |
| px_volume_num_long_flushes | Counter | Number of long flushes | |
| px_volume_num_long_reads | Counter | Number of long reads | |
| px_volume_num_long_writes | Counter | Number of long writes | |

## Disk stats

{{<info>}}
The metrics below are collected from `/proc/diskstats`
{{</info>}}

| Name | Type | Description | Notes |
| :--- | :--- | :--- | :--- |
| px_disk_stats_interval_seconds | Gauge | interval seconds | |
| px_disk_stats_io_seconds | Counter | Time spent doing I/Os | |
| px_disk_stats_progress_io | Gauge | I/Os currently in progress | |
| px_disk_stats_read_bytes | Counter | Total number of bytes read | |
| px_disk_stats_read_seconds | Counter | Time spent reading | |
| px_disk_stats_num_reads | Counter | Total number of reads | |
| px_disk_stats_used_bytes | Gauge | Used bytes | |
| px_disk_stats_write_bytes | Counter | Total number of bytes written | |
| px_disk_stats_write_seconds | Counter | Total number of ms spent by all writes | |
| px_disk_stats_num_writes | Counter | Total number of writes | |
| px_disk_stats_read_latency_seconds | Gauge | Read latency for disk | Computed as the total amount of time (in ms) spent doing reads divided by the number of reads | |
| px_disk_stats_write_latency_seconds | Gauge | write latency for disk | Computed as the total amount of time (in ms) spent doing writes divided by the number of writes |

## Pool stats

| Name | Type | Description | Notes |
| :--- | :--- | :--- | :--- |
| px_pool_stats_pool_flushed_bytes | Counter | Total number of flushed bytes | |
| px_pool_stats_pool_flushms | Counter | Time spent flushing | |
| px_pool_stats_pool_num_flushes | Counter | Total number of flushes | |
| px_pool_stats_pool_status | Gauge | Pool status | |
| px_pool_stats_pool_write_latency_seconds | Gauge | Write latency | |
| px_pool_stats_pool_writethroughput | Gauge | Bytes written per second | |
| px_pool_stats_pool_written_bytes | Counter | Total bytes written | |

## Proc stats

| Name | Type | Description | Notes |
| :--- | :--- | :--- | :--- |
| px_proc_stats_cputime | Counter | Amount of time spent by the CPU for processing| |
| px_proc_stats_res | Gauge | Amount of memory currently marked as referenced or
accessed | |
| px_proc_stats_virt | Gauge | The size of virtual memory | |

## Backup stats

| Name | Type | Description | Notes |
| :--- | :--- | :--- | :--- |
| px_backup_stats_size | Gauge | Size of the backup | |
| px_backup_stats_duration_seconds | Gauge | Time spent backing up data | |
| px_backup_stats_status | Gauge | Backup status | |

## Monitoring Scenarios

If you notice degraded cluster performance, the following monitoring scenarios could help you identify the root cause.

### Specific application is slow

#### How-to troubleshoot

1. Make sure the volumes used by the app are not out of capacity.
2. Check the host's CPU utilization and I/O.

#### Relevant metrics

1. by volume: px_volume_capacity_bytes, px_volume_usage_bytes
2. by cluster/instance: px_cluster_cpu_percent
3. by cluster/instance: px_cluster_pendingio

### High disk latency

#### How-to troubleshoot

1. Check disk latency to rule out disk issue.
2. Use the latency `heatmap` to identify volumes with high read/write latency.
3. Find the volume name from all volume latency panel.
4. Use the volume name to filter all metrics for that volume.

#### Relevant metrics

1. px_disk_stats_write_seconds, px_disk_stats_read_seconds
2. px_volume_vol_read_latency_seconds
3. px_volume_vol_write_latency_seconds
4. Check other volume metrics, as you see fit.

### Cluster health

#### How-to troubleshoot

1. Check the overall cluster disk usage.
2. Gauge the average cluster CPU utilization.
3. Verify the total number of nodes and storage nodes.
4. Check quorum.

#### Relevant metrics

1. px_cluster_disk_utilized_bytes/px_cluster_disk_available_bytes
2. px_cluster_cpu_percent
3. px_cluster_status_cluster_size, px_cluster_status_storage_nodes_online
4. px_cluster_status_cluster_size/px_cluster_status_cluster_quorum