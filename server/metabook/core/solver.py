from IPython.core.interactiveshell import InteractiveShell, ExecutionResult
from dotmap import DotMap
from collections import OrderedDict

class Context(OrderedDict):
    """
    Context is a data structure that represents the incoming parameters of a cell.
    It is a two-level ordered dictionary of the form Context[port_name][source_id].
    It stores references to evaluated/updated results.
    """
    pass

class MetabookShell(InteractiveShell):
    pass
    #def enable_gui(self, gui=None):
    #    return True

class IPythonSolver(object):

    def __init__(self):
        self.shell = MetabookShell()
        self.queue = set()
        self.results = {}
        self.cells = {}

    def run_cell(self, code):
        result = self.shell.run_cell(code)
        return result

    def reset(self):
        self.cells = {}
        self.shell.reset()

    def run_stateful_cell(self, cell_id, context):

        cell = self.cells[cell_id]

        specific_context = context["in:locals"]
        assert isinstance(specific_context, dict)
        if specific_context:
            # TODO Context aggregation from different sources
            # TODO currently the last available context is used via popitem()
            self.apply_context(specific_context.popitem()[1], self.shell)
        else:
            self.shell.reset()
        if type(cell.source) is list:
            cell.source = "".join(cell.source)
        execution_result = self.shell.run_cell(cell.source)
        results_dict = self.get_context(self.shell)
        # TODO Distinction among different types of cell evaluation
        return {'out:locals': {'result': execution_result, 'state': results_dict}}

    def get_context(self, shell: InteractiveShell):
        return shell.user_ns.copy()

    def apply_context(self, context, shell: InteractiveShell):
        state_dict = context['state']
        # shell.reset()
        shell.user_ns = state_dict

    def solve_all(self, cells, links):
        # TODO
        # 1. build hash of cells
        # 2. assign links to hash, turning it into a graph-like structure
        self.reset()
        self.shell.enable_matplotlib(gui="inline")
        for cell in cells:
            cell['outPorts'] = {port: {} for port in cell['outPorts']}
            cell['inPorts'] = {port: {} for port in cell['inPorts']}
            cell['evaluated'] = False
            cell['resolved'] = False
            self.cells[cell['id']] = DotMap(cell)
            self.queue.add(cell['id'])

        for link in links:
            source_id = link['source']['id']
            source_port = link['source']['port']
            target_id = link['target']['id']
            target_port = link['target']['port']
            assert isinstance(self.cells[source_id].outPorts[source_port], dict)
            self.cells[source_id].outPorts[source_port][target_id] = target_port
            self.cells[target_id].inPorts[target_port][source_id] = source_port
            print(target_id)

        # TODO Start with arbitrary point on graph.
        # TODO Find unresolved dependencies.
        # TODO If any, move to dependencies.
        # TODO Evaluate cell using resolved dependencies.
        # TODO Store results.
        # TODO continue until all cells are evaluated.
        while self.queue:
            ev_id = self.queue.pop()
            self.resolve_cell(ev_id)

        # result = self.shell.run_cell(cells)
        return False

    def resolve_cell(self, cell_id):
        cell_input = {}
        cell = self.cells[cell_id]
        for port_name, port in cell.inPorts.iteritems():
            cell_input[port_name] = self.resolve_port(port)
        # From here, all ports are recursively resolved
        result = self.run_stateful_cell(cell_id, context=cell_input)
        self.results[cell_id] = result
        cell.evaluated = True
        if cell_id in self.queue:
            self.queue.remove(cell_id)
        return result

    def resolve_port(self, port):
        port_output = {}
        if port:
            for source_id, source_port in port.iteritems():
                if self.cells[source_id].evaluated is False:
                    port_output[source_id] = self.resolve_cell(source_id)[source_port]
                else:
                    port_output[source_id] = self.results[source_id][source_port]
        else:
            return {}
        return port_output
