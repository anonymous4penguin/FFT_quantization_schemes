import subprocess
import re
import csv
import os

# CONFIG

WL_LIST = list(range(9, 17))

MODES = ["BT", "BR", "HUB"]

MACROS = ["butterfly", "rotator"]

RESULT_CSV = "macro_characterization.csv"

FLOW_DIR = "/home/ihs17/OpenROAD_work/OpenROAD-flow-scripts/flow"

TEMPLATE_DIR = f"{FLOW_DIR}/designs/src/templates"

OUTPUT_DIR = f"{FLOW_DIR}/designs/src/generated"

# VERILOG LOGIC

BT_LOGIC = """
assign out1_r_comb = sum_r >>> 1;
assign out1_i_comb = sum_i >>> 1;
assign out2_r_comb = diff_r >>> 1;
assign out2_i_comb = diff_i >>> 1;
"""

BR_LOGIC = """
assign out1_r_comb = (sum_r + 1) >>> 1;
assign out1_i_comb = (sum_i + 1) >>> 1;
assign out2_r_comb = (diff_r + 1) >>> 1;
assign out2_i_comb = (diff_i + 1) >>> 1;
"""

HUB_LOGIC = """
assign out1_r_comb = (sum_r + 1) >>> 1;
assign out1_i_comb = (sum_i + 1) >>> 1;
assign out2_r_comb = diff_r >>> 1;
assign out2_i_comb = diff_i >>> 1;
"""

# GET LOGIC

def get_logic(mode):

    if mode == "BT":
        return BT_LOGIC

    elif mode == "BR":
        return BR_LOGIC

    elif mode == "HUB":
        return HUB_LOGIC

    else:
        raise ValueError("Invalid mode")

# GENERATE BUTTERFLY RTL

def generate_butterfly(WL, mode):

    template_path = f"{TEMPLATE_DIR}/butterfly_template.v"

    output_path = f"{OUTPUT_DIR}/butterfly.v"

    with open(template_path, "r") as f:
        content = f.read()

    content = content.replace(
        "WL_PLACEHOLDER",
        str(WL)
    )

    content = content.replace(
        "MODE_LOGIC",
        get_logic(mode)
    )

    with open(output_path, "w") as f:
        f.write(content)

    return output_path

# GENERATE ROTATOR RTL

def generate_rotator(WL, mode):

    template_path = f"{TEMPLATE_DIR}/rotator_template.v"

    output_path = f"{OUTPUT_DIR}/rotator.v"

    with open(template_path, "r") as f:
        content = f.read()

    content = content.replace(
        "WL_PLACEHOLDER",
        str(WL)
    )

    content = content.replace(
        "MODE_NAME",
        mode
    )

    with open(output_path, "w") as f:
        f.write(content)

    return output_path

# RUN OPENROAD

def run_openroad(design_name):

    cmd_clean = (
        f"cd {FLOW_DIR} && "
        f"make clean_all"
    )

    subprocess.run(
        cmd_clean,
        shell=True,
        check=True
    )

    cmd_run = (
        f"cd {FLOW_DIR} && "
        f"make DESIGN_CONFIG=./designs/src/{design_name}/config.mk 3_5_place_dp"
    )

    subprocess.run(
        cmd_run,
        shell=True,
        check=True
    )

# EXTRACT AREA

def get_area():

    tcl_path = f"{FLOW_DIR}/get_area.tcl"

    with open(tcl_path, "w") as f:

        f.write(
            "read_db results/nangate45/top/base/3_5_place_dp.odb\n"
        )

        f.write(
            "report_design_area\n"
        )

        f.write(
            "exit\n"
        )

    result = subprocess.run(
        ["openroad", tcl_path],
        capture_output=True,
        text=True,
        cwd=FLOW_DIR
    )

    print(result.stdout)

    match = re.search(
        r"Design area\s+([\d\.]+)",
        result.stdout
    )

    if match:
        return float(match.group(1))

    raise RuntimeError(
        "Could not extract area"
    )

# CHARACTERIZE ONE MACRO

def characterize_macro(macro, WL, mode):

    print(
        f"\nCharacterizing: "
        f"{macro} | "
        f"WL={WL} | "
        f"{mode}"
    )

    if macro == "butterfly":

        generate_butterfly(WL, mode)

        design_name = "butterfly"

    elif macro == "rotator":

        generate_rotator(WL, mode)

        design_name = "rotator"

    else:
        raise ValueError("Invalid macro")

    run_openroad(design_name)

    area = get_area(	)

    print(f"Area = {area} um^2")

    return area

# MAIN CHARACTERIZATION LOOP

def run_characterization():

    rows = []
    for macro in MACROS:
        for mode in MODES:
            for WL in WL_LIST:
                try:

                    area = characterize_macro(
                        macro,
                        WL,
                        mode
                    )
                    rows.append([
                        macro,
                        mode,
                        WL,
                        area
                    ])
                except Exception as e:
                    print(
                        f"FAILED: "
                        f"{macro} "
                        f"{mode} "
                        f"WL={WL}"
                    )
                    print(e)

    with open(
        RESULT_CSV,
        "w",
        newline=""
    ) as f:

        writer = csv.writer(f)
        writer.writerow([
            "macro",
            "mode",
            "WL",
            "area_um2"
        ])
        writer.writerows(rows)

    print(
        f"\nSaved database to "
        f"{RESULT_CSV}"
    )

# MAIN

if __name__ == "__main__":

    run_characterization()