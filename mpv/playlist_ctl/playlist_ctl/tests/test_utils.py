import argparse
import unittest

from playlist_ctl.utils import validate_url


class TestArgs(unittest.TestCase):
    def test_valid_urls(self):
        s = "https://youtu.be/dQw4w9WgXcQ"
        surls = [s, s + "?list=PLlaN88a7y2_plecYoJxvRFTLHVbIVAOoc"]
        for su in surls:
            self.assertEqual(validate_url(su), s)

        l = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        lurls = [l, l + "&list=PLlaN88a7y2_plecYoJxvRFTLHVbIVAOoc"]
        for lu in lurls:
            self.assertEqual(validate_url(lu), l)

    def test_invalid_urls(self):
        urls = [
            "https://youtu.be/dQw4w9WgXc",
            "https://youtu.be/dQw4w9WgXcQa",
            "https://youtu.be/invalid123!",
            "https://www.youtube.com/watch?v=invalid",
            "https://www.youtube.com/watch?v=invalid&list=PLlaN88a7y2_plecYoJxvRFTLHVbIVAOoc",
        ]
        for url in urls:
            self.assertRaises(argparse.ArgumentTypeError, validate_url, url)
