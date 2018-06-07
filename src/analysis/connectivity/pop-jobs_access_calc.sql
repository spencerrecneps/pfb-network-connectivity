--
-- calculates access to a destination type from each census block
--
DROP TABLE IF EXISTS pg_temp.d;
DROP TABLE IF EXISTS pg_temp.summary;
UPDATE {blocks} AS blocks SET {score_attribute} = 0;

SELECT
    connections.{source_block} AS block_id,
    SUM(target_block.{val}) AS total
INTO TEMP TABLE pg_temp.summary
FROM
    {block_connections} connections,
    {destinations} target_block
WHERE
    {connection_true}
    AND connections.{target_block} = target_block.blockid10
GROUP BY connections.{source_block};

CREATE INDEX tidx_summary_block_id ON pg_temp.summary (block_id); ANALYZE pg_temp.summary;

UPDATE {blocks} AS blocks
SET {score_attribute} = summary.total
FROM pg_temp.summary
WHERE blocks.{block_id} = summary.block_id;
