-module(core).
-export([transform_uast_to_east/2]).

%%-----------------------------------------------------------------------------
%% Converte o uast em erl.
transform_uast_to_east(CerlAST, ErlangModuleName) ->
	ModuleName = get_module_name(ErlangModuleName),
	[_Class, DefinitionList | _] = CerlAST,	
	ClassDefinition = [match_definition(Definition)|| Definition <- DefinitionList],
	Attributes = get_attributes(CerlAST),
	Methods = get_methods(CerlAST),
	lists:flatten(ModuleName ++ ClassDefinition ++ Attributes ++ Methods).

%%------------------------------------------------------------------------------
%% Extrai nome do modulo
get_module_name(ErlangModuleName) ->
	ModuleName = "-module(" ++ atom_to_list(ErlangModuleName) ++ ").\n",
	ModuleName.
%%------------------------------------------------------------------------------
%% Extrai os atributos
get_attributes(CerlAST) ->
	Attributes = 
		case CerlAST of
			[_Class, _DefinitionList1, 
			{'class attributes.', AttributeList, '.'}, _Methods] ->
				transform_attribute_list(AttributeList);		
			_ -> 
				"\n"
		end,
		Attributes.
%%------------------------------------------------------------------------------
%% Extrai os metodos
get_methods(CerlAST) ->
	Methods = 
		case CerlAST of
			[_Class, _DefinitionList2, _AttributeList, 
			{'class methods.', MethodList, '.'}] ->
				transform_method_list(MethodList);		
			_ -> 
				"\n"
		end,
	Methods.

%%------------------------------------------------------------------------------
%% Pattern Match de Export
match_definition({export, ExportList}) ->
	transform_export_list(ExportList).

%%------------------------------------------------------------------------------
%% Transforma lista de export
transform_export_list([{Name, Arity} | Rest]) ->
	"-export([" ++ atom_to_list(Name) ++ 
	"/" ++ 
	integer_to_list(Arity) ++ 
	transform_export_rest(Rest).

transform_export_rest([{Name, Arity} | Rest]) ->
	", " ++ 
	atom_to_list(Name) ++ 
	"/" ++ 
	integer_to_list(Arity) ++ 
	transform_export_rest(Rest);
transform_export_rest([]) ->
	"]).\n".

%%------------------------------------------------------------------------------
%% Transforma lista de atributos
transform_attribute_list([{match, Name, Value}| Rest]) -> 
	"class_attributes()-> \n put({a, " ++ 
	atom_to_list(Name) ++ "}," ++ 
	resolve_param(Value) ++
	")" ++ 
	transform_attribute_rest(Rest).

transform_attribute_rest([{match, Name, Value} | Rest]) ->

	",\n set_attribute({a, " ++ 
	atom_to_list(Name) ++ "}," ++ 
	resolve_param(Value) ++
	")" ++ 
	transform_attribute_rest(Rest); 

transform_attribute_rest([]) ->
	".\n".

%%------------------------------------------------------------------------------
%% Transforma lista de métodos
transform_method_list([]) ->
	"\n";
transform_method_list([{Signature, MethodBody} | Rest]) ->
	{signature, MethodName, ParameterList} = Signature,
	Name = atom_to_list(MethodName),
	Parameter = "(" ++ resolve_parameter(ParameterList),
	Body = resolve_method_body(MethodBody), 	
	Name ++ Parameter ++ Body ++ transform_method_list(Rest).

%%------------------------------------------------------------------------------
%% Transforma lista de parâmetros
resolve_parameter([]) -> 
	") ->\n";
resolve_parameter([Parameter | Rest]) ->
	Param = resolve_param(Parameter),	
	case Rest of
		[]-> Param ++ resolve_parameter(Rest);
		_ -> Param ++ ", " ++ resolve_parameter(Rest)
	end.
resolve_param({text, Value}) -> "\"" ++ Value ++ "\"";
resolve_param(Value) when is_integer(Value) -> integer_to_list(Value);
resolve_param(Value) when is_float(Value) -> float_to_list(Value);
resolve_param(Value) when is_atom(Value) -> 
	case string:to_lower(atom_to_list(Value)) of
		"null" 	-> "nil";
		_	-> atom_to_list(Value)
	end;
