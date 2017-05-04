defmodule Param do
  @moduledoc false
  defstruct type_name: "", var_name: "", is_pointer: false, is_reference: false, is_const: false

  def new(type_name,var_name,is_pointer,is_reference,is_const) do
    %Param{type_name: type_name, var_name: var_name, is_pointer: is_pointer, is_reference: is_reference, is_const: is_const}
  end

  def typeName(param) do
    case String.contains?(param.type_name,"::") do
        true -> String.split(param.type_name,"::") |> Enum.reverse() |> Enum.at(0)
        false -> param.type_name
    end
  end

  def setTypeName(param,type_name) do
    %Param{param | type_name: type_name}
  end

  def varName(param) do
    param.var_name
  end

  def isPointer?(param) do
    param.is_pointer
  end

  def isReference(param) do
    param.is_reference
  end

  def is_const(param) do
    param.is_const
  end

  def is_object?(param) do
    !(param.type_name === "int" || param.type_name === "long" || param.type_name === "float" || param.type_name === "double" ||
    param.type_name === "bool" || param.type_name === "std::string" || param.type_name === "string")
  end

end