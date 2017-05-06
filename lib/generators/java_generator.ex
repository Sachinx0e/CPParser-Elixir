defmodule JavaGenerator do
  @moduledoc false


  #generate class
  def generate_source(ast) do
    template = "package core.natives;

                     public class %class_name% {

                          private long CPointer;
                          private boolean mOwnsMemory = true;

                          public %class_name% (long pointer, boolean ownsMemory){
                               CPointer = pointer;
                               mOwnsMemory = ownsMemory;
                          }

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

                          public long getPointer(){
                               return CPointer;
                          }

               }"

     template
      #remove spacing for proper alignment
      |> String.replace("                     ","")
      |> String.replace("               ","")

      #fill the template
      |> String.replace("%class_name%",Ast.get_class(ast))
      |> String.replace("%constructors%",generate_constructors(Ast.get_constructors(ast),Ast.get_class(ast)))
      |> String.replace("%functions%",generate_functions(Ast.get_functions(ast)))



  end

  #constructor list
  def generate_constructors(constructors_list,class_name) do
    Enum.reduce(constructors_list,"",fn(x,acc) -> acc <> "\n\n     " <> generate_constructor(x,class_name) end ) |> String.replace("\n","",global: :false)
  end

  #constructor
  def generate_constructor(constructor,class_name) do
    "public %class_name%(%params%) {
          CPointer = %func_name%(%param_names%);
     }
     private native static long %class_name%(%params_native%);
     "
     |> String.replace("%class_name%",class_name)
     |> String.replace("%params%",generate_params(Constructor.get_params(constructor)))
     |> String.replace("%params_native%",generate_params_native(Constructor.get_params(constructor)))
     |> String.replace("%func_name%",class_name)
     |> String.replace("%param_names%",generate_func_call_params(Constructor.get_params(constructor)) |> String.replace(",","",global: false) )

  end

  #functions list
  def generate_functions(functions_list) do
     Enum.reduce(functions_list,"",fn(x,acc) -> acc <> "\n\n     " <> generate_func(x) end ) |> String.replace("\n","",global: :false)
  end

  #generic function
  def generate_func(func) do

    is_return_type_object = Func.returnType(func) |> ReturnType.isObject?()
    case Func.is_static?(func) do
      true -> case (is_return_type_object) do
                  true -> generate_static_func_object_return_type(func)
                  false -> generate_static_func(func)
               end
      false -> case (is_return_type_object) do
                   true -> generate_func_object_return_type(func)
                   false -> generate_normal_func(func)
               end
    end

  end

  #function
  def generate_normal_func(func) do

    #combine the two functions
    func_template =
    "public %return_type% %func_name%(%params_list%){
           return %func_name%(CPointer%param_names%);
     }
     private native static %return_type% %func_name%(long CPointer%params_list_native%);"

    params_list = generate_params(Func.params(func))
    params_list_native = generate_params_native(Func.params(func))
    params_list_native = case params_list_native === "" do
      true -> params_list_native
      false -> "," <> params_list_native
    end

    func_template = func_template
                    #|> String.replace("           ","")
                    |> String.replace("%func_name%",Func.name(func))
                    |> String.replace("%params_list%",params_list)
                    |> String.replace("%params_list_native%",params_list_native)
                    |> String.replace("%param_names%",generate_func_call_params(Func.params(func)))
                    |> String.replace("%return_type%",Func.returnType(func) |> generate_returntype )

    #if return type == void
    is_void = ReturnType.name(Func.returnType(func)) === "void"
    case is_void do
         true -> String.replace(func_template,"return ","")
         false -> func_template
    end

  end

  def generate_func_object_return_type(func) do
     func_template =
     "public %return_type% %func_name%(%params_list%){
           long result = %func_name%(CPointer%param_names%);
           return new %return_type%(result,%owns_memory%);
     }
     private native static long %func_name%(long CPointer%params_list_static%);"

     params_list = generate_params(Func.params(func))
     params_list_static = case params_list === "" do
       true -> params_list
       false -> "," <> params_list
     end

     func_template
        |> String.replace("%return_type%",Func.returnType(func) |> ReturnType.name())
        |> String.replace("%func_name%",Func.name(func))
        |> String.replace("%param_names%",generate_func_call_params(Func.params(func)))
        |> String.replace("%params_list%",params_list)
        |> String.replace("%params_list_static%",params_list_static)
        |> String.replace("%owns_memory%",!(Func.returnType(func) |> ReturnType.disown_memory?()) |> Atom.to_string())

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


  def generate_static_func_object_return_type(func) do
     func_template =
     "public static %return_type% %func_name%_S(%params_list%){
             long result = %func_name%(%param_names%);
             return new %return_type%(result,%owns_memory%);
      }
      private native static long %func_name%(%params_list_native%);"

     func_template
        |> String.replace("%return_type%",Func.returnType(func) |> ReturnType.name())
        |> String.replace("%func_name%",Func.name(func))
        |> String.replace("%param_names%",generate_func_call_params(Func.params(func)) |> String.replace(",","",global: false) )
        |> String.replace("%params_list%",generate_params(Func.params(func)))
        |> String.replace("%params_list_native%",generate_params_native(Func.params(func)))
        |> String.replace("%owns_memory%",!(Func.returnType(func) |> ReturnType.disown_memory?()) |> Atom.to_string())

  end

  def generate_func_call_params(params) do

   verify_object = fn(param) ->
                       case Param.is_object?(param) do
                           true -> Param.varName(param) <> ".getPointer()"
                           false -> Param.varName(param)
                       end
                   end

   Enum.reduce(params,"",fn(param,acc) -> acc <> "," <> verify_object.(param) end )
  end

  #Params
  def generate_params(params_list) do
    Enum.reduce(params_list,"",fn(x,acc) -> acc <> "," <> generate_param(x) end ) |> String.replace(",","",global: false)
  end

  def generate_params_native(params) do
    Enum.reduce(params,"",fn(x,acc) -> acc <> "," <> generate_param(x,true) end ) |> String.replace(",","",global: false)
  end

  #Param
  def generate_param(param,is_native? \\false) do
     template = "%typeName% %varName%"

     typeName = Param.typeName(param)

     typeName = cond do
                  #String
                  typeName === "string" -> "String"

                  #bool
                  typeName === "bool" -> "boolean"

                  #object
                  Param.is_object?(param) -> case is_native? do
                                                true -> "long"
                                                false -> typeName
                                             end

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
         ReturnType.name(return_type) === "bool" -> "boolean"
         true -> ReturnType.name(return_type)
      end

  end

  
end