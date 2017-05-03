defmodule CparserTest do
  use ExUnit.Case

  test "comment" do
    # single comment
    construct = Cparser.get_construct("//this is a comment",%Ast{})
    assert construct === :ignore

    #multi line open comment
    construct = Cparser.get_construct("/*is is a comment",%Ast{})
    assert construct === :ignore
    construct = Cparser.get_construct("*this is a comment",%Ast{})
    assert construct === :ignore
    construct = Cparser.get_construct("this is a comment*/",%Ast{})
    assert construct === :ignore

  end

  test "include" do
    construct = Cparser.get_construct("#include <iostream>",%Ast{})
    assert construct === :ignore
  end

  test "forward declaration" do
    construct = Cparser.get_construct("/*FD*/ namespace forward_declared {",%Ast{})
    assert construct === :ignore
  end

  test "class forward declared" do
    construct = Cparser.get_construct("class forward_declared;",%Ast{})
    assert construct === :ignore
  end

  test "namespace" do
    construct = Cparser.get_construct("namespace rewire {",%Ast{})
    assert construct === :namespace
  end

  test "class" do
    construct = Cparser.get_construct("class myclass {",%Ast{})
    assert construct === :class
  end

  test "constructor" do
    construct = Cparser.get_construct("myclass();",%Ast{class: "myclass"})
    assert construct === :constructor
  end

  test "const function" do

    #const return type
    construct = Cparser.get_construct("const type func(const type var1, type var2);",%Ast{});
    assert construct === :ignore

    #const function
    construct = Cparser.get_construct("type func(const type* var1, type var2) const;",%Ast{});
    assert construct === :ignore

  end

  test "pure virtual function" do
    construct = Cparser.get_construct("virtual type func(type var1, type var2) = 0;",%Ast{});
    assert construct === :ignore
  end

  test "virtual function" do
    construct = Cparser.get_construct("virtual type func(type var1, type var2);",%Ast{});
    assert construct === :function
  end

  test "destructor" do
    construct = Cparser.get_construct("~myclass();",%Ast{})
    assert construct === :ignore
  end


  test "parse return type" do
    #normal
    return_type = Cparser.parse_returntype("void test_function1(int param1,int* param2, const std::string& param3);")
    assert return_type == ReturnType.new("void",false)

    #pointer
    return_type = Cparser.parse_returntype("std::string* test_function1(int param1,int* param2, const std::string& param3);")
    assert return_type == ReturnType.new("std::string",true)

  end

  test "parse parameters" do
    params = Cparser.parse_params("void test_function1(int param1,int* param2, const std::string& param3);")
    #assert return_type == ReturnType.new("void",false)

    assert params === [Param.new("int","param1",false,false,false),
                       Param.new("int","param2",true,false,false),
                       Param.new("std::string","param3",false,true,true)]

  end


  test "parse function" do
    function = Cparser.parse_function("void test_function1(int param1,int* param2, const std::string& param3);")

    #return type
    params = [Param.new("int","param1",false,false,false),
              Param.new("int","param2",true,false,false),
              Param.new("std::string","param3",false,true,true)]

    assert function == Func.new(ReturnType.new("void",false),"test_function1",params,false)

  end

  test "parse real source " do

    source = " #ifndef TEST_H
               #define TEST_H

               /*FD*/ namespace forward_namespace {
                   class test_class;
               }

               namespace test_namespace {
                   class test_class {
                       public:
                          test_class(const std::string& param1, int param2, Date* param3);

                          Data* function1(int param1, int* param2, int& param3, const int* param4, const int& param5);

                          static int function2(const Namespace2::Data& data);

                       private:
                          int mPram1;
                          int mParam2;

                   };
               }

             "

     ast = Cparser.build_ast(source)

     model_ast = %Ast{}
                 |> Ast.setNamespace("test_namespace")
                 |> Ast.setClass("test_class")
                 |> Ast.addConstructor(Constructor.new([Param.new("std::string","param1",false,true,true),
                                                                         Param.new("int","param2",false,false,false),
                                                                         Param.new("Date","param3",true,false,false)]))

                 |> Ast.addFunction(Func.new(ReturnType.new("Data",true),"function1",[Param.new("int","param1",false,false,false),
                                                                                            Param.new("int","param2",true,false,false),
                                                                                            Param.new("int","param3",false,true,false),
                                                                                            Param.new("int","param4",true,false,true),
                                                                                            Param.new("int","param5",false,true,true)],false))
                 |> Ast.addFunction(Func.new(ReturnType.new("int",false),"function2",[Param.new("Namespace2::Data","data",false,true,true)],true))
                 |> Ast.setHasReachedStop(true)


     assert ast === model_ast


  end



end
