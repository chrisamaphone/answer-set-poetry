#show output/1.

word(they).
word(them).
word(their).

pos(they, pronoun_subj).
pos(them, pronoun_obj).
pos(their, det).


% Nouns

word(transformation).
pos(transformation, noun).

word(self).
pos(self, noun).
plural(self, selves).

word(limb).
pos(limb, noun).
plural(limb, limbs).

word(eye).
pos(eye,noun).
plural(eye, eyes).

word(cloud).
post(cloud, noun).
plural(cloud, clouds).

% Verbs

word(transform).
pos(transform, vt).

word(unfurl).
pos(unfurl, vi).

word(touch).
pos(touch, vt).

word(glow).
pos(glow, vi).

word(flail).
pos(flail, vi).

% Determiners and prepositions

word(the).
pos(the, det).

word(a).
pos(a, det).

word(into).
pos(into, prep).


% Grammar expansion rules

expands(subj, seq(det, noun)).
expands(subj, pronoun_subj).
expands(vp, vi).
expands(vp, seq(vt, obj)).
expands(vp, seq(vi, avp)).
expands(vp, seq(seq(vt, obj), avp)).
expands(avp, seq(prep, obj)).
expands(obj, seq(det, noun)).
expands(obj, pronoun_obj).
expands(sentence, seq(subj, vp)).

expands(Pos, Word) :- pos(Word, Pos).

expands(noun, Plural) :- pos(Word, noun), plural(Word, Plural).

expands(seq(X,Y), seq(X1, Y))
  :- reachable(seq(X,Y)),
      expands(X, X1).

expands(seq(X,Y), seq(X,Y1))
  :- reachable(seq(X,Y)),
      expands(Y, Y1).

reachable(X) :- origin(X).
reachable(Y)
  :- reachable(X), expands(X, Y).
reachable(X)
  :- reachable(seq(X,Y)).
reachable(Y)
  :- reachable(seq(X,Y)).

matches(X, X)
  :- origin(X).
matches(X, Z)
  :- matches(X, Y), expands(Y,Z).


ground(W) :- word(W).
ground(seq(X,Y)) :- ground(X), ground(Y), reachable(seq(X,Y)).
ground(X) :- ground(seq(X,Y)).
ground(Y) :- ground(seq(X,Y)).

origin(sentence).

valid(Category, Instance) :- matches(Category, Instance), ground(Instance).

8 {output(S) : valid(sentence, S) } 8.

output_component(O) :- output(O).
output_component(X) :- output_component(seq(X,Y)).
output_component(Y) :- output_component(seq(X,Y)).
 
appears(W) :- word(W), output_component(W).
 
:- not appears(into).
:- output_component(seq(seq(touch, _), seq(into, _))).
:- output_component(seq(a, limbs)).


% first_of(W, W) :- word(W), appears(W).
% first_of(seq(W,Y), W) :- output_component(seq(W,Y)), word(W).
% first_of(seq(X,Y), W) :- first_of(X, W).
% 
% last_of(W, W) :- word(W), appears(W).
% last_of(seq(X,W), W) :- output_component(seq(X,W)), word(W).
% last_of(seq(X,Y), W) :- last_of(Y, W).
% 
% adjacent(W1,W2) :- 
%   output_component(seq(X,Y)), 
%   last_of(X, W1), 
% appears_times_in(W, 1, W) :- appears(W).
% appears_times_in(W, 0, W2) :- appears(W2), appears(W), W!=W2.
% appears_times_in(W, N1+N2, seq(X,Y)) :- 
%   output_component(seq(X,Y)),
%   appears_times_in(W, N1, X), 
%   appears_times_in(W, N2, Y).
% 
% :- appears_times_in(transformation, N, S), N > 1.
