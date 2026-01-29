# Contributing to RACE

Thank you for considering contributing to RACE! We welcome contributions from the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the maintainers.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include as many details as possible:

- Use a clear and descriptive title
- Describe the exact steps to reproduce the problem
- Provide specific examples to demonstrate the steps
- Describe the behavior you observed and what you expected
- Include your environment details (OS, Bash version, Terraform/OpenTofu version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- Use a clear and descriptive title
- Provide a detailed description of the suggested enhancement
- Explain why this enhancement would be useful
- List any alternative solutions you've considered

### Pull Requests

We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`
2. Make your changes following our coding standards
3. Test your changes thoroughly
4. Update documentation as needed
5. Write meaningful commit messages
6. Submit your pull request

## Development Setup

### Prerequisites

- Bash 4.0+
- Git
- Terraform or OpenTofu
- AWS CLI (for testing)
- (Optional) Nix with flakes support

### Local Development

1. Clone your fork:
```bash
git clone https://github.com/YOUR_USERNAME/race.git
cd race
```

2. Make the scripts executable:
```bash
chmod +x race *.sh
```

3. Test your changes:
```bash
./race version
./race usage
```

### Testing

Before submitting a pull request:

1. Test all modified scripts manually
2. Verify that existing functionality still works
3. Test in different environments if possible (different shells, OS versions)
4. Ensure no sensitive data is included in commits

## Coding Standards

### Bash Scripts

- Use `#!/usr/bin/env bash` as the shebang
- Use meaningful variable names
- Add comments for complex logic
- Use functions for reusable code
- Handle errors appropriately
- Quote variables to prevent word splitting
- Use `set -e` for critical scripts where appropriate

### Example:
```bash
#!/usr/bin/env bash

# Description of what this script does
function my_function() {
  local variable="value"

  if [[ -z "${variable}" ]]; then
    echo "Error: variable is empty"
    return 1
  fi

  echo "Processing: ${variable}"
}
```

### Python Scripts

- Follow PEP 8 style guide
- Use meaningful variable and function names
- Add docstrings to functions and modules
- Handle exceptions appropriately

## Commit Messages

Write clear and meaningful commit messages:

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests when relevant

### Examples:

```
Add nixrun command for Nix flake integration

- Automatically detect backend from tfbackend.state
- Match backend with flake targets
- Interactive menu for multiple matches

Fixes #123
```

## Pull Request Process

1. **Update Documentation**: Ensure README.md and relevant docs are updated
2. **Update CHANGELOG**: Add an entry to CHANGELOG.md describing your changes
3. **Test Thoroughly**: Verify your changes work as expected
4. **Describe Changes**: Provide a clear description of what your PR does
5. **Link Issues**: Reference any related issues
6. **Wait for Review**: Maintainers will review your PR and may request changes
7. **Address Feedback**: Make requested changes and push updates
8. **Merge**: Once approved, maintainers will merge your PR

### PR Checklist

- [ ] Code follows the project's coding standards
- [ ] Documentation has been updated
- [ ] CHANGELOG.md has been updated
- [ ] All tests pass
- [ ] Commit messages are clear and descriptive
- [ ] No sensitive information is included

## Project Structure

```
race/
├── race                    # Main CLI entry point
├── _racelib.sh            # Shared library functions
├── tfbackend.sh           # Backend switcher
├── tfplan.sh              # Plan wrapper
├── tfapply.sh             # Apply wrapper
├── tfdestroy.sh           # Destroy wrapper with safeguards
├── nixrun.sh              # Nix integration
├── terraform-docs-stack.py # Documentation generator
├── docs/                  # Documentation files
├── .github/               # GitHub templates and workflows
└── README.md              # Main documentation
```

## Recognition

Contributors will be recognized in the project. Significant contributions may be mentioned in release notes.

## Questions?

Feel free to open an issue with your question, or reach out to the maintainers directly.

## License

By contributing to RACE, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to RACE! Your efforts help make this tool better for everyone.
