
#const max_length=10.

element(a).

gen(0,nil).
{ gen(N+1,cons(X,S)) } :- gen(N,S), element(X), N < max_length.
