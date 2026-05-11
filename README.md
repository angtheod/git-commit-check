# Git Commit Check

#### A POSIX-compliant Shell tool for executing configurable and extendable pre-commit checks on your git repository.

---

- Download the git-commit-check directory and place it within your repository.

- Run the following commands to copy the pre-commit hook script example and the config example files
  and edit their values according to your project.

Let's assume you placed gitcc files under the bin directory of your repository:
```
cd path/to/your/repo
cp bin/git-commit-check/hooks/pre-commit.example bin/git-commit-check/hooks/pre-commit
cp bin/git-commit-check/config.sh.example bin/git-commit-check/config.sh
```
- Edit the config.sh file to set the values for the checks you want to run.
  - Set the ENABLED variable with the ',' separated script IDs that you want to enable.
- Create your own new script and add it to the `scripts` directory. Script naming conventions:
  1. Prepend a two-digit script ID to the script name.
  2. Append the .sh extension to the script name.
  3. Copy the contents of the `scripts/template` script into the new script file.
  4. Adjust the values in the script file to suit your needs, as described in the comments of the template script.
  5. Try to keep your scripts POSIX-compliant so that they will work in all (most) SHELL. There are command line and online tools that can help you verify this.
- Alternatively, you may copy one of the prepared scripts under the `scripts/prepared` directory into the `scripts` directory.
- Make the pre-commit hook executable. Run the following command to instruct git to call `gitcc` before allowing the developer to create a new commit.

```
git config core.hooksPath bin/git-commit-check/hooks`
```

- Run `git commit` to test the pre-commit hook. If your application is containerized (docker/podman), gitcc will automatically run within your container, regardless whether you do `git commit` from the host machine or the container.

- Done!
