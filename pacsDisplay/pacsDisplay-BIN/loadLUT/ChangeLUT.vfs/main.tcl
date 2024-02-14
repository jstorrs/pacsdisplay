## Starkit Initialization script
##
## Creator  : Tcl Dev Kit TclApp
## Created @: Tue Jan 21 18:59:57 EST 2014
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

set startup [file join $starkit::topdir lib/application/XIRL/BIN/HFHS/pacsDisplay/pacsDisplay-DEV/loadLUT_utilities/ChangeLUT1-4.tcl]
set ::argv0 $startup
source      $startup
