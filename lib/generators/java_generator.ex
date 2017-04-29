defmodule JavaGenerator do
  @moduledoc false


  #generate class
  def generate_class(ast) do
    template = "package core.natives

                class %class_name% {

                   private long CPointer;
                   private boolean mOwnsMemory = true;

                   %constructors%

                   %functions%

                   protected void finalize(){
                        if(mOwnsMemory){
                            finalize(CPointer);
                        }
                   }
                   private native static void finalize(long CPointer);

                   public void setMemown(boolean ownsMemory){
                        mOwnsMemory = ownsMemory;
                   }

                }"

     template
      |> String.replace("%class_name%",Ast.get_class(ast))
      |> String.replace("%constructors%",generate_constructors(Ast.get_constructors(ast),Ast.get_class(ast)))
      |> String.replace("%functions%",generate_functions(Ast.get_functions(ast)))

  end

  #constructor list
  def generate_constructors(constructors_list,class_name) do
    Enum.reduce(constructors_list,"",fn(x,acc) -> acc <> "\n" <> generate_constructor(x,class_name) end ) |> String.replace("\n","",global: :false)
  end

  #constructor
  def generate_constructor(constructor,class_name) do
    "public %class_name%(%params%) {
          CPointer = %func_call%;
     }
     private native static long %class_name%(%params%);
     "
     |> String.replace("%class_name%",class_name)
     |> String.replace("%params%",generate_params(Constructor.get_params(constructor)))
     |> String.replace("%func_call%",generate_func_call(class_name,Constructor.get_params((constructor))))

  end

  #functions list
  def generate_functions(functions_list) do
     Enum.reduce(functions_list,"",fn(x,acc) -> acc <> "\n" <> generate_func(x) end ) |> String.replace("\n","",global: :false)
  end

  #generic function
  def generate_func(func) do

    case Func.is_static?(func) do
      true  -> generate_static_func(func)
      false -> generate_normal_func(func)
    end

  end

  #function
  def generate_normal_func(func) do

    template = " %returnType% %functionName%(%params_list%)"

    #member function
    member_function = template
                    |> String.replace("%returnType%",Func.returnType(func) |> generate_returntype)
                    |> String.replace("%functionName%",Func.name(func))
                    |> String.replace("%params_list%",generate_params(Func.params(func)))


    #add param for static version
    params = [Param.new("long","CPointer",false,false,false) | Func.params(func)]
    func = Func.setParams(func,params)


    #static member function
    static_member_function = template
                            |> String.replace("%returnType%",Func.returnType(func) |> generate_returntype)
                            |> String.replace("%functionName%",Func.name(func))
                            |> String.replace("%params_list%",generate_params(Func.params(func)))

    #combine the two functions
    func_str = "public %member_func%{
                      return %static_func_call%;
                }
                private native static %static_member_func%;"

    func_call =  generate_func_call(Func.name(func),params)

    func_str = func_str
                    |> String.replace("%member_func%",member_function)
                    |> String.replace("%static_func_call%",func_call)
                    |> String.replace("%static_member_func%",static_member_function)


    #if return type == void
    is_void = ReturnType.name(Func.returnType(func)) === "void"
    func_str = case is_void do
                   true -> String.replace(func_str,"return ","")
                   false -> func_str
                end
    func_str

  end

  #generate static function
  def generate_static_func(func) do

    #generate parameters string
    param_str = Enum.reduce(Func.params(func),"",fn(x,acc) -> acc <> "," <> generate_param(x) end )
                |> String.replace(",","",global: :false)

    #fill the template
    "public native static %returnType% %functionName%(%params_list%);"
     |> String.replace("%returnType%",Func.returnType(func) |> generate_returntype)
     |> String.replace("%functionName%",Func.name(func))
     |> String.replace("%params_list%",param_str)

  end

  defp generate_func_call(func_name,params) do
    params_str = Enum.reduce(params,"",fn(param,acc) -> acc <> "," <> Param.varName(param) end ) |> String.replace(",","",global: :false)

    "%func_name% (%params%)"
        |> String.replace("%func_name%",func_name)
        |> String.replace("%params%",params_str)

  end

  #Params
  def generate_params(params_list) do
    Enum.reduce(params_list,"",fn(x,acc) -> acc <> "," <> generate_param(x) end ) |> String.replace(",","",global: :false)
  end

  #Param
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