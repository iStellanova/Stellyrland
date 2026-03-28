import sys
# Disable bytecode generation (__pycache__)
sys.dont_write_bytecode = True

# decage - Declarative Portage

from .plugins import Plugin, File, Directory
from .core import USER, HOME
