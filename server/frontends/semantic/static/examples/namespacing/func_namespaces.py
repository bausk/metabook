
def f1():
    import numpy as np
    return locals()

def f2():
    import json as np
    return locals()

result1 = f1()
result2 = f2()

print(result1)

print(result2)