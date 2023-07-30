import logging
from pathlib import Path
import unittest

from playlist_ctl.storage import Storage


class TestAll(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        logging.basicConfig(
            level=logging.DEBUG,
            filename="/tmp/playlist_ctl_test.log",
            format="[%(asctime)s %(levelname)s] %(message)s (%(funcName)s:%(lineno)d)",
        )
        cls.db_file = Path("/tmp/playlist_ctl_test.db")
        cls.stor = Storage(cls.db_file)
        if err := cls.stor.init_db():
            raise err

    @classmethod
    def tearDownClass(cls):
        cls.db_file.unlink(True)

    def test1_add_new(self):
        url = "https://youtu.be/dQw4w9WgXcQ"
        self.assertIsNone(self.stor.add_title(url))
        title = "Rick Astley - Never Gonna Give You Up (Official Music Video)"
        self.assertEqual(title, self.stor.select_title(url))

    def test1_add_not_found(self):
        err = self.stor.add_title("https://youtu.be/bad_request")
        self.assertIsInstance(err, Exception)

    def test2_insert_duplicate(self):
        url = "https://youtu.be/dQw4w9WgXcQ"
        self.assertIsNone(self.stor.add_title(url))
        count = len(self.stor.select_titles("%r" % url))
        self.assertEqual(count, 1)
