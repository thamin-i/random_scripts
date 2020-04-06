#!/usr/bin/env python3

import os
import argparse


def clean_import_line(line, pfd):
    """
    Get a list of modules imported in current line
    :param line: line to parse
    :param pfd: list of python files and directories in project (used to remove local imports)
    :return: list of imported modules
    """
    # If one of those strings is found => line is invalid
    invalid_strings = ["(", ")", "{", "}", ":"]
    # If one of those strings is found => remove it from line
    removable_strings = ["import", " ", "\ufeff"]
    # If one of those strings is found => only keep left part of line
    end_line_strings = ["as", ".", "#"]
    # If end_line_strings in line, take only left part of line
    for item in end_line_strings:
        if item in line:
            line = line.split(item)[0]
    # Return [] if invalid string in line
    for item in invalid_strings:
        if item in line:
            return []
    # Remove 'from' from line
    if line.startswith("from"):
        line = line.split("from")[1]
        line = line.split("import")[0]
    # Remove useless strings from line
    for item in removable_strings:
        line = line.replace(item, "")
    modules = list(set(line.split(",")))
    for module in modules:
        # Remove module from list if it is a python file name or a folder name
        for f in pfd:
            if f == module:
                modules.remove(module)
                break
    return [module for module in modules if module != ""]


def get_directories_in_path(path):
    """
    Get a list of all directories found in path
    :param path: path to use as root
    :return: list of directories
    """
    directories = []
    for root, dirs, fnames in os.walk(path):
        directories.append(root.split("/")[-1])
    return set(directories)


def get_python_files_in_path(path):
    """
    Get a list of all python files found in path
    :param path: path to use as root
    :return: list of python files (without '.py' in them)
    """
    files = []
    for root, dirs, fnames in os.walk(path):
        for fname in fnames:
            if fname.endswith(".py"):
                files.append(fname.replace(".py", ""))
    return set(files)


def get_imported_modules(path):
    """
    Get a list of all python modules imported in path
    :param path: path to use as root
    :return: list of imported modules
    """
    modules = []
    pfd = get_python_files_in_path(path).union(get_directories_in_path(path))
    for root, dirs, fnames in os.walk(path):
        for fname in fnames:
            if fname.endswith(".py"):
                with open(os.path.join(root, fname), "r", encoding='utf8') as f:
                    content = f.read()
                    lines = content.split("\n")
                    for line in lines:
                        # Strip line and clean it from all remaining tabs
                        line = line.strip().replace("\t", " ")
                        if "import " in line:
                            modules = list(set(modules + clean_import_line(line, pfd)))
    return modules


def test_import_modules(modules):
    """
    Get a list of successfully imported modules and a list of errors
    :param modules: modules that we want to import
    :return: list of success, list of errors
    """
    success = []
    errors = []
    for module in modules:
        try:
            exec("import {module}".format(module=module))
            success.append(module)
        except Exception:
            errors.append(module)
    return success, errors


def main(path, dump_success):
    """
    1 - Get all imported modules
    2 - Test modules imports
    3 - Dump success (if 'dump_success') & dump errors
    :param path: path to use as root
    :param dump_success: if True => dump successfully imported modules too
    :return: None
    """
    modules = get_imported_modules(path)
    success, errors = test_import_modules(modules)
    if dump_success:
        print("SUCCESS:\n{}\n-----".format(success))
    print("ERRORS:\n{}\n".format(errors))


if __name__ == "__main__":
    # Parse command line arguments
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("path", help="Path to the project directory you want to check")
    arg_parser.add_argument(
        '--dump-success',
        help="Dump successfully imported modules too",
        action="store_true"
    )
    args = arg_parser.parse_args()
    main(args.path, args.dump_success)
