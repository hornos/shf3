DROP TABLE IF EXISTS net_ipfw;

CREATE TABLE net_ipfw (
  -- rules
  rno    NUMERIC NOT NULL,
  rset   NUMERIC NOT NULL,
  rfunc  TEXT NOT NULL,
  rstate NUMERIC NOT NULL DEFAULT 0,
  PRIMARY KEY(rno),
  UNIQUE(rno,rfunc)
);
