#!/bin/bash

# This script creates a temp directory to use it as XDG_DATA_HOME
# and then runs neovim with configuration described in the test/init.lua

# got to the directory with this script (./test/):
cd $(dirname ${BASH_SOURCE[0]})

TMPDIR=${TMPDIR:-'/tmp'}
export XDG_CONFIG_HOME=$TMPDIR'/lualine-ex/conf'
export XDG_DATA_HOME=$TMPDIR'/lualine-ex/data'

ARG=$1

if [ "$ARG" == "--prepare" ]; then

  ARG=''
  rm -rf $XDG_DATA_HOME
  rm -rf $XDG_CONFIG_HOME

fi

mkdir -p $XDG_CONFIG_HOME
mkdir -p $XDG_DATA_HOME
nvim -u init.lua --cmd 'set rtp='$XDG_DATA_HOME',$VIMRUNTIME,'$XDG_CONFIG_HOME $ARG
