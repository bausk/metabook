from multiprocessing import Process, Queue
from time import time
init = time()

print("Start: ", 1000 * (time() - init))

def my_function(q, x):
    q.put(x + 100)

if __name__ == '__main__':
    print("In main: ", 1000 * (time() - init))
    queue = Queue()
    print("Queue: ", 1000 * (time() - init))
    p = Process(target=my_function, args=(queue, 1))
    print("Proc init: ", 1000 * (time() - init))
    p.start()
    print("Proc started: ", 1000 * (time() - init))
    p.join() # this blocks until the process terminates
    print("Proc joined: ", 1000 * (time() - init))
    result = queue.get()
    print(result)
    print("Finished: ", 1000 * (time() - init))