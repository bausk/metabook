from IPython.core.interactiveshell import InteractiveShell


class IPythonSolver(object):

    def __init__(self):
        self.shell = InteractiveShell()

    def run_cell(self, code):
        result = self.shell.run_cell(code)
        return result
