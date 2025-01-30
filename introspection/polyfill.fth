\ Accessing the input buffer components

\ This polyfill provides the following words (if they are missing):
\   source-offset
\   set-source-offset
\   source-preceding
\   source-following
\   source-line
\   source-line-offset

\ This polyfill does not provide words to access the input source components.



[undefined] source-offset [if]
: source-offset ( -- +n ) >in @ ;
[then]

[undefined] set-source-offset [if]
: set-source-offset ( +n -- )
  dup 0< if -12 throw then \ "argument type mismatch" (an optional check)
  dup source nip > if -24 throw then \ "invalid numeric argument"
  >in !
;
[then]

[undefined] source-preceding [if]
: source-preceding ( -- sd.the-preceding-area ) source drop source-offset ;
[then]

[undefined] source-following [if]
: source-following ( -- sd.the-following-area ) source source-offset /string ;
[then]



[undefined] source-line [if]

wordlist constant support.source-line
get-current ( wid.old )
get-order support.source-line swap 1+ set-order definitions


align here 13 , 10 ,  1+ 1  2constant line-terminator \ single LF

64 constant c/l

: split-string ( sd.text sd.separator -- sd.left sd.right | sd.text 0 0 )
  dup >r  3 pick >r  ( R: u.[sd.separator][1] addr.[st.text][2] )
  search 0= if 2rdrop 0 0 exit then ( addr u )
  over r@ - r> swap  2swap r> /string
;

: search-last ( sd1 sd.substring -- sd1 false | sd2 true )
  dup 0= if 2drop true exit then
  2dup 2>r search 0= if 2rdrop false exit then
  begin 2dup 1 /string 2r@ search while 2nip repeat
  2drop 2rdrop true
;

: split-string-last ( sd.text sd.separator -- sd.left sd.right | sd.text 0 0 )
  dup >r  3 pick >r  ( R: u.[sd.separator][1] addr.[st.text][2] )
  search-last 0= if 2rdrop 0 0 exit then ( addr u )
  over r@ - r> swap  2swap r> /string
;

( wid.old ) set-current \ export

: source-line ( -- sd.line )
  blk @ if
    source-preceding dup if 1- then ( c-addr.input-buffer +n.offset1 )
    dup c/l mod - +  c/l
    exit
  then
  source-id -1 = if
    source-preceding line-terminator split-string-last
    over if 2nip else 2drop then ( c-addr1 +n1 )
    line-terminator nip 1- min ( c-addr1 0|1 )
    source-following rot negate /string
    line-terminator search 2drop
    ( c-addr1 c-addr2 ) over -
    exit
  then
  source
;

previous
[then]



[undefined] source-line-offset [if]
: source-line-offset ( -- +n )
  source-following drop
  source-line drop  -
;
[then]

