open_project "juniperHLS"
open_solution "solution1"

# We assume the toplevel is called HLS for now...
set_top hls

foreach f [exec ls | grep -F .cpp] {
    add_files $f -cflags "-I../jamaciaheaders/."
}

foreach f [exec ls | grep -F .h] {
    add_files $f -cflags "-I../jamaciaheaders/."
}

# Use ZC706
set_part {xc7z045ffg900-2}

# I'm not sure the clock actually matters...
create_clock -period 10 -name default

# Create some hardware
csynth_design

# And dump to ISE
export_design -format syn_dcp -description "A module for the JUNIPER project" -vendor "york.ac.uk" -version "VERSIONNUM"

exit
