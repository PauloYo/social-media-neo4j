// =====================================================
// 1. CRIAR / ATUALIZAR USUÁRIOS
// =====================================================

UNWIND [
  {id: 'u1', username: 'paulo', name: 'Paulo Sousa', createdAt: '2026-01-10T10:00:00'},
  {id: 'u2', username: 'ana', name: 'Ana Martins', createdAt: '2026-01-11T11:30:00'},
  {id: 'u3', username: 'carlos', name: 'Carlos Lima', createdAt: '2026-01-12T09:20:00'},
  {id: 'u4', username: 'beatriz', name: 'Beatriz Rocha', createdAt: '2026-01-13T14:00:00'},
  {id: 'u5', username: 'joao', name: 'João Pedro', createdAt: '2026-01-14T16:45:00'},
  {id: 'u6', username: 'marina', name: 'Marina Alves', createdAt: '2026-01-15T08:10:00'}
] AS row
MERGE (u:User {id: row.id})
SET u.username = row.username,
    u.name = row.name,
    u.createdAt = datetime(row.createdAt);

// =====================================================
// 2. CRIAR / ATUALIZAR POSTS E RELACIONAMENTO POSTED
// =====================================================

UNWIND [
  {id: 'p1', userId: 'u2', content: 'Como a IA está mudando o desenvolvimento de software', createdAt: '2026-04-01T09:00:00'},
  {id: 'p2', userId: 'u3', content: 'Neo4j é muito útil para redes sociais', createdAt: '2026-04-02T10:00:00'},
  {id: 'p3', userId: 'u4', content: 'Dicas de produtividade para devs', createdAt: '2026-04-03T11:00:00'},
  {id: 'p4', userId: 'u5', content: 'Análise de comunidades em grafos', createdAt: '2026-04-04T12:00:00'},
  {id: 'p5', userId: 'u6', content: 'Automação com Python e APIs', createdAt: '2026-04-05T13:00:00'}
] AS row
MATCH (u:User {id: row.userId})
MERGE (p:Post {id: row.id})
SET p.content = row.content,
    p.createdAt = datetime(row.createdAt)
MERGE (u)-[:POSTED]->(p);

// =====================================================
// 3. CRIAR / ATUALIZAR TAGS
// =====================================================

UNWIND [
  'ia',
  'programacao',
  'neo4j',
  'grafos',
  'produtividade',
  'comunidades',
  'python',
  'automacao'
] AS tagName
MERGE (t:Tag {name: tagName});

// =====================================================
// 4. ASSOCIAR POSTS COM TAGS
// =====================================================

UNWIND [
  {postId: 'p1', tag: 'ia'},
  {postId: 'p1', tag: 'programacao'},
  {postId: 'p2', tag: 'neo4j'},
  {postId: 'p2', tag: 'grafos'},
  {postId: 'p3', tag: 'produtividade'},
  {postId: 'p3', tag: 'programacao'},
  {postId: 'p4', tag: 'grafos'},
  {postId: 'p4', tag: 'comunidades'},
  {postId: 'p5', tag: 'python'},
  {postId: 'p5', tag: 'automacao'}
] AS row
MATCH (p:Post {id: row.postId})
MATCH (t:Tag {name: row.tag})
MERGE (p)-[:HAS_TAG]->(t);
 

// =====================================================
// 5. CRIAR / ATUALIZAR RELACIONAMENTOS DE SEGUIMENTO
// =====================================================

UNWIND [
  {sourceUserId: 'u1', targetUserId: 'u2', since: '2026-02-01T10:00:00'},
  {sourceUserId: 'u1', targetUserId: 'u3', since: '2026-02-02T10:00:00'},
  {sourceUserId: 'u2', targetUserId: 'u4', since: '2026-02-03T10:00:00'},
  {sourceUserId: 'u3', targetUserId: 'u4', since: '2026-02-04T10:00:00'},
  {sourceUserId: 'u3', targetUserId: 'u5', since: '2026-02-05T10:00:00'},
  {sourceUserId: 'u4', targetUserId: 'u6', since: '2026-02-06T10:00:00'}
] AS row
MATCH (source:User {id: row.sourceUserId})
MATCH (target:User {id: row.targetUserId})
MERGE (source)-[r:FOLLOWS]->(target)
SET r.since = datetime(row.since);

// =====================================================
// 6. CRIAR / ATUALIZAR CURTIDAS
// =====================================================

UNWIND [
  {userId: 'u1', postId: 'p1', at: '2026-04-06T10:00:00'},
  {userId: 'u1', postId: 'p2', at: '2026-04-06T10:10:00'},
  {userId: 'u2', postId: 'p3', at: '2026-04-06T10:20:00'},
  {userId: 'u3', postId: 'p4', at: '2026-04-06T10:30:00'},
  {userId: 'u4', postId: 'p5', at: '2026-04-06T10:40:00'}
] AS row
MATCH (u:User {id: row.userId})
MATCH (p:Post {id: row.postId})
MERGE (u)-[r:LIKED]->(p)
SET r.at = datetime(row.at);

// =====================================================
// 7. CRIAR / ATUALIZAR COMENTÁRIOS
// =====================================================

UNWIND [
  {id: 'c1', userId: 'u1', postId: 'p1', text: 'Muito interessante!', createdAt: '2026-04-06T11:00:00'},
  {id: 'c2', userId: 'u3', postId: 'p1', text: 'Concordo com essa análise', createdAt: '2026-04-06T11:10:00'},
  {id: 'c3', userId: 'u2', postId: 'p2', text: 'Neo4j combina muito com esse caso', createdAt: '2026-04-06T11:20:00'}
] AS row
MATCH (u:User {id: row.userId})
MATCH (p:Post {id: row.postId})
MERGE (c:Comment {id: row.id})
SET c.text = row.text,
    c.createdAt = datetime(row.createdAt)
MERGE (u)-[:WROTE]->(c)
MERGE (c)-[:ON]->(p);

// =====================================================
// 8. VERIFICAR RESULTADO
// =====================================================

CALL {
  MATCH (u:User)
  RETURN count(u) AS totalUsers
}
CALL {
  MATCH (p:Post)
  RETURN count(p) AS totalPosts
}
CALL {
  MATCH (c:Comment)
  RETURN count(c) AS totalComments
}
CALL {
  MATCH (t:Tag)
  RETURN count(t) AS totalTags
}
RETURN totalUsers,
       totalPosts,
       totalComments,
       totalTags,
       'Dados carregados com sucesso! ✅' AS status;