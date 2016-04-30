from IPython.core.interactiveshell import InteractiveShell

shell = InteractiveShell()

result = shell.run_cell('hello = "world"')
assert shell.ns_table['user_local'] == shell.user_ns
a = shell.user_ns.copy()

result = shell.run_cell('hello')
shell.reset()
result = shell.run_cell('hello = "foo"')
result = shell.run_cell('print(hello)')
# shell.user_ns = a
shell.reset()
