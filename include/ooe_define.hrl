-define(VSN, 0.1).
-define(TEAM, [
    'object.oriented.erlang@gmail.com',
    'Emiliano Firmino <emiliano.firmino@gmail.com>',
    'Daniel Henrique <dhbaquino@gmail.com>',
    'Rodrigo Bernardino <rbbernadino@gmail.com>',
    'Jucimar Jr <jucimar.jr@gmail.com>',
    'Rafael Lins <rdl@cin.ufpe.br>']).
-define(YEAR, 2012-2014).
-define(CONSTR_NAME, new_).

-record(class, {
    name    = "",    % ClassName or InterfaceName
    parent  = null,  % ParentName
    attrs   = [],    % AttrList
    methods = [],    % MethodList
    constr  = [],    % ConstrList
    export  = [],    % ExportList
    static  = [],    % StaticList
    impl    = null,  % Implements
    is_interface = false}).
