open Containers
open Mini_ocaml

let check =
  let open Ast in
  let open Ast.Expression in
  Let ("x", Plus (IntLiteral 4, IntLiteral 3), Plus (VarRef "x", IntLiteral 3))
  |> eval3_with_emptyenv |> string_of_value |> print_endline

let c =
  let exp, _ =
    Oc_parser.(Parser.parse_string value "let x = 4 + 3 in x * 2 + 3")
    |> Option.get_exn_or "parse error"
  in
  Ast.(exp |> eval3_with_emptyenv |> string_of_value |> print_endline)

let () = c
