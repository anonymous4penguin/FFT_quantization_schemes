import numpy as np


class QuantizedFFT:

    def __init__(self, N=1024, Q=None, WL_vec=None, coeff_WL=16):

        self.N = N
        self.stages = int(np.log2(N))

        # Quantization type per stage
        # 1 = BT
        # 2 = BR
        # 3 = HUB
        if Q is None:
            self.Q = [3] * self.stages
        else:
            self.Q = Q

        # Wordlength per stage
        if WL_vec is None:
            self.WL_vec = [16] * self.stages
        else:
            self.WL_vec = WL_vec

        # Twiddle coefficient wordlength
        self.coeff_WL = coeff_WL

    # SATURATION
    def sat(self, x, WL):

    	INTERNAL_WL = 16
    	
    	mx = 2**(INTERNAL_WL - 1) - 1
    	mn = -2**(INTERNAL_WL - 1)
    	xr = np.clip(np.real(x), mn, mx)
    	xi = np.clip(np.imag(x), mn, mx)
    	
    	return xr + 1j * xi

    # QUANTIZATION FUNCTIONS

    def quantize_bt(self, val):

        return np.floor(val / 2)

    def quantize_br(self, val):

        return np.floor((val + 1) / 2)

    def quantize_hub_add(self, val):

        return np.floor((val + 1) / 2)

    def quantize_hub_sub(self, val):

        return np.floor(val / 2)

    # BUTTERFLY

    def butterfly(self, a, b, quant_type, WL):

        ar = np.real(a)
        ai = np.imag(a)

        br = np.real(b)
        bi = np.imag(b)

        # SUM
        sum_r = ar + br
        sum_i = ai + bi

        # DIFF
        diff_r = ar - br
        diff_i = ai - bi

        # BT

        if quant_type == 1:

            out1_r = self.quantize_bt(sum_r)
            out1_i = self.quantize_bt(sum_i)

            out2_r = self.quantize_bt(diff_r)
            out2_i = self.quantize_bt(diff_i)

        # BR

        elif quant_type == 2:

            out1_r = self.quantize_br(sum_r)
            out1_i = self.quantize_br(sum_i)

            out2_r = self.quantize_br(diff_r)
            out2_i = self.quantize_br(diff_i)

        # HUB

        elif quant_type == 3:

            out1_r = self.quantize_hub_add(sum_r)
            out1_i = self.quantize_hub_add(sum_i)

            out2_r = self.quantize_hub_sub(diff_r)
            out2_i = self.quantize_hub_sub(diff_i)

        else:
            raise ValueError("Invalid quantization type")

        out1 = out1_r + 1j * out1_i
        out2 = out2_r + 1j * out2_i

        out1 = self.sat(out1, WL)
        out2 = self.sat(out2, WL)

        return out1, out2

    # TWIDDLE FACTOR QUANTIZATION

    def quantize_twiddle(self, W):

        scale = 2**(self.coeff_WL - 2)

        Wr = np.round(np.real(W) * scale)
        Wi = np.round(np.imag(W) * scale)

        return Wr, Wi, scale

    # ROTATOR

    def rotator(self, x, angle, quant_type, WL):

        W = np.exp(1j * angle)

        C, S, scale = self.quantize_twiddle(W)

        xr = np.real(x)
        xi = np.imag(x)

        # BT / BR

        if quant_type in [1, 2]:

            rp = np.floor((xr * C - xi * S) / scale)
            ip = np.floor((xr * S + xi * C) / scale)

        # HUB

        elif quant_type == 3:

            rp = np.floor(
                (xr * C - xi * S + C / 2 - S / 2) / scale
            )
            ip = np.floor(
                (xr * S + xi * C + S / 2 + C / 2) / scale
            )

        else:
            raise ValueError("Invalid quantization type")

        out = rp + 1j * ip
        out = self.sat(out, WL)
        return out

    # SINGLE FFT STAGE

    def fft_stage(self, X, stage):

        N = self.N
        step = 2**(self.stages - stage)
        #step = 2**(stage + 1)
        half = step // 2
        quant_type = self.Q[stage]
        WL = self.WL_vec[stage]

        for k in range(0, N, step):
            for n in range(half):

                idx1 = k + n
                idx2 = k + n + half
                a = X[idx1]
                b = X[idx2]

                # Butterfly
                A, B = self.butterfly(a, b, quant_type, WL)

                # Rotator
                if stage != self.stages - 1 and n != 0:
                    angle = -2 * np.pi * n / step
                    B = self.rotator(
                        B,
                        angle,
                        quant_type,
                        WL
                    )

                X[idx1] = A
                X[idx2] = B

        return X

    # BIT REVERSE

    def bit_reverse_indices(self, n):

        bits = int(np.log2(n))

        indices = np.arange(n)

        reversed_indices = np.array([
            int(f"{i:0{bits}b}"[::-1], 2)
            for i in indices
        ])

        return reversed_indices

    # RUN FFT

    def run_fft(self, x_float):

        scale = 2**(self.WL_vec[0] - 1) - 1

        # Fixed-point conversion
        X = np.round(x_float * scale)

        # FFT stages
        for stage in range(self.stages):

            X = self.fft_stage(X, stage)

        # Rescale
        X = X / scale * (2**self.stages)
        #X = X / scale

        # Bit reversal
        rev = self.bit_reverse_indices(self.N)

        X = X[rev]

        return X

    # COMPUTE SQNR

    def compute_sqnr(self, trials=100):

        sqnr_vals = []

        for _ in range(trials):

            # Paper input generation
            theta = 2 * np.pi * np.random.rand(self.N)

            r_samp = np.sqrt(np.random.rand(self.N))

            x_float = r_samp * np.exp(1j * theta)

            # Ideal FFT
            X_ideal = np.fft.fft(x_float)

            # Quantized FFT
            X_quant = self.run_fft(x_float)

            # SQNR
            signal_power = np.sum(np.abs(X_ideal)**2)

            noise_power = np.sum(
                np.abs(X_ideal - X_quant)**2
            )

            sqnr = 10 * np.log10(signal_power / noise_power)

            sqnr_vals.append(sqnr)

        return np.mean(sqnr_vals)

# WRAPPER FUNCTION

def fft_flexible_engine(Q, WL_vec, trials=300):

    fft_engine = QuantizedFFT(
        N=1024,
        Q=Q,
        WL_vec=WL_vec,
        coeff_WL=16
    )

    sqnr = fft_engine.compute_sqnr(
        trials=trials
    )

    return sqnr

# TEST

if __name__ == "__main__":

    Q = [3] * 10
    WL_vec = [16] * 10

    fft_engine = QuantizedFFT(
        N=1024,
        Q=Q,
        WL_vec=WL_vec,
        coeff_WL=16
    )

    sqnr = fft_engine.compute_sqnr(trials=50)

    print(f"\nSQNR = {sqnr:.2f} dB\n")