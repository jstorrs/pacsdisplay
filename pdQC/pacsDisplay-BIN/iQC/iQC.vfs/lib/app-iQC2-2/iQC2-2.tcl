package provide app-iQC2-2 1.0


#########-#########-#########-#########-#########-#########-#########-##
#                                                                      #
#                         iQC.tcl                                      #
#                                                                      #
#  Display iQC test pattern at full size with pan control              #
#  Image files should be in the same directory at this script.         #
#																		#
#	v2.1 - NB - Apr 2021	Update with additional test patterns		#
#							Improve comments							#
#							Remove img package dependencies				#
#	v2.2 - NB - Apr 2021	Update with addition sizes					#
#							Extend to allow any number of imgs, sizes	#
#                                                                      #
#########-#########-#########-#########-#########-#########-#########-##

set title "iQC v2.2 - Image Quality Control"

# -----------------------------------------------------------------------
#console show

# get home directory to support wrapping with tclApp
set home [file dirname [info script]]

# load tcl scripts for support procs
source   [file join $home tcl iqcDefs.tsp]
source   [file join $home tcl iqcUtil2-2.tsp]

# set directory for misc files (instructions, etc.)
set misc [file join $home misc]

# Set image variables for the image files and initialize the variable type
set img_path [file join $home images]

# Set sizes
set sizes {1024 1536 2048}
# Populate a list of wds, hts
foreach size $sizes {
	lappend wds $size
	lappend hts $size
}

# Create a list of images. The name should follow name_size.png 
set imgs {pQC sQC}
foreach img $imgs {
	foreach size $sizes {
		lappend limgs [join [list $img _ $size .png] ""]
	}
}

# Initialize the image type
set imgType 1

# initialize info value
set info	0

# -----------------------------------------------------------------------
# configuration initial parameters
set credit "pacsDisplay, Henry Ford Health System, Copyright 2021"

# Initialize imgSize, winSize, ht, wd
set imgSize 1
set winSize 1
set wd [lindex $wds $imgSize-1]; set ht [lindex $hts $imgSize-1]

# Initialize the canvas size and scrollable areas
# Initialize the canvas size and scrollable areas
set canWidth     $wd
set scrollWidth  $wd
set canHeight    $ht
set scrollHeight $ht
# -----------------------------------------------------------------------
# 
# Initialize the grid naming with a base "iqc" variable with value "."
set iqc .
# Set the title of the window using the variable established at the beginning of this script
# wm is the windows manager
wm title $iqc $title
# name the icon for the window
wm iconname $iqc "iQC"
# restrict the maximum size of the window with a padding of 25
wm maxsize  $iqc [expr $canWidth  + 23] \
                 [expr $canHeight + 23]

# -----------------------------------------------------------------------
# create canvas and scroll control frame
# ConCat calls the iqcUtil script to concatenate the arguments with "." as a delimiter

set grid    [ConCat $iqc grid]
frame $grid
set vscroll [ConCat $grid vscroll]
set hscroll [ConCat $grid hscroll]
set can     [ConCat $grid can]

# create the canvas with the variables/parameters above
canvas $can \
	-scrollregion [list 0 0 $scrollWidth $scrollHeight] \
	-yscrollcommand [list $vscroll set]          \
	-xscrollcommand [list $hscroll set]          \
	-yscrollincrement 1          \
	-xscrollincrement 1          \
	-relief           flat       \
	-borderwidth      0          \
	-confine          1          \
	-height           $canHeight \
	-width            $canWidth  \
	-cursor           tcross
bind $can <Button-1>  {CanvasMark %x %y %W} ;# canvas pan binding.
bind $can <B1-Motion> {CanvasDrag %x %y %W}	;# action when clicking will drag around

scrollbar $vscroll -command [list $can yview] \
                   -orient vertical           \
                   -width 15
scrollbar $hscroll -command [list $can xview] \
                   -orient horizontal         \
                   -width 15
pack $grid -expand yes -fill both

grid rowconfig    $grid 0 -weight 1 -minsize 0
grid columnconfig $grid 0 -weight 1 -minsize 0
grid $can -padx 1 -in $grid -pady 1 \
    -row 0 -column 0 -rowspan 1 -columnspan 1 -sticky news
grid $vscroll -in $grid -padx 1 -pady 1 \
    -row 0 -column 1 -rowspan 1 -columnspan 1 -sticky news
grid $hscroll -in $grid -padx 1 -pady 1 \
    -row 1 -column 0 -rowspan 1 -columnspan 1 -sticky news
	
# --- > Create the help icon in the upper right
#image create photo help -file [file join $home help.bmp]
$can create text	12 12					\
                    -text ?					\
					-font {courier 14 bold}	\
					-fill grey70			\
					-activefill grey100		\
                    -tags help
$can bind help  <Button-1> {Help_message}

# -----------------------------------------------------------------------
# load both initial images. displayed images is controlled by raising the one
# of interest to the top level.

loadImg

# -----------------------------------------------------------------------
# Mag and minify window

bind $can <KeyPress-Up>    {changeImgSize up  }
bind $can <KeyPress-Down>  {changeImgSize down}

bind $can <KeyPress-Right> {changeWinSize up  }
bind $can <KeyPress-Left>  {changeWinSize down}

# -----------------------------------------------------------------------
# Change image

bind $can <Button-3> {changeImg}
