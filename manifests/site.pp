import "vars.pp"
import "defines.pp"
import "exec.pp"
import "nodes/*.pp"

# Just make stdlib available for use.  This also establishes our stages
# as well.  See stdlib::stages.
include stdlib

