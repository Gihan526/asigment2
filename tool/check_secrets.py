#!/usr/bin/env python3
"""Check the Git index without displaying credential values."""

import re
import subprocess
import sys
from pathlib import PurePosixPath


def git(*args):
    return subprocess.check_output(['git', *args])


def main():
    blocked = []
    patterns = (
        rb'AIza[0-9A-Za-z_-]{35}',
        rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----',
    )
    for raw in git('ls-files', '-z').split(b'\0'):
        if not raw:
            continue
        name = raw.decode('utf-8', errors='surrogateescape')
        path = PurePosixPath(name)
        local_config = (
            name == 'lib/firebase_options.dart'
            or path.name in {'google-services.json', 'GoogleService-Info.plist'}
            or (path.name.startswith('.env') and path.name != '.env.example')
            or '-service-account' in path.name
            or '-firebase-adminsdk-' in path.name
        )
        if local_config:
            blocked.append((name, 'local credential/configuration file'))
            continue
        content = git('show', ':' + name)
        if any(re.search(pattern, content) for pattern in patterns):
            blocked.append((name, 'Google API key or private key'))
    for name, reason in blocked:
        print(f'Blocked: {name!r} ({reason})', file=sys.stderr)
    if blocked:
        print('Remove these files/credentials from the staged snapshot.', file=sys.stderr)
        return 1
    print('Secret check passed: no blocked files or key patterns in the Git index.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
