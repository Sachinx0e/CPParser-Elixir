defmodule Func do
  @moduledoc false
  defstruct return_type: %ReturnType{}, name: "",params: []

  def new(return_type,name,params) do
    %Func{return_type: return_type,name: name, params: params}
  end


end