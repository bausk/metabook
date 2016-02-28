from __future__ import print_function

import timeit
from asq.initiators import query
import lifter
import pynq
from drafts import fakedata

setup = """

from asq.initiators import query
import lifter
import pynq
from drafts import fakedata


def test_asq(fake_data):
    return query(fake_data).where(lambda a: (a['is_active'] == True and a['eye_color'] != 'brown'))\
        .order_by(lambda a: a['age'])


def test_pynq(fake_data):
    return pynq.From(fake_data).where("item['is_active'] == True and item['eye_color'] != 'brown'")\
        .order_by('age')\
        .select_many()


def test_lifter(fake_data):
    User = lifter.models.Model('User')
    manager = User.load(fake_data)
    return manager.filter(User.is_active == True)\
        .exclude(User.eye_color == "brown")\
        .order_by('age')
"""

def time_function(func_name):
    timed_code = "context = {}(fakedata.fake)".format(func_name).strip()
    time = min(timeit.Timer(timed_code, setup=setup).repeat(3, 1000))
    print("{}: {} ms".format(func_name, int(time * 1000)))


time_function("test_asq")
time_function("test_lifter")
time_function("test_pynq")

#print(test_asq(fakedata.fake), "\n")
#print(test_lifter(fakedata.fake))
