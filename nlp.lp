%% Parsing and parts of speech

% Word library; TODO import from prev. iterations
pos(her, det).

% Production rules for terminals (base categories)
prod(POS, Word) :- pos(Word, POS). % access to more general word lib
prod(det, the).
prod(adj, awkward; adj, cute; adj, simple).
prod(noun, turtle; noun, slime; noun, robot).
prod(verb, dances; verb, chuckles; verb, thinks).

% General production rules for compound categories
prod(phrase, seq(adj,noun)).
prod(dphrase, seq(det,phrase)).
prod(dphrase, seq(det, noun)).
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

% #show origin/1.
% #show matches/2.

%%% Defining subsequences of generated sequences
% relseq = "relevant sequence"
relseq(S) :- relseq(seq(X,S)).
relseq(G) :- matches(G, Origin).

%%% Adding syllable counts
syl(the, 1).
syl(her, 1).
syl(awkward, 2).
syl(cute, 1).
syl(simple, 2).
syl(robot, 2).
syl(turtle, 2).
syl(slime, 1).
syl(dances, 2).
syl(thinks, 1).
syl(chuckles, 2).

syl(nil, 0).
syl(seq(W, S), N1+N2)
  :- relseq(seq(W,S)), syl(W,N1), syl(S,N2).

total_syl(N, Generated) :- 
  matches(Generated, Origin), syl(Generated, N).
#show total_syl/2.

% constraint: only generate utterances of equal syllable length
% :- total_syl(N1, Gen1), total_syl(N2, Gen2), N1 != N2.

% constraint: only generate utterance of syllable count 6
% :- total_syl(N, Gen), N != 6.
