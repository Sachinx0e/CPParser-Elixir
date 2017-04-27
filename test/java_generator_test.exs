defmodule JavaGeneratorTest do
  use ExUnit.Case

  test "generate param" do
     param = JavaGenerator.generate_param(Param.new("int","param1",false,false,false));
     assert param === "int param1"

     param = JavaGenerator.generate_param(Param.new("string","param1",false,false,false));
     assert param === "String param1"
  end

  test "generate return type" do
    return_type = JavaGenerator.generate_returntype(ReturnType.new("string",false))
    assert return_type === "String"
  end

  test "generate normal function" do

     return_type = ReturnType.new("string",false)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false)]

     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,false))
     assert func === "public String test_function(String param1,int param2);"

     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,true),true)
     assert func === "public static String test_function(long CPointer,String param1,int param2);"

  end



end