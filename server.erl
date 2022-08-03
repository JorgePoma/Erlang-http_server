
-module(server).
-export([start/0, clienteJson/3, list_rand/2]).

start() ->
	inets:start(httpd, [
		{modules, [
			mod_alias,
			mod_auth,
			mod_esi,
			mod_actions,
			mod_cgi,
			mod_dir,
			mod_get,
			mod_head,
			mod_log,
			mod_disk_log
		]},
		{port,8090},
		{server_name,"shell"},
		{server_root, "F://serverPrueba"},
        {document_root, "F://serverPrueba/htdocs"},
        {erl_script_alias, {"/api", [server]}},
        {error_log, "error.log"},
        {security_log, "security.log"},
        {transfer_log, "transfer.log"},
        {mime_types, [
        	{"html", "text/html"},
        	{"css", "text/css"},
        	{"js", "application/x-javascript"},
            {"json", "application/json"}
        ]}
	]).

clienteJson(SessionID, _Env, _Input) -> 
    io:format("Data: ~p~n", [_Input]),
    [_Out1|H] = string:split(_Input, "="),
    [Num|N] = string:split(H, "/"),
    Numero = list_to_integer(Num),
    io:format("Numero: ~w~n", [Numero]),
    Lado = list_rand([],Numero),
    io:format("lado: ~w~n",[Lado]),
    [_L|Tipo] = string:split(N, "="),
    io:format("Tipo: ~p~n", Tipo),
    Superficie = calc_superficie(Tipo,Lado),
    Salida_F = io_lib:format("{~n\"figura\":\"~ts\",~n\"superficie\":~w~n}",[Tipo,Superficie]),
    mod_esi:deliver(SessionID,
    ["Content-Type: application/json\r\n\r\n", Salida_F]).

%list_rand([], 10, 0).


list_rand(Arr, N) ->
    X = rand:uniform(100),
    if 
        length(Arr) == N ->
            io:format("arreglo random: ~w~n",[Arr]),
            Out = [Y || Y <- Arr, Y rem 2 =:= 0],
            io:format("arreglo pares: ~w~n",[Out]),
            Salida = sumar(Out, 0),
            io:format("Suma total: ~w~n",[Salida]),
            Salida;
        true ->
            list_rand(Arr++[X], N)
        end.

sumar([], L) -> L;

sumar(Arr, L)->
    [H|F] = Arr,
    sumar(F, L+H).

calc_superficie(Respuesta,0) ->
    Respuesta;

calc_superficie(Tipo, Numero)->
    %io:format("entrando~p~n", Tipo),
    C1 = string:equal(Tipo, "cuadrado"),
    C2 = string:equal(Tipo, "circulo"),
    if C1 ->
        %io:format("cuadrado: ~p~n", [Numero]),
        %io:format("cuadrado~w~n",[1]);
        Superficie = Numero*Numero,
        io:format("S_Cuadrado: ~w~n",[Superficie]),
        calc_superficie(Superficie,0);
    C2->
        %io:format("circulo: ~p~n", [Numero]),
        %io:format("circulo~w~n",[1]);
        Pi = math:pi(),
        Superficie = Pi*Numero*Numero,
        io:format("S_Circulo: ~w~n",[Superficie]),
        calc_superficie(Superficie,0);
    true ->
        io:format("nada~w~n",[1])
    end.