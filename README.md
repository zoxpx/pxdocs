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

## hugo docs

Because the site is based on hugo - you can use any of the shortcodes, functions and variables listed in the [hugo documentation](https://gohugo.io/documentation/)
