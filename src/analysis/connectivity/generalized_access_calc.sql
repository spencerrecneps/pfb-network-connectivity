--
-- calculates access to a destination type from each census block
--
DROP TABLE IF EXISTS pg_temp.d;
DROP TABLE IF EXISTS pg_temp.summary;
UPDATE {blocks} AS blocks SET {score_attribute} = 0;

SELECT
    {destination_id} AS id,
    unnest({destination_block_ids}) AS block_id
INTO TEMP TABLE pg_temp.d
FROM {destinations};
CREATE INDEX tidx_d_id ON pg_temp.d (id);
ANALYZE pg_temp.d;

SELECT
    connections.{source_block} AS block_id,
    COUNT(DISTINCT d.id) AS total
INTO TEMP TABLE pg_temp.summary
FROM
    {block_connections} connections,
    pg_temp.d
WHERE
    connections.{connection_true}
    AND connections.{target_block} = d.block_id
GROUP BY connections.{source_block};

CREATE INDEX tidx_summary_block_id ON pg_temp.summary (block_id); ANALYZE pg_temp.summary;

UPDATE {blocks} AS blocks
SET {score_attribute} = summary.total
FROM pg_temp.summary
WHERE blocks.{block_id} = summary.block_id;
