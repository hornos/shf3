#!/usr/bin/awk -f
#
# http://sites.google.com/site/dannychouinard/Home/unix-linux-trinkets/little-utilities/base64-and-base85-encoding-awk-scripts
#
function encode64() {
  while( "od -v -t x1" | getline ) {
    for(c=9; c<=length($0); c++) {
      d=index("0123456789abcdef",substr($0,c,1));
      if(d--) {
        for(b=1; b<=4; b++ ) {
          o=o*2+int(d/8); d=(d*2)%16;
          if(++obc==6) {
            printf substr(b64,o+1,1);
            # if(++rc>75) { printf("\n"); rc=0; }
            obc=0; o=0;
          }
        }
      }
    }
  }
  if(obc) {
    while(obc++<6) { o=o*2; }
    printf "%c",substr(b64,o+1,1);
  }
  print "==";
}
function decode64() {
  while( getline < "/dev/stdin" ) {
    for(i=1;i<=length($0);i++) {
      c=index(b64,substr($0,i,1));
      if(c--) {
        for(b=0;b<6;b++) {
          o=o*2+int(c/32); c=(c*2)%64;
          if(++obc==8) { printf "%c",o; obc=0; o=0; }
        }
      }
    }
  }
}
BEGIN {
  b64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  if(ARGV[1]=="d") { decode64(); exit; }
  encode64();
}
