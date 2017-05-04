defmodule InterfaceParserTest do
  use ExUnit.Case

  test "parse interface source" do

    source =
    "HEADER_FILE :- /source/header.h
     PARENT_HEADER_FILE :- /source/parent_header_file.h
     IS_PARENT_TEMPLATED :- true

     IGNORE :- constructor(int param1);
     IGNORE :- constructor(std::string param1);
     IGNORE :- constructor(float param1);

     IGNORE :- void function(int param1);
     IGNORE :- void function(string param1);
    "

    interface = InterfaceParser.parse(source)

    assert Interface.get_header(interface) === "/source/header.h"
    assert Interface.get_parent_header(interface) === "/source/parent_header_file.h"
    assert Interface.is_parent_templated?(interface) === true

    assert Interface.is_ignored?(interface,"constructor(int param1);") === true
    assert Interface.is_ignored?(interface,"constructor(std::string param1);") === true
    assert Interface.is_ignored?(interface,"constructor(float param1);") === true

  end
  
end