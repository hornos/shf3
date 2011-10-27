DROP TABLE IF EXISTS enc_pass;

CREATE TABLE enc_pass (
  uid       varchar(512) PRIMARY KEY NOT NULL,
  pass      text,
  ctime     date,
  mtime     date
);
