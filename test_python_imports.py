#!/usr/bin/env python3

import os
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


def get_imports_from_file(path):
    """
    Yield every single imports made in a given file
    :param path: absolute path to the file
    :return: module name
    """
    with open(path) as fh:
        root = ast.parse(fh.read(), path)

    for node in ast.iter_child_nodes(root):
        if isinstance(node, ast.Import):
            module = []
        elif isinstance(node, ast.ImportFrom):
            module = node.module.split('.')
        else:
            continue

        for n in node.names:
            if len(module) == 1:
                yield module[0]
            else:
                yield n.name.split('.')[0]


def get_imports_from_folder(path):
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
                for module in get_imports_from_file(os.path.join(root, fname)):
                    # Do not add module to list if it is a file / folder name in the project
                    for f in pfd:
                        if f == module:
                            module = None
                    if module:
                        modules.append(module)
    return list(set(modules))


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
    modules = get_imports_from_folder(path)
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
