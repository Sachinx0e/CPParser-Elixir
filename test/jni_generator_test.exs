defmodule JniGeneratorTest do
  @moduledoc false
  use ExUnit.Case

  test "mangled params" do
    params = [Param.new("long","CPointer",false,false,false),
              Param.new("int","param1",false,false,false),
              Param.new("string","param2",false,false,false),
              Param.new("bool","param3",false,false,false),
              Param.new("float","param4",false,false,false),
              Param.new("double","param5",false,false,false)]

    mangled_params = JniGenerator.generate_mangled_params(params)

    assert mangled_params === "__JILjava_lang_String_2ZFD"

  end


  test "function params" do
    params = [Param.new("long","CPointer",false,false,false),
              Param.new("int","param1",false,false,false),
              Param.new("string","param2",false,false,false),
              Param.new("bool","param3",false,false,false),
              Param.new("float","param4",false,false,false),
              Param.new("double","param5",false,false,false)]

    params_str = JniGenerator.generate_func_params(params)

    assert params_str === "jlong CPointer,jint param1,jstring param2,jboolean param3,jfloat param4,jdouble param5"

  end


end