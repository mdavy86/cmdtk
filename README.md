cmdtk
=====

A toolkit of commands

Create a perlbrew library and install module dependencies

#
# modules
#
module unload perl
module load perlbrew

## Create perlbrew environment

#
# choose the perl and library name
#
perlVersion=5.26.0
library=powerplant
perlbrew_lib="${perlVersion}@${library}"

#
# create the library and load, reporting as loaded
#
perlbrew lib create $perlbrew_lib
eval $(perlbrew --quiet env $perlbrew_lib)
__perlbrew_set_path

#
# populate the library with the required code
#
cpanm --installdeps --cpanfile ./cpanfile -n -q .