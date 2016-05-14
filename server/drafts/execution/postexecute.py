# appropriated from https://github.com/ipython/ipython/issues/9105
from IPython.core.interactiveshell import InteractiveShell

user_ns = {'a': 1, 'b': 2}
shell = InteractiveShell.instance()


def reinitialize_user_ns():
    shell.user_ns = user_ns.copy()

shell.events.register('post_run_cell', reinitialize_user_ns)
# run once, to get started
reinitialize_user_ns()

shell.run_cell('c=a+b')
print(shell.user_ns)

shell.run_cell('c+a+b') # NameError
print(shell.user_ns)