
#########-#########-#########-#########-#########-#########-#########-##
#                                                                      #
#                         iqcUtil2-1.tsp                               #
#                                                                      #
#  Utility programs and                                                #
#  bindings calls to change iQC display properties:                    #
#                                                                      #
#       <KeyPress-Right>	2X magnify with same canvas size.			#
#       <KeyPress-Left>		.5 minify with 1/2 canvas size.				#
#       <KeyPress-Up>		Increase image to size 2.					#
#       <KeyPress-Down>		Decrease image to size 1.					#
#                                                                      #
#########-#########-#########-#########-#########-#########-#########-##

#**********************************************************************
proc ConCat args {
	regsub -all {[      \.]+} $args . args
	return $args
}
#**********************************************************************
# Utility procedures to handle scrolling
# (modified from Pg. 393 of B.Welch)
proc CanvasMark { x y can} {
	global canvasX canvasY
#	... Map from view coords to canvas coords
	set canvasX  $x
	set canvasY  $y
}
#
proc CanvasDrag { x y can } {
	global canvasX canvasY
#	... Map from view coords to canvas coords
	set X  $x
	set Y  $y
#	... move the canvas
	set dx [expr int($canvasX - $X)]
	set dy [expr int($canvasY - $Y)]
	$can xview scroll $dx units
	$can yview scroll $dy units
#	... save the new canvas coords
	set canvasX $x
	set canvasY $y
}
#**********************************************************************
# Utility to get the position of a window
proc windowGeom {win} {
	global winPosX winPosY
	set geom [wm geometry $win]
	set first [string first + $geom]
	set last [string last + $geom]
	set length [string length $geom]
	set winPosX [string range $geom [expr $first+1] [expr $last-1]]
	set winPosY [string range $geom [expr $last+1] $length]
}
#**********************************************************************
# Procedure to change image size.
proc changeImgSize {direction} {

	global imgSize
	global sizes
	# Load all the widths/heights based on the number of sizes
	global wds hts

	# Determine the number of sizes
	set sizeLen [llength $sizes]

	if {$direction == "up"} {
		if {$imgSize < $sizeLen} {
			incr imgSize
			imgConfig $imgSize [lindex $wds $imgSize-1] [lindex $hts $imgSize-1]
		} elseif {$imgSize == $sizeLen} {
			;# ignore up request if already max size
		} else {
			puts "ERROR - unrecognized imgSize in changeImgSize"
		}
	} elseif {$direction == "down"} {
		if {$imgSize > 1} {
			incr imgSize -1
			imgConfig $imgSize [lindex $wds $imgSize-1] [lindex $hts $imgSize-1]
			changeWinSize down ; # Enforce a small window size for the smaller image
		} elseif {$imgSize == 1} {
			;# ignore down request if already size 1
		} else {
			puts "ERROR - unrecognized imgSize in changeImgSize"
		}
	} else {
		puts "ERROR - unrecognized parameter in changeImgSize call"
	}
}
proc imgConfig {size scrollSizeX scrollSizeY} {
	global can
	$can configure \
		-scrollregion [list 0 0 $scrollSizeX $scrollSizeY]
	$can raise imgS$size
	$can raise help
}
#**********************************************************************
# Procedure to change window size.
proc changeWinSize {direction} {

	global winSize
	global sizes
	global wds hts
	global imgSize
	
	# Determine the number of sizes
	set sizeLen [llength $sizes]

	if {$direction == "up"} {	
		if {$winSize < $sizeLen} {
			incr winSize
			winConfig $winSize [lindex $wds $winSize-1] [lindex $hts $winSize-1]
			set imgSize $winSize ; # Set imgSize for bindings
		} elseif {$winSize == $sizeLen} {
			;# ignore up request if already max size
		} else {
			puts "ERROR - unrecognized winSize in changeWinSize"
		}
	} elseif {$direction == "down"} {
		if {$winSize > 1} {
			incr winSize -1
			winConfig $winSize [lindex $wds $winSize-1] [lindex $hts $winSize-1]
			set imgSize $winSize ; # Set imgSize for bindings
		} elseif {$winSize == 1} {
			;# ignore up request if already min size
		} else {
			puts "ERROR - unrecognized winSize in changeWinSize"
		}
	} else {
		puts "ERROR - unrecognized parameter in changeWinSize call"
	}
}
proc winConfig {size canSizeX canSizeY} {

	global iqc can

	$can configure \
		-height           $canSizeY \
		-width            $canSizeX
	set dimX  [expr $canSizeX  + 23]
	set dimY  [expr $canSizeY  + 23]
	wm geometry $iqc ${dimX}x${dimY}
	wm maxsize  $iqc $dimX $dimY
	$can raise imgS$size
	$can raise help
}
#**********************************************************************
# Procedure to load images
proc loadImg {} {
	global imgs img_path limgs sizes
	# Load all the imgX file names
	for {set i 1} {$i <= [llength $imgs]} {incr i} {
		global img$i
	}
	global credit
	global imgSize imgType
	global can 
	
	# Prepare the imgFile names and put in a list
	for {set i 1} {$i <= [llength $sizes]} {incr i} {
		# Set an index for image based on the number of sizes and the imgType
		set imgInd [expr ($imgType-1)*[llength $sizes]+$i-1]
		if {$i == 1} {
			set imgFiles [file join $img_path [lindex $limgs $imgInd]]
		} else {
			lappend imgFiles [file join $img_path [lindex $limgs $imgInd]]
		}
	}		

	# Put each image on the canvas for a given size
	set j 1
	foreach imgFile $imgFiles {
		image create photo iQCs$j -palette 256
		iQCs$j read $imgFile -format png
		$can create image 0 0            \
						 -image iQCs$j    \
						 -anchor nw      \
						 -tag imgS$j
		$can create text  [expr 90 * [lindex $sizes $j-1]/1024] 0    \
						 -font "arial 8" \
						 -fill grey40    \
						 -justify left   \
						 -anchor nw      \
						 -text $credit   \
						 -tag imgS$j
		incr j
	}

	$can raise imgS$imgSize
	$can raise help
}

# procedure to change an image
proc changeImg {} {
	global imgType imgs
	# Proceed through the next image type
	# Based on the length of the image type list
	# Use modulo function to roll back around to 1
	set imgType [expr $imgType % [llength $imgs] + 1]
	# Load the other images
	loadImg
}

# ------------------------------------------------------------
#  procedure to put up the information message
#
proc Help_message {}  {
	global misc

		# open file for reading
		set input [file join $misc "INSTRUCTIONS.txt"]
		if [catch {open $input r} hfilein] {
			puts stderr "Cannnot open $input $hfilein"
			tk-MessageBoxMod -type ok -message "Cannot open $input $hfilein"
			return
		}
		
		set w .help
		# don't open the help if it's already open
		if { [catch {toplevel $w}] } {return}
		wm title $w "Instructions for iQC"
		wm iconname $w "Instructions"

		text $w.text -bg white \
				-height 49 -width 42  \
				-relief sunken -setgrid 1 \
				-font {Courier 10}  \
				-yscrollcommand "$w.scroll set"
			
		scrollbar $w.scroll -command "$w.text yview"

		pack $w.scroll -side right -fill y
		pack $w.text -expand yes -fill both

		foreach line [split [read $hfilein] \n] {
			$w.text insert end "$line\n"
		}
		close $hfilein

		$w.text configure -state disabled
}