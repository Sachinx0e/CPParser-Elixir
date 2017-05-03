defmodule Interface do
  @moduledoc false

  defstruct header_file: "",
            parent_header_file: "",
            ignored_constructors: [],
            ignored_functions: []


  def new() do
    %Interface{}
  end

  def set_header(interface,header) do
    %{interface | header_file: header }
  end

  def get_header(interface) do
    interface.header_file
  end

  def set_parent_header(interface,parent_header) do
    %{interface | parent_header_file: parent_header}
  end

  def get_parent_header(interface) do
    interface.parent_header_file
  end

  def add_ignored_constructor(interface, ignored_constructor) do
    %{interface | ignored_constructors: Misc.append_to_list(interface.ignored_constructors,ignored_constructor)}
  end

  def is_constructor_ignored?(interface,constructor) do
    Enum.member?(interface.ignored_constructors,constructor)
  end

  def add_ignored_function(interface, ignored_function) do
    %{interface | ignored_functions: Misc.append_to_list(interface.ignored_functions,ignored_function)}
  end

  def is_function_ignored?(interface, function) do
    Enum.member?(interface.ignored_functions,function)
  end

end