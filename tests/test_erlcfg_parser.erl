-module(test_erlcfg_parser).
-include_lib("eunit/include/eunit.hrl").

parse_bool_assignment_test() ->
    Tokens = [{atom, 1, foo}, {'=', 1}, {bool, 1, true}, {';', 1}],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, [{set, foo, {val, true, noop}}, []]},
    ?assertEqual(Expected, Result).

parse_integer_assignment_test() ->
    Tokens = [{atom, 1, foo}, {'=', 1}, {integer, 1, 51}, {';', 1}],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, [{set, foo, {val, 51, noop}}, []]},
    ?assertEqual(Expected, Result).

parse_float_assignment_test() ->
    Tokens = [{atom, 1, foo}, {'=', 1}, {float, 1, -51.0e-10}, {';', 1}],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, [{set, foo, {val, -51.0e-10, noop}}, []]},
    ?assertEqual(Expected, Result).

parse_atom_assignment_test() ->
    Tokens = [{atom, 1, foo}, {'=', 1}, {atom, 1, foo51}, {';', 1}],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, [{set, foo, {val, foo51, noop}}, []]},
    ?assertEqual(Expected, Result).

parse_quoted_atom_assignment_test() ->
    Tokens = [{atom, 1, foo}, {'=', 1}, {quoted_atom, 1, '.foo@51'}, {';', 1}],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, [{set, foo, {val, '.foo@51', noop}}, []]},
    ?assertEqual(Expected, Result).

parse_string_assignment_test() ->
    Tokens = [{atom, 1, foo}, {'=', 1}, {string, 1, "A String"}, {';', 1}],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, [{set, foo, {val, "A String", noop}}, []]},
    ?assertEqual(Expected, Result).

parse_variable_assignment_test() ->
    Tokens = [{atom, 1, foo}, {'=', 1}, {variable, 1, foo.bar}, {';', 1}],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, [{set, foo, {val, {get, foo.bar, noop}, noop}}, []]},
    ?assertEqual(Expected, Result).

parse_mixed_assignment_test() ->
    Tokens = [
        {atom, 1, foo}, {'=', 1}, {bool, 1, false}, {';', 1},
        {atom, 1, foo}, {'=', 1}, {integer, 1, 51}, {';', 1},
        {atom, 1, foo}, {'=', 1}, {float, 1, -51.0e-10}, {';', 1},
        {atom, 1, foo}, {'=', 1}, {atom, 1, foo51}, {';', 1},
        {atom, 1, foo}, {'=', 1}, {string, 1, "A String"}, {';', 1},
        {atom, 1, foo}, {'=', 1}, {variable, 1, foo.bar}, {';', 1}
    ],
    Result = erlcfg_parser:parse(Tokens),
    Expected = {ok, 
        [{set, foo, {val, false, noop}},
            [{set, foo, {val, 51, noop}},
                [{set, foo, {val, -51.0e-10, noop}}, 
                    [{set, foo, {val, foo51, noop}}, 
                        [{set, foo, {val, "A String", noop}}, 
                            [{set, foo, {val, {get, foo.bar, noop}, noop}}, []]
                        ]
                    ]
                ]
            ]
        ]
    },
    ?assertEqual(Expected, Result).