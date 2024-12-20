\ 2024-12-19 ruv


\ Some words from
\   https://github.com/ForthHub/fep-recognizer/blob/master/implementation/lib/string-match.fth
[undefined] equals [if]
: equals ( sd sd -- flag )
  dup 3 pick <> if 2drop 2drop false exit then
  compare 0=
;
[then]
[undefined] ends-with [if]
: ends-with ( sd sd.tail -- flag )
  dup >r 2swap dup r@ u< if  2drop 2drop rdrop false exit then
  r@ - + r> compare 0=
;
[then]
[undefined] starts-with [if]
: starts-with ( sd sd.head -- flag )
  rot over u< if  2drop drop false exit then
  tuck compare 0=
;
[then]

\ The words `2pick` and `2roll`
\   see: https://github.com/ForthHub/discussion/discussions/186#discussioncomment-11435928
[undefined] 2pick [if]
: 2pick (  xd.param  +n.cnt*x +n.cnt -- xd.param  +n.cnt*x  xd.param )
  1+ dup 1+ pick swap pick
;
[then]
[undefined] 2roll [if]
: 2roll (  xd.param  +n.cnt*x +n.cnt -- +n.cnt*x  xd.param )
  1+ dup 1+ roll swap roll
;
[then]





: \TEST ( "text" -- )
  source >in @ /string dup >in +!
  cr ." \ TEST: " type cr
; immediate





[undefined] resolve-uri-here [if]  [undefined] resolve-uri [if]
cr .( \ INFO: neither `resolve-uri-here` nor `resolve-uri` is defined ) cr

: crop ( sd sd.buf -- sd.vacant )
  dup >r rot umin dup >r 2dup + >r  move r> 2r> -
;
: path-directory ( sd.path -- sd.directory )
  \ sd.directory either ends with "/", or has zero length
  over + begin 2dup u< while
    char- dup c@ '/' =
  until char+ then
  over -
;
: test-path-full ( sd.path -- sd.path flag )
  2dup s" /" starts-with if true exit then
  2dup 15 umin s" :" search nip nip if true exit then
  false
;

1024 buffer: uri-resolved-addr0
: uri-resolved-buf ( -- a-addr u.size ) uri-resolved-addr0 1024 ;

\ See: https://www.w3.org/TR/xpath-functions/#func-resolve-uri
: resolve-uri ( sd.uri sd.uri.base -- sd.uri | sd.uri.resolved.transient )
  \ todo: the result URI must be normalized
  2>r test-path-full if 2r> 2drop exit then
  2r> path-directory uri-resolved-buf over >r crop crop
  if 0 over c! r> tuck - exit then
  true abort" resolve-uri: too long URI"
;

[then] \ now `resolve-uri` is defined anyway
\TEST `resolve-uri` has the type ( sd.uri sd.uri.base -- sd.uri.resolved.transient )
t{ s" foo" s" bar/baz" resolve-uri s" bar/foo" equals -> true }t

\TEST `resolve-uri` must return the same full path if any
t{ s" /foo"       2dup s" bar/baz" resolve-uri  d=  -> true }t
t{ s" about:foo"  2dup s" bar/baz" resolve-uri  d=  -> true }t

: resolve-uri-here ( sd.uri sd.uri.base -- sd.uri.resolved )
  resolve-uri here swap 2dup 2>r dup allot move 0 c, 2r>
;
[then]

.( \ INFO, in the context of "test/index.fth" ) cr
.( \   source-path       is: ) source-path type cr
.( \   source-base-path  is: ) source-base-path type cr

source-base-path s" /" starts-with  source-base-path s" :" search nip nip or  0= [if]
  .( \ WARNING: `source-base-path` must return a full path name ) cr
[then]



[undefined] apply-base-path [if]
.( \ INFO: `apply-base-path` is not defined ) cr
[else]

\TEST `apply-base-path`
t{ s" /foo/bar" :noname ( sd -- flag ) source-base-path equals ; 1 2pick apply-base-path -> true }t

\TEST `apply-base-path` must take into account `source-base-path`
t{ s" foo/bar" 2dup source-base-path resolve-uri-here 2swap :noname ( sd -- flag ) source-base-path equals ; 1 2roll apply-base-path -> true }t

[then]


\TEST expected `source-path` inside `evaluate`
t{ :noname true
    source-path nip 0= if exit then
    source-path s" about:input/" starts-with if exit then
    source-path s" data:" starts-with if exit then
    drop false
  ;
  s" execute" evaluate -> true
}t

\TEST `evaluate` must not affect `source-base-path`
t{ source-base-path s" source-base-path equals" evaluate -> true }t


\TEST expected `source-path` inside `include-file`
t{ s" ./data/unknown-path.fth" source-base-path resolve-uri-here r/o open-file throw include-file -> true }t

\TEST `include-file` must not affect `source-base-path`
t{ source-base-path s" ./data/base-path-equals.fth" 2over resolve-uri-here r/o open-file throw include-file -> true }t


\TEST `included` must correctly affect `source-base-path`
t{ source-base-path s" ./data/base-path-equals.fth" 2over resolve-uri-here included -> false }t

\TEST `include` must correctly affect `source-base-path`
t{ source-base-path s" ./data/base-path-equals.fth" 2over resolve-uri-here ' include execute-parsing -> false }t


\TEST `source-path` inside `included` must not be located at the same address range as the input path
t{ s" ./data/path-same.fth" source-base-path resolve-uri-here 2dup included -> false }t

cr .( \ INFO, testing is completed ) cr cr
