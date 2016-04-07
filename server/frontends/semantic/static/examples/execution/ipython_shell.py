from IPython.core.interactiveshell import InteractiveShell

shell = InteractiveShell()

result = shell.run_cell('hello = "world"')
assert shell.ns_table['user_local'] == shell.user_ns
ipython = shell.get_ipython()
shell.reset()
