import os
from jupyter_client.manager import start_new_kernel

km, kc = start_new_kernel(
    kernel_name="python3",
    stderr=open(os.devnull, 'w'),
    cwd="F:\\Documents\\GitHub\\metabook\\server")

message = """
import matplotlib.pyplot as plt
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

sent_msg_id = kc.execute(message)
reply = kc.get_shell_msg(sent_msg_id)
data = kc.iopub_channel.get_msg(timeout=4)
message = "plt"

