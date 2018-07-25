# px-docs-spike

[![Travis branch](https://img.shields.io/travis/portworx/pxdocs/master.svg)](https://travis-ci.org/portworx/pxdocs)

A [hugo](https://gohugo.io/) implementation of the Portworx documentation.

## develop locally

To develop the docs site locally - first ensure you have [docker](https://docs.docker.com/install/) installed and then:

```bash
make develop
```

You can then view the site in your browser at [http://localhost:1313](http://localhost:1313).  As you edit content in the `content` folder - the browser will refresh as you save files.

## versions

Each version of the docs is kept on a different branch.  For example do `git checkout 1.3` before running `make develop` to edit the `1.3` version of the docs.

To activate the version dropdown that appears in production - the following variables need to be exported before you run `make develop`:

```bash
export VERSIONS_ALL="1.3,1.4"
export VERSIONS_CURRENT="1.3"
export VERSIONS_BASE_URL="docs.portworx.wk1.co"
```

**note** if you use the version dropdown - it will redirect to the live site.  If you want to edit a different version locally - use `git checkout <VERSION>`

## updating the theme

It's important to make sure the theme the docs site uses is up to date.  To do this:

```bash
make theme
```

This will pull in the latest content from [pxdocs-tooling](https://github.com/portworx/pxdocs-tooling) - make sure you `git commit` once you have updated the theme.

Make sure you update the theme for each of the version branches.

## publish site

If you want to generate the built website locally - you can:

```bash
make publish
```

This will generate a `public` folder in which the static docs website for the current version branch is placed.

## algolia search

If you want the algolia search bar to be activated locally for testing - you will need to export the following variables - get these from an administrator:

```bash
export ALGOLIA_APP_ID=XXX
export ALGOLIA_API_KEY=XXX
export ALGOLIA_ADMIN_KEY=XXX
export ALGOLIA_INDEX_NAME=local-docs
```

Then you will need to update the remote algolia index with the contents of the site:

```bash
make search
```

Finally run `make develop` as normal and the algolia search bar should display with the content of the site indexed.

You can always re-run the `make search` command again to re-index.

## deployment

Deployment of your changes is handled by Travis upon a git push to the git repo.  Once you have made changes and viewed them locally - a `git push` of the version branch you are working on will result in the content being deployed into production.

## production build

The following command will output the static site in the `public` folder:

```
hugo
```

If you want full debug output with no caching i.e. the cleanest build you can have (which is what should be used in CI):

```
hugo -v --debug --gc --ignoreCache --cleanDestinationDir
```

You can then serve the `public` folder as the static build of the site.

## editing content

Each page is written in [Markdown](https://daringfireball.net/projects/markdown/syntax) and uses [front-matter](https://gohugo.io/content-management/front-matter/) in YAML format to describe the page.

The important fields in the front-matter are as follow:

 * `title` - the name of the page and the name that will appear on the menu
 * `weight` - what order the page will appear in the menu and previous & next links within sections

#### sections

The menu on the left hand side is build from the `section` pages.  A section is created by making `_index.md` file within a folder.

You can make sections within sections by placing folders with `_index.md` files recursively in a folder tree - the menu will render the sections into the same tree represented by the folders.

#### reusing content

To re-use the same content across multiple pages - we use the `content` shortcode.  Here is an example from the kubernetes installation section where there are multiple sections re-using the same page content:

```
---
title: 2. Secure ETCD and Certificates
weight: 2
---

{{% content "portworx-install-with-kubernetes/shared/2-secure-etcd-and-certificates.md" %}}
```

This page will live inside it's section but render the content from the `portworx-install-with-kubernetes/shared/2-secure-etcd-and-certificates.md` file.

To create a section that has shared content but is not rendered in the tree (like the `shared` folder in the example above) - we use the `hidden` value of the front-matter.  Here is the `_index.md` for the shared section that provides the content files used above:


```
---
title: Shared
hidden: true
---

Shared content for kubernetes installation
```

This means we can add files into the `shared` folder but they won't show up in the menu.

#### Linking between sections

Pages within a section will display **next** and **previous** links based on the `weight` property of the front-matter.  Sometimes it's useful to put a manual link into a page (or shared content) to keep the flow going.

Use the `widelink` shortcode to do this as follows:

```
{{< widelink url="/application-install-with-kubernetes" >}}Stateful applications on Kubernetes{{</widelink>}}
```

This will render the wide orange links to the page url given.

#### Section homepages

The `_index.md` page of a section can contain content and it will list all of the pages and/or sections that live below it.

You can disable the list of child links using the `hidesections` property of the front-matter in the `_index.md` page - then it will only render the section page content.

## hugo docs

Because the site is based on hugo - you can use any of the shortcodes, functions and variables listed in the [hugo documentation](https://gohugo.io/documentation/)