resolve_param(Value) when is_list(Value) -> Value;
resolve_param(Value) when is_tuple(Value) -> 
	case Value of
		{tuple, Tuple} -> 
			resolve_tuple(Tuple);
		{list, List} -> 
			resolve_list(List);
		{list, List, EndList} ->
			resolve_list(List) ++ " | " ++ resolve_param(EndList);
		{oo_new, _} -> "ok";
		{call_function, Name, {none}} ->
			atom_to_list(Name) ++ "()";
		{call_function, Name, ParameterList} ->
			atom_to_list(Name) ++ 
			"(" ++ 
			resolve_list_parameter(ParameterList) ++ ")";
		{match, Name, Match} ->
			atom_to_list(Name) ++ "=" ++ match_erlang(Match)
	end.

%%------------------------------------------------------------------------------
%% Transforma tupla
resolve_tuple(Tuple) when is_tuple(Tuple) -> "{}";
resolve_tuple([Element | Rest]) ->
	case Rest of
		[]-> "{" ++ resolve_param(Element) ++ "}";
		_ -> "{" ++ resolve_param(Element) ++ ", " ++ 
			resolve_tuple_rest(Rest)
	end.

resolve_tuple_rest([Element | Rest]) ->
	case Rest of
		[]-> resolve_param(Element) ++ "}";
		_ -> resolve_param(Element) ++ ", " ++ 
			resolve_tuple_rest(Rest)
	end.
	
%%------------------------------------------------------------------------------
%% Transforma lista
resolve_list(List) when is_tuple(List) -> "[]";
resolve_list([Element | Rest]) ->
	case Rest of
		[]-> "[" ++ resolve_param(Element) ++ "]";
		_ -> "[" ++ resolve_param(Element) ++ ", " ++ 
			resolve_list_rest(Rest)
	end.

resolve_list_rest([Element | Rest]) ->
	case Rest of
		[]-> resolve_param(Element) ++ "]";
		_ -> resolve_param(Element) ++ ", " ++ 
			resolve_list_rest(Rest)
	end.

%%------------------------------------------------------------------------------
%% Transforma corpo do método

resolve_method_body([Head | Rest]) ->
	ErlangStatment = match_erlang(Head), 
	case Rest of
		[]	-> ErlangStatment ++ ".\n";
		_ 	-> ErlangStatment ++ ",\n" ++ resolve_method_body(Rest)	
	end.

match_erlang({text, Value}) -> "\"" ++ Value ++ "\"";
match_erlang(Value) when is_integer(Value) -> integer_to_list(Value);
match_erlang(Value) when is_float(Value) -> float_to_list(Value);
match_erlang(Value) when is_atom(Value) -> 
	case string:to_lower(atom_to_list(Value)) of
		"null" 	-> "nil";
		_	-> atom_to_list(Value)
	end;
%match_erlang(Value) when is_list(Value) -> Value;
match_erlang(Value) when is_tuple(Value) -> 
	case Value of
		{tuple, Tuple} -> 
			resolve_tuple(Tuple);
		{list, List} -> 
			resolve_list(List);
		{list, List, EndList} ->
			resolve_list(List) ++ " | " ++ resolve_param(EndList);
		{oo_new, _} -> "ok";		
		{call_function, Name, {none}} ->
			atom_to_list(Name) ++ "()";
		{call_function, Name, ParameterList} ->				
			atom_to_list(Name) ++ 
			"(" ++ 
			resolve_list_parameter(ParameterList) ++ ")";
		{match, Name, Match} ->
			atom_to_list(Name) ++ "=" ++ match_erlang(Match)
	end;
match_erlang([Head | Rest]) ->
	case Rest of
		[]	-> match_erlang(Head);
		_	-> match_erlang(Head) ++
				" " ++ 
				match_erlang(Rest)		
	end;
match_erlang(_) -> "ok".

resolve_list_parameter([Head | Rest]) ->
	case Rest of
		[]	-> match_erlang(Head);
		_	-> match_erlang(Head) ++ "," ++	
				resolve_list_parameter(Rest)
	end.
