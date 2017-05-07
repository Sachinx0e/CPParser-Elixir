defmodule Main do
  @moduledoc false

    #Main entry point
    def main(args) do

      {options,_,_} = OptionParser.parse(args,switches: [config: :string,test: :string])

      #parse the global config file
      #IO.inspect options

      #read the config file
      config_file = options[:config]
      source = File.read!(config_file)

      #parse the config
      config = ConfigParser.parse_config(source)

      #get the list of interface files
      interfaces = get_interface_files(Config.get_interface_dir(config))

      #delete and create the sources directory
      File.rm_rf(Config.get_java_output_dir(config))
      File.mkdir_p(Config.get_java_output_dir(config))
      File.rm_rf(Config.get_cpp_output_dir(config))
      File.mkdir_p(Config.get_cpp_output_dir(config))

      Enum.each(interfaces,fn(interface) -> generate_source(config,interface)  end)

      #loop through the idf files
        #parse the idf

        #parse the c++ source

        #build the ast

        #generate the java source

        #write java source

        #generate the c++ source

        #write c++ source

    end

    def generate_source(config,interface_file) do

      IO.puts("*************************#{interface_file}************************************")

      #read interface source
      interface_file = Path.join(Config.get_interface_dir(config),interface_file)
      interface_source = File.read!(interface_file)

      #parse interface source
      IO.puts("Parsing " <> interface_file)
      interface = InterfaceParser.parse(interface_source)

      #read the header file source
      header_file = Path.join(Config.get_source_dir(config),Interface.get_header(interface))
      header_source = File.read!(header_file)

      #parse the header and build an ast
      IO.puts("Parsing " <> header_file)
      ast = Cparser.build_ast(header_source,interface)

      #parse the parent header
      ast = case Interface.has_parent?(interface) do
        true -> parent_header_file = Path.join(Config.get_source_dir(config),Interface.get_parent_header(interface))
                parent_source = File.read!(parent_header_file)
                IO.puts("Parsing parent " <> parent_header_file)
                case Interface.is_parent_templated?(interface) do
                    true -> CtemplateParser.build_ast(ast,parent_source,interface)
                    false -> Cparser.build_ast_parent(ast,parent_source,interface)
                end
        false -> ast
      end


      #generate java source
      java_source = JavaGenerator.generate_source(ast)

      #write to file
      java_source_file_path = Path.join(Config.get_java_output_dir(config),Ast.get_class(ast) <> ".java")
      java_source_file = File.open!(java_source_file_path,[:write, :utf8])
      IO.write(java_source_file,java_source)
      IO.puts("Generated " <> java_source_file_path)

      #generate jni source
      jni_source = JniGenerator.generate_source(ast,Interface.get_header(interface))

      #write to file
      jni_source_file_path=Path.join(Config.get_cpp_output_dir(config),Ast.get_class(ast) <> "_jni.cpp")
      jni_source_file = File.open!(jni_source_file_path,[:write, :utf8])
      IO.write(jni_source_file,jni_source)
      IO.puts("Generated " <> jni_source_file_path)

      #space
      IO.puts("")

    end

    def get_interface_files(interface_file_dir) do
        File.ls!(interface_file_dir)
    end

  
end