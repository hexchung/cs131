/* tower/3 */

tower(N,T,C) :-

  % create/check T
  length(T,N), 
  maplist(len(N),T),
  maplist(fd_dom(1,N),T),
  maplist(fd_all_different,T),

  % extract column lists from T
  length(TC,N),
  getcols(T,1,TC),
  maplist(fd_all_different,TC),
  
  maplist(fd_labeling,T),

  % create/check C
  C = counts(Top, Bottom, Left, Right),
  length(Top,N),
  length(Bottom,N),
  length(Left,N),
  length(Right,N),
  
  % check/add count values
  countcheck(T,Left,Right),
  countcheck(TC,Top,Bottom).

len(N,List) :- length(List,N).
fd_dom(Lower,Upper,List) :- fd_domain(List,Lower,Upper).

getcols(_,_,[]).
getcols(T,M,[TCH|TCT]) :-
  setcols(T,M,[],TCH),
  M1 is M+1,
  getcols(T,M1,TCT).

setcols([],_,S,S).
setcols([H1|T2],M,Cols,TCH) :-
  nth(M,H1,X),
  append(Cols,[X],TCH1),
  setcols(T2,M,TCH1,TCH).

counthelp([],Count,_,Count).
counthelp([H|T],Head,Max,Count) :-
  H > Max,
  NewCount is Count+1,
  counthelp(T,Head,H,NewCount).

counthelp([H|T],Head,Max,Count) :-
  H < Max,
  counthelp(T,Head,Max,Count).

countcheck([],[],[]).
countcheck([TH|TT],[LH|LT],[RH|RT]) :-
  counthelp(TH,LH,0,0),
  reverse(TH,RTH),
  counthelp(RTH,RH,0,0),   % pass in reversed first row of T to find right-side count
  countcheck(TT,LT,RT).   % recurse through rest of T, Left, and Right.
























/* plain_tower/3 */

plain_tower(N,T,C) :-

  % create/check T
  length(T,N),
  maplist(len(N),T),
  
  % manually make sure T only contains permutations of elements 1-N
  range(1,N,Dom),
  maplist(permutation(Dom),T), 

  % extract column lists from T
  length(TC,N),
  getcols(T,1,TC),

  % manually make sure each list in TC contains all different values
  all_different(TC),

  % create/check C
  C = counts(Top, Bottom, Left, Right),
  length(Top,N),
  length(Bottom,N),
  length(Left,N),
  length(Right,N),

  % create/check count values
  countcheck(T,Left,Right),
  countcheck(TC,Top,Bottom).

range(N,N,[N]) :- !.
range(N,M,[N|T]) :-
  N1 is N+1,
  range(N1,M,T).

all_different(_,[]).

all_different(H1,T) :-
  member(H1,T),!.

all_different(_,[H2|T]) :-
  all_different(H2,T).

all_different([]).
all_different([[H1|T1]|Tail]) :-
  all_different(H1,T1),
  all_different(Tail).

speedup(S) :-
  statistics(cpu_time,_),
  tower(4,T,C),
  statistics(cpu_time,[_,Diff1]),
  Tower is (Diff1+1),  

  statistics(runtime,_),
  plain_tower(4,T1,C1),
  statistics(cpu_time,[_,Diff2]),
  Plain is Diff2,

  write('tower/3 speed: '),
  write(Tower),
  write(' ms'),
  nl,
  write('plaintower/3 speed: '),
  write(Plain),
  write(' ms'),
  nl,

  S is Plain/Tower.

/* ambiguous/4 */

ambiguous(N,C,T1,T2) :-
  tower(N,T1,C),
  tower(N,T2,C),
  T1 \= T2.
