import tornado.web
import metabook.local.files as localfiles
import json
import uuid
import pprint

def define_format(data_json):
    try:
        fmt = data_json["metadata"]["metabook"]["format"]
        return fmt
    except KeyError:
        return "import:ipynb"


class FileFormatter:

    def __init__(self, fmt, **kwargs):

        self.formatters = {
            "import:ipynb": self._from_import_ipynb,
            "native:ipynb": self._from_native_ipynb,
            "native": self._from_native
        }

        self.newfile = kwargs['newfile']
        self.format = fmt
        self.data = kwargs['data']
        self.cells_index = {}
        self.template = {}
        self._wire_data = {}

    def id(self):
        return self._wire_data['id'] if 'id' in self._wire_data else self.data['metadata']['metabook']['id']

    def get_data(self):
        return self.formatters[self.format]()

    def update_from_wire(self, wire_data):
        self._wire_data.update(wire_data)
        self._to_native_ipynb()
        return self.data

    def _to_native_ipynb(self):
        self.data['metadata']['metabook']['id'] = self._wire_data['id']
        self.data['metadata']['metabook']['links'] = self._wire_data['links']
        self.data['metadata']['metabook']['tabs'] = self._wire_data['tabs']

        self.data['cells'] = []

        new_ipynb_cells = {}
        for cell in self._wire_data['cells']:
            assert isinstance(cell, dict)
            parsed_cell = cell.copy()
            ipynb_cell = self.cells_index[cell['id']]
            cell_id = cell['id']
            if cell['cell_type'] == 'code':
                cell['outputs'] = self._wire_data['results'][cell_id]
            else:
                try:
                    del cell['outputs']
                except KeyError:
                    pass

            ipynb_cell['source'] = parsed_cell.pop('source')
            ipynb_cell['cell_type'] = parsed_cell.pop('cell_type')
            ipynb_cell['metadata']['metabook'] = parsed_cell

            new_ipynb_cells[cell_id] = ipynb_cell
            self.data['cells'].append(ipynb_cell)

        self.cells_index = new_ipynb_cells

    def _from_import_ipynb(self):
        try:
            with open(localfiles.path_to_template()) as tpl:
                self.template = json.load(tpl)
        except EnvironmentError:
            raise tornado.web.HTTPError(404)
        tpl_metadata = self.template['metadata']['metabook']
        tpl_cell_metadata = tpl_metadata['defaults']['native:ipynb']['cell']['metadata']['metabook']
        generation_metadata = tpl_metadata['defaults']['native:ipynb']['cell_generation']
        self.data['metadata']['metabook'] = tpl_metadata

        previous_linked_cell = None
        links = []
        incremented_position = {
            'x': generation_metadata['start_x'],
            'y': generation_metadata['start_y'],
        }
        for cell in self.data['cells']:

            #copy metadata
            cell_data = cell['metadata']['metabook'] = tpl_cell_metadata.copy()

            #generate id
            cell_data['id'] = str(uuid.uuid4())

            #generate position
            incremented_position['x'] += generation_metadata['increment_x']
            incremented_position['y'] += generation_metadata['increment_y']
            cell_data['position'] = incremented_position.copy()

            #create link if needed
            if cell['cell_type'] == 'code':
                if previous_linked_cell is not None:
                    link = {
                        'id': str(uuid.uuid4()),
                        'source': {
                            'id': previous_linked_cell['metadata']['metabook']['id'],
                            'port': "out:locals"
                        },
                        'target': {
                            'id': cell['metadata']['metabook']['id'],
                            'port': "in:locals"
                        }
                    }
                    links.append(link)
                else:
                    previous_linked_cell = cell

            self.data['metadata']['metabook']['links'] = links
            self.data['metadata']['metabook']['id'] = str(uuid.uuid4())

        pprint.pprint(self.data)
        print('\nFetching data from native:ipynb\n')
        self.format = "native:ipynb"
        return self._from_native_ipynb()

    def _from_native_ipynb(self):

        self._wire_data['cells'] = []
        self._wire_data['results'] = {}
        self.cells_index = {}
        for cell in self.data['cells']:
            if self.newfile:
                cell['metadata']['metabook']['id'] = str(uuid.uuid4())
            cell_id = cell['metadata']['metabook']['id']
            self._wire_data['results'][cell_id] = cell['outputs'] if cell['cell_type'] == 'code' else {}
            self._wire_data['cells'].append(
                {
                    'source': cell['source'],
                    **cell['metadata']['metabook'],
                    'cell_type': cell['cell_type']
                }
            )
            self.cells_index[cell_id] = cell

        self._wire_data['links'] = self.data['metadata']['metabook']['links']
        self._wire_data['tabs'] = {}
        self._wire_data['id'] = str(uuid.uuid4()) if self.newfile else self.data['metadata']['metabook']['id']

        # Send dicts in wire format: {cells, links, tabs, results, metadata}
        return self._wire_data

    def _from_native(self):
        raise NotImplementedError("Native format not implemented yet")


