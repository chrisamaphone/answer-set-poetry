#show output/1.

% word(she).
% pos(she, pronoun_subj).
% 
% word(her).
% pos(her, pronoun_obj).
% pos(her, det).
% 
% word(he).
% word(him).
% word(his).
% 
% pos(he, pronoun_subj).
% pos(him, pronoun_obj).
% pos(his, det).

word(they).
word(them).
word(their).

pos(they, pronoun_subj).
% pos(them, pronoun_obj).
pos(their, det).

% first take on meter - just nsyllables
meter(they, 1).
meter(them, 1).
meter(their, 1).


% Nouns

word(transformation).
pos(transformation, noun).

word(self).
pos(self, noun).
plural(self, selves).
meter(self, 1). meter(selves, 1).

word(limb).
pos(limb, noun).
plural(limb, limbs).
meter(limb, 1). meter(limbs, 1).

word(eye).
pos(eye,noun).
plural(eye, eyes).
meter(eye, 1). meter(eyes, 1).

word(grace).
pos(grace, subj).
pos(grace, obj).
meter(grace, 1).

% Verbs

word(transform).
pos(transform, vt).
meter(transform, 2).

word(see).
pos(see, vt).
meter(see, 1).

word(touch).
pos(touch, vt).
meter(touch, 1).

word(luminesce).
pos(luminesce, vi).
meter(luminesce, 3).

word(flail).
pos(flail, vi).
meter(flail, 1).

word(unfurl).
pos(unfurl, vi).
meter(unfurl, 2).

word(fall).
pos(fall, vi).
meter(fall, 1).


% Determiners and prepositions

word(the).
pos(the, det).
meter(the, 1).

word(a).
pos(a, det).
meter(a, 1).

word(into).
pos(into, prep).
meter(into, 2).

word(for).
pos(for, prep).
meter(for, 1).

word(from).
pos(from, prep).
meter(from, 1).

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

2 { appears(W) : pos(W, prep) } 8.
 
:- output_component(seq(seq(touch, _), seq(into, _))).
:- output_component(seq(a, X)), plural(_,X).

first_of(W, W) :- word(W), appears(W).
first_of(seq(W,Y), W) :- output_component(seq(W,Y)), word(W).
first_of(seq(X,Y), W) :- first_of(X, W), output_component(seq(X,Y)).

first_word(W) :- output(O), first_of(O, W).

#show first_word/1.

% force more than one first word
more_than_one_first_word :- first_word(W1), first_word(W2), not W1=W2.
:- not more_than_one_first_word.


% defining meter for lines
% meter(seq(X,Y), N+M)
%  :- output_component(seq(X,Y)), meter(X,N), meter(Y,M).

% force all lines to have the same meter
% different_meter :- output(O1), output(O2), meter(O1,M1), meter(O2,M2), M1>M2. 

% :- different_meter.
