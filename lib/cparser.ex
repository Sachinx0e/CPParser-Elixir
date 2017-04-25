defmodule Cparser do

  #Main entry point
  def main(_args) do
    IO.puts("Hello world")
  end

  def get_construct(line,ast) when byte_size(line) > 0  do
        #remove semicolon
        line = String.replace(line, ";","")
        cond do
          #empty line
          String.length(line) === 0 -> :unknown

          #include
          String.split(line)|> Enum.at(0) === "#include" -> :include

          #forward declaration
          String.split(line) |> Enum.at(0) === "/*FD*/" -> :unknown

          #comment
          String.contains?(line,"//") ||
          String.contains?(line,"/*") ||
          String.contains?(line,"*/") ||
          String.at(line,0) === "*" -> :unknown

          #namespace
          String.split(line) |> Enum.at(0) === "namespace" -> :namespace

          #class
          String.split(line) |> Enum.at(0) === "class" && String.last(line) === "{" -> :class

          #constructor
          String.contains?(line,"(") && String.contains?(line,")") &&
          ast.class !== "" && String.split(line,"(") |> Enum.at(0) === ast.class -> :constructor

          #destructors
          String.contains?(line,"~") -> :unknown

          #pure virtual functions
          String.contains?(line,"virtual") && String.contains?(line,"=") -> :unknown

          #function
          String.contains?(line,"(") && String.contains?(line,")") ->
            cond do
              function_const?(line) -> :unknown
              true -> :function
            end

          #private
          String.contains?(line,"private:") -> :private

          #protected
          String.contains?(line,"protected:") -> :protected

          #nothing matches
          true -> :unknown

        end
  end

  defp function_const?(line) do
    words = String.split(line)
    cond do
      Enum.at(words,0) === "const" || Enum.at(words,length(words) - 1) === "const" -> :true
      true -> :false
    end

  end


end
