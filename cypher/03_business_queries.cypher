// Queries de negócio para análise da rede social
// Essas consultas demonstram o poder do Neo4j para recomendações

// ============================================================
// CONSULTA 1: Indicação de amizades
// Pergunta: quais usuários Paulo deveria seguir com base em conexões em comum?
// ============================================================

MATCH (me:User {username: 'paulo'})
MATCH (me)-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(candidate:User)
WHERE candidate <> me
  AND NOT (me)-[:FOLLOWS]->(candidate)

WITH me, candidate, collect(DISTINCT friend.username) AS mutualFriends

OPTIONAL MATCH (me)-[:LIKED]->(:Post)-[:HAS_TAG]->(tag:Tag)<-[:HAS_TAG]-(:Post)<-[:POSTED]-(candidate)

RETURN candidate.username AS suggestedUser,
       candidate.name AS name,
       mutualFriends,
       size(mutualFriends) AS mutualFriendsCount,
       count(DISTINCT tag) AS commonInterests,
       size(mutualFriends) * 2 + count(DISTINCT tag) AS recommendationScore
ORDER BY recommendationScore DESC;

// ============================================================
// CONSULTA 2: Feed baseado em quem o usuário segue
// Pergunta: quais posts devem aparecer no feed de Paulo?
// ============================================================

MATCH (me:User {username: 'paulo'})
MATCH (me)-[:FOLLOWS]->(author:User)-[:POSTED]->(post:Post)

OPTIONAL MATCH (post)<-[like:LIKED]-(:User)
WITH me, author, post, count(DISTINCT like) AS likes

OPTIONAL MATCH (post)<-[:ON]-(comment:Comment)
WITH author, post, likes, count(DISTINCT comment) AS comments

RETURN author.username AS author,
       post.content AS content,
       post.createdAt AS createdAt,
       likes,
       comments,
       likes * 3 + comments * 2 AS engagementScore
ORDER BY engagementScore DESC, createdAt DESC;

// ============================================================
// CONSULTA 3: Recomendação de posts com base no que o usuário curtiu
// Pergunta: quais posts Paulo pode gostar, mesmo que não siga o autor?
// ============================================================

MATCH (me:User {username: 'paulo'})
MATCH (me)-[:LIKED]->(:Post)-[:HAS_TAG]->(tag:Tag)
MATCH (tag)<-[:HAS_TAG]-(recommendedPost:Post)<-[:POSTED]-(author:User)

WHERE NOT (me)-[:LIKED]->(recommendedPost)
  AND NOT (me)-[:POSTED]->(recommendedPost)

OPTIONAL MATCH (recommendedPost)<-[like:LIKED]-(:User)
WITH recommendedPost, author, collect(DISTINCT tag.name) AS matchedTags, count(DISTINCT like) AS likes

RETURN recommendedPost.content AS post,
       author.username AS author,
       matchedTags,
       size(matchedTags) AS interestScore,
       likes AS popularityScore,
       size(matchedTags) * 5 + likes AS finalScore
ORDER BY finalScore DESC;

// ============================================================
// CONSULTA 4: Posts mais populares da rede
// Pergunta: quais posts possuem maior engajamento?
// ============================================================

MATCH (post:Post)<-[:POSTED]-(author:User)

OPTIONAL MATCH (post)<-[like:LIKED]-(:User)
WITH post, author, count(DISTINCT like) AS likes

OPTIONAL MATCH (post)<-[:ON]-(comment:Comment)
WITH post, author, likes, count(DISTINCT comment) AS comments

RETURN post.content AS post,
       author.username AS author,
       likes,
       comments,
       likes * 1 + comments * 2 AS engagementScore
ORDER BY engagementScore DESC;

// ============================================================
// CONSULTA 5: Usuários mais influentes
// Pergunta: quais usuários têm maior influência na rede?
// ============================================================

MATCH (u:User)

OPTIONAL MATCH (follower:User)-[:FOLLOWS]->(u)
WITH u, count(DISTINCT follower) AS followers

OPTIONAL MATCH (u)-[:POSTED]->(post:Post)<-[like:LIKED]-(:User)
WITH u, followers, count(DISTINCT like) AS totalLikesReceived

OPTIONAL MATCH (u)-[:POSTED]->(post:Post)<-[:ON]-(comment:Comment)
WITH u, followers, totalLikesReceived, count(DISTINCT comment) AS totalCommentsReceived

RETURN u.username AS username,
       u.name AS name,
       followers,
       totalLikesReceived,
       totalCommentsReceived,
       followers * 3 + totalLikesReceived * 2 + totalCommentsReceived AS influenceScore
ORDER BY influenceScore DESC;

// ============================================================
// CONSULTA 6: Comunidades de interesse por tags
// Pergunta: quais temas concentram mais usuários engajados?
// ============================================================

MATCH (u:User)-[:LIKED]->(:Post)-[:HAS_TAG]->(tag:Tag)

RETURN tag.name AS interest,
       count(DISTINCT u) AS engagedUsers,
       collect(DISTINCT u.username)[0..5] AS sampleUsers
ORDER BY engagedUsers DESC;

// ============================================================
// CONSULTA 7: Usuários com interesses parecidos
// Pergunta: quais usuários têm interesses parecidos com Paulo?
// ============================================================

MATCH (me:User {username: 'paulo'})
MATCH (me)-[:LIKED]->(:Post)-[:HAS_TAG]->(tag:Tag)
MATCH (other:User)-[:LIKED]->(:Post)-[:HAS_TAG]->(tag)

WHERE other <> me

RETURN other.username AS similarUser,
       other.name AS name,
       collect(DISTINCT tag.name) AS commonTags,
       count(DISTINCT tag) AS similarityScore
ORDER BY similarityScore DESC;
