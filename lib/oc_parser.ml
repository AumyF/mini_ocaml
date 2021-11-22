open Parser
open Ast

let get_identifier = get_identifier

(* let get_string_literal =
   let match_dquote = match_char '"' in
   let match_ascii = satisfy (function ' ' .. '~' -> true | _ -> false) in
   get_token (let+ _ = match_dquote and+ content = match_ascii and+_ = match_dquote in content ) *)

let get_int_literal = map (fun x -> Expression.IntLiteral x) get_int

let get_plus = get_symbol "+"

let get_minus = get_symbol "-"

let get_asterisk = get_symbol "*"

let get_slash = get_symbol "/"

let get_equal = get_symbol "="

let get_less = get_symbol "<"

let get_greater = get_symbol ">"

let get_coloncolon = get_symbol "::"

let get_paren_left = get_symbol "("

let get_paren_right = get_symbol ")"

let get_bracket_left = get_symbol "["

let get_bracket_right = get_symbol "]"

let get_arrow = get_symbol "->"

let get_vbar = get_symbol "|"

let get_semicolon = get_symbol ";"

(* Keywords *)

let get_true = get_symbol "true" *> pure (Expression.BoolLiteral true)

let get_false = get_symbol "false" *> pure (Expression.BoolLiteral false)

let get_bool_literal = get_true <|> get_false

let get_fun = get_symbol "fun"

let get_let = get_symbol "let"

let get_rec = get_symbol "rec"

let get_in = get_symbol "in"

let get_if = get_symbol "if"

let get_then = get_symbol "then"

let get_else = get_symbol "else"

let get_literal = get_int_literal <|> get_bool_literal

let get_varref = map (fun varname -> Expression.VarRef varname) get_identifier

(* unit -> (exp Parser.t) * (exp Parser.t) ref *)
let create_parser_forwarded_to_ref _ =
  let dummy_parser =
    let inner _ = failwith "unfixed forwarded parser" in
    inner
  in
  let parser_ref = ref dummy_parser in
  let inner input = parse !parser_ref input in
  let wrapper_parser = inner in

  (wrapper_parser, parser_ref)

let (get_exp : Expression.t Parser.t), get_exp_ref =
  create_parser_forwarded_to_ref ()

(* let get_add =
   let+ left = get_exp and+ _ = get_plus and+ right = get_exp in
   Plus (left, right) *)

let add_sub =
  let op_add =
    let+ _ = get_plus in
    fun lhs rhs -> Expression.Plus (lhs, rhs)
  in
  let op_sub =
    let+ _ = get_minus in
    fun lhs rhs -> Expression.Subtract (lhs, rhs)
  in
  op_add <|> op_sub

let get_multiply =
  let+ _ = get_asterisk in
  fun lhs rhs -> Expression.Times (lhs, rhs)

let get_div =
  let+ _ = get_slash in
  fun lhs rhs -> Expression.Div (lhs, rhs)

let tap p =
  map
    (fun x ->
      print_endline x;
      x)
    p

let p_add = get_plus *> pure (fun l r -> Expression.Plus (l, r))

let p_subtract = get_minus *> pure (fun l r -> Expression.Subtract (l, r))

let rec get_add i = chainl1 term (p_add <|> p_subtract) i

(* and get_mul i = chainl1 value (get_multiply <|> get_div) i *)

(* and value i = (get_let_in <|> get_varref <|> get_int_literal <|> get_add) i *)
and term i = get_int_literal i

and value i = get_add i

(* and get_if_then_else i =
     (let+ _ = get_if
      and+ predicate = value
      and+ _ = get_then
      and+ then_expr = value
      and+ _ = get_else
      and+ else_expr = value in
      If (predicate, then_expr, else_expr))
       i

   and get_let_in i =
     (let+ _ = get_let
      and+ varname = get_identifier
      and+ _ = get_equal
      and+ varexpr = value
      and+ _ = get_in
      and+ rest = value in
      Let (varname, varexpr, rest))
       i *)