DROP TABLE IF EXISTS net_ipfw;

CREATE TABLE net_ipfw (
  no    NUMERIC NOT NULL,
  func  TEXT NOT NULL,
  rule  TEXT NOT NULL,
  state NUMERIC NOT NULL DEFAULT 0,
  PRIMARY KEY(no),
  UNIQUE(no,func)
);
