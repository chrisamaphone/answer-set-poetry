
% term(awkward;cute;simple;turtle;slime;robot).

% production rules
prod(det, the).
prod(adj, awkward; adj, cute; adj, simple).
prod(noun, turtle; noun, slime; noun, robot).
prod(phrase, seq(adj,noun)).
prod(dphrase, seq(det,phrase)).
prod(verb, dances; verb, chuckles; verb, thinks).
prod(sentence, seq(dphrase, verb)).

% defining terminals and nonterminals
nonterm(X) :- prod(X, _).

prod_seq(nil).
prod_seq(seq(H,T)) :- prod(_, seq(H,T)).
prod_seq(seq(X,S)) :- prod_seq(seq(_,seq(X,S))).
prod_seq(seq(X,S)) :- prod_seq(seq(seq(X,S),_)).
term(T) :- prod_seq(seq(T,S)), not prod_seq(T), not nonterm(T).
term(T) :- prod(N, T), not prod_seq(T), not nonterm(T).

% #show term/1.

%% Rules for parsing/expanding

% shift (different cases for non-nil and nil)
gen(Beta, seq(T,W))
  :- gen(seq(Beta,T), W), term(T).

gen(nil, seq(T,W))
  :- gen(T, W), term(T).

% reduce end of sequence
{gen(seq(Beta, Alpha), W)}
  :- gen(seq(Beta, Gamma), W),
      prod(Gamma, Alpha).

% reduce stand-alone nonterminal
{gen(Alpha, W)}
  :- gen(Gamma, W),
      prod(Gamma, Alpha).

% rebalance sequence to access atomic nonterm
gen(seq(seq(X,Y), Z), W)
  :- gen(seq(X, seq(Y,Z)), W).

% start
gen(Origin, nil)
  :- origin(Origin).

matches(Generated, Origin)
  :- gen(nil, Generated), origin(Origin).


%%% Different use modes

% Choose one origin such that it has at least 1 match.
% 1 { origin(N) : nonterm(N) } 1.
% 1 { matches(G,N) : matches(G,N) }.

% Choose a string that matches a given origin (e.g. sentence, phrase).
origin(sentence).
5 { gen(nil, G) : gen(nil, G) }.

% Choose an origin that matches a given input (parse)
% 1 { origin(N) : nonterm(N) }.
% :- not gen(nil, seq(the, seq(cute, seq(robot, seq(dances,nil))))).

#show origin/1.
#show matches/2.

