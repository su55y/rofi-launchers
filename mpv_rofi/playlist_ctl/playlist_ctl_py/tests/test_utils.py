import argparse
import unittest

from playlist_ctl.utils import validate_url


class TestArgs(unittest.TestCase):
    def test_valid_urls(self):
        urls = [
            "https://youtu.be/dQw4w9WgXcQ",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ&pp=ygUXbmV2ZXIgZ29ubmEgZ2l2ZSB5b3UgdXA%3D",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=PLlaN88a7y2_plecYoJxvRFTLHVbIVAOoc",
        ]
        for url in urls:
            self.assertEqual(validate_url(url), url)

    def test_invalid_urls(self):
        urls = [
            "https://youtu.be/invalid123!",
            "https://www.youtube.com/watch?v=invalid",
            "https://www.youtube.com/watch?v=invalid&pp=ygUXbmV2ZXIgZ29ubmEgZ2l2ZSB5b3UgdXA%3D",
            "https://www.youtube.com/watch?v=invalid&list=PLlaN88a7y2_plecYoJxvRFTLHVbIVAOoc",
        ]
        for url in urls:
            self.assertRaises(argparse.ArgumentTypeError, validate_url, url)
