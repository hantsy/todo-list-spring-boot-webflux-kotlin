CREATE SEQUENCE IF NOT EXISTS todos_id_seq;

CREATE TABLE IF NOT EXISTS todos(
id INTEGER NOT NULL PRIMARY KEY DEFAULT nextval('todos_id_seq') ,
title VARCHAR(255) NOT NULL,
completed BOOL DEFAULT FALSE,
created_by VARCHAR(255),
created_at TIMESTAMP
);

ALTER SEQUENCE todos_id_seq OWNED BY todos.id;
