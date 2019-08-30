type ('a, 'b) symbol = N of 'a | T of 'b

(* function 1: subset *)

let rec subset a b =
  match a,b with
  | [],[]
  | [],_ -> true
  | _,[] -> false
  | c::cc,d::dd ->
    if List.mem c b = true then subset cc b
    else false;;

(* function 2: equal sets *)

let rec equal_sets a b =
  if subset a b = false then false
  else match a,b with
    | [],_ -> true
    | _, [] -> false
    | c::cc,d::dd ->
      if List.mem d a = true then subset dd a
      else false;;

(* function 3: set_union *)

let set_union a b =
  List.sort_uniq compare (List.append a b);;

(* function 4: set_intersection *)

let set_intersection a b =
  List.sort_uniq compare (List.find_all (fun x -> List.mem x a) b);;

(* function 5: set_diff *)

let set_diff a b =
  List.sort_uniq compare (List.find_all (fun x -> List.mem x b = false) a);;

(* function 6: computed_fixed_point *)

let rec computed_fixed_point eq f x =
  match (eq x (f(x))) with
  | true -> x
  | false -> computed_fixed_point eq f (f(x));;

(* function 7: filter reachable g *)

let is_match sym h =
  match h with
  | N b -> if b = sym then true else false
  | T _ -> false

let rec list_contains sym lst =
  match lst with
  | [] -> false
  | h::t -> if (is_match sym h) then true
            else list_contains sym t

let is_valid sym rule =
  match rule with
  | s,lst -> if (list_contains sym lst) then true
             else false

let rec check_sym sym prod =
  match prod with
  | [] -> false
  | rule::t -> if (is_valid sym rule) then true
     	       else check_sym sym t

let rec add_rules start rules_1 rules_2 prod =
  match rules_1 with
  | [] -> prod
  | nonterm::lst -> if ((fst nonterm) = start) || (check_sym (fst nonterm) prod)
     	 	      then add_rules start (List.remove_assoc (fst nonterm) rules_2)
			   	     (List.remove_assoc (fst nonterm) rules_2) (nonterm::prod)
		    else add_rules start lst rules_2 prod

let rem_unprod_rules g =
  List.filter (fun x -> List.mem x (add_rules (fst g) (snd g) (snd g) ([]))) (snd g)

let filter_reachable g =
  ((fst g), rem_unprod_rules g)
