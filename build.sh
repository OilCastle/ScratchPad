#!/bin/bash

# Define usage function
function usage {
  echo "Usage: $0 <command>"
  echo "Commands:"
  echo "  cfg      - Configure the project"
  echo "  build    - Build the project"
  echo "  clean    - Clean the project"
  echo "  run      - Run the project"
  echo "  dbg      - Debug the project"
  echo "  rst      - Reset the project"
  exit 1
}

# Define usage varialble
dir_build="build"
dir_current=$(pwd)
dir_build_full="$dir_current/$dir_build"

# Initialize varialble for case branch
string_cmake_gen=""
string_build=""
string_clean=""
string_run=""
string_debug=""
tool_build=""
run_target=""

# Define configuration flag varialble
flag_make="n"
flag_ninja="n"

# Define the path to the text file
file_config=".config_tool"

# Check if the file exists
if [ ! -f "$file_config" ]; then
  echo "File $file_config does not exist."
  exit 1
fi

# Read and process the configuration file
while IFS='=' read -r key value; do
  # Remove leading and trailing whitespace from key and value
  key="${key// /}"
  value="${value// /}"

  # Check if key and value are not empty
  if [ -n "$key" ] && [ -n "$value" ]; then
    case "$key" in
      "make")
        if [ "$value" = "y" ]; then
          flag_make="y"
        else
          flag_make="n"
        fi
        ;;
      "ninja")
        if [ "$value" = "y" ]; then
          flag_ninja="y"
        else
          flag_ninja="n"
        fi
        ;;
      "name")
        run_target="$value"
        ;;
      *)
        echo "Unknown configuration key: $key"
        ;;
    esac
  fi
done < "$file_config"

flag_config="$flag_make$flag_ninja"

if [ "$flag_config" = "yn" ]; then
  tool_build="make"
elif [ "$flag_config" = "ny" ]; then
  tool_build="ninja"
else
  echo "Invalid configuration"
  echo "1. Please check only one tool"
  echo "2. Please check at least one tool"
  exit 1
fi


# Check if there is exactly one argument
if [ "$#" -ne 1 ]; then
  usage
fi

# Check build directory 
if ! [ -d "$dir_build_full" ]; then
  # echo "The build directory already exists."
# else
  echo "The build directory does not exist. Creating it..."
  mkdir -p "$dir_build_full"
  if [ $? -eq 0 ]; then
    echo ">> Result : SUCCESS"
  else
    echo ">> Result : FAILED"
  fi
fi

# Change to the 'build_ninja' directory
cd "$dir_build_full"

case "$tool_build" in
  "make")
    string_cmake_gen="Unix Makefiles"
    string_build="make all"
    string_clean="make clean"
    string_run="./$run_target"
    string_debug="gdb $run_target"
    ;;
  "ninja")
    string_cmake_gen="Ninja"
    string_build="ninja"
    string_clean="ninja -t clean"
    ;;
esac
string_run="./$run_target"
string_debug="gdb $run_target"
string_reset="rm -rf $dir_build_full"

# Check the command argument
case "$1" in
  "cfg")
    sed -i "6s/.*/    ${run_target}/" "$dir_current/CMakeLists.txt"
    cmake -G "$string_cmake_gen" ..
    ;;
  "build")
    $string_build
    ;;
  "clr")
    $string_clean
    ;;
  "run")
    $string_run
    ;;
  "dbg")
    $string_debug
    ;;
  "rst")
    $string_reset
    ;;
  *)
    # Invalid command
    usage
    ;;
esac

# Change back to the previous directory
cd "$dir_current"
