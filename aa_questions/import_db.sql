PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname VARCHAR(50) NOT NULL,
    lname VARCHAR(50) NOT NULL
);

INSERT INTO 
    users (fname, lname)
VALUES
    ('Nick', 'Werner'),
    ('Carlos', 'Arias');




CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL, 

    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
   questions (title, body, user_id)
VALUES
    ('How do we persist data?', 'How do we persist data in our databases from session to session?', (SELECT id FROM users WHERE fname = 'Nick')),
    ('How do we format tables in SQLite3?', 'What command line statements do we use to format our output in SQLite3?', (SELECT id FROM users WHERE fname = 'Carlos'));




CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
    question_follows (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Carlos'), (SELECT id FROM questions WHERE title = 'How do we format tables in SQLite3?')),
    ((SELECT id FROM users WHERE fname = 'Nick'), (SELECT id FROM questions WHERE title = 'How do we persist data?')),
    ((SELECT id FROM users WHERE fname = 'Nick'), (SELECT id FROM questions WHERE title = 'How do we format tables in SQLite3?')),
    ((SELECT id FROM users WHERE fname = 'Carlos'), (SELECT id FROM questions WHERE title = 'How do we persist data?'));




CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    parent_id INTEGER,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (parent_id) REFERENCES replies(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
    replies (body, parent_id, user_id, question_id)
VALUES
    ('Use the commands: ".headers on", and ".mode column".', NULL, (SELECT id FROM users WHERE fname = 'Nick'), (SELECT id FROM questions WHERE title = 'How do we format tables in SQLite3?')),
    ('Eventually, we will export our files to heroku, which will host our databases', NULL, (SELECT id FROM users WHERE fname = 'Carlos'), (SELECT id FROM questions WHERE title = 'How do we persist data?'));

INSERT INTO 
    replies (body, parent_id, user_id, question_id)
VALUES 
    ('Great Work!', (SELECT replies.id FROM replies WHERE replies.body = 'Eventually, we will export our files to heroku, which will host our databases'), (SELECT id FROM users WHERE fname = 'Nick'), (SELECT id FROM questions WHERE title = 'How do we persist data?'));



CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
    question_likes (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Nick'), (SELECT id FROM questions WHERE title = 'How do we format tables in SQLite3?')),
    ((SELECT id FROM users WHERE fname = 'Carlos'), (SELECT id FROM questions WHERE title = 'How do we persist data?'));




