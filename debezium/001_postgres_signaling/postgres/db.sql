CREATE database test;

\connect test;

CREATE TABLE mock1 (
	id serial PRIMARY KEY,
	col1 VARCHAR ( 50 ) UNIQUE NOT NULL,
	col2 VARCHAR ( 50 ) NOT NULL
);

INSERT INTO mock1 (id,col1,col2) VALUES (1,'123','123');
INSERT INTO mock1 (id,col1,col2) VALUES (2,'323','823');
INSERT INTO mock1 (id,col1,col2) VALUES (3,'423','523');

CREATE PUBLICATION debezium FOR ALL TABLES;

CREATE TABLE debezium_signal (
    id VARCHAR(50) PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    data VARCHAR(2048) NULL
);
