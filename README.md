Simple fork of pacsdisplay to improve accessiblity of the tcl source (for study).

pacsdisplay is distributed as GPL but the source code are contained within starkit windows excutables which are self-contained bundles with both the code, libraries and tcl interpeter which can be cumbersome to study.

The code extracted from each *.exe can be found inside the corresponding *.vfs folder in the same directory (extracted with sdx on linux). Things that looked like external libraries/packages have been removed from the *.vfs/lib/ directories. The things were removed are stuff like tcl8, tk8, etc that get bundled into the *.exe that don't seem particularly interesting to study here.
