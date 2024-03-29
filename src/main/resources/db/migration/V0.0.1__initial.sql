CREATE TABLE clusters
( id            INT NOT NULL GENERATED ALWAYS AS IDENTITY
, k_cluster_id  VARCHAR NOT NULL
, name          VARCHAR NOT NULL
, discovered_at TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at   TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at  TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY (id)
, CONSTRAINT kafka_cluster_id UNIQUE(k_cluster_id)
);

CREATE TABLE nodes
( id            INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id    INT NOT NULL
, k_node_id     INT NOT NULL
, host          VARCHAR
, port          INT
, rack          VARCHAR
, controller    BOOLEAN NOT NULL
, leader        BOOLEAN
, voter         BOOLEAN
, observer      BOOLEAN
, discovered_at TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at   TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at  TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_node_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT kafka_node_id UNIQUE(cluster_id, k_node_id)
);

CREATE TABLE node_configs
( id             INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id     INT NOT NULL
, node_id        INT NOT NULL
, name           VARCHAR NOT NULL
, "value"        VARCHAR
, source         VARCHAR NOT NULL
, sensitive      BOOLEAN NOT NULL
, read_only      BOOLEAN NOT NULL
, "type"         VARCHAR NOT NULL
, documentation  VARCHAR
, discovered_at  TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at    TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at   TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_node_config_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_node_config_node FOREIGN KEY(node_id) REFERENCES nodes(id) ON DELETE CASCADE
, CONSTRAINT kafka_node_config_id UNIQUE(cluster_id, node_id, name)
);

CREATE TABLE topics
( id            INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id    INT NOT NULL
, k_topic_id    VARCHAR NOT NULL
, name          VARCHAR NOT NULL
, internal      BOOLEAN NOT NULL
, discovered_at TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at   TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at  TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_topic_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT kafka_topic_id UNIQUE(cluster_id, k_topic_id)
);

CREATE TABLE topic_partitions
( id             INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id     INT NOT NULL
, topic_id       INT NOT NULL
, k_partition_id INT NOT NULL
, discovered_at  TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at    TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at   TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_topic_partition_cluster FOREIGN KEY(cluster_id)     REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_topic_partition_topic   FOREIGN KEY(topic_id)       REFERENCES topics(id)   ON DELETE CASCADE
, CONSTRAINT kafka_topic_partition_id UNIQUE(cluster_id, topic_id, k_partition_id)
);

CREATE TABLE partition_offsets
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, topic_partition_id INT NOT NULL
, offset_type        VARCHAR NOT NULL
, "offset"           BIGINT
, "timestamp"        TIMESTAMP WITH TIME ZONE
, leader_epoch       BIGINT
, velocity           REAL
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_partition_offset_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_partition_offset_topic_partition FOREIGN KEY(topic_partition_id) REFERENCES topic_partitions(id) ON DELETE CASCADE
, CONSTRAINT kafka_partition_offset_id UNIQUE(cluster_id, topic_partition_id, offset_type)
);

CREATE TABLE partition_replicas
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, topic_partition_id INT NOT NULL
, node_id            INT NOT NULL
, leader             BOOLEAN NOT NULL
, in_sync            BOOLEAN NOT NULL
, size               BIGINT
, offset_lag         BIGINT
, future             BOOLEAN
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_partition_replica_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_partition_replica_topic_partition FOREIGN KEY(topic_partition_id) REFERENCES topic_partitions(id) ON DELETE CASCADE
, CONSTRAINT fk_partition_replica_node FOREIGN KEY(node_id) REFERENCES nodes(id)
, CONSTRAINT kafka_partition_replica_id UNIQUE(cluster_id, topic_partition_id, node_id)
);

