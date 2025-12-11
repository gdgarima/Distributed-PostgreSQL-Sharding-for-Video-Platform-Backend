-- init_node3.sql

-- Create the custom schema
CREATE SCHEMA IF NOT EXISTS youtube_schema;

-- Sharded Videos Table for Node 3 (for user_id % 3 = 2)
CREATE TABLE IF NOT EXISTS youtube_schema.videos_shard_2 (
    video_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    url VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    views INT DEFAULT 0
);

-- Populate videos shard 2
INSERT INTO youtube_schema.videos_shard_2 (user_id, title, description, url, views)
SELECT mod(i, 1000) + 1, 'Video ' || i, 'Description for video ' || i, 'http://video-url-' || i, mod(i, 10000)
FROM generate_series(1, 100000) AS s(i)
WHERE mod(i, 3) = 2;

-- Create indexes
CREATE INDEX idx_videos_user_id_2 ON youtube_schema.videos_shard_2 (user_id);
