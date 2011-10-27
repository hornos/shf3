#!/usr/bin/awk -f
#
# http://sites.google.com/site/dannychouinard/Home/unix-linux-trinkets/little-utilities/base64-and-base85-encoding-awk-scripts
#
function l(){if(++p>72){p=0;print t}}

function s(v,b){
 if(v==0) {
   printf(z);l()
 } else {
  o=t;for(n=0;n<5;n++){o=o substr(h,(v%g)+1,1);v/=g}
  while(n>4-b){printf(c,substr(o,n--,1));l()}
 }
}

function e(){
 printf("<~");
 while("od -vtu1"|getline){
  for(y=1;y<NF;){i+=($(++y)*m);m/=a;if(++k>3){s(i,k);k=i=0;m=j}}
 }
 if(k) s(i,k);
 p++;l();print "~>"
}

function d(){
 while(!f&&getline<"/dev/stdin"){if(substr($0,1,2)=="<~") f=1}
 while(f){
  while(++p<=length($0)&&f){
   n=index(h,substr($0,p,1));if(substr($0,p,2)=="~>") f=0;
   if(n>g) {
    printf(c c c c,0,0,0,0)
   } else {
    if(n--){
     q=g*q+n;
     if(++i>4){
      while(--i){printf(c,(q/j)%a);q*=a}
      q=0
     }
    }
   }
  }
  p=0;if(!getline<"/dev/stdin") f=0
 }
 if(i) { q=++q*g^(5-i--); while(i--){printf(c,(q/j)%a);q=a*(q-(j*int(q/j)))} }
}

BEGIN{
 z=h="z";c="%c";a=256;i=g=85;m=j=a^3;p=2;while(i){h=sprintf(c,32+i--) h}
 if(ARGV[1]=="d") d();
 else e()
}
