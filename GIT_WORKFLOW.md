## Day 1 setup

* Fork https://github.com/portworx/pxdocs into your github account (Click the fork button on top right).
* Clone your fork using `git clone git@github.com:<YOUR-GITUSERNAME>/pxdocs.git`
* Add the official repo as upstream using `git remote add upstream git@github.com:portworx/pxdocs.git`
* Fetch upstream `git fetch upstream`

## Starting on a new change

* Fetch the latest upstream: `git fetch upstream`
* Checkout out a new dev branch: `git checkout -b change-name upstream/master`
* Make your changes. Always ensure `git status` shows no untracked and uncommitted changes. So if you add new files, use `git add <file-path>` so git starts tracking them.
* Use `make update-theme` to pick new theme changes other's might have made (if any).
* Use `make develop` to deploy the docs site locally and preview your changes.
* If changes look good, submit a pull request and assign the Subject Matter Expert for review.

## Doing multiple changes at the same time

* `git checkout -b branch-foo upstream/master`
* `git commit -sam "Making foo changes"`
* `git checkout -b branch-bar upstream/master`
* `git commit -sam "Making bar changes"`
