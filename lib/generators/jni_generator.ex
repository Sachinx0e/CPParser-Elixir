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

  def generate_signature(params) do
     Enum.reduce(params,"",fn(param,acc) ->  acc <> to_jni_short_type(Param.typeName(param))  end)
  end

  def generate_func_params(params) do
    Enum.reduce(params,"",fn(param,acc) -> acc <> "," <> to_jni_long_type(Param.typeName(param)) <> " " <> Param.varName(param) end)
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
      true -> "jobject"
    end
  end

end