-- ParadeDB 初始化：paradedb/paradedb 镜像已内置 vector 与 pg_search 扩展，此处启用。
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_search;
