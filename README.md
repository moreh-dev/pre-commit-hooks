## pre-commit

### add-jira-issue-key-to-commit-msg

- `<jiraProjectKey>`: MAF, MO 등 프로젝트를 구분하는 키
- `<jiraIssueKey>`: `<jiraProjectKey>-<issueNumber>` 형식의 이슈를 구분하는 키

`--key <jiraProjectKey>`를 설정하면, 브랜치 명이 `<jiraIssueKey>`로 시작하는 경우 커밋 메시지 앞에 `<jiraIssueKey>: 기존 메시지`를 추가합니다. 기존 메시지에 이미 `<jiraIssueKey>`가 포함되어 있는 경우 추가하지 않습니다.

```yaml
default_install_hook_types:
  - pre-commit
  - prepare-commit-msg
  - ...
repos:
  - repo: https://github.com/moreh-dev/pre-commit-hooks
    rev: f3a9639
    hooks:
      - id: add-jira-issue-key-to-commit-msg
        args: ["--key", "MAF"]
```