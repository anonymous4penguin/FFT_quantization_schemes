from fft_engine import fft_flexible_engine
from area_model import FFTAreaModel

# DESIGN EVALUATOR

class DesignEvaluator:

    def __init__(self):
        self.area_model = FFTAreaModel()

    # EVALUATE DESIGN

    def evaluate(self, Q, WL_vec):

        sqnr = fft_flexible_engine(
            Q,
            WL_vec
        )
        
        area = self.area_model.compute_area(
            Q,
            WL_vec
        )

        return area, sqnr

    # FULL REPORT

    def report(self, Q, WL_vec):

        print("\nDESIGN EVALUATION")
        print("\nQuantization:")

        print(Q)
        print("\nWordlengths:")
        print(WL_vec)

        # SQNR

        sqnr = fft_flexible_engine(
            Q,
            WL_vec
        )

        print(
            f"\nSQNR = {sqnr:.2f} dB"
        )

        # AREA

        area = self.area_model.compute_area(
            Q,
            WL_vec
        )

        print(
            f"AREA = {area:.2f} um^2"
        )

        return area, sqnr


# TEST

if __name__ == "__main__":

    evaluator = DesignEvaluator()

    # Example:
    # all HUB
    # all 16-bit

    Q = [1,2,1,2,1,2,1,2,1,2]
    #Q = [3] * 10
    
    #WL_vec = [16,16,15,15,14,13,12,11,10,9]
    WL_vec = [16] * 10
    
    evaluator.report(
        Q,
        WL_vec
    )