# px-docs-spike

[![Travis branch](https://img.shields.io/travis/portworx/pxdocs/master.svg)](https://travis-ci.org/portworx/pxdocs)

A [hugo](https://gohugo.io/) implementation of the Portworx documentation.

## install & run

You can install and run hugo in one of two ways:

### locally

Download hugo from the [releases page](https://github.com/gohugoio/hugo/releases) - make sure you get at least version `0.40`

Then copy the `hugo` binary into `/usr/local/bin` - to check it's worked:

```
hugo version
```

### with Docker

Make sure you have Docker installed and running and use the use the `./hugo.sh` script in this repo.  It wraps the `docker run` command and mounts the code into the container for local development.

The first time you run, you must pass the `BUILD=1` var so the image is created - you can always rebuild by passing this on subsequent runs:

```
BUILD=1 ./hugo.sh version
```

To run hugo inside docker normally:

```
./hugo.sh --help
```
For the rest of this document - interchange the `hugo` command for `./hugo.sh` if you are running inside Docker.

For e.g to start the docs website locally using this script use: `./hugo.sh server`

### development server

The following command will start the development server with hot-reloading on code changes:

```
hugo server
```

Open [http://localhost:1313](http://localhost:1313) in your browser and you should see the site rendered.

Sometimes hugo will cache things and you need to restart the server - sometimes running the following command will reduce the need to do this at the cost of slightly slower build times:

```
hugo server --disableFastRender
```

### production build

The following command will output the static site in the `public` folder:

```
hugo
```

If you want full debug output with no caching i.e. the cleanest build you can have (which is what should be used in CI):

```
hugo -v --debug --gc --ignoreCache --cleanDestinationDir
```

You can then serve the `public` folder as the static build of the site.

### algolia

We use [algolia](https://www.algolia.com/) to power the search.

The JSON index that is used to populate the algolia index is [here](layouts/_default/list.algilia.json).  When a hugo build is done - this will produce `public/algolia.json` that contains the records we will upload.

Then we use the [atomic-algoila](https://www.npmjs.com/package/atomic-algolia) node package that will upload the records to the index we use for searching.

You should set the following environment variables to power this:

 * `ALGOLIA_ADMIN_KEY` - the algolia admin key - used for writing records
 * `ALGOLIA_API_KEY` - the algolia api key - public, used for reading records
 * `ALGOLIA_APP_ID` - the algolia app that contains all indexes
 * `ALGOLIA_INDEX_NAME` - the index name for this build
 * `ALGOLIA_INDEX_FILE` - the JSON file to upload into the index

It is important that each branch build uses a different index name so results from one branch don't pollute another branch.

When doing a hugo build - it will need to have the following variables set:

 * `ALGOLIA_APP_ID`
 * `ALGOLIA_API_KEY`
 * `ALGOLIA_INDEX_NAME`

To upload the index (do this once you have generated a hugo build) - we need to first build the node.js indexer image and then run the script passing in the `algolia.json` index file and the correct variables:

```bash
docker build -t px-docs-indexer:latest -f Dockerfile.indexer .
docker run --rm \
  --name px-docs-indexer \
  -v $PWD/public/algolia.json:/algolia.json:ro \
  -e ALGOLIA_APP_ID \
  -e ALGOLIA_ADMIN_KEY \
  -e ALGOLIA_INDEX_NAME \
  -e ALGOLIA_INDEX_FILE=/algolia.json \
  px-docs-indexer:latest
```

### versions

To build the version drop-down that will redirect to another version of the site - you need the following variables:

 * `VERSIONS_ALL` - a comma delimited list of all versions (e.g. `1.2,1.3,1.4`)
 * `VERSIONS_BASE_URL` - the base url that the version will be prepended to (e.g. `pxdocs.wk1.co`)
 * `VERSIONS_CURRENT` - the current version we are building

We manage content for each version in it's own branch (named after the version). The `content` directory is sourced from a branch named after the version that is being built and is merged with the rest of the files from `master`.

If you are making content updates - you must make the changes in the branch named after the version you are updating.

If you are making updates to the core build itself - make those changes in `master`.

## site structure

Here are the main hugo files and folders and what they do:

 * `config.yaml` - the top level config file for hugo
 * `content` - the folder where the Markdown for pages lives
 * `layouts` - where HTML templates live
 * `static` - where other files like Javascript, CSS and Images live

### content

This folder is where you will spend the most time writing documentation pages and creating section folders.

#### sections

The menu on the left hand side is build from the `section` pages.  A section is created by making `_index.md` file within a folder.

You can make sections within sections by placing folders with `_index.md` files recursively in a folder tree - the menu will render the sections into the same tree represented by the folders.

#### single content page

Each page is written in Markdown and uses [front-matter](https://gohugo.io/content-management/front-matter/) in YAML format to describe the page.

The important fields in the front-matter are as follow:

 * `title` - the name of the page and the name that will appear on the menu
 * `weight` - what order the page will appear in the menu and previous & next links within sections

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

## look and feel

The HTML is generated from the files in `layouts` - you have total control over what HTML is displayed by editing these files.

### static files

Any files & folders you put into the `static` folder are merged into the final build and can be referenced from any of the templates.

### material design
The CSS can also be updated in any way you want - the current site uses [material design lite](https://github.com/google/material-design-lite) as a CSS framework but you can replace that and use any CSS framework / custom CSS you want.

There is documentation for generating the material design CSS with custom colors [here](docs/material-design.md)

### custom CSS

The main pages for changing the HTML for the site are as follow:

 * `layouts/_default/baseof.html` - the core HTML template that includes the CSS and Javascripts for the page and generates the layout
 * `layouts/_default/single.html` - the template used for displaying a single page of content
 * `layouts/_default/list.html` - the template used for displaying a section homepage
 * `layouts/_default/li.html` - the template used for displaying a section homepage list item

### partials

The partials are template fragments that can be used from other templates:

 * `layouts/partials/contentheaderhtml` - the section at the top of the page that displays the title, edited by info and github link
 * `layouts/partials/menu.html` - the template that generates the menu tree on the left
 * `layouts/partials/prevnext.html` - the template that generates the previous & next links at the bottom of a content page

### shortcodes

Shortcodes can be used from within content pages:

 * `layouts/shortcodes/content.html` - the shortcode used to include some content from another page - used for sharing content between pages
 * `layouts/shortcodes/info.htmk` - used to display an inset block with some information that should be highlighted
 * `layouts/shortcodes/widelink.htmk` - render a wide orange link that can be used inside some content


## hugo docs

Because the site is based on hugo - you can use any of the shortcodes, functions and variables listed in the [hugo documentation](https://gohugo.io/documentation/)
