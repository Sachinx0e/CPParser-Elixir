defmodule JavaGeneratorTest do
  use ExUnit.Case

  test "generate param" do
     param = JavaGenerator.generate_param(Param.new("int","param1",false,false,false));
     assert param === "int param1"

     param = JavaGenerator.generate_param(Param.new("string","param1",false,false,false));
     assert param === "String param1"
  end

  test "generate params native" do
    params = [Param.new("int","param1",false,false,false),
              Param.new("string","param2",false,false,false),
              Param.new("DummyClass","param3",true,true,true)]

    params_native = JavaGenerator.generate_params_native(params)

    model_params = "int param1,String param2,long param3"

    assert params_native === model_params

  end

  test "generate return type" do
    return_type = JavaGenerator.generate_returntype(ReturnType.new("string",false))
    assert return_type === "String"
  end

  test "generate function call params" do

    params = [Param.new("int","param1",false,false,false),
              Param.new("string","param2",false,false,false),
              Param.new("DummyClass","param3",false,false,false)]

    func_call_params = JavaGenerator.generate_func_call_params(params)

    model_func_call_params = ",param1,param2,param3.getPointer()"

    assert func_call_params === model_func_call_params

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

  test "generate function class return type" do

     return_type = ReturnType.new("DummyClass",false,false)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false)]

     #normal version return type
     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,false))
     func = Misc.strip(func)

     model_func = "public DummyClass test_function(String param1,int param2){
                        long result = test_function(CPointer,param1,param2);
                        return new DummyClass(result,true);
                   }
                   private native static long test_function(long CPointer,String param1,int param2);"

     model_func = Misc.strip(model_func)


     assert func === model_func

  end

  test "generate function class return type that does not own memory" do

     return_type = ReturnType.new("DummyClass",false,true)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false)]

     #normal version return type
     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,false))
     func = Misc.strip(func)

     model_func = "public DummyClass test_function(String param1,int param2){
                        long result = test_function(CPointer,param1,param2);
                        return new DummyClass(result,false);
                   }
                   private native static long test_function(long CPointer,String param1,int param2);"

     model_func = Misc.strip(model_func)


     assert func === model_func

  end

  test "generate normal function Object param " do

     return_type = ReturnType.new("string",false)
     params = [Param.new("string","param1",true,true,false),
               Param.new("DummyClass","param2",false,false,false)]

     #normal version return type
     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,false))
     func = Misc.strip(func)

     model_func = "public String test_function(String param1,DummyClass param2){
                        return test_function(CPointer,param1,param2.getPointer());
                   }
                   private native static String test_function(long CPointer,String param1,long param2);"

     model_func = Misc.strip(model_func)


     assert func === model_func

  end


  test "generate static function normal type" do

     return_type = ReturnType.new("std::string",false)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false)]

     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,true))
     assert func === "public native static String test_function(String param1,int param2);"

  end

  test "generate static function class return type" do

     return_type = ReturnType.new("DummyClass",false)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false),
               Param.new("Dummy","param3",true,false,false)
               ]

     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,true))

     model_func = "public static DummyClass test_function_S(String param1,int param2,Dummy param3){
                       long result = test_function(param1,param2,param3.getPointer());
                       return new DummyClass(result,true);
                   }
                   private native static long test_function(String param1,int param2,long param3);"

     assert Misc.strip(func) === Misc.strip(model_func)

  end


  test "generate static function class return type that does not own memory" do

     return_type = ReturnType.new("DummyClass",false,true)
     params = [Param.new("string","param1",true,true,false),
               Param.new("int","param2",false,false,false)]

     func = JavaGenerator.generate_func(Func.new(return_type,"test_function",params,true))

     model_func = "public static DummyClass test_function_S(String param1,int param2){
                       long result = test_function(param1,param2);
                       return new DummyClass(result,false);
                   }
                   private native static long test_function(String param1,int param2);"

     assert Misc.strip(func) === Misc.strip(model_func)

  end



  test "generate class" do
    ast = Ast.new()
          |> Ast.setClass("test_class")
          |> Ast.addConstructor(Constructor.new([Param.new("int","param1",false,false,false)]))
          |> Ast.addConstructor(Constructor.new([Param.new("string","param1",false,false,false)]))
          |> Ast.addFunction(Func.new(ReturnType.new("void",false),"test_function",[Param.new("int","param1",false,false,false)],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_return",[],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_static",[Param.new("int","param1",false,false,false)],true))


    class = JavaGenerator.generate_source(ast)
                |> Misc.strip()

    model_class = "package core.natives;

                   public class test_class {

                   private final transient long CPointer;
                   private boolean mOwnsMemory = true;

                   public test_class (long pointer, boolean ownsMemory){
                         CPointer = pointer;
                         mOwnsMemory = ownsMemory;
                   }

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
                             delete(CPointer);
                         }
                   }

                   private native static void delete(long CPointer);

                   public void delete(){
                         delete(CPointer);
                   }

                   public void setMemown(boolean ownsMemory){
                        mOwnsMemory = ownsMemory;
                   }

                   public long getPointer(){
                        return CPointer;
                   }

                }"

    model_class = Misc.strip(model_class)

    assert class == model_class

  end



end