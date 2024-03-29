import argparse
import time
import csv
import random
import matplotlib.pyplot as plt
import os


def get_next_core(cores, current_core):
    mode = (current_core + 1) % len(cores)
    if cores[current_core] < cores[mode]:
        return current_core
    else:
        return mode


def greedy(cores, threads_data):
    start = time.time()
    cores = [0] * cores
    order = []
    core = 0
    for thread in threads_data:
        cores[core] += thread["duration"]
        order.append(core)
        core = get_next_core(cores, core)
    
    end = time.time()
    solution = {"order": order, "value": max(cores), "time": end - start}
    return solution


def create_first_population(cores, threads_data, population_size):
    population = []
    threads = len(threads_data)
    for _ in range(population_size):
        chromosome = {"order": []}
        for _ in range(threads):
            chromosome["order"].append(random.randint(0, cores - 1))

        chromosome["value"] = fitness(chromosome, cores, threads_data)
        population.append(chromosome)
    
    return population


def fitness(chromosome, cores, threads_data):
    cores = [0] * cores
    for index, thread in enumerate(chromosome["order"]):
        cores[thread] += threads_data[index]["duration"]

    return max(cores)


def mutation(cores, chromosome, mutation_chance):
    if random.random() <= mutation_chance:
        gen = random.randint(0, len(chromosome) - 1)
        chromosome["order"][gen] = random.randint(0, cores - 1)

    return chromosome


def create_chromosome(order, cores, mutation_chance, threads_data):
    chromosome = {"order": order}
    chromosome = mutation(cores, chromosome, mutation_chance)
    chromosome["value"] = fitness(chromosome, cores, threads_data)
    return chromosome


def crossover(parent_1, parent_2, cores, mutation_chance, threads_data):
    index = random.randint(1, len(parent_1["order"]) - 2)
    order = parent_1["order"][:index] + parent_2["order"][index:]
    chromosome_1 = create_chromosome(order, cores, mutation_chance, threads_data)
    order = parent_2["order"][:index] + parent_1["order"][index:]
    chromosome_2 = create_chromosome(order, cores, mutation_chance, threads_data)
    return chromosome_1, chromosome_2


def get_best_parents(population):
    return population[0], population[1]


def get_smart_parents(population):
    probability = [1 / chromosome["value"] for chromosome in population]
    F = sum(probability)
    weights = [item / F for item in probability]
    return random.choices(population=population, weights=weights, k=2)


def draw_ga_history(title, generation, history):
    plt.figure(figsize=(25,10))
    plt.title(title, fontsize=14)
    plt.ylabel('avg solution', fontsize=16)
    plt.xlabel('generations', fontsize=16)
    plt.plot(history)
    plt.show()


def ga(cores, threads_data, population_size, mutation_chance, timeout, parent_function, draw_history=False):
    if parent_function == "best":
        p_function = get_best_parents
    elif parent_function == "smart":
        p_function = get_smart_parents
    start = time.time()
    population = create_first_population(cores, threads_data, population_size)
    population = sorted(population, key=lambda chromosome: chromosome["value"])
    history = []
    generation = 0
    while time.time() - start < timeout:
        history.append(sum(chromosome["value"] for chromosome in population) / float(len(population)))
        parent_1, parent_2 = p_function(population)
        son_1, son_2 = crossover(parent_1, parent_2, cores, mutation_chance, threads_data)
        population.append(son_1)
        population.append(son_2)
        population = sorted(population, key=lambda chromosome: chromosome["value"])
        del population[-1]
        del population[-1]
        generation += 1

    end = time.time()
    if draw_history:
        title = "population size = {}, mutation chance = {}, run time = {}".format(population_size, mutation_chance, end - start)
        draw_ga_history(title, generation, history)

    population[0]["time"] = end - start
    population[0]["generation"] = generation
    return population[0]


def arguments_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', "--cores", type=int, required=True)
    parser.add_argument('-f', "--thread_data_folder", required=True)
    parser.add_argument('-a', "--algorithm", choices=['ga', 'greedy', 'both'], required=True)
    parser.add_argument('-s', "--population_size", type=int)
    parser.add_argument('-m', "--mutation_chance", type=float)
    parser.add_argument('-p', "--parent_function", choices=['best', 'smart'])
    parser.add_argument('-d', "--draw_history", action='store_true')
    return parser.parse_args()


def main():
    args = arguments_parser()
    problems = os.listdir(args.thread_data_folder)
    f = open(args.thread_data_folder + "(" + str(args.cores) + ").csv", "w")
    writer = csv.writer(f)
    for problem in problems:
        print(problem)
        reader = csv.DictReader(open(args.thread_data_folder + "/" + problem))
        threads_data = []
        solution_data = []
        for row in reader:
            duration = float(row["duration"])
            threads_data.append({"duration": duration, "pid": row["pid"]})
        threads_data = sorted(threads_data, key=lambda thread: thread["duration"], reverse=True)
        run_time = 1
        if args.algorithm == "greedy" or args.algorithm == "both":
            greedy_solution = greedy(args.cores, threads_data)
            solution_data.append(greedy_solution["value"])
            run_time += greedy_solution["time"] * 1000

        if args.algorithm == "ga" or args.algorithm == "both":
            for _ in range(4):
                ga_solution = ga(args.cores, threads_data, args.population_size, args.mutation_chance, run_time, args.parent_function, args.draw_history)
                solution_data.append(ga_solution["value"])

        writer.writerow(solution_data)



if __name__ == '__main__':
    main()