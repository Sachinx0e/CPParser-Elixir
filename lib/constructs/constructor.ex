defmodule Constructor do
  @moduledoc false
  defstruct name: "", params: []

  def new(name,params) do
    %Constructor{name: name, params: params}
  end

end