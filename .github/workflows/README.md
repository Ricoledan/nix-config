# GitHub Actions Workflows

This directory contains CI/CD workflows for the Nix configuration repository.

## Workflows

### ci.yml - Main CI Pipeline

- Runs on every push and PR to main branch
- Tests on Ubuntu and macOS
- Performs flake checks, formatting validation, and security scanning
- Requires security-events write permission for SARIF upload

### ci-simple.yml - Simplified CI (Alternative)

- Alternative workflow without security scanning
- Use if main CI has permission issues
- Focuses on core functionality testing

### update-deps.yml - Automated Dependency Updates

- Runs weekly (Monday 9 AM UTC)
- Updates Nix flake inputs
- Updates Homebrew packages
- Creates PRs automatically

### pr-validation.yml - Pull Request Validation

- Validates commits, files, and documentation
- Posts summary comments on PRs
- Checks for sensitive information

## Fixing Permission Issues

If you see "Resource not accessible by integration" errors:

### Option 1: Enable GitHub Advanced Security (Recommended)

1. Go to Settings → Code security and analysis
2. Enable "Dependency graph"
3. Enable "Dependabot alerts"
4. Enable "Code scanning" (if available)

### Option 2: Adjust Repository Settings

1. Go to Settings → Actions → General
2. Under "Workflow permissions", select:
   - "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"

### Option 3: Use Personal Access Token

1. Create a PAT with `repo` and `security_events` scopes
2. Add as repository secret: `SECURITY_TOKEN`
3. Update workflow to use: `token: ${{ secrets.SECURITY_TOKEN }}`

### Option 4: Use Simplified CI

If security scanning isn't needed:

```yaml
# Disable the main CI workflow
# Use ci-simple.yml instead
```

## Manual Workflow Triggers

All workflows support `workflow_dispatch` for manual triggering:

1. Go to Actions tab
2. Select the workflow
3. Click "Run workflow"
4. Choose branch and options

## Local Testing

Test workflows locally using [act](https://github.com/nektos/act):

```bash
# Install act
brew install act  # or nix-shell -p act

# Test CI workflow
act push

# Test PR workflow
act pull_request

# Test with specific job
act -j check
```

## Debugging Failed Workflows

1. **Enable debug logging:**
   - Add secret: `ACTIONS_STEP_DEBUG` = `true`
   - Add secret: `ACTIONS_RUNNER_DEBUG` = `true`

2. **Check workflow syntax:**

   ```bash
   # Validate YAML
   yamllint .github/workflows/*.yml

   # Check with actionlint
   actionlint .github/workflows/*.yml
   ```

3. **Common issues:**
   - Permissions: Check workflow and job-level permissions
   - Nix errors: Usually need `--impure` flag
   - Cache issues: Clear with new cache key
   - Platform differences: Test both Linux and macOS

## Workflow Status Badges

Add to your README:

```markdown
[![CI](https://github.com/YOUR_USERNAME/nix-config/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/nix-config/actions/workflows/ci.yml)
[![Update Dependencies](https://github.com/YOUR_USERNAME/nix-config/actions/workflows/update-deps.yml/badge.svg)](https://github.com/YOUR_USERNAME/nix-config/actions/workflows/update-deps.yml)
```

## Security Considerations

- Workflows have minimal required permissions
- Secrets are never logged or exposed
- PRs from forks run with read-only permissions
- Dependency updates create PRs for review

## Contributing

When adding new workflows:

1. Follow existing naming conventions
2. Add appropriate permissions
3. Include error handling
4. Document in this README
5. Test locally with `act` first
