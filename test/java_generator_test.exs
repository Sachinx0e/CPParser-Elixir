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

  test "generate constructor" do
    construtor = JavaGenerator.generate_constructor(Constructor.new([Param.new("int","param1",false,false,false)]),"test_class")
                 |> Misc.strip()

    model_constructor = "public test_class(int param1){
                             CPointer = test_class(param1);
                         }
                         private native static long test_class(int param1);
                         "
    model_constructor = Misc.strip(model_constructor)

    assert construtor === model_constructor

  end

  test "generate normal function" do

     return_type = ReturnType.new("string",false)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false)]

     #normal version return type
     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,false))
     func = Misc.strip(func)

     model_func = "public String test_function(String param1,int param2){
                        return test_function(CPointer,param1,param2);
                   }
                   private native static String test_function(long CPointer,String param1,int param2);"

     model_func = Misc.strip(model_func)


     assert func === model_func

  end

  test "generate static function" do

     return_type = ReturnType.new("string",false)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false)]

     func = JavaGenerator.generate_static_func(Func.new(return_type,"test_function",params,false))
     assert func === "public native static String test_function(String param1,int param2);"

  end

  test "generate class" do
    ast = Ast.new()
          |> Ast.setClass("test_class")
          |> Ast.addConstructor(Constructor.new([Param.new("int","param1",false,false,false)]))
          |> Ast.addConstructor(Constructor.new([Param.new("string","param1",false,false,false)]))
          |> Ast.addFunction(Func.new(ReturnType.new("void",false),"test_function",[Param.new("int","param1",false,false,false)],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_return",[],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_static",[Param.new("int","param1",false,false,false)],true))

    class = JavaGenerator.generate_class(ast)
                |> Misc.strip()

    model_class = "class test_class {

                   private long CPointer;
                   private boolean mOwnsMemory = true;

                   public test_class(int param1){
                        CPointer = test_class(param1);
                   }
                   private native static long test_class(int param1);

                   public test_class(String param1){
                        CPointer = test_class(param1);
                   }
                   private native static long test_class(String param1);

                   public void test_function(int param1){
                        test_function(CPointer,param1);
                   }
                   private native static void test_function(long CPointer,int param1);

                   public String test_function_return(){
                        return test_function_return(CPointer);
                   }
                   private native static String test_function_return(long CPointer);

                   public native static String test_function_static(int param1);

                   protected void finalize(){
                        if(mOwnsMemory){
                            finalize(CPointer);
                        }
                   }
                   private native static void finalize(long CPointer);

                   public void setMemown(ownsMemory){
                        mOwnsMemory = ownsMemory;
                   }

                }"

    model_class = Misc.strip(model_class)

    assert class == model_class

  end



end