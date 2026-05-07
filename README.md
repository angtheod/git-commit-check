# Git Commit Check

#### A POSIX-compliant shell script for running configurable and extendable pre-commit checks on your local git repository.

---

- Download the files and place the scripts directory and the gitcc shell script within your repo.

- Run the following commands to copy the pre-commit hook script example and the config example files
  and edit their values according to your project.

```
cp hooks/pre-commit.example hooks/pre-commit
cp config.sh.example config.sh
```
- Run the following command to instruct git to call `gitcc` before allowing the developer to create a new commit.

`git config core.hooksPath hooks`
