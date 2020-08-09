# Cparser

C++ parser written in elixir to parse C++ headers and generate corresponding JNI headers. These JNI headers can then be use to build a dynamic library to be loaded by any Java applications. The primary motivation of this project is to make it easy to reuse existing C++ codebase to build a library that can be readily used in Android applications. This project is similar to the SWIG project but is much more light weight.

## Requirements

* OS - Ubuntu 18.04
* Elixir version - 1.9

## Getting started

```
# get the deps
mix deps.get

# build the executable
mix escript.build

# execute the binary
./cparser 

```


