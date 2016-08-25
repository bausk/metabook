# inline_puzzle.py
#
# Various attempts at making library functions work (puzzler)



class Task:
    def __init__(self, gen):
        self._gen = gen

    def step(self, value=None, exc=None):
        try:
            if exc:
                fut = self._gen.throw(exc)
            else:
                fut = self._gen.send(value)
            fut.add_done_callback(self._wakeup)
        except StopIteration as exc:
            pass

    def _wakeup(self, fut):
        try:
            result = fut.result()
            self.step(result, None)
        except Exception as exc:
            self.step(None, exc)

# ------- Example
if __name__ == '__main__':

    def patch_future(cls):
        def __iter__(self):
            if not self.done():
                yield self
            return self.result()
        cls.__iter__ = __iter__

    from concurrent.futures import Future
    patch_future(Future)

    import time
    from concurrent.futures import ThreadPoolExecutor
    pool = ThreadPoolExecutor(max_workers=8)

    def func(x, y):
        time.sleep(1)
        yield x + y
        time.sleep(1)
        yield x + y


    def do_func(x, y):
        try:
            result = yield from pool.submit(func, x, y)
            print('Got:', result)
        except Exception as e:
            print('Failed:', repr(e))

    def example4():
        '''
        Works, using yield from.  But "yield" and "yield from" both used
        '''
        def after(delay, fut):
            '''
            Run a future after a time delay.
            '''
            yield from pool.submit(time.sleep, delay)
            yield from fut

        Task(after(10, do_func(2, 3))).step()

    example4()

