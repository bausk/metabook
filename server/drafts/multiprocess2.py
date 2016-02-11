import multiprocessing
from time import time
init = time()

def worker():
    """worker function"""
    print('Worker')
    return

print("start: ", 1000 * (time() - init))

if __name__ == '__main__':
    print("In main: ", 1000 * (time() - init))
    jobs = []
    for i in range(1):
        print("In for loop: ", 1000 * (time() - init))
        p = multiprocessing.Process(target=worker)
        print("Process init: ", 1000 * (time() - init))
        jobs.append(p)
        print("Job appended: ", 1000 * (time() - init))
        p.start()
        print("Process started: ", 1000 * (time() - init))
    print("Finished: ", 1000 * (time() - init))