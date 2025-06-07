## pre-commit

### 설정

```shell
git config --global init.templateDir ~/.git-template \
&& pre-commit init-templatedir ~/.git-template -t pre-commit -t prepare-commit-msg
```

위 명령어를 실행하면 레포지토리를 생성하거나 클론할 때 자동으로 pre-commit 훅이 등록됩니다.

이미 레포지토리를 생성하거나 클론한 상태라면 해당 레포지토리에서 `pre-commit install` 명령어를 실행하여 훅을 등록할 수 있습니다.

### add-jira-issue-key-to-commit-msg

- `<jiraProjectKey>`: MAF, MO 등 프로젝트를 구분하는 키
- `<jiraIssueKey>`: `<jiraProjectKey>-<issueNumber>` 형식의 이슈를 구분하는 키

```yaml
default_install_hook_types:
  - pre-commit
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
    - JIRA 프로젝트 키를 지정합니다. 여러 개를 지정할 수 있습니다.
    - 브랜치 명이 해당 `<jiraIssueKey>`로 시작하는 경우 커밋 메시지 앞에 `<jiraIssueKey>: `를 추가합니다.
  - `-n|--enable-no-issue`
    - 인식할 수 있는 `<jiraIssueKey>`가 없는 경우 `NO-ISSUE: `를 커밋 메시지 앞에 추가합니다.

### commit convention

- https://www.conventionalcommits.org/ko/v1.0.0/
