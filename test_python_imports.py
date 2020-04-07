#!/usr/bin/env python3

import os
import sys
import ast
import argparse


def get_directories_in_path(path):
    """
    Get a list of all directories found in path
    :param path: path to use as root
    :return: list of directories
    """
    directories = []
    for root, dirs, fnames in os.walk(path):
        directories.append(os.path.normpath(root).split(os.sep)[-1])
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


def get_imports_from_file(path):
    """
    Yield every single imports made in a given file
    :param path: absolute path to the file
    :return: module name
    """
    with open(path) as fh:
        try:
            root = ast.parse(fh.read(), path)
        except (SyntaxError, UnicodeDecodeError) as e:
            print("IGNORING file: '{path}' because of error: '{error}'".format(error=e, path=path))
            # Error in python file, impossible to parse imports
            return

    for node in ast.iter_child_nodes(root):
        if isinstance(node, ast.ImportFrom):
            if node.module:
                yield node.module.split('.')[0]
            else:
                # no module found, line probably looks like something like that: `from .. import toto`
                pass
        elif isinstance(node, ast.Import):
            for n in node.names:
                yield n.name.split('.')[0]


def get_imports_from_folder(path):
    """
    Get a list of all python modules imported in path
    :param path: path to use as root
    :return: list of imported modules
    """
    modules = set()
    pfd = get_python_files_in_path(path).union(get_directories_in_path(path))
    for root, dirs, fnames in os.walk(path):
        for fname in fnames:
            if fname.endswith(".py"):
                for module in get_imports_from_file(os.path.join(root, fname)):
                    # Do not add module to list if it is a file / folder name in the project
                    for f in pfd:
                        if f == module:
                            module = None
                    if module:
                        modules.add(module)
    return list(modules)


def test_import_modules(modules):
    """
    Get:
    - a list of successfully imported modules
    - a list of unknown modules
    - a dict of requirements (module => version)
    :param modules: modules that we want to import
    :return: list of success, list of errors, dict of requirements
    """

    success = []
    errors = []
    for module in modules:
        try:
            __import__(module)
            success.append(module)
        except ModuleNotFoundError:
            errors.append(module)

    requirements = {}
    for k, v in sys.modules.items():
        try:
            package = v.__package__ or ""
            if len(package) > 0 and package in modules:
                requirements[package] = v.__version__
        except AttributeError:
            pass

    return success, errors, requirements


def main(path, dump_success, dump_errors, dump_requirements):
    """
    1 - Get a list of all modules imported in the given project path
    2 - Try to import those modules
    3 - dump (if asked for it) success, errors and requirements
    :param path: path to use as project root
    :param dump_success: if True => dumping list of successfully imported modules
    :param dump_errors: if True => dumping list of unsuccessfully imported modules
    :param dump_requirements: if True => dumping successfully imported modules as requirements (with their versions)
    :return: None
    """
    modules = get_imports_from_folder(path)
    success, errors, requirements = test_import_modules(modules)
    if dump_success:
        print("\nSUCCESS:\n{}\n\n-----".format(success))
    if dump_errors:
        print("\nERRORS:\n{}\n\n-----".format(errors))
    if dump_requirements:
        str = "\nREQUIREMENTS:\n"
        for requirement, version in requirements.items():
            str += "{requirement}=={version}\n".format(requirement=requirement, version=version)
        str += "\n-----\n"
        print(str)


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("path", help="Path to the project directory you want to check")
    arg_parser.add_argument(
        '--dump-errors',
        help="Dump list of unsuccessfully imported modules",
        action="store_true"
    )
    arg_parser.add_argument(
        '--dump-success',
        help="Dump list of successfully imported modules",
        action="store_true"
    )
    arg_parser.add_argument(
        '--dump-requirements',
        help="Dump successfully imported modules and their version (as in requirements files)",
        action="store_true"
    )
    args = arg_parser.parse_args()
    main(**vars(args))
