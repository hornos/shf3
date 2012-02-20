DROP TABLE IF EXISTS ipfw_rule;
DROP TABLE IF EXISTS ipfw_tag;

CREATE TABLE ipfw_tag (
  tag   TEXT NOT NULL,
  ctime INTEGER NOT NULL,
  valid INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(tag)
);

CREATE TABLE ipfw_rule (
  id    NUMERIC NOT NULL,
  rule  TEXT NOT NULL,
  tag   TEXT NOT NULL,
  PRIMARY KEY(id),
  UNIQUE(id,rule),
  FOREIGN KEY(tag) REFERENCES ipfw_tag(tag)
);
