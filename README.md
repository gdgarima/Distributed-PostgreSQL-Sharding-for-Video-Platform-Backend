# 🎥 Distributed PostgreSQL Sharding for Video Platform Backend

## 🎯 Overview

This project sets up a three-node **distributed PostgreSQL database cluster** using **Docker Compose**. It demonstrates a sharding architecture designed to handle large-scale data, such as a high-traffic video platform (similar to YouTube).

The core of the architecture relies on:
1.  **Horizontal Sharding:** Distributing the high-volume `videos` data across multiple database instances (nodes).
2.  **Foreign Data Wrappers (FDW):** Using the PostgreSQL `postgres_fdw` extension to allow a coordinating node (Node 1) to query data distributed across the other nodes transparently.

## 💻 Technology Stack

* **Containerization:** Docker & Docker Compose (v3)
* **Database:** PostgreSQL (`latest` image)
* **Sharding Tool:** PostgreSQL Foreign Data Wrapper (`postgres_fdw`)

## 🧠 Architecture: 3-Node Sharding

The application logic is distributed across three separate PostgreSQL instances, each handling a specific portion of the total data set. 

* **Node 1 (`postgres-node1`) - Coordinating Node (Port 5433):**
    * Holds core tables (`users`, `playlists`, `comments`).
    * Hosts the **Partitioned Table** (`youtube_schema_partition.videos`) using native PostgreSQL partitioning for certain queries.
    * Acts as the central query point by creating **Foreign Tables** that link to the shards on Node 2 and Node 3 using `postgres_fdw`.
* **Node 2 (`postgres-node2`) - Data Node 1 (Port 5434):**
    * Holds the video shard: `youtube_schema.videos_shard_1`.
    * Sharding Key: Data for users where `user_id % 3 = 1`.
* **Node 3 (`postgres-node3`) - Data Node 2 (Port 5435):**
    * Holds the video shard: `youtube_schema.videos_shard_2`.
    * Sharding Key: Data for users where `user_id % 3 = 2`.

## ▶️ Getting Started

### Prerequisites

* Docker and Docker Compose installed.

### Deployment Steps

1.  **Clone the repository/Unzip the project files:**
    Ensure all files (`docker-compose.yaml` and the `.sql` files) are in the same directory.
2.  **Run Docker Compose:**
    Execute the following command in the project directory to build and start the three database containers:

    ```bash
    docker-compose up -d
    ```

    *This command will create three separate PostgreSQL instances, each initializing its respective database schema and populating it with sample data based on the included SQL files.*

3.  **Verify Status:**
    Check that all three containers are running:

    ```bash
    docker-compose ps
    ```

## 📂 Project Files

| File Name | Role | Description |
| :--- | :--- | :--- |
| `docker-compose.yaml` | **Deployment** | Defines the three separate PostgreSQL services (`postgres-node1`, `postgres-node2`, `postgres-node3`) and maps their ports (5433, 5434, 5435). |
| `init_node1.sql` | **Schema Setup (Node 1)** | Creates core tables (`users`, `playlists`) and a large partitioned `videos` table on the coordinating node. |
| `init_node2.sql` | **Schema Setup (Node 2)** | Creates the sharded table `videos_shard_1` and populates it with data where `user_id % 3 = 1`. |
| `init_node3.sql` | **Schema Setup (Node 3)** | Creates the sharded table `videos_shard_2` and populates it with data where `user_id % 3 = 2`. |
| `init_extension_node1.sql` | **FDW Configuration** | **Crucial linking file.** Sets up `postgres_fdw` extension, creates foreign servers for Node 2 & 3, and creates **Foreign Tables** on Node 1 that reference the sharded tables on the other two nodes. |

## 💡 How to Query

To query the distributed data, you typically connect to the coordinating node (Node 1) on port **5433**.

### Example: Connect to Node 1

```bash
psql -h localhost -p 5433 -U user1 -d shard1
