defmodule ReturnType do
  @moduledoc false
  defstruct name: "", is_pointer: false, disowns_memory: false

  def new(name,is_pointer, disowns_memory \\ false) do
    %ReturnType{name: name,is_pointer: is_pointer, disowns_memory: disowns_memory}
  end

  def name(returnType) do
    case String.contains?(returnType.name,"::") do
       true -> String.split(returnType.name,"::") |> Enum.reverse() |> Enum.at(0)
       false -> returnType.name
    end
  end

  def isPointer?(returnType) do
    returnType.is_pointer
  end

  def isObject?(returnType) do
    !(returnType.name === "int" || returnType.name === "long" || returnType.name === "float" || returnType.name === "double" ||
    returnType.name === "bool" || returnType.name === "std::string" || returnType.name === "string" || returnType.name === "void" )
  end

  def set_disown_memory(returnType,disown_memory) do
    %{returnType | disowns_memory: disown_memory}
  end

  def disown_memory?(returnType) do
    returnType.disowns_memory
  end


end