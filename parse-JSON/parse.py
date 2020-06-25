#!/usr/bin/env python3

# Parse JSON and extract values from 'Section' and 'coordinates'
#  Save output in CVS with the following format:
#  Section, 1st coordinate, 2nd coordinate

import argparse
import csv
import json
from pathlib import Path


description = 'parse JSON, output CSV'
version = '%(prog)s 1.0'
usage = '%(prog)s --file JSON-file'

csv_data = []


def options():
    parser = argparse.ArgumentParser(
        usage=usage, description=description
    )
    parser.add_argument('-v', '--version', action='version', version=version)
    group = parser.add_argument_group('required arguments')
    group.add_argument(
        '-f', '--file', dest='jsonfile', default='None',
        required=True, action='store', nargs='?', help='JSON file'
    )
    args = parser.parse_args()
    return args


def main():
    args = options()
    csv_data.clear

    file = Path(args.jsonfile)
    if file.exists():
        with open(file, 'r') as json_file:
            data = json.load(json_file)
        for elem in data["features"]:
            section = elem['properties']['info']['Section']
            if elem['geometry']['type'] == 'Point':
                # plain set of coordinates, non need to cycle
                coord = elem['geometry']['coordinates']
                csv_data.append([section, coord[0], coord[1]])
            else:
                for coord in elem['geometry']['coordinates']:
                    if elem['geometry']['type'] == 'MultiLineString':
                        for multi_coord in coord:
                            csv_data.append([section, multi_coord[0], multi_coord[1]])
                    else:
                        csv_data.append([section, coord[0], coord[1]])

        # printout CSV
        outfile_name = file.stem + ".csv"
        with open(outfile_name, "w") as csv_file:
            csv_writer = csv.writer(csv_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            for line in csv_data:
                csv_writer.writerow([line[0], line[1], line[2]])

        print("DONE!! File saved as {}".format(outfile_name))
    else:
        print("File {} not found.".format(args.jsonfile))


if __name__ == '__main__':
    main()
