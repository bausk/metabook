import sys
from IPython.display import display, HTML, Image

import matplotlib.pyplot as plt
import numpy as np
t = np.arange(0.0, 2.0, 0.01)
s = np.sin(2*np.pi*t)
plt.plot(t, s)
plt.xlabel('time (s)')
plt.ylabel('voltage (mV)')
plt.title('About as simple as it gets, folks')
plt.grid(True)
plt.imshow()
display(plt.imshow())
print("hello")
display(HTML("<b>bold</b>"))
print("ERRORED", file=sys.stderr)
display(Image(url='http://history.nasa.gov/ap11ann/kippsphotos/5903.jpg'))