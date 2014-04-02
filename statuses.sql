CREATE TABLE statuses (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL
);


INSERT INTO
  statuses (body)
VALUES
  ("Welcome to my Ruby Tram App"), 
("These two tweets are seeded in the database on server launch");
