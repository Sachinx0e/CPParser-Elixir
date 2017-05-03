defmodule JniGeneratorTest do
  @moduledoc false
  use ExUnit.Case

  test "function signature" do
    params = [Param.new("long","CPointer",false,false,false),
              Param.new("int","param1",false,false,false),
              Param.new("string","param2",false,false,false),
              Param.new("bool","param3",false,false,false),
              Param.new("float","param4",false,false,false),
              Param.new("double","param5",false,false,false),
              Param.new("DummyClass","param6",false,false,false)
              ]

    signature = JniGenerator.generate_signature(params)

    assert signature === "JILjava_lang_String_2ZFDJ"

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

    test "mangled_function_declaration static" do

       func = Func.new(ReturnType.new("string",false),"testFunction",[Param.new("int","param1",false,false,false)],true)

       func_declaration = JniGenerator.generate_func_declaration(func,"TestClass")

       assert func_declaration === "JNIEXPORT jstring JNICALL Java_core_natives_TestClass_testFunction__I(JNIEnv* env,jclass _class,jint param1)"

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

     model_conversion = "TestClass* current_object = (TestClass*)CPointer;
                         int param1_converted = (int)param1;
                         float param2_converted = (float)param2;
                         double param3_converted = (double)param3;
                         long param4_converted = (long)param4;
                         std::string param5_converted = jstring2string(env,param5);
                         DummyClass* param6_converted = (DummyClass*)param6;"

     assert Misc.strip(params_conversion) === Misc.strip(model_conversion)

  end

    test "function parameters conversions static" do
       params = [Param.new("int","param1",false,false,false),
                 Param.new("float","param2",false,false,false),
                 Param.new("double","param3",false,false,false),
                 Param.new("long","param4",false,false,false),
                 Param.new("string","param5",false,false,false),
                 Param.new("DummyClass","param6",false,false,false)
                 ]

       params_conversion = JniGenerator.generate_params_conversion(params,"TestClass",true)

       model_conversion = "int param1_converted = (int)param1;
                           float param2_converted = (float)param2;
                           double param3_converted = (double)param3;
                           long param4_converted = (long)param4;
                           std::string param5_converted = jstring2string(env,param5);
                           DummyClass* param6_converted = (DummyClass*)param6;"

       assert Misc.strip(params_conversion) === Misc.strip(model_conversion)

    end

  test "function call no return type" do

     func = Func.new(ReturnType.new("void",false),"testFunction",[Param.new("int","param1",false,false,false),
                                                   Param.new("string","param2",false,true,false),
                                                   Param.new("DummyClass","param3",true,false,false)],false)

     func_call = JniGenerator.generate_func_call(func)

     assert Misc.strip(func_call) === "current_object->testFunction(param1_converted,param2_converted,param3_converted);"

  end

  test "function call normal return type" do
    func = Func.new(ReturnType.new("int",false),"testFunction",[Param.new("int","param1",false,false,false),
                                                   Param.new("string","param2",false,true,false),
                                                   Param.new("DummyClass","param3",true,false,false)],false)

    func_call = JniGenerator.generate_func_call(func)

    model_func_call = "int result = current_object->testFunction(param1_converted,param2_converted,param3_converted);
                       return result;"

    assert Misc.strip(func_call) === Misc.strip(model_func_call)

  end


  test "function call normal string return type" do
      func = Func.new(ReturnType.new("string",false),"testFunction",[Param.new("int","param1",false,false,false),
                                                     Param.new("string","param2",false,true,false),
                                                     Param.new("DummyClass","param3",true,false,false)],false)

      func_call = JniGenerator.generate_func_call(func)

      model_func_call = "std::string result = current_object->testFunction(param1_converted,param2_converted,param3_converted);
                         return env->NewStringUTF(result.c_str());"

      assert Misc.strip(func_call) === Misc.strip(model_func_call)

  end

  test "generate function normal return type" do
       func = Func.new(ReturnType.new("int",false),"testFunction",[Param.new("int","param1",false,false,false),
                                                          Param.new("string","param2",false,true,false),
                                                          Param.new("DummyClass","param3",true,false,false)],false)

       func_str = JniGenerator.generate_func(func,"TestClass")

       model_func_str = "
                        //int TestClass.testFunction(int param1,string& param2,DummyClass* param3)
                        JNIEXPORT jint JNICALL Java_core_natives_TestClass_testFunction__JILjava_lang_String_2J(JNIEnv* env,jclass _class,jlong CPointer,jint param1,jstring param2,long param3) {
                           TestClass* current_object = (TestClass*)CPointer;
                           int param1_converted = (int)param1;
                           std::string param2_converted = jstring2string(env,param2);
                           DummyClass* param3_converted = (DummyClass*) param3;
                           int result = current_object->testFunction(param1_converted,param2_converted,param3_converted);
                           return result;
                         }"

       assert Misc.strip(func_str) === Misc.strip(model_func_str)

  end


  test "generate constructors" do
      constructor_str = JniGenerator.generate_constructor(Constructor.new([Param.new("int","param1",false,false,false)]),"test_class")

      model_constructor = "JNIEXPORT jlong JNICALL Java_core_natives_test_1class_test_1class__I(JNIEnv* env,jclass _class,jint param1) {
                               int param1_converted = (int)param1;
                               long result = (long) new test_class(param1_converted);
                               return result;
                           }"

      assert Misc.strip(constructor_str) === Misc.strip(model_constructor)

  end

  test "generate source" do
    ast = Ast.new()
          |> Ast.setNamespace("test_namespace")
          |> Ast.setClass("test_class")
          |> Ast.addConstructor(Constructor.new([Param.new("int","param1",false,false,false)]))
          |> Ast.addConstructor(Constructor.new([Param.new("string","param1",false,false,false)]))
          |> Ast.addFunction(Func.new(ReturnType.new("void",false),"test_function",[Param.new("int","param1",false,false,false)],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_return",[],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_static",[Param.new("int","param1",false,false,false)],true))

    source = JniGenerator.generate_source(ast,"headers/TestClass.h")

    model_source = "#ifndef TEST_CLASS_JNI_H
                    #define TEST_CLASS_JNI_H

                    #include <jni.h>
                    #include <jni_helper.h>

                    #include <headers/TestClass.h>

                    using namespace test_namespace;

                    extern \"C\" {

                    JNIEXPORT jlong JNICALL Java_core_natives_test_1class_test_1class__I(JNIEnv* env,jclass _class,jint param1) {
                       int param1_converted = (int)param1;
                       long result = (long) new test_class(param1_converted);
                       return result;
                    }


                    JNIEXPORT jlong JNICALL Java_core_natives_test_1class_test_1class__Ljava_lang_String_2(JNIEnv* env,jclass _class,jstring param1) {
                       std::string param1_converted = jstring2string(env,param1);
                       long result = (long) new test_class(param1_converted);
                       return result;
                    }


                    //void test_class.test_function(int param1)
                    JNIEXPORT void JNICALL Java_core_natives_test_1class_test_1function__JI(JNIEnv* env,jclass _class,jlong CPointer,jint param1) {
                      test_class* current_object = (test_class*)CPointer;
                      int param1_converted = (int)param1;
                      current_object->test_function(param1_converted);
                    }


                    //string test_class.test_function_return()
                    JNIEXPORT jstring JNICALL Java_core_natives_test_1class_test_1function_1return__J(JNIEnv* env,jclass _class,jlong CPointer) {
                      test_class* current_object = (test_class*)CPointer;
                      std::string result = current_object->test_function_return();
                      return env->NewStringUTF(result.c_str());
                    }


                    //static string test_class.test_function_static(int param1)
                    JNIEXPORT jstring JNICALL Java_core_natives_test_1class_test_1function_1static__I(JNIEnv* env,jclass _class,jint param1) {
                      int param1_converted = (int)param1;
                      std::string result = test_function_static(param1_converted);
                      return env->NewStringUTF(result.c_str());
                    }

                    JNIEXPORT void JNICALL Java_core_natives_test_1class_finalize__J(JNIEnv* env,jlong CPointer){
                      test_class* current_object = (test_class*)CPointer;
                      delete current_object;
                    }


                    }

                    #endif"


    assert Misc.strip(source) === Misc.strip(model_source)

  end

end