import os
from typing import Iterable
from glob2 import iglob
from git_back_up.common import GitBackUpError
from git_back_up.common import ChangeDirectory

class BackupStrategy:
    def _get_files_to_copy(self, from_dir: str, include_globs: Iterable, exclude_globs: Iterable) -> Iterable:
        if not isinstance(from_dir, str):
            raise GitBackUpError('from_dir was {}, not type str'.format(type(from_dir)))
        if not isinstance(include_globs, Iterable):
            raise GitBackUpError('include_globs was {}, not type iterable'.format(type(from_dir)))
        if not isinstance(exclude_globs, Iterable):
            raise GitBackUpError('exclude_globs was {}, not type iterable'.format(type(from_dir)))
        if not os.path.isdir(from_dir):
            raise GitBackUpError('from_dir {} does not exist'.format(from_dir))
        if not isinstance(include_globs, list):
            include_globs = list(include_globs)
        if not isinstance(exclude_globs, list):
            exclude_globs = list(exclude_globs)
        if not include_globs:
            include_globs = ['**/*']

        with ChangeDirectory(from_dir):
            included = {path for include in include_globs for path in iglob(include) if os.path.isfile(path)}
            excluded = {path for exclude in exclude_globs for path in iglob(exclude) if os.path.isfile(path)}
        return included - excluded
        

    def _copy_files(self, from_dir: str, include_globs: Iterable, exclude_globs: Iterable) -> None:
        if not isinstance(from_dir, str):
            raise GitBackUpError('from_dir was {}, not type str'.format(type(from_dir)))
        if not isinstance(include_globs, Iterable):
            raise GitBackUpError('include_globs was {}, not type iterable'.format(type(from_dir)))
        if not isinstance(exclude_globs, Iterable):
            raise GitBackUpError('exclude_globs was {}, not type iterable'.format(type(from_dir)))
        if not isinstance(include_globs, list):
            include_globs = list(include_globs)
        if not isinstance(exclude_globs, list):
            exclude_globs = list(exclude_globs)
        if any(not isinstance(it, str) for it in include_globs):
            raise GitBackUpError('Parameter {} had')