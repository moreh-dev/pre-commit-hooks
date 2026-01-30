import os
import subprocess
from pathlib import Path

import pytest

# Path to the hook script relative to this test file
# tests/test_hook.py -> ../pre_commit_hooks/add_jira_issue_key_to_commit_msg.sh
HOOK_SCRIPT = (
    Path(__file__).parents[1]
    / "pre_commit_hooks"
    / "add_jira_issue_key_to_commit_msg.sh"
).resolve()
PROJECT_KEYS = ["JIRA", "PROJ"]


@pytest.fixture
def git_repo(tmp_path):
    """Fixture to create a temporary git repo with a configured user."""
    subprocess.run(
        ["git", "init"],
        cwd=tmp_path,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        ["git", "config", "user.email", "you@example.com"],
        cwd=tmp_path,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        ["git", "config", "user.name", "Your Name"],
        cwd=tmp_path,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    # Create valid HEAD
    subprocess.run(
        ["git", "commit", "--allow-empty", "-m", "Initial"],
        cwd=tmp_path,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    # Ensure hook is executable
    if HOOK_SCRIPT.exists():
        os.chmod(HOOK_SCRIPT, 0o755)
    else:
        pytest.fail(f"Hook script not found at {HOOK_SCRIPT}")

    return tmp_path


@pytest.mark.parametrize(
    "branch,original_msg,expected_msg",
    [
        # add key
        ("master", "feat: simple", "NO-ISSUE: feat: simple"),
        ("JIRA-123-feature", "feat: foo", "JIRA-123: feat: foo"),
        # ignore if key already exists
        ("master", "NO-ISSUE: feat: simple", "NO-ISSUE: feat: simple"),
        ("JIRA-123-feature", "JIRA-123: feat: foo", "JIRA-123: feat: foo"),
        # change key
        ("master", "JIRA-123: feat: manual", "NO-ISSUE: feat: manual"),
        ("JIRA-123-feature", "PROJ-456: feat: foo", "JIRA-123: feat: foo"),
        ("JIRA-123-feature", "NO-ISSUE: feat: foo", "JIRA-123: feat: foo"),
    ],
)
def test_jira_hook(git_repo, branch, original_msg, expected_msg):
    # Checkout branch
    subprocess.run(
        ["git", "checkout", "-b", branch],
        cwd=git_repo,
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    # Create commit message file
    msg_file = git_repo / "COMMIT_EDITMSG"
    msg_file.write_text(original_msg)

    # Build args
    args = [str(HOOK_SCRIPT), str(msg_file)]
    for key in PROJECT_KEYS:
        args.extend(["-k", key])
    args.append("--enable-no-issue")

    # Run hook
    # Capture stderr for debugging if assertion fails
    result = subprocess.run(
        args,
        cwd=git_repo,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding="utf-8",
    )

    if result.returncode != 0:
        pytest.fail(f"Hook failed with {result.returncode}\nStderr: {result.stderr}")

    final_msg = msg_file.read_text().strip()
    assert final_msg == expected_msg.strip(), f"Stderr: {result.stderr}"
