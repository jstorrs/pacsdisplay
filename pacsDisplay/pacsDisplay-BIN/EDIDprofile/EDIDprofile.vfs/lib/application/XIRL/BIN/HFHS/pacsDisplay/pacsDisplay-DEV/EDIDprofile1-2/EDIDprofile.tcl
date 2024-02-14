###########################################################################
#                    EDIDprofile.tcl                                     #
#  Written by:                                                            #
#    Michael J. Flynn (mikef@rad.hfh.edu)                                 #
#                                                                         #
#  X-ray Imaging Lab, Henry Ford Health Systems, Detroit, MI              #
#  Nuclear Engineering and Radiological Sciences, Univ. of Michigan       #
#                                                                         #
#  This program uses the getEDID.cpp program to access and parse the EDID #
#  strings that are read from monitors and stored in Windows registry.    #
#  The getEDID program is invoked successively on 6 display numbers.      #
#  The results for those numbers with successful replies are reported     #
#  in an ascii file as a table.                                           #
#                                                                         #
#       Copyright:       Xray Imaging Research Laboratory                 #
#                               Henry Ford Health System                  #
#                               Detroit, MI                               #
#                                                                         #
#       Vers 1.0  OCT  2000                                               #
#                                                                         #
#       Vers 1.1  JAN  2013                                               #
#                                                                         #
#       Vers 1.2  DEC  2013                                               #
#                            - Selects and makes a save directory.        #
#                              Initial directory set in config file.      #
#                            - Change name of output file.                #
#                            - TK window is now withdrawn.                #
#                              Only the directory select window is shown. #
#                            - dumpEdid replies now sent to log file.     #
#                              Application runs without the console.      #
#                            - Asks to view at the end.                   #
#                            - Reorganized tables for array size and      #
#                              added newlines for readability.            #
###########################################################################

wm withdraw .   ;# No app window, just the directory select window.

set wrapHome [file dirname [info script]] ;# used to wrap script

source [file join $wrapHome EDIDprofile-proc.tsp]   ;# wrap with *.tcl
source [file join $wrapHome xirlDefs-v06.tsp]       ;# wrap with *.tcl

source EDIDprofile-config.txt                       ;# DON'T wrap

# ----------------------------------------------------------------------
# Workstation name and output file

set hostname  [info hostname]
set date      [clock format [clock seconds] -format %Y%m%d]
set outFILE   profile-${hostname}_${date}.txt

#--- save directory aligned with lumResponse code
set saveDir  [tk_chooseDirectory \
                   -initialdir $lumFilePath \
                   -title "CHOOSE WORKSTATION SAVE DIRECTORY" ]
if {$saveDir eq ""} {
	puts "Cancel from directory select, quiting"
	exit
} else {
	set saveDir  [file join $saveDir ${hostname} ]
}
file mkdir  $saveDir

set outFID [open [file join $saveDir $outFILE       ] w]
set outLOG [open [file join $logDir  LOG_EDIDprofile.txt] w]

# ----------------------------------------------------------------------
# System profile, regGet procedures is in EDIDprofile-proc.tsp

set compManf  [regGet "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\BIOS"                "SystemManufacturer" ]
set compModel [regGet "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\BIOS"                "SystemProductName"  ]
set cpu0      [regGet "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0" "ProcessorNameString"]
set cpu1      [regGet "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\1" "ProcessorNameString"]
set cpu2      [regGet "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\2" "ProcessorNameString"]
set cpu3      [regGet "HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\3" "ProcessorNameString"]

puts $outFID "\n#  System Profile\n#[string repeat - 32]"
puts $outFID "Hostname:    $hostname"
puts $outFID "Date:        $date\n"
puts $outFID "Manf:        [string map {" " ""} $compManf]"
puts $outFID "Model:       [string map {" " ""} $compModel]\n"
puts $outFID "CPU_0:       [string map {" " ""} $cpu0]"
puts $outFID "CPU_1:       [string map {" " ""} $cpu1]"
puts $outFID "CPU_1:       [string map {" " ""} $cpu2]"
puts $outFID "CPU_1:       [string map {" " ""} $cpu3]"

# ----------------------------------------------------------------------
# Build the table lines

set tableLines [initEdidTable] ;# total labels defined

set tableList [ list dNum    ddID    ddDesc  descrp     \
                     longSN  week    year               \
                     sizeHmm sizeVmm                    \
                     natCol  curCol  natRow  curRow     \
                     psizeH  psizeV                     \
                     order   Lmax    iQC                ]

for {set i 1} {$i <= $maxDisplayNum} {incr i} {
	dumpEdid $i
	puts $outLOG "$i: $edidError($i,code) - $edidError($i,string)"
	if {$edidError($i,code) == 0} {
		foreach p $tableList {
			append edidTable($p) [ format %20s $edid($i,$p) ]
		}
	}
}
# ----------------------------------------------------------------------
# Print Display profile

set tableList [ list dNum    ddID    ddDesc  descrp     \
                     longSN  week    year               \
                     sizeHmm sizeVmm                    \
                     natCol  curCol  natRow  curRow     \
                     psizeH  psizeV                     \
                                                        ]

puts $outFID "\n#  Display Profile\n#[string repeat - 32]"
foreach p $tableList {
	puts $outFID $edidTable($p)
}

# ----------------------------------------------------------------------
# Grayscale profile

set tableList [list order]
puts $outFID "\n#  Grayscale Profile\n#[string repeat - 32]"
foreach p $tableList {
	puts $outFID $edidTable($p)
}

close $outFID
close $outLOG
# ----------------------------------------------------------------------
# Ask to show the profile.

set textmsg "$outFILE saved to\n\n"
append textmsg "${saveDir}\n\n"
append textmsg "Do you want to view the file?"

set answer [tk_messageBox -type yesno -message $textmsg]
if {$answer == "yes"} {
	if {[catch {exec notepad [file join $saveDir $outFILE       ]} fid]} {
		set msg "Error opening logfile with notepad\n$fid"
		tk-MessageBoxMod -message $msg -type ok -icon warning -title "WARNING"
	}
}

# ----------------------------------------------------------------------

exit


