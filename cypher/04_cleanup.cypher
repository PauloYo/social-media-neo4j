-- Script de limpeza para remover todos os dados
-- Use com cuidado! Este script deleta todo o conteúdo do banco

-- Deletar todos os nós e relacionamentos
MATCH (n)
DETACH DELETE n;

-- Remover constraints (opcional)
-- DROP CONSTRAINT user_id_unique;
-- DROP CONSTRAINT post_id_unique;
-- DROP CONSTRAINT comment_id_unique;
-- DROP CONSTRAINT tag_name_unique;
-- (community constraint not present)

-- Remover índices (opcional)
-- DROP INDEX post_created_at;
-- DROP INDEX user_username;
