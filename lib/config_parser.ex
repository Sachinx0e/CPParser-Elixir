defmodule ConfigParser do
  @moduledoc false

  def parse_config(source) do
    #split the source
    statements = Enum.reduce(String.split(source,"\n"),[],&(check_and_add(&1,&2))) |> Enum.reverse

    #loop over statements and build config
    Enum.reduce(statements,Config.new(),&update_config(&1,&2))

  end

  defp update_config(statement,config) do

    case get_construct(statement) do

      :generator_type -> Config.set_generator_type(config,parse_value(statement))

      :source_dir -> Config.set_source_dir(config,parse_value(statement))

      :java_output_dir -> Config.set_java_output_dir(config,parse_value(statement))

      :cpp_output_dir -> Config.set_cpp_output_dir(config,parse_value(statement))

      :pass -> config

    end

  end

  def get_construct(statement) do

    cond do

        String.contains?(statement,"#") -> :pass

        String.contains?(statement,"generator_type :") -> :generator_type

        String.contains?(statement,"source_dir :") -> :source_dir

        String.contains?(statement,"java_output_dir :") -> :java_output_dir

        String.contains?(statement,"cpp_output_dir :") -> :cpp_output_dir

        true -> :pass

    end

  end

  #check if statement is empty and if not add to list
  defp check_and_add(statement,list) do
    statement = String.strip(statement)
    case String.length(statement) > 0 do
      :true -> [statement | list]
      :false -> list
    end
  end


  defp parse_value(statement) do
      String.split(statement,":") |> Enum.at(1) |> String.strip()
  end



end