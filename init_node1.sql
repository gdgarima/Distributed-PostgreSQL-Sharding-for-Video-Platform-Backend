-- init_node1.sql

-- Create the custom schema
CREATE SCHEMA IF NOT EXISTS youtube_schema;

-- Users Table
CREATE TABLE IF NOT EXISTS youtube_schema.users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    profile_pic VARCHAR(255)
);

-- Playlists Table
CREATE TABLE IF NOT EXISTS youtube_schema.playlists (
    playlist_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES youtube_schema.users(user_id),
    title VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comments Table
CREATE TABLE IF NOT EXISTS youtube_schema.comments (
    comment_id SERIAL PRIMARY KEY,
    video_id INT NOT NULL,
    user_id INT NOT NULL REFERENCES youtube_schema.users(user_id),
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subscriptions Table
CREATE TABLE IF NOT EXISTS youtube_schema.subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    subscriber_id INT NOT NULL REFERENCES youtube_schema.users(user_id),
    channel_id INT NOT NULL REFERENCES youtube_schema.users(user_id),
    subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sharded Videos Table for Node 1 (for user_id % 3 = 0)
CREATE TABLE IF NOT EXISTS youtube_schema.videos_shard_0 (
    video_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    url VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    views INT DEFAULT 0
);

-- Populate users with sample data
INSERT INTO youtube_schema.users (username, email, password_hash, profile_pic)
SELECT 'user' || i, 'user' || i || '@example.com', 'password_hash_' || i, 'pic' || i || '.jpg'
FROM generate_series(1, 1000) AS s(i);

-- Populate videos shard 0
INSERT INTO youtube_schema.videos_shard_0 (user_id, title, description, url, views)
SELECT mod(i, 1000) + 1, 'Video ' || i, 'Description for video ' || i, 'http://video-url-' || i, mod(i, 10000)
FROM generate_series(1, 100000) AS s(i)
WHERE mod(i, 3) = 0;

-- Populate Playlists table
INSERT INTO youtube_schema.playlists (user_id, title)
SELECT mod(i, 1000) + 1, 'Playlist ' || i
FROM generate_series(1, 5000) AS s(i);

-- Populate Comments table
INSERT INTO youtube_schema.comments (video_id, user_id, comment_text)
SELECT mod(i, 100000) + 1, mod(i, 1000) + 1, 'This is a sample comment for video ' || mod(i, 100000)
FROM generate_series(1, 500000) AS s(i);

-- Populate Subscriptions table
INSERT INTO youtube_schema.subscriptions (subscriber_id, channel_id)
SELECT mod(i, 1000) + 1, mod(i + 1, 1000) + 1
FROM generate_series(1, 5000) AS s(i);

-- Create indexes
CREATE INDEX idx_videos_user_id_0 ON youtube_schema.videos_shard_0 (user_id);

--- Create schema for partition
CREATE SCHEMA IF NOT EXISTS youtube_schema_partition;

-- Adjusted Partition Definitions

CREATE TABLE youtube_schema_partition.videos (
    video_id SERIAL,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    url VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    views INT DEFAULT 0,
    PRIMARY KEY (video_id, user_id)  -- Include user_id in the primary key
) PARTITION BY RANGE (user_id);

-- Create partitions for user_id from 1 to 1000
CREATE TABLE youtube_schema_partition.videos_part_1 PARTITION OF youtube_schema_partition.videos
FOR VALUES FROM (1) TO (334);  -- Users 1 to 333

CREATE TABLE youtube_schema_partition.videos_part_2 PARTITION OF youtube_schema_partition.videos
FOR VALUES FROM (334) TO (667);  -- Users 334 to 666

CREATE TABLE youtube_schema_partition.videos_part_3 PARTITION OF youtube_schema_partition.videos
FOR VALUES FROM (667) TO (1001);  -- Users 667 to 1000


--- insert into partition table
INSERT INTO youtube_schema_partition.videos (user_id, title, description, url, views)
SELECT mod(i, 1000) + 1, 'Video ' || i, 'Description for video ' || i, 'http://video-url-' || i, mod(i, 10000)
FROM generate_series(1, 300000) AS s(i);

---create indexes on partition table
CREATE INDEX idx_videos_user_id ON youtube_schema_partition.videos (user_id);
CREATE INDEX idx_videos_title ON youtube_schema_partition.videos (title);






