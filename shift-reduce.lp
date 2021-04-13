
term(awkward;cute;simple;turtle;slime;robot).
nonterm(phrase;adj;noun).

% production rules
prod(phrase, seq(adj,noun)).
prod(adj, awkward; adj, cute; adj, simple).
prod(noun, turtle; noun, slime; noun, robot).

% shift (different cases for non-nil and nil)
parse(seq(Beta,T), W)
  :- parse(Beta, seq(T,W)), Beta != nil.

parse(T, W)
  :- parse(nil, seq(T,W)).

% reduce end of sequence
parse(seq(Beta, Gamma), W)
  :- parse(seq(Beta, Alpha), W),
      prod(Gamma, Alpha).

% reduce starting nonterm
parse(Gamma, W)
  :- parse(Alpha, W),
      prod(Gamma, Alpha).

% start
parse(nil, W)
  :- start_sequence(W).

parse_all(Parse)
  :- parse(Parse, nil).

#show parse_all/1.

% example supplying an input and generating a parse.
% start_sequence(seq(cute, seq(robot,nil))).

% example supplying a starting nonterm and generating an input sequence.
{generated_sequence(nil)}.
{generated_sequence(seq(T,S))} :- term(T), generated_sequence(S).
1 {start_sequence(S) : generated_sequence(S)} 1.

:- not parse_all(phrase).


