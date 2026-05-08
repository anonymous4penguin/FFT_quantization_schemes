import random
import numpy as np
import matplotlib.pyplot as plt
from evaluate_design import DesignEvaluator

# NSGA-II FFT OPTIMIZER

class NSGA2FFT:

    def __init__(self,
                 population_size=60,
                 generations=25):

        self.population_size = population_size

        self.generations = generations

        self.num_stages = 10

        self.evaluator = DesignEvaluator()

    # RANDOM INDIVIDUAL

    def random_individual(self):	

        Q = [
            random.randint(1, 3)
            for _ in range(self.num_stages)
        ]

        WL = [
            random.randint(9, 16)
            for _ in range(self.num_stages)
        ]

        return {
            "Q": Q,
            "WL": WL
        }

    # INITIAL POPULATION

    def initialize_population(self):

        population = []

        for _ in range(self.population_size):

            population.append(
                self.random_individual()
            )

        return population

    # EVALUATE POPULATION

    def evaluate_population(self, population):

        evaluated = []

        for idx, individual in enumerate(population):

            print("\n===================================")

            print(
                f"Evaluating "
                f"{idx+1}/{len(population)}"
            )

            Q = individual["Q"]

            WL = individual["WL"]

            area, sqnr = self.evaluator.evaluate(
                Q,
                WL
            )

            print(f"SQNR = {sqnr:.2f} dB")

            print(f"AREA = {area:.2f} um²")

            evaluated.append({

                "Q": Q,

                "WL": WL,

                "area": area,

                "sqnr": sqnr

            })

        return evaluated

    # DOMINATION CHECK

    def dominates(self, a, b):

        better_or_equal = (
            a["sqnr"] >= b["sqnr"]
            and
            a["area"] <= b["area"]
        )

        strictly_better = (
            a["sqnr"] > b["sqnr"]
            or
            a["area"] < b["area"]
        )

        return (
            better_or_equal
            and
            strictly_better
        )

    # FAST NON-DOMINATED SORT

    def fast_non_dominated_sort(self, population):
        fronts = [[]]
        domination_count = {}
        dominated_set = {}
        rank = {}
        for p in range(len(population)):
            domination_count[p] = 0
            dominated_set[p] = []
            for q in range(len(population)):
                if self.dominates(
                    population[p],
                    population[q]
                ):

                    dominated_set[p].append(q)

                elif self.dominates(
                    population[q],
                    population[p]
                ):
                    domination_count[p] += 1
            if domination_count[p] == 0:
                rank[p] = 0
                fronts[0].append(p)

        i = 0

        while fronts[i]:
            next_front = []
            for p in fronts[i]:
                for q in dominated_set[p]:
                    domination_count[q] -= 1
                    if domination_count[q] == 0:
                        rank[q] = i + 1
                        next_front.append(q)
            i += 1
            fronts.append(next_front)
        fronts.pop()

        return fronts

    # CROWDING DISTANCE

    def crowding_distance(self, front, population):

        distance = [0] * len(front)
        objectives = ["sqnr", "area"]
        for obj in objectives:

            values = [
                population[i][obj]
                for i in front
            ]

            sorted_idx = np.argsort(values)
            distance[sorted_idx[0]] = float("inf")
            distance[sorted_idx[-1]] = float("inf")

            vmin = min(values)
            vmax = max(values)

            if vmax == vmin:
                continue

            for k in range(1, len(front)-1):

                prev_val = values[sorted_idx[k-1]]

                next_val = values[sorted_idx[k+1]]

                dist = (
                    next_val - prev_val
                ) / (vmax - vmin)

                distance[sorted_idx[k]] += dist

        return distance

    # TOURNAMENT SELECTION

    def tournament(self, population):
        a = random.choice(population)
        b = random.choice(population)
        if a["sqnr"] > b["sqnr"]:
            return a
        else:
            return b
        
    def crossover(self, p1, p2):

        point = random.randint(1, 8)
        child_Q = (
            p1["Q"][:point]
            +
            p2["Q"][point:]
        )
        child_WL = (
            p1["WL"][:point]
            +
            p2["WL"][point:]
        )
        return {
            "Q": child_Q,
            "WL": child_WL
        }

    # MUTATION

    def mutate(self, individual, mutation_rate=0.1):

        Q = individual["Q"][:]

        WL = individual["WL"][:]

        # MUTATE QUANTIZATION

        for i in range(self.num_stages):

            if random.random() < mutation_rate:

                Q[i] = random.randint(1, 3)

        # MUTATE WORDLENGTHS

        for i in range(self.num_stages):

            if random.random() < mutation_rate:

                # EARLY STAGES
                if i <= 2:

                    min_wl = 13
                    max_wl = 16

                # MIDDLE STAGES
                elif i <= 5:

                    min_wl = 11
                    max_wl = 15

                # LATE STAGES
                else:

                    min_wl = 9
                    max_wl = 13

                # MONOTONIC CONSTRAINT
                if i > 0:

                    max_wl = min(
                        max_wl,
                        WL[i - 1]
                    )

                # SAFETY FIX
                if min_wl > max_wl:
                    min_wl = max_wl

                WL[i] = random.randint(
                    min_wl,
                    max_wl
                )

        # FINAL MONOTONIC CLEANUP
        for i in range(1, self.num_stages):

            WL[i] = min(
                WL[i],
                WL[i - 1]
            )

        return {
            "Q": Q,
            "WL": WL
        }

    # CREATE OFFSPRING

    def create_offspring(self, population):

        offspring = []

        while len(offspring) < self.population_size:

            p1 = self.tournament(population)
            p2 = self.tournament(population)
            child = self.crossover(p1, p2)
            child = self.mutate(child)
            offspring.append(child)
        return offspring

    # NEXT GENERATION

    def next_generation(self, combined):

        fronts = self.fast_non_dominated_sort(
            combined
        )

        new_population = []

        for front in fronts:

            if (
                len(new_population)
                +
                len(front)
                <=
                self.population_size
            ):

                for idx in front:

                    new_population.append(
                        combined[idx]
                    )

            else:

                distances = self.crowding_distance(
                    front,
                    combined
                )

                sorted_front = sorted(

                    zip(front, distances),

                    key=lambda x: x[1],

                    reverse=True
                )

                remaining = (
                    self.population_size
                    -
                    len(new_population)
                )

                for idx, _ in sorted_front[:remaining]:

                    new_population.append(
                        combined[idx]
                    )

                break

        return new_population

    # PLOT PARETO FRONT

    def plot_pareto(self, population):

        sqnr = [
            p["sqnr"]
            for p in population
        ]

        area = [
            p["area"]
            for p in population
        ]

        plt.figure(figsize=(8,6))
        plt.scatter(area, sqnr)
        plt.xlabel("Area (um²)")
        plt.ylabel("SQNR (dB)")
        plt.title(
            "Pareto Front: Area vs SQNR"
        )

        plt.grid(True)
        plt.show()

    # RUN NSGA-II

    def run(self):

        print("\n===================================")
        print("INITIALIZING POPULATION")
        print("===================================")

        population = self.initialize_population()

        population = self.evaluate_population(
            population
        )

        # GENERATIONS

        for gen in range(self.generations):

            print("\n===================================")

            print(
                f"GENERATION {gen+1}"
            )

            print("===================================")

            offspring = self.create_offspring(
                population
            )

            offspring = self.evaluate_population(
                offspring
            )

            combined = (
                population
                +
                offspring
            )

            population = self.next_generation(
                combined
            )

        # FINAL RESULTS

        print("\n===================================")
        print("FINAL PARETO POPULATION")
        print("===================================")

        for p in population:

            print("\n---------------------------")

            print(
                f"SQNR : {p['sqnr']:.2f} dB"
            )

            print(
                f"AREA : {p['area']:.2f} um²"
            )

            print(
                f"Q    : {p['Q']}"
            )

            print(
                f"WL   : {p['WL']}"
            )

        self.plot_pareto(population)

        return population


# MAIN

if __name__ == "__main__":
    optimizer = NSGA2FFT(
        population_size=60,
        generations=25
    )

    final_population = optimizer.run()