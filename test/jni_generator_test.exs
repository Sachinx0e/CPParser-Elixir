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

  test "function parameters conversions" do
     params = [Param.new("int","param1",false,false,false),
               Param.new("float","param2",false,false,false),
               Param.new("double","param3",false,false,false),
               Param.new("long","param4",false,false,false),
               Param.new("string","param5",false,false,false),
               Param.new("DummyClass","param6",false,false,false)
               ]

     params_conversion = JniGenerator.generate_params_conversion(params,"TestClass",false)

     model_conversion = "TestClass* this = (TestClass*)CPointer;
                         int param1_converted = (int)param1;
                         float param2_converted = (float)param2;
                         double param3_converted = (double)param3;
                         long param4_converted = (long)param4;
                         std::string* param5_converted = jstring2string(param5);
                         DummyClass* param6_converted = (DummyClass*)param6;"

     assert Misc.strip(params_conversion) === Misc.strip(model_conversion)

  end

  test "function call no return type" do

     func = Func.new(ReturnType.new("void",false),"testFunction",[Param.new("int","param1",false,false,false),
                                                   Param.new("string","param2",false,true,false),
                                                   Param.new("DummyClass","param3",true,false,false)],false)

     func_call = JniGenerator.generate_func_call(func)

     assert func_call === "this->testFunction(param1_converted,*(param2_converted),param3_converted);"

  end


end