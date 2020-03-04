---
title: Lsctl command reference
description: CLI reference for lsctl commands
keywords: lsctl, CLI, command line, command line tool, reference
weight: 9
hidden: true
---

## lcstl

The license server command line interface

```text
lsctl [global options] command [command options] [arguments...]
```

#### Commands

|**Command**|**Description**|
|----|----|
| `lcstl login`     | Log into the License Server, preserve configuration |
| `lcstl info`      | License server information |
| `lcstl client`    | Manage clients |
| `lcstl license`   | Manage/Load License server's licenses |
| `lcstl users`     | Manage users |
| `lcstl ha`        | License server High Availability setup |
| `lcstl help`, `h` | Shows a list of commands or help for one command |

#### Options

|**Option**|**Description**|
|----|----|
| `--help`, `-h` | show help |
| `--version`, `-v`| print the version |

## lcstl info

License server information

```text
lsctl info command [command options] [arguments...]
```

#### Commands

|**Command**|**Description**|
|----|----|
| `lcstl info health` | Display Health info |
| `lcstl info hostids` | Display License server's hostIDs |
| `lcstl info endpoint` | Display License server's endpoint |
| `lcstl info version` | Display versions |

#### Options

|**Option**|**Description**|
|----|----|
| `--help`, `-h` | show help |


## lcstl client

Manage attached Portworx clients

```text
lsctl client command [command options] [arguments...]
```

#### Commands

|**Command**|**Description**|
|----|----|
| `lcstl client ls`    | Display clients details |
| `lcstl client usage` | Display clients checked-out features |

#### Options

|**Option**|**Description**|
|----|----|
| `--help`, `-h` | show help |

## lsctl login

Log in to the license server

```text
lsctl login [OPTIONS] <endpoint> [<instance>]
```

#### Options

|**Option**|**Description**|
|----|----|
| `-u` value, `--username` value | Specify username |
| `-p` value, `--password` value | Specify password |
| `--allow-unknown-root-ca`      | Allow the license server to import an unknown SSL Root certificate authority |

## lsctl license

Manage and load license server's licenses

```text
lsctl license command [command options] [arguments...]
```

#### Commands

|**Command**|**Description**|
|----|----|
| `lsctl license ls`        | Display available license features details |
| `lsctl license activate`  | Activate licensing codes for license server |
| `lsctl license add`       | Adds a binary license file to license server |

#### Options

|**Option**|**Description**|
|----|----|
| `--help`, `-h` | show help |

## lsctl users

Manage users

```text
lsctl users command [command options] [arguments...]
```

#### Commands

|**Command**|**Description**|
|----|----|
| `lsctl users ls`                        | Lists users |
| `lsctl users create`                    | Create new user |
| `lsctl users setrole`                   | Set existing user's roles |
| `lsctl users passwd`                    | Change existing user's password |
| `lsctl users delete`, `lsctl users rm`  | Delete user by ID |

#### Options

|**Option**|**Description**|
|----|----|
| `--help`, `-h` | show help |

## lsctl ha

License server High Availability setup

```text
lsctl ha command [command options] [arguments...]
```

#### Commands

|**Command**|**Description**|
|----|----|
| `lsctl ha info` | Display instance High Availability details |
| `lsctl ha conf` | Configure License servers HA pair |

#### Options

|**Option**|**Description**|
|----|----|
| `--help`, `-h` | show help |







<!--

```
/opt/pwx-ls/bin/lsctl -h
```
```
NAME:
   lsctl - A new cli application

USAGE:
   lsctl [global options] command [command options] [arguments...]

VERSION:
   1.0.0-31-g138f1f4

COMMANDS:
     login    Log into the License Server, preserve configuration
     info     License server information
     client   Manage clients
     license  Manage/Load License server's licenses
     users    Manage users
     ha       License server High Availability setup
     help, h  Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --help, -h     show help
   --version, -v  print the version
```

```
/opt/pwx-ls/bin/lsctl info -h
```
```
NAME:
   lsctl info - License server information

USAGE:
   lsctl info command [command options] [arguments...]

COMMANDS:
     health    Display Health info
     hostids   Display License server's hostIDs
     endpoint  Display License server's endpoint
     version   Display versions

OPTIONS:
   --help, -h  show help
```


```
/opt/pwx-ls/bin/lsctl client -h
```
```
NAME:
   lsctl client - Manage clients

USAGE:
   lsctl client command [command options] [arguments...]

COMMANDS:
     ls     Display clients details
     usage  Display clients checked-out features

OPTIONS:
   --help, -h  show help
```

```
/opt/pwx-ls/bin/lsctl login -h
```
```
NAME:
   lsctl login - Log into the License Server, preserve configuration

USAGE:
   lsctl login [OPTIONS] <endpoint> [<instance>]

OPTIONS:
   -u value, --username value  Specify username
   -p value, --password value  Specify password
   --allow-unknown-root-ca     Specify if we should import unknown SSL Root CA
```
```
/opt/pwx-ls/bin/lsctl license -h
```
```
NAME:
   lsctl license - Manage/Load License server's licenses

USAGE:
   lsctl license command [command options] [arguments...]

COMMANDS:
     ls        Display available license features details
     activate  Activate licensing codes for license server
     add       Adds a binary license file to license server

OPTIONS:
   --help, -h  show help
```
```
/opt/pwx-ls/bin/lsctl users -h
```
```
NAME:
   lsctl users - Manage users

USAGE:
   lsctl users command [command options] [arguments...]

COMMANDS:
     ls          Lists users
     create      Create new user
     setrole     Set existing user's roles
     passwd      Change existing user's password
     delete, rm  Delete user by ID

OPTIONS:
   --help, -h  show help
```
```
/opt/pwx-ls/bin/lsctl ha -h
```
```
NAME:
   lsctl ha - License server High Availability setup

USAGE:
   lsctl ha command [command options] [arguments...]

COMMANDS:
     info  Display instance High Availability details
     conf  Configure License servers HA pair

OPTIONS:
   --help, -h  show help
``` -->
