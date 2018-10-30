type ('a, 'b) symbol = N of 'a | T of 'b
 
(* function 1: convert_grammar *)

let rec match_key rules d =
  match rules with
  | [] -> []
  | (k,v)::t -> if k = d then v::(match_key t d)
                else match_key t d

let convert_grammar gram1 =
  ((fst gram1), fun d -> match_key (snd gram1) d) 

(* function 2: parse_prefix *)

let rec derive rule rules_func accept d frag =
  match rule with
  | [] -> accept d frag
  | _ -> match frag with
         | [] -> None
         | h1::t1 -> match rule with
                     | N nonterm::rest -> match_help nonterm (rules_func nonterm) 
					  rules_func (derive rest rules_func 
						      accept) d frag
            	     | T term::rest -> if term = h1 then derive rest rules_func 
						      accept d t1
                           	     else None
		     | [] -> None

and match_help start_sym start_rules rules_func accept d frag =
    match start_rules with
    | [] -> None
    | h::t -> match derive h rules_func accept (d@[start_sym,h]) frag with
	      | None -> match_help start_sym t rules_func accept d frag
              | is_match -> is_match;;

let parse_prefix gram = 
  fun accept frag -> match_help (fst gram) ((snd gram) (fst gram)) (snd gram) 
		     accept ([]) frag
