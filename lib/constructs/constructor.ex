defmodule Constructor do
  @moduledoc false
  defstruct params: []

  def new(params) do
    %Constructor{params: params}
  end

  def get_params(constructor) do
    constructor.params
  end

end