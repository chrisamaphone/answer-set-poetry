
% term(awkward;cute;simple;turtle;slime;robot).

% production rules
prod(phrase, seq(adj,noun)).
prod(adj, awkward; adj, cute; adj, simple).
prod(noun, turtle; noun, slime; noun, robot).
prod(verb, dances; verb, chuckles; verb, thinks).
prod(sentence, seq(phrase, verb)).

% defining terminals and nonterminals
nonterm(X) :- prod(X, _).

prod_seq(seq(H,T)) :- prod(_, seq(H,T)).
term(T) :- prod(N, T), not prod_seq(T), not nonterm(T).

% shift (different cases for non-nil and nil)
gen(Beta, seq(T,W))
  :- gen(seq(Beta,T), W), term(T).

gen(nil, seq(T,W))
  :- gen(T, W), term(T).

% reduce end of sequence
{gen(seq(Beta, Alpha), W)}
  :- gen(seq(Beta, Gamma), W),
      prod(Gamma, Alpha).

% reduce starting nonterm
{gen(Alpha, W)}
  :- gen(Gamma, W),
      prod(Gamma, Alpha).

% start
gen(Origin, nil)
  :- origin(Origin).

matches(Generated, Origin)
  :- gen(nil, Generated), origin(Origin).


% Choose one origin such that it has at least 1 match.
% 1 { origin(N) : nonterm(N) } 1.
% 1 { matches(G,N) : matches(G,N) }.

% Choose a string that matches a given origin (e.g. sentence, phrase).
% origin(phrase).
% 3 { gen(nil, G) : gen(nil, G) }.

% Choose an origin that matches a given input (parse)
% 1 { origin(N) : nonterm(N) }.
% :- not gen(nil, seq(cute, seq(robot, nil))).

#show origin/1.
#show matches/2.

