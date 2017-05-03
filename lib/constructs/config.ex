defmodule Config do
  @moduledoc false
  defstruct generator_type:  "",
            interface_dir: "",
            source_dir: "",
            java_output_dir: "",
            cpp_output_dir: ""


  def new do
    %Config{}
  end

  def get_generator_type(config) do
    config.generator_type
  end

  def set_generator_type(config,generator_type) do
    %{config | generator_type: generator_type}
  end

  def set_interface_dir(config,interface_dir) do
    %{config | interface_dir: interface_dir}
  end

  def get_interface_dir(config) do
    config.interface_dir
  end

  def set_source_dir(config,source_dir) do
    %{config | source_dir: source_dir}
  end

  def get_source_dir(config) do
    config.source_dir
  end

  def set_java_output_dir(config,java_ouput_dir) do
    %{config | java_output_dir: java_ouput_dir}
  end

  def get_java_output_dir(config) do
    config.java_output_dir
  end

  def set_cpp_output_dir(config,cpp_ouput_dir) do
    %{config | cpp_output_dir: cpp_ouput_dir}
  end

  def get_cpp_output_dir(config) do
    config.cpp_output_dir
  end

end