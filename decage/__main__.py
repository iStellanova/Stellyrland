#!/usr/bin/env python3
import sys
# Disable bytecode generation (__pycache__)
sys.dont_write_bytecode = True

"""Allow ``python -m decage`` invocation."""
from decage.core import main

main()
