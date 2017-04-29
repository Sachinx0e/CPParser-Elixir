defmodule Misc do
  @moduledoc false

  def strip(string) do
    String.replace(string," ","") |> String.replace("\n","") |> String.replace("\t","")
  end

end