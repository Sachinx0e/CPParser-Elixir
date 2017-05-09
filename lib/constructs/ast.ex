defmodule Ast do
  @moduledoc false

  defstruct namespace: "",
            class: "",
            constructors: [],
            functions: [],
            typenames_child: [],
            typenames_parent: [],
            reached_stop: false

  def new() do
    %Ast{}
  end

  def setNamespace(ast,namespace)do
     %{ast | namespace: namespace}
  end

  def get_namespace(ast) do
    ast.namespace
  end

  def setClass(ast,class) do
    %{ast | class: class}
  end

  def get_class(ast) do
    ast.class
  end

  def addConstructor(ast,constructor) do
    constructors = [constructor | ast.constructors] |> Enum.reverse
    %{ast | constructors: constructors}
  end

  def get_constructors(ast)do
    ast.constructors
  end

  def addFunction(ast,function) do
    case Enum.any?(ast.functions,fn(func) -> Func.is_same?(func,function) end) do
      true -> ast
      false -> %{ast | functions: Misc.append_to_list(ast.functions,function)}
    end
  end

  def get_functions(ast) do
    ast.functions
  end

  def setHasReachedStop(ast,reached_stop) do
    %{ast | reached_stop: reached_stop}
  end

  def setTypeNamesChild(ast,typenames) do
    %{ast | typenames_child: typenames}
  end

  def getTypeNamesChild(ast) do
    ast.typenames_child
  end

  def setTypeNamesParent(ast,typenames) do
    %{ast | typenames_parent: typenames}
  end

  def getTypeNamesParent(ast) do
    ast.typenames_parent
  end

  def hasReachedStop?(ast) do
     ast.reached_stop
  end

end