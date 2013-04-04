%% @doc HTTP request decompresion as an elli middleware
%%
%% Even if it is not standard, if you have control over the client or you
%% can get benefit of compresing the request to your backend.
%%
%% This elli middleware will decompres any body, and update the content-size of
%% any POST,PUT,PATCH request tha comes with the header "Content-Encoding:
%% gzip"
%%

-module(elli_gzip_request).
-behaviour(elli_middleware).
-export([handle/2,preprocess/2,postprocess/3,handle_event/3]).
-include("../deps/elli/include/elli.hrl").


postprocess(_Req, Reply, _Args) -> Reply.
handle(_Req, _Args) -> ignore.
handle_event(_Event, _Data, _ElliArgs) -> ok.

preprocess(Req, _Args) ->
    case elli_request:get_header(<<"Content-Encoding">>, Req) of
        <<"gzip">> ->
            uncompress_request(Req);
        _ ->
            Req
    end.

uncompress_request(Req) ->
    Body = Req#req.body,
    Headers = Req#req.headers,
    CleanHeaders = proplists:delete(<<"Content-Encoding">>,
                                   proplists:delete(<<"Content-Length">>, Headers)),

    NewBody = zlib:gunzip(Body),
    NewSize = list_to_binary(integer_to_list(byte_size(NewBody))),

    NewHeaders = [{<<"Content-Length">>, NewSize}|CleanHeaders],

    NewReq = Req#req{body = NewBody, headers = NewHeaders},

    NewReq.


%-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

preprocess_test() ->
    Req = #req{body = <<"asdf">>, headers = []},
    ?assertEqual(Req, preprocess(Req,{})).

uncompress_request_test() ->
    Body = <<31,139,8,0,0,0,0,0,0,3,243,72,205,201,201,7,0,130,137,
             209,247,5,0,0,0>>,
    Size = list_to_binary(integer_to_list(bit_size(Body))),
    Headers = [{<<"Content-Encoding">>, <<"gzip">>},{<<"Content-Length">>, Size}],
    Req = #req{body = Body, headers = Headers},
    NewReq = uncompress_request(Req),

    ?assertEqual(<<"Hello">>,NewReq#req.body),
    ?assertEqual(<<"5">>, proplists:get_value(<<"Content-Length">>, NewReq#req.headers)).





    %-endif.
