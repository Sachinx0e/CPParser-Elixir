defmodule JniGenerator do
  @moduledoc false

  def generate_func_declaration(func,class_name) do
     template = "JNIEXPORT %return_type% JNICALL Java_core_natives_%class%_%function%__J%signature%(JNIEnv* env,jclass _class,jlong CPointer%params%)"

     #mangle class name
     mangled_class_name = String.replace(class_name,"_","_1")

     #mangle function name
     mangled_func_name = String.replace(Func.name(func),"_","_1")

     template
          |> String.replace("%return_type%",to_jni_long_type(Func.returnType(func) |> ReturnType.name()))
          |> String.replace("%class%",mangled_class_name)
          |> String.replace("%function%",mangled_func_name)
          |> String.replace("%signature%",generate_signature(Func.params(func)))
          |> String.replace("%params%", generate_func_params(Func.params(func)))

  end

  def generate_params_conversion(params,class_name,is_static?) do
      params = case is_static? do
                false -> [Param.new("long","CPointer",false,false,false) | params ]
                true -> params
               end
      Enum.reduce(params,"",fn(param,acc) ->  acc <> "\n" <> convert_param(param,class_name)  end) |> String.replace("\n","",global: false)
  end

  def convert_param(param,class_name) do
     type_name = Param.typeName(param)
     var_name = Param.varName(param)

     cond do
       #strings
       type_name === "string" ->
       "std::string* %var_name%_converted = jstring2string(%var_name%);"
       |> String.replace("%var_name%",var_name)

       #this pointer
       type_name === "long" && var_name === "CPointer" ->
       "%class_name%* this = (%class_name%*)CPointer;"
        |> String.replace("%class_name%",class_name)

       #basic types
       type_name === "int" || type_name === "long" || type_name === "float" || type_name === "double" || type_name === "bool" ->
                  "%type_name% %var_name%_converted = (%type_name%)%var_name%;"
                  |> String.replace("%type_name%",type_name)
                  |> String.replace("%var_name%",Param.varName(param))


       #object type
       true -> "%type_name%* %var_name%_converted = (%type_name%*) %var_name%;"
        |>String.replace("%type_name%",type_name)
        |>String.replace("%var_name%",var_name)

     end

  end

  def generate_signature(params) do
     Enum.reduce(params,"",fn(param,acc) ->  acc <> to_jni_short_type(Param.typeName(param))  end)
  end

  def generate_func_params(params) do
    Enum.reduce(params,"",fn(param,acc) -> acc <> "," <> to_jni_long_type(Param.typeName(param)) <> " " <> Param.varName(param) end)
  end

  def generate_func_call(func) do
    template = "%return_type% result = this->%func_name%(%params%);"

    #if return type is void
    template = case (Func.returnType(func) |> ReturnType.name()) === "void" do
                  true  -> template |> String.replace("%return_type% result = ","")
                  false -> template
               end

    #if function is static
    template = case Func.is_static?(func) do
                    true  -> template |> String.replace("this->","")
                    false -> template
               end

    #function name
    template = template |> String.replace("%func_name%",Func.name(func))

    #params
    params = generate_func_call_params(Func.params(func));

    template |> String.replace("%params%",params)

  end

  def generate_func_call_params(params) do

    generate_param_name = fn(param) ->

                              type_name = Param.typeName(param)

                              cond do
                                #string,reference
                                type_name === "string" && Param.isReference(param) -> "*(%var_name%_converted)"
                                                                                 |> String.replace("%var_name%",Param.varName(param))

                                #int,long,float,double,bool
                                type_name === "int" || type_name === "long" ||
                                type_name === "float" || type_name === "double" || type_name === "bool"
                                -> ("%var_name%_converted") |> String.replace("%var_name%",Param.varName(param))

                                #object reference
                                Param.isReference(param) -> "*(%var_name%_converted)" |> String.replace("%var_name%",Param.varName(param))

                                #object pointer
                                Param.isPointer?(param) -> "%var_name%_converted" |> String.replace("%var_name%",Param.varName(param))
                              end

                          end

    Enum.reduce(params,"",fn(x,acc) -> acc <> "," <> generate_param_name.(x) end) |> String.replace(",","",global: false)

  end

  defp to_jni_short_type(type) do

    cond do
      type === "int" -> "I"
      type === "long" -> "J"
      type === "float" -> "F"
      type === "double" -> "D"
      type === "bool" -> "Z"
      type === "string" -> "Ljava_lang_String_2"
      true -> type
    end

  end

  defp to_jni_long_type(type) do
    cond do
      type === "int" -> "jint"
      type === "long" -> "jlong"
      type === "float" -> "jfloat"
      type === "double" -> "jdouble"
      type === "bool" -> "jboolean"
      type === "string" -> "jstring"
      type === "void" -> "void"
      true -> "long"
    end
  end

end