import unittest
from counter import positive_total
class CounterTests(unittest.TestCase):
    def test_empty(self): self.assertEqual(positive_total([]), 0)
    def test_positive(self): self.assertEqual(positive_total([1, 2, 3]), 6)
    def test_negative(self):
        with self.assertRaises(ValueError): positive_total([-1])
