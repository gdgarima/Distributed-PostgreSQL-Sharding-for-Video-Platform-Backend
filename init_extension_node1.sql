-- init_node1.sql (Add these commands)

-- Create the foreign data wrapper extension
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Create foreign server for Node 2
CREATE SERVER node2_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'postgres-node2', dbname 'shard2', port '5432');

-- Create foreign server for Node 3
CREATE SERVER node3_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'postgres-node3', dbname 'shard3', port '5432');

-- Create user mapping to allow access to Node 2 and Node 3
CREATE USER MAPPING FOR user1
    SERVER node2_server
    OPTIONS (user 'user2', password 'password2');

CREATE USER MAPPING FOR user1
    SERVER node3_server
    OPTIONS (user 'user3', password 'password3');

-- Create foreign table for videos_shard_1 on Node 2
CREATE FOREIGN TABLE IF NOT EXISTS youtube_schema.videos_shard_1 (
    video_id INT,
    user_id INT,
    title VARCHAR(100),
    description TEXT,
    url VARCHAR(255),
    upload_date TIMESTAMP WITH TIME ZONE,
    views INT
) SERVER node2_server OPTIONS (schema_name 'youtube_schema', table_name 'videos_shard_1');

-- Create foreign table for videos_shard_2 on Node 3
CREATE FOREIGN TABLE IF NOT EXISTS youtube_schema.videos_shard_2 (
    video_id INT,
    user_id INT,
    title VARCHAR(100),
    description TEXT,
    url VARCHAR(255),
    upload_date TIMESTAMP WITH TIME ZONE,
    views INT
) SERVER node3_server OPTIONS (schema_name 'youtube_schema', table_name 'videos_shard_2');
