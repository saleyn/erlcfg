-module(test_erlcfg_node).
-include_lib("eunit/include/eunit.hrl").
-export([
        parent_found_mfa/2
    ]).


node_empty_set_test() ->
    Node = [],
    Expected = [
        {foo, bar}
    ],
    Result = erlcfg_node:node_set(Node, foo, bar),
    ?assertEqual(Expected, Result).

node_singlecontent_set_test() ->
    Node = [
        {bar, baz}
    ],
    Expected = [
        {bar, baz},
        {foo, bar}
    ],
    Result = erlcfg_node:node_set(Node, foo, bar),
    ?assertEqual(Expected, Result).

node_multiplecontent_set_test() ->
    Node = [
        {bar, baz},
        {moo, foo}
    ],
    Expected = [
        {bar, baz},
        {moo, foo},
        {foo, bar}
    ],
    Result = erlcfg_node:node_set(Node, foo, bar),
    ?assertEqual(Expected, Result).

node_multiplecontent_multipleset_collision_test() ->
    Node = [
        {bar, baz},
        {moo, foo}
    ],

    Expected = [
        {bar, baz},
        {moo, foo},
        {foo, bar}
    ],
    Result = erlcfg_node:node_set(Node, foo, bar),
    ?assertEqual(Expected, Result),

    Expected1 = [
        {bar, foo},
        {moo, foo},
        {foo, bar}
    ],

    Result1 = erlcfg_node:node_set(Result, bar, foo),
    ?assertEqual(Expected1, Result1).

node_get_when_empty_test() ->
    Node = [],
    Expected = {error, undefined},
    Result = erlcfg_node:node_get(Node, foo),
    ?assertEqual(Expected, Result).

node_get_when_not_empty_and_key_not_set_test() ->
    Node = [
        {foo, bar}
    ],
    Expected = {error, undefined},
    Result = erlcfg_node:node_get(Node, moo),
    ?assertEqual(Expected, Result).

node_get_single_entry_and_key_is_set_test() ->
    Node = [
        {foo, bar}
    ],
    Expected = {value, bar},
    Result = erlcfg_node:node_get(Node, foo),
    ?assertEqual(Expected, Result).

node_get_multiple_entry_and_key_is_set_test() ->
    Node = [
        {foo, bar}
    ],
    Expected = {value, bar},
    Result = erlcfg_node:node_get(Node, foo),
    ?assertEqual(Expected, Result).

node_get_multiple_entry_and_multiple_get_test() ->
    Node = [
        {foo, bar},
        {foo1, bar1},
        {foo2, bar2}
    ],

    Expected = {value, bar},
    Result = erlcfg_node:node_get(Node, foo),
    ?assertEqual(Expected, Result),

    Expected1 = {value, bar1},
    Result1 = erlcfg_node:node_get(Node, foo1),
    ?assertEqual(Expected1, Result1),

    Expected2 = {value, bar2},
    Result2 = erlcfg_node:node_get(Node, foo2),
    ?assertEqual(Expected2, Result2),

    Expected3 = {error, undefined},
    Result3 = erlcfg_node:node_get(Node, foo3),
    ?assertEqual(Expected3, Result3).

parent_found_mfa(Parent, ChildName)  -> 
    {Parent, ChildName}.


if_parent_found_ok_test() ->
    Data = [
        {one, 
            [
                {two, 
                    [
                        {three, 123},
                        {four, 124}
                    ]
                },
                {three,
                    [
                        {three, 133},
                        {four, 134}
                    ]
                }
            ]
        },
        {two, void}
    ],

    Fun = fun(Parent, ChildName)  ->
            {Parent, ChildName}
    end,

    Expected = {
        [ 
            {two, 
                [
                    {three, 123}, 
                    {four, 124} 
                ]
            },
            {three,
                [
                    {three, 133},
                    {four, 134}
                ]
            }
        ],

        two
    },

    Result = erlcfg_node:if_parent_found(Data, one.two, Fun),
    ?assertEqual(Expected, Result),

    Expected1 = { 
        [ 
            {three, 123}, 
            {four, 124} 
        ], 
        three 
    },

    Result1 = erlcfg_node:if_parent_found(Data, one.two.three, ?MODULE, parent_found_mfa, []),
    ?assertEqual(Expected1, Result1).


if_parent_found_not_found_test() ->
    Data = [
        {one, 
            [
                {two, 
                    [
                        {three, 123},
                        {four, 124}
                    ]
                },
                {three,
                    [
                        {three, 133},
                        {four, 134}
                    ]
                }
            ]
        },
        {two, void}
    ],
    Fun = fun(Parent, ChildName)  ->
            {Parent, ChildName}
    end,

    Expected = {not_found, one.two.five},
    Result = erlcfg_node:if_parent_found(Data, one.two.five.six, Fun),
    ?assertEqual(Expected, Result),

    Expected1 = {not_found, one.three.three.four},
    Result1 = erlcfg_node:if_parent_found(Data, one.three.three.four.five.six.seven, Fun),
    ?assertEqual(Expected1, Result1),

    Expected2 = {not_found, three},
    Result2 = erlcfg_node:if_parent_found(Data, three.four.five, Fun),
    ?assertEqual(Expected2, Result2).


get_test() ->
    Data = [
        {one, 
            [
                {two, 
                    [
                        {three, 123},
                        {four, 124}
                    ]
                },
                {three,
                    [
                        {three, 133},
                        {four, 134}
                    ]
                }
            ]
        },
        {two, void}
    ],

    Expected = {value, 123},
    Result = erlcfg_node:get(Data, one.two.three),
    ?assertEqual(Expected, Result),

    Expected1 = {value, void},
    Result1 = erlcfg_node:get(Data, two),
    ?assertEqual(Expected1, Result1),

    Expected2 = {not_found, two.three},
    Result2 = erlcfg_node:get(Data, two.three.four.five),
    ?assertEqual(Expected2, Result2).

set_test() ->
    Data = [],
    Expected = [
        {one, []}, 
        {two, void}
    ],

    D1 = erlcfg_node:set(Data, one, []),
    Data1 = erlcfg_node:set(D1, two, void),
    ?assertEqual(Expected, Data1),

    Expected2 = [
        {
            one, 
            [ 
                {
                    two, 
                    [ 
                        {three, 123}, 
                        {four, 124}
                    ]
                }
            ]
        }, 
        {two, void}
    ],

    D2 = erlcfg_node:set(Data1, one.two, []),
    D3 = erlcfg_node:set(D2, one.two.three, 123),
    Data2 = erlcfg_node:set(D3, one.two.four, 124),
    ?assertEqual(Expected2, Data2).