DROP TABLE IF EXISTS que_track;

CREATE TABLE que_track (
  jid       varchar(512) NOT NULL,
  job       varchar(512) NOT NULL,
  host      varchar(512) NOT NULL,
  que       varchar(512) NOT NULL,
  acc       varchar(512),
  uid       varchar(512) NOT NULL,
  -- submit time
  ctime     integer,
  -- start time
  stime     integer,
  -- end time
  etime     integer,
  exit      integer,
  path      text,
  UNIQUE(jid,job,host,que,uid)
);
