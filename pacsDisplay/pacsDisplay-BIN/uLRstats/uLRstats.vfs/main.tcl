## Starkit Initialization script
##
## Creator  : Tcl Dev Kit TclApp
## Created @: Thu Feb 20 17:07:52 EST 2014
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

set startup [file join $starkit::topdir lib/application/XIRL/BIN/HFHS/pacsDisplay/pacsDisplay-DEV/uLRstats1-1/uLRstats1-1.tcl]
set ::argv0 $startup
source      $startup