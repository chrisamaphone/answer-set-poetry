%% Relating sequences of words to parse trees %%

split(nil, nil, nil).
split(seq(W, Rest), seq(W, Seq1), Seq2)
  :- word(W), sequence(Rest), split(Rest, Seq1, Seq2).
split(S, nil, S)
  :- sequence(S).

%% Some rules to only consider problems that are subproblems of our input.

sequence(S) :- sequence(seq(W, S)), word(W).
relevant_word(W) :- sequence(seq(W,S)).
% input example:
sequence(seq(they, seq(transform, seq(the, seq(cloud, nil))))).

%% SYNTAX TREES
% Trees are either:
% - expr(nil_pos, leaf)
% - expr(POS, Word)
% - expr(POS, pair(Tree1, Tree2))

%% parse(seq, tree)

% needed?
% parse(nil, expr(nil_pos, leaf)).

parse(seq(Word,nil), expr(POS, Word))
  :- relevant_word(Word), pos(Word, POS).

% Parsing determined and undetermined subjects
parse(Seq, expr(dsubj, Expr))
  :- parse(Seq, expr(pronoun_subj, Expr)).

parse(Seq, expr(dsubj, pair(expr(det, Det), expr(usubj,Usubj))))
  :- split(Seq, DetSeq, UsubjSeq),
     parse(DetSeq, expr(det, Det)),
     parse(UsubjSeq, expr(usubj, Usubj)).

parse(Seq, expr(usubj, Noun))
  :- parse(Seq, expr(noun, Noun)).

% Parsing determined and undetermined objects
parse(Seq, expr(uobj, Noun))
  :- parse(Seq, expr(noun, Noun)).

parse(Seq, expr(dobj, Pronoun))
  :- parse(Seq, expr(pronoun_obj, Pronoun)).

parse(Seq, expr(dobj, pair(expr(det,Det), expr(uobj,Uobj))))
  :- split(Seq, DetSeq, UobjSeq),
     parse(DetSeq, expr(det, Det)),
     parse(UobjSeq, expr(uobj, Uobj)).

% Parsing verb phrases
parse(Seq, expr(vp, Verb))
  :- parse(Seq, expr(vi, Verb)).

parse(Seq, expr(vp, pair(expr(vt,VT), expr(dobj,Dobj))))
  :- split(Seq, VTSeq, DobjSeq),
     parse(VTSeq, expr(vt, VT)),
     parse(DobjSeq, expr(dobj, Dobj)).


% Parsing sentences
parse(Seq, expr(sentence, pair(expr(dsubj,NP),expr(vp,VP))))
  :- split(Seq, NPSeq, VPSeq),
     parse(NPSeq, expr(dsubj, NP)),
     parse(VPSeq, expr(vp, VP)).


% #show sequence/1.
#show parse/2.
#show relevant_word/1.
% #show split/3.

%%%% Word Library %%%%

% Pronouns

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
pos(cloud, noun).
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

word(every).
pos(every, det).

word(into).
pos(into, prep).

