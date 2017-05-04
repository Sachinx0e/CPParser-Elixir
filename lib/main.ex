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

      #read interface source
      interface_source = File.read!(Path.join(Config.get_interface_dir(config),interface_file))

      #parse interface source
      interface = InterfaceParser.parse(interface_source)

      #read the header file source
      header_source = File.read!(Path.join(Config.get_source_dir(config),Interface.get_header(interface)))

      #parse the header and build an ast
      ast = Cparser.build_ast(header_source,interface)

      #parse the parent header
      ast = case Interface.has_parent?(interface) do
        true -> parent_source = File.read!(Path.join(Config.get_source_dir(config),Interface.get_parent_header(interface)))
                case Interface.is_parent_templated?(interface) do
                    true -> CtemplateParser.build_ast(ast,parent_source,interface)
                    false -> Cparser.build_ast_parent(ast,parent_source,interface)
                end
        false -> ast
      end


      #generate java source
      java_source = JavaGenerator.generate_source(ast)

      #write to file
      java_source_file = File.open!(Path.join(Config.get_java_output_dir(config),Ast.get_class(ast) <> ".java"),[:write, :utf8])
      IO.write(java_source_file,java_source)

      #generate jni source
      jni_source = JniGenerator.generate_source(ast,Interface.get_header(interface))

      #write to file
      jni_source_file = File.open!(Path.join(Config.get_cpp_output_dir(config),Ast.get_class(ast) <> "_jni.cpp"),[:write, :utf8])
      IO.write(jni_source_file,jni_source)

    end

    def get_interface_files(interface_file_dir) do
        File.ls!(interface_file_dir)
    end

  
end