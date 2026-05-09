CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User)
REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT post_id_unique IF NOT EXISTS
FOR (p:Post)
REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT comment_id_unique IF NOT EXISTS
FOR (c:Comment)
REQUIRE c.id IS UNIQUE;

CREATE CONSTRAINT tag_name_unique IF NOT EXISTS
FOR (t:Tag)
REQUIRE t.name IS UNIQUE;
CREATE INDEX post_created_at IF NOT EXISTS
FOR (p:Post)
ON (p.createdAt);

CREATE INDEX user_username IF NOT EXISTS
FOR (u:User)
ON (u.username);