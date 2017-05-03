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

      Enum.each(interfaces,fn(interface) -> generate_source(Path.join(Config.get_interface_dir(config),interface))  end)

      #loop through the idf files
        #parse the idf

        #parse the c++ source

        #build the ast

        #generate the java source

        #write java source

        #generate the c++ source

        #write c++ source

    end

    def generate_source(interface_file) do

      interface_source = File.read!(interface_file)

      IO.puts(interface_source)

    end

    def get_interface_files(interface_file_dir) do
        File.ls!(interface_file_dir)
    end

  
end