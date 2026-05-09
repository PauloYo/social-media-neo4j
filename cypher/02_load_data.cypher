-- Script para carregar dados dos arquivos CSV (ALTERNATIVA)
-- Este script usa `LOAD CSV` e pressupõe que os arquivos CSV
-- foram copiados para a pasta `import` do Neo4j.
-- Caminho padrão de import: <NEO4J_HOME>/import/
--
-- Observações:
-- - Se preferir não usar CSVs, use `cypher/02_load_data_inline.cypher` (insere os dados inline).
-- - O Neo4j pode bloquear URLs "file:///" por segurança. Se receber o erro:
--      Neo.ClientError.Statement.ExternalResourceFailed
--      Cannot load from URL 'file:///users.csv': configuration property 'dbms.security.allow_csv_import_from_file_urls' is false
--   então habilite em `neo4j.conf`:
--      dbms.security.allow_csv_import_from_file_urls=true
-- - Para Docker, copie os arquivos para `/var/lib/neo4j/import/` no container.

-- Carregar usuários
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {id: row.id})
SET u.username = row.username,
    u.name = row.name,
    u.createdAt = datetime(row.createdAt);

-- Carregar posts
LOAD CSV WITH HEADERS FROM 'file:///posts.csv' AS row
MATCH (u:User {id: row.userId})
MERGE (p:Post {id: row.id})
SET p.content = row.content,
    p.createdAt = datetime(row.createdAt)
MERGE (u)-[:POSTED]->(p);

-- Carregar seguidores
LOAD CSV WITH HEADERS FROM 'file:///follows.csv' AS row
MATCH (source:User {id: row.sourceUserId})
MATCH (target:User {id: row.targetUserId})
MERGE (source)-[r:FOLLOWS]->(target)
SET r.since = datetime(row.since);

-- Carregar curtidas
LOAD CSV WITH HEADERS FROM 'file:///likes.csv' AS row
MATCH (u:User {id: row.userId})
MATCH (p:Post {id: row.postId})
MERGE (u)-[r:LIKED]->(p)
SET r.at = datetime(row.at);

-- Carregar comentários
LOAD CSV WITH HEADERS FROM 'file:///comments.csv' AS row
MATCH (u:User {id: row.userId})
MATCH (p:Post {id: row.postId})
MERGE (c:Comment {id: row.id})
SET c.text = row.text,
    c.createdAt = datetime(row.createdAt)
MERGE (u)-[:WROTE]->(c)
MERGE (c)-[:ON]->(p);

-- Carregar tags dos posts
LOAD CSV WITH HEADERS FROM 'file:///post_tags.csv' AS row
MATCH (p:Post {id: row.postId})
MERGE (t:Tag {name: row.tag})
MERGE (p)-[:HAS_TAG]->(t);
