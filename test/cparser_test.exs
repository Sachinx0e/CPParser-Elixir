defmodule CparserTest do
  use ExUnit.Case

  test "comment" do
    # single comment
    construct = Cparser.get_construct("//this is a comment",%Ast{})
    assert construct === :unknown

    #multi line open comment
    construct = Cparser.get_construct("/*is is a comment",%Ast{})
    assert construct === :unknown
    construct = Cparser.get_construct("*this is a comment",%Ast{})
    assert construct === :unknown
    construct = Cparser.get_construct("this is a comment*/",%Ast{})
    assert construct === :unknown

  end

  test "include" do
    construct = Cparser.get_construct("#include <iostream>",%Ast{})
    assert construct === :include
  end

  test "forward declaration" do
    construct = Cparser.get_construct("/*FD*/ namespace forward_declared {",%Ast{})
    assert construct === :unknown
  end

  test "class forward declared" do
    construct = Cparser.get_construct("class forward_declared;",%Ast{})
    assert construct === :unknown
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
    assert construct === :unknown

    #const function
    construct = Cparser.get_construct("type func(const type* var1, type var2) const;",%Ast{});
    assert construct === :unknown

  end

  test "pure virtual function" do
    construct = Cparser.get_construct("virtual type func(type var1, type var2) = 0;",%Ast{});
    assert construct === :unknown
  end

  test "virtual function" do
    construct = Cparser.get_construct("virtual type func(type var1, type var2);",%Ast{});
    assert construct === :function
  end

  test "destructor" do
    construct = Cparser.get_construct("~myclass();",%Ast{})
    assert construct === :unknown
  end


end
