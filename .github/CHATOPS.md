# ChatOps Implementation

This repository uses a webhook-based ChatOps system for PR management, inspired by Kubernetes Prow.

## Available Commands

Use these commands in PR comments (must start with `/`):

| Command | Description | Example |
|---------|-------------|---------|
| `/approve` | Mark PR as approved | `/approve` |
| `/lgtm` | Add "lgtm" label | `/lgtm` |
| `/hold` | Add hold label to prevent merge | `/hold` |
| `/unhold` | Remove hold label | `/unhold` |
| `/label <name>` | Add a label | `/label kind/bug` |
| `/remove-label <name>` | Remove a label | `/remove-label priority/backlog` |
| `/assign [@user]` | Assign to yourself or someone | `/assign` or `/assign @username` |
| `/unassign [@user]` | Unassign | `/unassign` |
| `/cc @user` | Request review | `/cc @reviewer` |
| `/retest` | Trigger CI re-run | `/retest` |
| `/close` | Close issue/PR | `/close` |
| `/reopen` | Reopen issue/PR | `/reopen` |
| `/help` | Show help message | `/help` |

## How It Works

1. **Comment Trigger**: User posts a comment starting with `/` on a PR
2. **Dispatcher**: `chatops-dispatcher.yml` parses the command and dispatches to specific workflow
3. **Command Handler**: Individual workflow (e.g., `chatops-approve.yml`) executes the action
4. **Feedback**: Bot reacts to comment with 🚀 and performs the requested action

## Architecture

```
PR Comment (/approve)
    ↓
chatops-dispatcher.yml (parses command)
    ↓
repository_dispatch event (approve-command)
    ↓
chatops-approve.yml (adds label + comment)
    ↓
PR updated with "approved" label
```

## Valid Labels

Labels must be defined in `.prowlabels.yaml`. Current categories:

- **Area**: `area/ci`, `area/docs`, `area/testing`
- **Kind**: `kind/bug`, `kind/feature`, `kind/cleanup`
- **Priority**: `priority/critical-urgent`, `priority/important-soon`
- **Triage**: `triage/needs-information`, `triage/accepted`
- **PR State**: `approved`, `lgtm`, `do-not-merge/hold`
- **Size**: `size/XS`, `size/S`, `size/M`, `size/L`, `size/XL`

## Setup Requirements

### Permissions

The workflows use `GITHUB_TOKEN` with these permissions:
- `issues: write`
- `pull-requests: write`
- `contents: read`

No additional PAT tokens required!

### Enable Workflows

1. Ensure Actions are enabled in repository settings
2. Grant workflow permissions: Settings → Actions → General → Workflow permissions → "Read and write permissions"
3. Enable "Allow GitHub Actions to create and approve pull requests"

## Testing

Test commands on a PR:

```
/help
/label kind/feature
/approve
```

The bot should:
1. React with 🚀 to your comment
2. Execute the command
3. Add appropriate labels/comments

## Troubleshooting

### Command not recognized
- Ensure command starts with `/`
- Check spelling (case-sensitive)
- Use `/help` to see available commands

### Permission denied
- Verify workflow permissions in Settings → Actions
- Check that `GITHUB_TOKEN` has write access

### Label not found
- Verify label exists in `.prowlabels.yaml`
- Labels are case-sensitive

## Extending

To add a new command:

1. Add command mapping in `chatops-dispatcher.yml`
2. Create new workflow file `chatops-<command>.yml`
3. Add `repository_dispatch` trigger with your event type
4. Implement command logic using `github-script`

Example:

```yaml
name: ChatOps My Command
on:
  repository_dispatch:
    types: [my-command]
permissions:
  issues: write
jobs:
  execute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            // Your logic here
```
