defmodule CtemplateParserTest do
  use ExUnit.Case

  test "construct - typenames" do
    construct = CtemplateParser.get_construct("template <typename typeT, typename typeF, typename typeA, typename typeDH>")
    assert construct === :typenames
  end

  test "construct function" do
    construct = CtemplateParser.get_construct("/*F*/ virtual void function()")
    assert construct === :function
  end

  test "construct pass" do
    construct = CtemplateParser.get_construct("virtual void function()")
    assert construct === :pass
  end

  test "parse typenames parent" do
    typenames = CtemplateParser.parse_typenames("template <typename typeT, typename typeF, typename typeA, typename typeDH>")
    assert typenames === ["typeT","typeF","typeA","typeDH"]
  end

  test "parse functions" do
    func = CtemplateParser.parse_function("/*F*/ virtual typeT* testFunction(typeF param1,typeA param2)",Interface.new())
    assert func === Func.new(ReturnType.new("typeT",true),"testFunction",[Param.new("typeF","param1",false,false,false),
                                                                          Param.new("typeA","param2",false,false,false)],false)
  end

  test "update ast" do

    ast = Ast.new()
          |> Ast.setNamespace("TestNamespace")
          |> Ast.setClass("TestClass")
          |> Ast.addConstructor(Constructor.new([Param.new("long","param1",false,false,false)]))
          |> Ast.addFunction(Func.new(ReturnType.new("int",false),"test_function",[Param.new("int","param1",false,true,true)],true))
          |> Ast.addFunction(Func.new(ReturnType.new("Item",false),"get",[Param.new("Filter","filter",false,false,false)],false))
          |> Ast.setTypeNamesChild(["Item","Filter"])

    source = "
               namespace parent_namespace {
                   template <typename typeT,typename typeF>
                   class ParentClass {
                       public:
                          ParentClass(const std::string& param1, int param2, typeT* param3);

                          /*F*/ typeT* function1(typeF param1);

                          /*F*/ static int function2(const typeT& data);

                          /*F*/ typeT get(typeF filter_parent);

                       private:
                          int mPram1;
                          int mParam2;

                   };
               }
    "

    updated_ast = CtemplateParser.build_ast(ast,source,Interface.new())

    ast = Ast.addFunction(ast,Func.new(ReturnType.new("Item",true),"function1",[Param.new("Filter","param1",false,false,false)],false))
          |> Ast.addFunction(Func.new(ReturnType.new("int",false),"function2",[Param.new("Item","data",false,true,true)],true))
          |> Ast.setTypeNamesParent(["typeT","typeF"])

    assert updated_ast === ast

  end
  
end