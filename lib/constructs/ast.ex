defmodule Ast do
  @moduledoc false

  defstruct namespace: "",
            class: "",
            parent_class: "",
            constructors: [],
            functions: [],
            reached_stop: false

  def new() do
    %Ast{}
  end

  def setNamespace(ast,namespace)do
     %{ast | namespace: namespace}
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
    functions = [function | ast.functions] |> Enum.reverse
    %{ast | functions: functions}
  end

  def get_functions(ast) do
    ast.functions
  end

  def setHasReachedStop(ast,reached_stop) do
    %{ast | reached_stop: reached_stop}
  end

  def hasReachedStop?(ast) do
     ast.reached_stop
  end

end