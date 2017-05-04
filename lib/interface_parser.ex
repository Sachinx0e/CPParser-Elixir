defmodule InterfaceParser do
  @moduledoc false

  def parse(source) do
    #split the source
    statements = Enum.reduce(String.split(source,"\n"),[],&(Misc.check_and_add(&1,&2))) |> Enum.reverse

    #loop over statements and build config
    Enum.reduce(statements,Interface.new(),&update_interface(&1,&2))

  end

  def update_interface(statement,interface) do

     case get_construct(statement) do
       :pass -> interface

       :parent_header_file -> Interface.set_parent_header(interface,Misc.parse_value(statement))

       :header_file -> Interface.set_header(interface,Misc.parse_value(statement))

       :is_parent_templated -> Interface.set_is_parent_templated(interface,String.to_atom(Misc.parse_value(statement)))

       :disown_memory -> Interface.add_disown_memory(interface,Misc.parse_value(statement))

       :ignored -> Interface.add_ignored(interface,Misc.parse_value(statement))

       true -> interface

     end

  end

  def get_construct(statement) do

    cond do

        String.contains?(statement,"#") -> :pass

        String.contains?(statement,"PARENT_HEADER_FILE :") -> :parent_header_file

        String.contains?(statement,"HEADER_FILE :") -> :header_file

        String.contains?(statement,"IS_PARENT_TEMPLATED :") -> :is_parent_templated

        String.contains?(statement,"IGNORE :") -> :ignored

        String.contains?(statement,"DISOWN_MEMORY :") -> :disown_memory

        true -> :pass

    end

  end

end