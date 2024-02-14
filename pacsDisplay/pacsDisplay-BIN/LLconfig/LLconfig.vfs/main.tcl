## Starkit Initialization script
##
## Creator  : Tcl Dev Kit TclApp
## Created @: Thu Feb 20 17:07:40 EST 2014
## User     : mikef
#
# License/Origin: Michael Flynn (Commercial)
#

## ###
## Standard setup

package require starkit
starkit::startup

## ###
## Jump to wrapped application

set startup [file join $starkit::topdir lib/application/XIRL/BIN/HFHS/pacsDisplay/pacsDisplay-DEV/LLconfig1-4/LLconfig1-4.tcl]
set ::argv0 $startup
source      $startup
