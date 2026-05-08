# Git Commit Check

#### A POSIX-compliant shell script for running configurable and extendable pre-commit checks on your local git repository.

---

- Download the git-commit-check directory and place it within your repo (e.g. `path/to/your/repo/bin/git-commit-check`)

- Run the following commands to copy the pre-commit hook script example and the config example files
  and edit their values according to your project.

Let's assume you placed gitcc files under the bin directory of your repo:
```
cd path/to/your/repo
cp bin/git-commit-check/hooks/pre-commit.example bin/git-commit-check/hooks/pre-commit
cp bin/git-commit-check/config.sh.example bin/git-commit-check/config.sh
```
- Run the following command to instruct git to call `gitcc` before allowing the developer to create a new commit.

```
git config core.hooksPath bin/git-commit-check/hooks`
```
