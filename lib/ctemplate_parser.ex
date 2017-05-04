defmodule CtemplateParser do
  @moduledoc false

  def build_ast(ast,source) do
    #first pass extract typenames
    get_typenames = fn(statement,ast)->
                            case get_construct(statement,true) do
                              :typenames -> Ast.setTypeNamesParent(ast,parse_typenames(statement))
                              :pass -> ast
                              _ -> ast
                            end
                   end

    ast = Enum.reduce(String.split(source,"\n"),ast,&(get_typenames.(&1,&2)))

    #replace typenames in source
    typemap = Enum.zip(Ast.getTypeNamesParent(ast),Ast.getTypeNamesChild(ast))
    source = Enum.reduce(typemap,source,fn(x,acc) -> String.replace(acc,elem(x,0),elem(x,1)) end)

    #build the ast
    update_ast = fn(statement,ast) ->
                  case get_construct(statement,false) do
                     :typenames -> ast
                     :function -> Ast.addFunction(ast,parse_function(statement))
                     :pass -> ast
                  end
                end

    Enum.reduce(String.split(source,"\n"),ast,&(update_ast.(&1,&2)))

  end

  def get_construct(statement, only_typenames? \\ false) do
     cond do
       String.contains?(statement,"template <typename ") -> :typenames

       String.contains?(statement,"/*F*/") ->  case only_typenames? do
                                                true-> :pass
                                                false-> :function
                                               end
       true -> :pass
     end
  end

  def parse_typenames(statement) do
    statement
     |> String.replace("template","")
     |> String.replace("typename","")
     |> String.replace("<","")
     |> String.replace(">","")
     |> String.replace(" ","")
     |> String.split(",")
  end

  def parse_function(statement) do
    statement
     |> String.replace("/*F*/ ","")
     |> String.replace("virtual","")
     |> String.strip()
     |> Cparser.parse_function()
  end
  
end