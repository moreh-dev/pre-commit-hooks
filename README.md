## pre-commit-hooks

### Setup

You must create a `.pre-commit-config.yaml` file in the root of your repository before running the install command.

```shell
pre-commit install
```

or

```shell
prek install
```

### add-jira-issue-key-to-commit-msg

- `<jiraProjectKey>`: Key identifying the project (e.g., MAF, MO).
- `<jiraIssueKey>`: Key identifying the issue in the format `<jiraProjectKey>-<issueNumber>`.

```yaml
default_install_hook_types:
  - prepare-commit-msg
repos:
  - repo: https://github.com/moreh-dev/pre-commit-hooks
    rev: main
    hooks:
      - id: add-jira-issue-key-to-commit-msg
        args:
          - --key
          - MAF
          - --key
          - MV
          - --enable-no-issue
```

- args
  - `-k|--key <jiraProjectKey>`
    - Specifies the JIRA project key. Can be specified multiple times.
    - If the branch name starts with the corresponding `<jiraIssueKey>`, adds `<jiraIssueKey>: ` to the beginning of the commit message.
  - `-n|--enable-no-issue`
    - If no recognizable `<jiraIssueKey>` is found, adds `NO-ISSUE: ` to the beginning of the commit message.