CREATE TABLE topic_configs
( id             INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id     INT NOT NULL
, topic_id       INT NOT NULL
, name           VARCHAR NOT NULL
, "value"        VARCHAR
, source         VARCHAR NOT NULL
, sensitive      BOOLEAN NOT NULL
, read_only      BOOLEAN NOT NULL
, "type"         VARCHAR NOT NULL
, documentation  VARCHAR
, discovered_at  TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at    TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at   TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_topic_config_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_topic_config_topic FOREIGN KEY(topic_id) REFERENCES topics(id) ON DELETE CASCADE
, CONSTRAINT kafka_topic_config_id UNIQUE(cluster_id, topic_id, name)
);

CREATE TABLE consumer_groups
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, group_id           VARCHAR NOT NULL
, coordinator_id     INT NOT NULL
, simple             BOOLEAN NOT NULL
, state              VARCHAR NOT NULL
, partition_assignor VARCHAR
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_consumer_group_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_consumer_group_coordinator_node FOREIGN KEY(coordinator_id) REFERENCES nodes(id)
, CONSTRAINT kafka_consumer_group_id UNIQUE(cluster_id, group_id)
);

CREATE TABLE consumer_group_members
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, consumer_group_id  INT NOT NULL
, member_id          VARCHAR NOT NULL
, group_instance_id  VARCHAR
, client_id          VARCHAR
, host               VARCHAR
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_consumer_group_member_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_consumer_group_member_group FOREIGN KEY(consumer_group_id) REFERENCES consumer_groups(id)
, CONSTRAINT kafka_consumer_group_member_id UNIQUE(cluster_id, consumer_group_id, member_id)
);

CREATE TABLE consumer_group_member_assignments
( id                       INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id               INT NOT NULL
, consumer_group_member_id INT NOT NULL
, topic_partition_id       INT NOT NULL
, discovered_at            TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at              TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at             TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_consumer_group_member_assignment_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_consumer_group_member_assignment_member FOREIGN KEY(consumer_group_member_id) REFERENCES consumer_group_members(id) ON DELETE CASCADE
, CONSTRAINT kafka_consumer_group_member_assignment UNIQUE(cluster_id, consumer_group_member_id, topic_partition_id)
);

CREATE TABLE consumer_group_offsets
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, consumer_group_id  INT NOT NULL
, topic_partition_id INT NOT NULL
, "offset"           BIGINT NOT NULL
, offset_timestamp   TIMESTAMP WITH TIME ZONE
, metadata           VARCHAR
, leader_epoch       BIGINT
, velocity           REAL
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_consumer_group_offset_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT fk_consumer_group_offset_group FOREIGN KEY(consumer_group_id) REFERENCES consumer_groups(id) ON DELETE CASCADE
, CONSTRAINT kafka_consumer_group_offset_id UNIQUE(cluster_id, consumer_group_id, topic_partition_id)
);

CREATE TABLE acl_resources
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, resource_type      VARCHAR NOT NULL
, name               VARCHAR NOT NULL
, pattern_type       VARCHAR NOT NULL
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_acl_resource_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT uk_acl_resource UNIQUE(cluster_id, resource_type, name, pattern_type)
);

CREATE TABLE acl_entries
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, principal          VARCHAR NOT NULL
, host               VARCHAR NOT NULL
, operation          VARCHAR NOT NULL
, permission_type    VARCHAR NOT NULL
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_acl_entry_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT uk_acl_entry UNIQUE(cluster_id, principal, host, operation, permission_type)
);

CREATE TABLE acl_bindings
( id                 INT NOT NULL GENERATED ALWAYS AS IDENTITY
, cluster_id         INT NOT NULL
, resource_id        INT NOT NULL
, entry_id           INT NOT NULL
, discovered_at      TIMESTAMP WITH TIME ZONE NOT NULL
, modified_at        TIMESTAMP WITH TIME ZONE NOT NULL
, refreshed_at       TIMESTAMP WITH TIME ZONE NOT NULL
-- Constraints
, PRIMARY KEY(id)
, CONSTRAINT fk_acl_binding_cluster FOREIGN KEY(cluster_id) REFERENCES clusters(id) ON DELETE CASCADE
, CONSTRAINT uk_acl_binding UNIQUE(cluster_id, resource_id, entry_id)
);
