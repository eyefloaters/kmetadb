MERGE INTO nodes AS t
USING ( SELECT ? AS cluster_id
             , ? AS kafka_id
             , ? AS host
             , ? AS port
             , ? AS rack
             , ? AS controller
             , ? AS leader
             , ? AS voter
             , ? AS observer
             , CAST(? AS TIMESTAMP WITH TIME ZONE) AS refreshed_at
             ) AS n
ON  t.cluster_id     = n.cluster_id
AND t.kafka_id       = n.kafka_id

WHEN MATCHED
    AND t.host        = n.host
    AND t.port        = n.port
    AND t.rack        = n.rack
    AND t.controller  = n.controller
    AND t.leader      = n.leader
    AND t.voter       = n.voter
    AND t.observer    = n.observer
  THEN
    UPDATE
    SET refreshed_at  = n.refreshed_at

WHEN MATCHED
  THEN
    UPDATE
    SET host          = n.host
      , port          = n.port
      , rack          = n.rack
      , controller    = n.controller
      , leader        = n.leader
      , voter         = n.voter
      , observer      = n.observer
      , modified_at   = n.refreshed_at
      , refreshed_at  = n.refreshed_at

WHEN NOT MATCHED
  THEN
    INSERT ( cluster_id
           , kafka_id
           , host
           , port
           , rack
           , controller
           , leader
           , voter
           , observer
           , discovered_at
           , modified_at
           , refreshed_at
           )
    VALUES ( n.cluster_id
           , n.kafka_id
           , n.host
           , n.port
           , n.rack
           , n.controller
           , n.leader
           , n.voter
           , n.observer
           , n.refreshed_at
           , n.refreshed_at
           , n.refreshed_at
           )
