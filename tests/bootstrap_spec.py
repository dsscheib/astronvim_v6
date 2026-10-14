"""Exercise bootstrap errors with stdin held open; never download plugins."""
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='nvim-bootstrap-') as folder:
    temp = Path(folder)
    env = dict(os.environ, LAZY=str(temp / 'missing'), NVIM_LOG_FILE=str(temp / 'log'))
    result = subprocess.Popen(['nvim', '--headless', '-u', str(ROOT / 'init.lua'), '-c', 'quitall'],
                              stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
    try:
        result.wait(timeout=5)
    except subprocess.TimeoutExpired:
        result.kill()
        raise AssertionError('Bootstrap waited for input')
    _, stderr = result.communicate()
    assert result.returncode != 0, stderr.decode()
    assert b'Unable to load lazy' in stderr, stderr.decode()
    # An absent default lazy directory forces the clone failure path, using a
    # local git stub so this check works offline.
    (temp / 'git').write_text('#!/bin/sh\necho "fixture clone failed" >&2\nexit 1\n')
    (temp / 'git').chmod(0o755)
    env.pop('LAZY')
    env['PATH'] = str(temp) + os.pathsep + env['PATH']
    env['XDG_DATA_HOME'] = str(temp / 'data')
    result = subprocess.run(['nvim', '--headless', '-u', str(ROOT / 'init.lua'), '-c', 'quitall'],
                            capture_output=True, env=env, timeout=5)
    assert result.returncode != 0 and b'fixture clone failed' in result.stderr, result.stderr.decode()
print('Headless bootstrap error checks passed: 2')

# Exercise the documented backup block with isolated XDG roots and a clone stub.
# Repeating it must create distinct backups rather than nesting into old ones.
import re
backup_block = re.search(r'```bash\n(\(.*?\n\))\n```', (ROOT / 'README.md').read_text(), re.S).group(1)
with tempfile.TemporaryDirectory(prefix='nvim-backup-') as folder:
    temp = Path(folder)
    bin_dir = temp / 'bin'
    bin_dir.mkdir()
    (bin_dir / 'git').write_text('#!/bin/sh\nmkdir -p "$3"\nprintf cloned > "$3/clone-fixture"\n')
    (bin_dir / 'git').chmod(0o755)
    env = dict(os.environ, HOME=str(temp), PATH=str(bin_dir) + os.pathsep + os.environ['PATH'])
    for kind in ('config', 'data', 'state', 'cache'):
        env['XDG_' + kind.upper() + '_HOME'] = str(temp / kind)
        path = temp / kind / 'nvim'
        path.mkdir(parents=True)
        (path / 'original').write_text(kind)
    for _ in range(2):
        result = subprocess.run(['bash', '-c', backup_block], capture_output=True, env=env)
        assert result.returncode == 0, result.stderr.decode()
    backups = sorted(temp.glob('nvim-backup.*'))
    assert len(backups) == 2
    assert any((path / 'config/original').exists() for path in backups)
    assert any((path / 'config/clone-fixture').exists() for path in backups)
    assert all(not (path / 'config/nvim').exists() for path in backups)
    # Stop before cloning when moving an existing directory fails.
    (bin_dir / 'mv').write_text('#!/bin/sh\nexit 42\n')
    (bin_dir / 'mv').chmod(0o755)
    result = subprocess.run(['bash', '-c', backup_block], capture_output=True, env=env)
    assert result.returncode == 42, result.stderr.decode()
    assert (temp / 'config/nvim/clone-fixture').exists()
print('README backup checks passed: repeated backups and move failure')
