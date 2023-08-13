#!/bin/sh

set -e

test() {
  if [ "$2" != "" ]; then
    echo "----------------------------------------"
  fi
  echo "$1"
  echo "----------------------------------------"
}

test "help"
./newchanges -h

test "version" 1
./newchanges -V

# LINK="$HOME/.vmodules/prantlf/newchanges"

# echo "----------------------------------------"
# echo "clean up"
# rm -rf "$LINK"

# test "link" 1
# ./newchanges link
# if [ ! -L "$LINK" ]; then
#   echo "link not created"
#   exit 1
# fi

# test "unlink" 1
# ./newchanges unlink
# if [ -L "$LINK" ]; then
#   echo "link not removed"
#   exit 1
# fi

echo "----------------------------------------"
echo "done"
