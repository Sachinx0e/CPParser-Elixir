defmodule Misc do
  @moduledoc false

  def strip(string) do
    String.replace(string," ","") |> String.replace("\n","") |> String.replace("\t","")
  end

  #check if statement is empty and if not add to list
  def check_and_add(statement,list) do
    statement = String.strip(statement)
    case String.length(statement) > 0 do
      :true -> [statement | list]
      :false -> list
    end
  end

  def parse_value(statement) do
      String.split(statement,":-") |> Enum.at(1) |> String.strip()
  end

  def append_to_list(list,value) do
      list = Enum.reverse(list)
      list = [value | list]
      Enum.reverse(list)
  end

end