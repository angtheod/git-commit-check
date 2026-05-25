# Git Commit Check

### A POSIX-compliant Shell tool for executing configurable pre-commit checks on your git repository.

---
##### *Please Give a Star to this repo, if you liked it!*

May be used as a pre-commit git hook, as part of a CI/CD pipeline or as a standalone tool.
Tested on the following platforms: `x86_64 (aka amd64), arm64` and the following shells: `sh, bash, dash`

##### Steps to use:
1. Download the latest git-commit-check release and place it within your repository.

2. Change directory to the main directory of your project & copy file config.sh.example and edit their values according to your project e.g., project path, gitcc path, container name, shell.

Let's assume you placed git-commit-check under the bin directory of your project:

```
cd path/to/your/project
cp bin/git-commit-check/config.sh.example bin/git-commit-check/config.sh
```
3. Copy file pre-commit.example to pre-commit
```
cp bin/git-commit-check/hooks/pre-commit.example bin/git-commit-check/hooks/pre-commit
```

Edit the config.sh file to set the values for the checks you want to run.
Set the SCRIPTS_ENABLED string variable with the script names that you want to use, separated by new-line.


4. Create your own new script and add it to the `scripts/use` directory. Script naming conventions:
    1. Prepend a two-digit script ID to the script name to indicate the order of execution.
    2. Append the .sh extension to the script name.
    3. Copy the contents of the `scripts/template` script into the new script file.
    4. Follow the instructions within the template file.
       a. MUST implement function 'before_run' and initialize the 4 variables (HEADER, COMMAND, COMMAND_NAME & COMMAND_VERSION)
       b. MAY implement function 'run' and add custom logic. A typical use case can be found in the template file.
       c. MAY implement function 'after_run' to perform any cleanup or post-processing actions.
    5. Try to keep your scripts POSIX-compliant so that they will work in all (most) SHELL. There are command line and online tools that can help you verify this.
Alternatively, you may copy one of the existing scripts under the `scripts/library` directory into the `scripts/use` directory.

5. Make the pre-commit hook executable. Run the following command to instruct git to call `gitcc` before allowing the developer to create a new commit.

```
git config core.hooksPath bin/git-commit-check/hooks
```

5. Run `git commit` to test the pre-commit hook. If your application is containerized (docker/podman), gitcc will automatically run within your container, regardless whether you do `git commit` from the host machine or the container.
This way the pre-commit hook and all the checks will be executed in the same environment as the application. There is a configuration option for forcing gitcc to run in Host machine if desired.

Done!

---
##### *Please Give a Star to this repo, if you liked it!*
