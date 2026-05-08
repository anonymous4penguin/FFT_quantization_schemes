import csv

# AREA MODEL FOR RADIX-2² SDF FFT

class FFTAreaModel:

    def __init__(self, csv_file="macro_characterization.csv"):

        self.csv_file = csv_file
        self.db = {
            "butterfly": {},
            "rotator": {}
        }

        self.load_database()

    # LOAD CSV DATABASE

    def load_database(self):

        with open(self.csv_file, "r") as f:
            reader = csv.DictReader(f)
            for row in reader:

                macro = row["macro"]
                mode = row["mode"]
                WL = int(row["WL"])
                total_area = float(row["area_um2"])

                # IMPORTANT:
                # Divide by 16 because characterization synthesized
                # 16 instantiated macros.

                single_area = total_area / 16.0

                if mode not in self.db[macro]:

                    self.db[macro][mode] = {}

                self.db[macro][mode][WL] = single_area

    # GET SINGLE BUTTERFLY AREA

    def butterfly_area(self, mode, WL):

        return self.db["butterfly"][mode][WL]

    # GET SINGLE ROTATOR AREA
    def rotator_area(self, mode, WL):

        return self.db["rotator"][mode][WL]

    # DELAY MEMORY AREA MODEL

    def delay_area(self, delay_length, WL):

        MEMORY_BIT_AREA = 5.00

        return delay_length * WL * MEMORY_BIT_AREA

    # RADIX-2² SDF STAGE DELAYS

    def stage_delay_lengths(self, N=1024):

        delays = []
        current = N // 2
        for _ in range(10):
            delays.append(current)
            current = current // 2
        return delays

    # COMPUTE TOTAL FFT AREA
    def compute_area(self, Q, WL_vec):

        total_area = 0
        delay_lengths = self.stage_delay_lengths()

        for stage in range(10):
            
            # Decode quantization
            q = Q[stage]
            if q == 1:
                mode = "BT"
            elif q == 2:
                mode = "BR"
            elif q == 3:
                mode = "HUB"
            else:
                raise ValueError(
                    f"Invalid quantization: {q}"
                )
            WL = WL_vec[stage]

            # Butterfly Area

            bf_area = self.butterfly_area(
                mode,
                WL
            )

            # Rotator Area
            # Last stage has no rotator.

            if stage == 9:
                rot_area = 0

            else:
                rot_area = self.rotator_area(
                    mode,
                    WL
                )

            # Delay Memory Area

            mem_area = self.delay_area(
                delay_lengths[stage],
                WL
            )

            # Stage Total

            stage_area = (
                bf_area
                +
                rot_area
                +
                mem_area
            )

            total_area += stage_area

        return total_area

    # DETAILED REPORT

    def report(self, Q, WL_vec):

        total_area = 0

        delay_lengths = self.stage_delay_lengths()

        print("\nFFT AREA REPORT")

        for stage in range(10):
            q = Q[stage]
            if q == 1:
                mode = "BT"
            elif q == 2:
                mode = "BR"
            elif q == 3:
                mode = "HUB"
            WL = WL_vec[stage]

            bf_area = self.butterfly_area(
                mode,
                WL
            )

            if stage == 9:
                rot_area = 0
            else:
                rot_area = self.rotator_area(
                    mode,
                    WL
                )

            mem_area = self.delay_area(
                delay_lengths[stage],
                WL
            )

            stage_area = (
                bf_area
                +
                rot_area
                +
                mem_area
            )

            total_area += stage_area

            print(
                f"\nStage {stage+1}"
            )

            print(
                f"Mode        : {mode}"
            )

            print(
                f"WL          : {WL}"
            )

            print(
                f"Butterfly   : {bf_area:.2f} um^2"
            )

            print(
                f"Rotator     : {rot_area:.2f} um^2"
            )

            print(
                f"Delay Mem   : {mem_area:.2f} um^2"
            )

            print(
                f"Stage Total : {stage_area:.2f} um^2"
            )

        print(
            f"TOTAL FFT AREA = "
            f"{total_area:.2f} um^2"
        )

    # SIMPLE TEST

if __name__ == "__main__":

    Q = [3] * 10
    WL_vec = [16] * 10
    area_model = FFTAreaModel()

    total_area = area_model.compute_area(
        Q,
        WL_vec
    )
    area_model.report(
        Q,
        WL_vec
    )