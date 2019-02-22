## versions

Each version of the docs is kept on a different branch.  For example do `git checkout 1.7` before running `make develop` to edit the `1.7` version of the docs.

To activate the version dropdown that appears in production - the following variables need to be exported before you run `make develop`:

```bash
export VERSIONS_ALL="2.0,1.7"
export VERSIONS_CURRENT="2.0"
export VERSIONS_BASE_URL="docs.portworx.com"
```

**note** if you use the version dropdown - it will redirect to the live site.  If you want to edit a different version locally - use `git checkout <VERSION>`
