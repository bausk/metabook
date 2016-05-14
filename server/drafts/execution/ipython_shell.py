from IPython.core.interactiveshell import InteractiveShell
from IPython.utils.capture import capture_output

class CustomShell(InteractiveShell):

    def enable_gui(self, gui=None):
        return False

shell = CustomShell.instance()


cell = """
%matplotlib notebook
import sys
from IPython.display import display, HTML, Image, SVG
import matplotlib
import matplotlib.pyplot as plt
matplotlib.use('nbagg')
import numpy as np
t = np.arange(0.0, 2.0, 0.01)
s = np.sin(2*np.pi*t)
plt.plot(t, s)
plt.xlabel('time (s)')
plt.ylabel('voltage (mV)')
plt.title('About as simple as it gets, folks')
plt.grid(True)
plt.show()
"""

c2 = """
print("hello")
display(HTML("<b>bold</b>"))
print("ERRORED", file=sys.stderr)
display(Image(url='http://history.nasa.gov/ap11ann/kippsphotos/5903.jpg'))
SVG(url='http://upload.wikimedia.org/wikipedia/en/a/a4/Flag_of_the_United_States.svg')
"""

# cell = """
# %matplotlib inline
# from bokeh.plotting import figure, output_file, show
# from bokeh.io import output_notebook
# output_notebook()
# p = figure(plot_width=400, plot_height=400)
#
# # add a circle renderer with a size, color, and alpha
# p.circle([1, 2, 3, 4, 5], [6, 7, 2, 4, 5], size=20, color="navy", alpha=0.5)
#
# # show the results
# show(p)
# """
#
# cell = """
# %matplotlib qt5
# import matplotlib
# import matplotlib.pyplot as plt
# import sys
# print(matplotlib.pyplot.get_backend())
# """

with capture_output() as out:
    result = shell.run_cell(cell)
    assert shell.ns_table['user_local'] == shell.user_ns

a = shell.user_ns.copy()

shell.reset()