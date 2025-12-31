-- MariaDB setup for CDC sink
CREATE DATABASE IF NOT EXISTS target_database DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP TABLE IF EXISTS target_database.target_orders;
