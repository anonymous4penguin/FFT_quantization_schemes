export DESIGN_NAME = top
export PLATFORM = nangate45
export VERILOG_FILES = ./designs/src/generated/rotator.v
export CLOCK_PORT = clk
export CLOCK_PERIOD = 10
export SDC_FILE = ./designs/src/rotator/constraint.sdc

# FLOORPLAN SETTINGS

export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.50
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN = 2
