#!/usr/bin/env python3
"""
analyze_repos.py

Simple helper to analyze a GitHub repos JSON dump (from `gh repo list --json ...`).

Usage:
  python3 analyze_repos.py /path/to/krvax_repos.json

Outputs (written to /tmp):
  - /tmp/krvax_summary.json
  - /tmp/krvax_old_forks.txt

Optional: pass --archive to attempt archiving old forks via `gh api` (dangerous,
requires `gh` auth). This script will only attempt archival if `--archive` is set.
"""
import json
import sys
from datetime import datetime
import subprocess
import argparse


def load(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def write_summary(data, out='/tmp/krvax_summary.json'):
    total = len(data)
    forks = [r for r in data if r.get('isFork')]
    nonforks = [r for r in data if not r.get('isFork')]
    old_forks = [r for r in forks if (r.get('updatedAt') or '') < '2018-01-01']
    parent_count = {}
    for r in forks:
        p = r.get('parent')
        if p:
            parent_count[p.get('name')] = parent_count.get(p.get('name'), 0) + 1

    outd = {
        'total': total,
        'forks': len(forks),
        'nonforks': len(nonforks),
        'old_forks': len(old_forks),
        'top_parents': sorted(parent_count.items(), key=lambda x: -x[1])[:20],
    }
    with open(out, 'w', encoding='utf-8') as f:
        json.dump(outd, f, indent=2)
    return outd


def write_old_forks(data, out='/tmp/krvax_old_forks.txt'):
    forks = [r for r in data if r.get('isFork')]
    old_forks = [r for r in forks if (r.get('updatedAt') or '') < '2018-01-01']
    names = [r['name'] for r in old_forks]
    with open(out, 'w', encoding='utf-8') as f:
        f.write('\n'.join(names))
    return names


def archive_repos(names, owner='krvax'):
    """Archive repos by calling `gh api -X PATCH /repos/{owner}/{repo} -f archived=true`.
    WARNING: this modifies remote state. Use only when you understand the effects.
    """
    results = {}
    for n in names:
        cmd = ['gh', 'api', '-X', 'PATCH', f'/repos/{owner}/{n}', '-f', 'archived=true']
        try:
            subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            results[n] = 'archived'
        except subprocess.CalledProcessError:
            results[n] = 'failed'
    return results


def main():
    p = argparse.ArgumentParser()
    p.add_argument('jsonfile', help='Path to JSON file produced by `gh repo list <owner> --json ...`')
    p.add_argument('--archive', action='store_true', help='Archive old forks via gh API')
    p.add_argument('--owner', default='krvax', help='GitHub owner/login')
    args = p.parse_args()

    data = load(args.jsonfile)
    summary = write_summary(data)
    names = write_old_forks(data)
    print('Wrote /tmp/krvax_summary.json and /tmp/krvax_old_forks.txt')

    if args.archive:
        print('Archiving repos (this may change remote state) ...')
        res = archive_repos(names, owner=args.owner)
        outlog = '/tmp/krvax_archive_log.txt'
        with open(outlog, 'w', encoding='utf-8') as f:
            for k, v in res.items():
                f.write(f'{v} {k}\n')
        print('Archive log written to', outlog)


if __name__ == '__main__':
    main()
