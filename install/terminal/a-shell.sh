#!/bin/bash

# Configure the bash shell using Omakub defaults
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
cp $OMAKUB_PATH/configs/bashrc ~/.bashrc

# Load the PATH for use later in the installers
source $OMAKUB_PATH/defaults/bash/shell

[ -f ~/.inputrc ] && mv ~/.inputrc ~/.inputrc.bak
# Configure the inputrc using Omakub defaults
cp $OMAKUB_PATH/configs/inputrc ~/.inputrc
