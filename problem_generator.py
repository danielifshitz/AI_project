import argparse
import csv
import random


def arguments_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', "--prodacts", type=int, required=True)
    parser.add_argument('-l', "--low_value", type=int, default = 1)
    parser.add_argument('-u', "--upper_value", type=int, default = 100)
    parser.add_argument('-f', "--file_name", required=True)
    parser.add_argument('-s', "--start_number", type=int, default = 1)
    parser.add_argument('-e', "--end_number", type=int, default = 1)
    return parser.parse_args()


def main():
    args = arguments_parser()
    for file_number in range(args.start_number, args.end_number + 1):
        csv_file = args.file_name + "#" + str(file_number) + ".csv"
        csv_columns = ['pid','duration']
        threads = []
        for item_number in range(1, args.prodacts + 1):
            duration = random.randint(args.low_value, args.upper_value)
            threads.append({"pid": item_number, "duration": duration})

        try:
            with open(csv_file, 'w+') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=csv_columns)
                writer.writeheader()
                for data in threads:
                    writer.writerow(data)
        except IOError:
            print("I/O error") 


if __name__ == '__main__':
    main()