-module(area).
-export([new/1, area/1]).
class_attributes()-> 
 put({a, R},nil),
 put({a, J},2.34000000000000013545e-01),
 put({a, S},"teste"),
 put({a, K},4),
 put({a, Z},nil).
class_init() ->
class_attributes().
new([]) ->
class_init() , spawn fun thread().
thread() ->
receive {From, {area, [Dados]}} -> From ! area(Dados) , B="oi" , thread() ; {From, {print, []}} -> From ! print() , thread() ; {From, Other} -> From ! {self(), {error, Other}} , thread() end.
area(Dados) ->
ok.
print() ->
ok.

