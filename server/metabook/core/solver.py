from IPython.core.interactiveshell import InteractiveShell, ExecutionResult
from collections import OrderedDict
from metabook.api.format import FileFormatter
from IPython.utils.capture import capture_output


class Context(OrderedDict):
    """
    Context is a data structure that represents the incoming parameters of a cell.
    It is a two-level ordered dictionary of the form Context[port_name][source_id].
    It stores references to evaluated/updated results.
    """
    pass


class MetabookShell(InteractiveShell):
    def enable_gui(self, gui=None):
        return True


class Cell:
    def __init__(self, cell):
        self.outPorts = {port: {} for port in cell['outPorts']}
        self.inPorts = {port: {} for port in cell['inPorts']}
        self.evaluated = False
        self.source = cell['source']
        self.id = cell['id']
        self.result = {}

class ExecutionResult:
    def __init__(self):
        pass

class IPythonSolver(object):
    def __init__(self):
        self.shell = MetabookShell().instance()
        self.queue = set()
        self.results = {}
        self.cells_hash = {}

    def run_cell(self, code):
        if type(code) is list:
            code = "".join(code)
        result = self.shell.run_cell(code)
        return result

    def reset(self):
        self.cells_hash = {}
        self.shell.reset()

    def get_solvable_graph(self, cells, links):
        solvable_graph = {}
        for cell in cells:
            solvable_graph[cell['id']] = Cell(cell)
        for link in links:
            source_id = link['source']['id']
            source_port = link['source']['port']
            target_id = link['target']['id']
            target_port = link['target']['port']
            assert isinstance(solvable_graph[source_id].outPorts[source_port], dict)
            solvable_graph[source_id].outPorts[source_port][target_id] = target_port
            solvable_graph[target_id].inPorts[target_port][source_id] = source_port
        return solvable_graph

    def run_stateful_cell(self, cell, context):

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

        with capture_output() as out:
            execution_result = self.shell.run_cell(cell.source)
        results_dict = self.get_context(self.shell)
        # TODO Distinction among different types of cell evaluation
        return {'out:locals': {'result': execution_result, 'state': results_dict, 'outputs': out.outputs}}

    def get_context(self, shell: InteractiveShell):
        return shell.user_ns.copy()

    def apply_context(self, context, shell: InteractiveShell):
        state_dict = context['state']
        # shell.reset()
        shell.user_ns = state_dict

    def solve(self, cells, links, ids: list) -> dict:
        # 1. build hash of cells
        # 2. assign links to hash, turning it into a graph-like structure
        self.reset()
        # self.shell.enable_matplotlib(gui="inline")
        self.queue = set(ids)
        self.graph = self.get_solvable_graph(cells, links)
        while self.queue:
            ev_id = self.queue.pop()
            self.resolve_cell(ev_id)

        return self.results

    def update_cells(self, cells, links, ids: list):
        self.reset()
        self.queue = set(ids)
        self.graph = self.get_solvable_graph(cells, links)
        self.mark_for_update(self.queue)
        while self.queue:
            ev_id = self.queue.pop()
            self.resolve_cell(ev_id)

        # TODO Discern between new and stale results
        return self.results

    def mark_for_update(self, ids):
        for cell in self.graph:
            if cell not in ids:
                self.graph[cell].evaluated = True

    def resolve_cell(self, cell_id):
        cell_input = {}
        cell = self.graph[cell_id]
        assert isinstance(cell, Cell)
        for port_name, port in cell.inPorts.items():
            cell_input[port_name] = self.resolve_port(port)
        # From here, all ports are recursively resolved

        result = self.run_stateful_cell(cell, context=cell_input)
        self.results[cell_id] = result
        cell.evaluated = True
        if cell_id in self.queue:
            self.queue.remove(cell_id)
        return result

    def resolve_port(self, port):
        port_output = {}
        if port:
            for source_id, source_port in port.items():
                if self.graph[source_id].evaluated is False:
                    port_output[source_id] = self.resolve_cell(source_id)[source_port]
                else:
                    port_output[source_id] = self.results[source_id][source_port]
        else:
            return {}
        return port_output
