defmodule JniGeneratorTest do
  @moduledoc false
  use ExUnit.Case

  test "function signature" do
    params = [Param.new("long","CPointer",false,false,false),
              Param.new("int","param1",false,false,false),
              Param.new("string","param2",false,false,false),
              Param.new("bool","param3",false,false,false),
              Param.new("float","param4",false,false,false),
              Param.new("double","param5",false,false,false)]

    signature = JniGenerator.generate_signature(params)

    assert signature === "JILjava_lang_String_2ZFD"

  end


  test "function params" do
    params = [Param.new("long","CPointer",false,false,false),
              Param.new("int","param1",false,false,false),
              Param.new("string","param2",false,false,false),
              Param.new("bool","param3",false,false,false),
              Param.new("float","param4",false,false,false),
              Param.new("double","param5",false,false,false)]

    params_str = JniGenerator.generate_func_params(params)

    assert params_str === ",jlong CPointer,jint param1,jstring param2,jboolean param3,jfloat param4,jdouble param5"

  end

  test "mangled_function_declaration" do

     func = Func.new(ReturnType.new("string",false),"testFunction",[Param.new("int","param1",false,false,false)],false)

     func_declaration = JniGenerator.generate_func_declaration(func,"TestClass")

     assert func_declaration === "JNIEXPORT jstring JNICALL Java_core_natives_TestClass_testFunction__JI(JNIEnv* env,jclass _class,jlong CPointer,jint param1)"

  end


end