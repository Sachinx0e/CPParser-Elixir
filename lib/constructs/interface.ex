defmodule Interface do
  @moduledoc false

  defstruct header_file: "",
            parent_header_file: "",
            is_parent_templated?: false,
            ignored: ["void staticjson_init(staticjson::ObjectHandler* handler);"],
            disown_memory: []


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

  def has_parent?(interface) do
    interface.parent_header_file !== ""
  end

  def set_is_parent_templated(interface,is_templated) do
    %{interface | is_parent_templated?: is_templated}
  end

  def is_parent_templated?(interface) do
    interface.is_parent_templated?
  end

  def add_ignored(interface,statement) do
    %{interface | ignored: Misc.append_to_list(interface.ignored,statement)}
  end

  def is_ignored?(interface,constructor) do
    Enum.member?(interface.ignored,constructor)
  end

  def get_ignored(interface) do
    interface.ignored
  end

  def add_disown_memory(interface,function_statement) do
    %{interface | disown_memory: Misc.append_to_list(interface.disown_memory,function_statement)}
  end

  def memory_disowned?(interface,func_statement) do
    Enum.member?(interface.disown_memory,func_statement)
  end

end