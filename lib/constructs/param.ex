defmodule Param do
  @moduledoc false
  defstruct type_name: "", var_name: "", is_pointer: false, is_reference: false, is_const: false

  def new(type_name,var_name,is_pointer,is_reference,is_const) do
    %Param{type_name: type_name, var_name: var_name, is_pointer: is_pointer, is_reference: is_reference, is_const: is_const}
  end

end