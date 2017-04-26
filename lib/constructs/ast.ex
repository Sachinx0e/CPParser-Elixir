defmodule Ast do
  @moduledoc false

  defstruct namespace: "",
            class: "",
            parent_class: "",
            constructors: [],
            functions: []

  def setNamespace(ast,namespace)do
     %{ast | namespace: namespace}
  end

  def setClass(ast,class) do
    %{ast | class: class}
  end

  def addConstructor(ast,constructor) do
    constructors = [constructor | ast.constructors] |> Enum.reverse
    %{ast | constructors: constructors}
  end

  def addFunction(ast,function) do
    functions = [function | ast.functions] |> Enum.reverse
    %{ast | functions: functions}
  end

end