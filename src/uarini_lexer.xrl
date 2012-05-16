%% Uarini Lexer

Definitions.

Class 			= -class
Constructor 		= -constructor
DefAtributtes 		= -def_atributtes
Export 			= -export

Digit			= [0-9]
Identifier		= [a-zA-Z_][a-zA-Z0-9_]*
StringLiteral		= "(\\\^.|\\.|[^\"])*"

OpenParentheses		= \(
CloseParentheses	= \)
OpenBrackets		= \[
CloseBrackets		= \]
OpenKeys		= \{
CloseKeys		= \}
Dot			= \.
Comma			= ,
Barra			= \/

Digit			= [0-9]
Identifier		= [a-zA-Z_][a-zA-Z0-9_]*
WhiteSpace		= [\r|\s|\n|\t|\f]

Rules.

{Class}		: {token, {class, TokenLine, list_to_atom(TokenChars)}}.
{Constructor}	: {token, {constructor, TokenLine, list_to_atom(TokenChars)}}.
{DefAtributtes}	: {token, {def_atributtes, TokenLine, list_to_atom(TokenChars)}}.
{Export}	: {token, {export, TokenLine, list_to_atom(TokenChars)}}.

{OpenParentheses}	: {token, {list_to_atom(TokenChars), TokenLine}}.
{CloseParentheses}	: {token, {list_to_atom(TokenChars), TokenLine}}.
{OpenBrackets}		: {token, {list_to_atom(TokenChars), TokenLine}}.
{CloseBrackets}		: {token, {list_to_atom(TokenChars), TokenLine}}.
{OpenKeys}		: {token, {list_to_atom(TokenChars), TokenLine}}.
{CloseKeys}		: {token, {list_to_atom(TokenChars), TokenLine}}.
{Dot}			: {token, {list_to_atom(TokenChars), TokenLine}}.
{Comma}			: {token, {list_to_atom(TokenChars), TokenLine}}.
{Barra}			: {token, {list_to_atom(TokenChars), TokenLine}}.

{Digit}+		: {token, {integer, TokenLine, list_to_integer(TokenChars)}}.
{Digit}+\.{Digit}+	: {token, {float, TokenLine, list_to_float(TokenChars)}}.
{Identifier}		: {token, {identifier, TokenLine, list_to_atom(TokenChars)}}.
{StringLiteral}		: build_text(text, TokenChars, TokenLine, TokenLen).

{WhiteSpace}+		: skip_token.

Erlang code.

build_text(Type, Chars, Line, Length) ->
	Text = detect_special_char(lists:sublist(Chars, 2, Length - 2)),
	{token, {Type, Line, Text}}.

detect_special_char(Text) ->
	detect_special_char(Text, []).
detect_special_char([], Output) ->
	lists:reverse(Output);
detect_special_char([$\\, SpecialChar | Rest], Output) ->
	Char = case SpecialChar of
		$\\	-> $\\;
		$/	-> $/;
		$\" 	-> $\";
		$\' 	-> $\';
		$b	-> $\b;
		$d	-> $\d;
		$e	-> $\e;
		$f	-> $\f;
		$n	-> $\n;
		$r	-> $\r;
		$s	-> $\s;
		$t	-> $\t;
		$v	-> $\v;
		_	->
			throw({error,
				{"unrecognized special character: ", [$\\, SpecialChar]}})
	end,
	detect_special_char(Rest, [Char|Output]);
detect_special_char([Char|Rest], Output) ->
	detect_special_char(Rest, [Char|Output]).
