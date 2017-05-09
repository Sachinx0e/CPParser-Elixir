defmodule Func do
  @moduledoc false
  defstruct return_type: %ReturnType{}, name: "",params: [], is_static?: false

  def new(return_type,name,params,is_static?) do
    %Func{return_type: return_type,name: name, params: params, is_static?: is_static?}
  end

  def name(func) do
    func.name
  end

  def params(func) do
    func.params
  end

  def setParams(func,params) do
    %{func | params: params}
  end

  def returnType(func) do
    func.return_type
  end

  def is_static?(func) do
    func.is_static?
  end

  def is_same?(func1,func2) do
    case Func.name(func1) === Func.name(func2) do
      true -> case Func.returnType(func1) === Func.returnType(func2) do
                true -> Param.is_same?(Func.params(func1),Func.params(func2))
                false -> :false
              end
      false -> :false
    end
  end

end