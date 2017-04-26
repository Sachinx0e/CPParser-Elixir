defmodule ReturnType do
  @moduledoc false
  defstruct name: "", is_pointer: false

  def new(name,is_pointer) do
    %ReturnType{name: name,is_pointer: is_pointer}
  end

end