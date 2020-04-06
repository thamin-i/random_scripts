### Summary
- [introduction](#INTRODUCTION)
- [test_python_imports](#TEST_PYTHON_IMPORTS)
____
### INTRODUCTION
_This repository contains various homemade scripts_
____
### TEST_PYTHON_IMPORTS
_This script is useful in big python projects when you want to check that all your imported modules are available in your environment_  
- You can access the help by launching `python test_python_imports.py --help`:  
```shell script
usage: test_python_imports.py [-h] [--dump-success] path

positional arguments:
  path            Path to the project directory you want to check

optional arguments:
  -h, --help      show this help message and exit
  --dump-success  Dump successfully imported modules too
```
- An example of use could be:  
```shell script
$>python test_python_imports.py "/tmp/random_scripts" --dump-success
    SUCCESS:
    ['os', 'argparse']
    -----
    ERRORS:
    []
```
____