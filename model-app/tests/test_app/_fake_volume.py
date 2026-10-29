"""An in-memory Unity Catalog Volume behind a mocked ``ws.files``.

``FakeVolume(ws)`` wires ``download``, ``upload``, ``delete`` and
``list_directory_contents`` of a ``MagicMock`` workspace client to a dict of
``path -> bytes``, so tests that walk, copy and index Volume folders (the
import dialogs, the kickstart) see real folder contents.
"""
from __future__ import annotations

import io
import json
from types import SimpleNamespace
from typing import Any


class FakeVolume:
    def __init__(self, ws: Any):
        self.files: dict[str, bytes] = {}
        self.uploads: list[str] = []
        ws.files.download.side_effect = self._download
        ws.files.upload.side_effect = self._upload
        ws.files.delete.side_effect = self._delete
        ws.files.list_directory_contents.side_effect = self._list

    def put(self, path: str, content: Any) -> None:
        if isinstance(content, (dict, list)):
            content = json.dumps(content)
        self.files[path] = content.encode() if isinstance(content, str) else content

    def json(self, path: str) -> Any:
        return json.loads(self.files[path])

    def under(self, folder: str) -> dict[str, bytes]:
        prefix = folder.rstrip("/") + "/"
        return {p: b for p, b in self.files.items() if p.startswith(prefix)}

    def _download(self, path):
        if path not in self.files:
            raise FileNotFoundError(path)
        return SimpleNamespace(contents=io.BytesIO(self.files[path]))

    def _upload(self, path, contents, overwrite=False):
        self.files[path] = contents.read()
        self.uploads.append(path)

    def _delete(self, path):
        self.files.pop(path, None)

    def _list(self, directory):
        prefix = directory.rstrip("/") + "/"
        children: dict[str, bool] = {}
        for path in self.files:
            if path.startswith(prefix):
                head, _, rest = path[len(prefix):].partition("/")
                children[head] = children.get(head, False) or bool(rest)
        if not children:
            raise FileNotFoundError(directory)
        return [
            SimpleNamespace(name=name, is_directory=is_dir, file_size=None if is_dir else len(self.files[prefix + name]))
            for name, is_dir in sorted(children.items())
        ]
