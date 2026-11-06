#!/usr/bin/env python3
"""Swap all windows between the focused workspace and a target workspace in i3wm,
preserving exact container layouts and window sizes, and moving focus to the target workspace."""

import json
import subprocess
import sys


def i3_msg(args):
    res = subprocess.run(
        ["i3-msg"] + args,
        capture_output=True,
        text=True,
        check=False,
    )
    return res.stdout


def get_workspaces():
    out = i3_msg(["-t", "get_workspaces"])
    return json.loads(out) if out else []


def get_workspace_window_counts():
    out = i3_msg(["-t", "get_tree"])
    if not out:
        return {}
    tree = json.loads(out)
    counts = {}

    def count_windows(node):
        total = 1 if node.get("window") is not None else 0
        for child in node.get("nodes", []) + node.get("floating_nodes", []):
            total += count_windows(child)
        return total

    def walk(node):
        if node.get("type") == "workspace" and node.get("name") != "__i3_scratch":
            counts[node.get("name")] = count_windows(node)
            return
        for child in node.get("nodes", []) + node.get("floating_nodes", []):
            walk(child)

    walk(tree)
    return counts


def main():
    if len(sys.argv) < 2:
        i3_msg(['mode "default"'])
        sys.exit(1)

    target_arg = sys.argv[1].strip(",")
    workspaces = get_workspaces()
    if not workspaces:
        i3_msg(['mode "default"'])
        sys.exit(1)

    cur_idx = next(
        (i for i, w in enumerate(workspaces) if w.get("focused")), None
    )
    if cur_idx is None:
        i3_msg(['mode "default"'])
        sys.exit(1)

    cur_ws = workspaces[cur_idx]
    src_name = cur_ws["name"]
    src_output = cur_ws["output"]

    if target_arg == "next":
        dst_ws = workspaces[(cur_idx + 1) % len(workspaces)]
    elif target_arg == "prev":
        dst_ws = workspaces[(cur_idx - 1) % len(workspaces)]
    else:
        dst_ws = next(
            (
                w
                for w in workspaces
                if w.get("name") == target_arg or str(w.get("num")) == target_arg
            ),
            None,
        )

    dst_name = dst_ws["name"] if dst_ws else target_arg
    dst_output = dst_ws["output"] if dst_ws else None

    if src_name == dst_name:
        i3_msg(['mode "default"'])
        sys.exit(0)

    win_counts = get_workspace_window_counts()
    src_has_wins = win_counts.get(src_name, 0) > 0
    dst_has_wins = win_counts.get(dst_name, 0) > 0

    if not src_has_wins and not dst_has_wins:
        i3_msg([f'workspace "{dst_name}"; mode "default"'])
        sys.exit(0)

    if dst_ws is None:
        # Target workspace does not exist yet; rename current workspace to target
        # and stay on the newly renamed target workspace.
        i3_msg([
            f'rename workspace "{src_name}" to "{dst_name}"; '
            f'workspace "{dst_name}"; '
            f'mode "default"'
        ])
        sys.exit(0)

    tmp_name = "i3_swap_tmp"
    cmds = [
        f'rename workspace "{src_name}" to "{tmp_name}"',
        f'rename workspace "{dst_name}" to "{src_name}"',
        f'rename workspace "{tmp_name}" to "{dst_name}"',
    ]

    if src_output and dst_output and src_output != dst_output:
        if src_has_wins and not dst_has_wins:
            cmds.extend([
                f'move workspace to output "{dst_output}"',
                f'focus output "{src_output}"',
                f'workspace "{src_name}"',
                f'focus output "{dst_output}"',
                f'workspace "{dst_name}"',
            ])
        elif dst_has_wins and not src_has_wins:
            cmds.extend([
                f'workspace "{src_name}"',
                f'move workspace to output "{src_output}"',
                f'focus output "{dst_output}"',
                f'workspace "{dst_name}"',
            ])
        else:
            cmds.extend([
                f'move workspace to output "{dst_output}"',
                f'workspace "{src_name}"',
                f'move workspace to output "{src_output}"',
                f'workspace "{dst_name}"',
            ])
    else:
        # Both workspaces are on the same output; stay focused on dst_name
        cmds.append(f'workspace "{dst_name}"')

    cmds.append('mode "default"')
    i3_msg(["; ".join(cmds)])


if __name__ == "__main__":
    main()
