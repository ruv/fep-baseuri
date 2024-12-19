( -- flag )

.(      \ info, inside "data/unknown-path.fth", `source-path`  is: ) cr
.(      \    ) source-path type cr

source-path nip [if]
  source-path s" about:input/" starts-with
  source-path s" /path-unknown.fth" ends-with
  or
[else]
.(      \ warning, inside "data/unknown-path.fth", `source-path` is empty ) cr

  true

[then]
