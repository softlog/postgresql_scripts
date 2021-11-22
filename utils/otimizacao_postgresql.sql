SELECT 
        now()-pg_postmaster_start_time()    "Uptime", now()-stats_reset     "Since stats reset",
        round(100.0*checkpoints_req/total_checkpoints,1)                    "Forced checkpoint ratio (%)",
        round(np.min_since_reset/total_checkpoints,2)                       "Minutes between checkpoints",
        round(checkpoint_write_time::numeric/(total_checkpoints*1000),2)    "Average write time per checkpoint (s)",
        round(checkpoint_sync_time::numeric/(total_checkpoints*1000),2)     "Average sync time per checkpoint (s)",
        round(total_buffers/np.mp,1)                                        "Total MB written",
        round(buffers_checkpoint/(np.mp*total_checkpoints),2)               "MB per checkpoint",
        round(buffers_checkpoint/(np.mp*np.min_since_reset*60),2)           "Checkpoint MBps",
        round(buffers_clean/(np.mp*np.min_since_reset*60),2)                "Bgwriter MBps",
        round(buffers_backend/(np.mp*np.min_since_reset*60),2)              "Backend MBps",
        round(total_buffers/(np.mp*np.min_since_reset*60),2)                "Total MBps",
        round(1.0*buffers_alloc/total_buffers,3)                            "New buffer allocation ratio",        
        round(100.0*buffers_checkpoint/total_buffers,1)                     "Clean by checkpoints (%)",
        round(100.0*buffers_clean/total_buffers,1)                          "Clean by bgwriter (%)",
        round(100.0*buffers_backend/total_buffers,1)                        "Clean by backends (%)",
        round(100.0*maxwritten_clean/(np.min_since_reset*60000/np.bgwr_delay),2)            "Bgwriter halt-only length (buffers)",
        coalesce(round(100.0*maxwritten_clean/(nullif(buffers_clean,0)/np.bgwr_maxp),2),0)  "Bgwriter halt ratio (%)",
        '--------------------------------------'         "--------------------------------------",
        bgstats.*
  FROM (
    SELECT bg.*,
        checkpoints_timed + checkpoints_req total_checkpoints,
        buffers_checkpoint + buffers_clean + buffers_backend total_buffers,
        pg_postmaster_start_time() startup,
        current_setting('checkpoint_timeout') checkpoint_timeout,
        current_setting('max_wal_size') max_wal_size,
        current_setting('checkpoint_completion_target') checkpoint_completion_target,
        current_setting('bgwriter_delay') bgwriter_delay,
        current_setting('bgwriter_lru_maxpages') bgwriter_lru_maxpages,
        current_setting('bgwriter_lru_multiplier') bgwriter_lru_multiplier
    FROM pg_stat_bgwriter bg
        ) bgstats,
        (
    SELECT
        round(extract('epoch' from now() - stats_reset)/60)::numeric min_since_reset,
        (1024 * 1024 / block.setting::numeric) mp,
        delay.setting::numeric bgwr_delay,
        lru.setting::numeric bgwr_maxp
    FROM pg_stat_bgwriter bg
    JOIN pg_settings lru   ON lru.name = 'bgwriter_lru_maxpages'
    JOIN pg_settings delay ON delay.name = 'bgwriter_delay'
    JOIN pg_settings block ON block.name = 'block_size'
) np; -- don't print that


SHOW shared_buffers;
--SELECT INTEGER '1'

SHOW effective_cache_size;

select * from pg_stats

SELECT 
	(blks_hit/(blks_hit + blks_read)::numeric)::numeric(12,6) as taxa_hits,
	*
FROM 
	pg_stat_database
WHERE
	blks_read + blks_hit <> 0
ORDER BY 1 DESC;

SELECT 
	sum ( blks_hit ) /
	sum (( blks_read + blks_hit ):: numeric ) as taxa_leitura_memoria
FROM 
	pg_stat_database
WHERE
	blks_read + blks_hit <> 0;

--22 % dos dados lidos no banco são lidos em memória.
-- 1 - Tem muito seq_scan?
-- 2 - Configurar o shared_buffers, quantidade de memoria para cache.


--Percentual do checkpointer
SELECT buffers_checkpoint /
	( buffers_checkpoint + buffers_backend ):: numeric AS checkpointer_ratio
FROM 
	pg_stat_bgwriter ;


--Verificacao das requisições de CHECKPOINT 
SELECT checkpoints_timed /
	( checkpoints_timed + checkpoints_req ):: numeric AS timed_ratio
FROM 
	pg_stat_bgwriter ;

SELECT * from pg_stat_bgwriter

--Verificacao da utilizacao de arquivos temporarios
SELECT pg_size_pretty (sum ( temp_bytes ))
AS size
FROM pg_stat_database ;
--Aumetar o paremtro de work_men

--Utilização dos indices
SELECT relname , seq_scan , idx_scan
FROM pg_stat_user_tables
ORDER BY seq_scan DESC LIMIT 10;

SELECT relname , indexrelname
FROM pg_stat_user_indexes
WHERE idx_scan = 0;


SELECT pg_size_pretty(count(*) * 8192) as ideal_shared_buffers
FROM pg_buffercache b
WHERE usagecount >= 3;