import unittest

from counter import total


class CounterTests(unittest.TestCase):
    def test_nonnegative(self):
        self.assertEqual(total([0, 1, 2, 3]), 6)

    def test_empty(self):
        self.assertEqual(total([]), 0)

    def test_negative(self):
        with self.assertRaises(ValueError):
            total([1, -1, 2])
