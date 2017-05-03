defmodule ConfigParserTest do
  use ExUnit.Case

  test "parse config for java" do

    config_src = "
    #set the generator type
    generator_type :- java

    #interface dir
    interface_dir :- /home/interface

    #source dir
    source_dir :- /home/source

    #out_put dirs
    java_output_dir :- /home/java/output
    cpp_output_dir :- /home/cpp/output
    "

    config = ConfigParser.parse_config(config_src)

    generator_type = Config.get_generator_type(config)
    assert generator_type === "java"

    interface_dir = Config.get_interface_dir(config)
    assert interface_dir === "/home/interface"

    source_dir = Config.get_source_dir(config)
    assert source_dir === "/home/source"

    java_output_dir = Config.get_java_output_dir(config)
    assert java_output_dir === "/home/java/output"

    cpp_output_dir = Config.get_cpp_output_dir(config)
    assert cpp_output_dir === "/home/cpp/output"

  end

end