defmodule Main do
  @moduledoc false

    #Main entry point
    def main(args) do

      {options,_,_} = OptionParser.parse(args,switches: [config: :string,test: :string])

      #parse the global config file
      IO.inspect options

      #loop through the idf files
        #parse the idf

        #parse the c++ source

        #build the ast

        #generate the java source

        #generate the c++ source


      ast = Ast.new()
          |> Ast.setClass("test_class")
          |> Ast.addConstructor(Constructor.new([Param.new("int","param1",false,false,false)]))
          |> Ast.addConstructor(Constructor.new([Param.new("string","param1",false,false,false)]))
          |> Ast.addFunction(Func.new(ReturnType.new("void",false),"test_function",[Param.new("int","param1",false,false,false)],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_return",[],false))
          |> Ast.addFunction(Func.new(ReturnType.new("string",false),"test_function_static",[Param.new("int","param1",false,false,false)],true))


      class_src = JavaGenerator.generate_class(ast)

      IO.puts(class_src)

      case File.open("test_class.java",[:write,:utf8]) do
        {:ok,file} -> IO.puts(file,class_src)
        {:error,error_msg} -> IO.puts error_msg
      end

    end
  
end