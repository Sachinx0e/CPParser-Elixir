defmodule JavaGenerator do
  @moduledoc false


  #function
  def generate_func(func,static? \\ false) do

    #add param for static version
    func = case static? do
                true -> params = [Param.new("long","CPointer",false,false,false) | Func.params(func)]
                        Func.setParams(func,params)
                false -> func
           end

    #template selection
    template = case static? do
                    true -> "public static %returnType% %functionName%(%params_list%);"
                    false -> "public %returnType% %functionName%(%params_list%);"
               end

    #generate parameters string
    param_str = Enum.reduce(Func.params(func),"",fn(x,acc) -> acc <> "," <> generate_param(x) end )
                |> String.replace(",","",global: :false)

    #fill the template
    template
     |> String.replace("%returnType%",Func.returnType(func) |> generate_returntype)
     |> String.replace("%functionName%",Func.name(func))
     |> String.replace("%params_list%",param_str)

  end

  #Params
  def generate_param(param) do
     template = "%typeName% %varName%"

     typeName = Param.typeName(param)

     typeName = cond do
                  #String
                  typeName === "string" -> "String"

                  #No match
                  true -> typeName
                end

     template
        |> String.replace("%typeName%",typeName)
        |> String.replace("%varName%",Param.varName(param))

  end

  #return type
  def generate_returntype(return_type) do

      cond do
         ReturnType.name(return_type) === "string" -> "String"
         true -> ReturnType.name(return_type)
      end

  end
  
end