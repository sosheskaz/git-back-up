import os
import unittest
from glob2 import iglob

from git_back_up.common import ChangeDirectory, BackupStrategy, GitBackUpError

class BackupStrategyTC(unittest.TestCase):
    def setUp(self):
        self.strat = BackupStrategy()
        self.testdir = os.path.dirname(__file__)
        self.filesdir = os.path.join(self.testdir, 'files')

    def testGetFiles_badSrcType_raises(self):
        with self.assertRaises(GitBackUpError):
            self.strat._get_files_to_copy(5, [], [])

    def testGetFiles_badSrcValue_raises(self):
        with self.assertRaises(GitBackUpError):
            self.strat._get_files_to_copy(self.filesdir + 'b', [], [])

    def testGetFiles_goodSrcValue_returnsAll(self):
        file_list = self.strat._get_files_to_copy(self.filesdir, [], [])
        with ChangeDirectory(self.filesdir):
            expected = [path for path in iglob('**/*') if os.path.isfile(path)]
        self.assertSetEqual(set(file_list), set(expected))

    def testGetFiles_goodSrcValueIncludeTxt_returnsTxt(self):
        file_list = self.strat._get_files_to_copy(self.filesdir, ['**/*.txt'], [])
        with ChangeDirectory(self.filesdir):
            expected = [path for path in iglob('**/*.txt') if os.path.isfile(path)]
        self.assertSetEqual(set(file_list), set(expected))

    def testGetFiles_goodSrcValueExcludeTxt_returnsB64(self):
        file_list = self.strat._get_files_to_copy(self.filesdir, [], ['**/*.txt'])
        with ChangeDirectory(self.filesdir):
            expected = [path for path in iglob('**/*.b64') if os.path.isfile(path)]
        self.assertSetEqual(set(file_list), set(expected))
    
    def tearDown(self):
        pass