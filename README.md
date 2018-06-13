# CiStatus

[![Build Status](https://travis-ci.org/relayr/pdm-ci-status.svg?branch=master)](https://travis-ci.org/relayr/pdm-ci-status)

This is a simple server storage for CI build statuses of different types. Build status consists of:
* link - custom link e.g. to CI server's task that generated this build
* badge - metadata used to generate badge with https://shields.io

Both link and badge can be used in a README's markdown e.g.
```markdown
[![Build](https://ci-status.domain.com/build/packages/http-utils/versions/latest/badge)](https://ci-status.domain.com/build/packages/http-utils/versions/latest/link) 
[![Coverage](https://ci-status.domain.com/coverage/packages/http-utils/versions/0.1.3/badge)](https://ci-status.domain.com/coverage/packages/http-utils/versions/0.1.3/link) 
```

## Configuration
Configure prod.exs or dev.exs file
```
use Mix.Config

config :ci_status, CiStatus.Db.Repo,
  adapter: Sqlite.Ecto2,
  database: "ci_statuses.sqlite3"

config :ci_status, port: 80
config :ci_status, shields_url: "https://img.shields.io"

import_config "prod.secret.exs"
```

Configure prod.secret.exs or dev.secret.exs file
```
use Mix.Config

config :ci_status, secret: "5eCr3t"
```

## Installation

Set your required environment to prod or dev
```bash
$ export MIX_ENV=prod
```

Download dependencies
```bash
$ mix deps.get
```

Create database
```bash
$ mix ecto.migrate
```

Test application
```bash
$ mix test
```

Run application
```bash
$ mix run --no-halt
```

## REST API

##### Set CI build status
This endpoint requires token authentication
```
> PUT https://ci-status.domain.com/packages/http-utils/versions/0.1.3/coverage
> x-ci-status-secret: 5eCr3t
> content-type: application/json

{
    "link": "https://ci.domain.com/jobs/148132",
    "badge": {
        "text": "73%",
        "color":"orange"
    }
}

< HTTP/1.1 200 OK

Status Updated
```

---

##### Get badge for CI build

```
> GET https://ci-status.domain.com/packages/http-utils/versions/0.1.3/coverage/badge

< HTTP/1.1 200 OK
< content-type: image/svg+xml
<
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="88" height="20"><linearGradient id="b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><clipPath id="a"><rect width="88" height="20" rx="3" fill="#fff"/></clipPath><g clip-path="url(#a)"><path fill="#555" d="M0 0h55v20H0z"/><path fill="#fe7d37" d="M55 0h33v20H55z"/><path fill="url(#b)" d="M0 0h88v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="110"><text x="285" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="450">coverage</text><text x="285" y="140" transform="scale(.1)" textLength="450">coverage</text><text x="705" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="230">73%</text><text x="705" y="140" transform="scale(.1)" textLength="230">73%</text></g> </svg>
```

---

##### Get link for CI build

```
> GET https://ci-status.domain.com/packages/http-utils/versions/0.1.3/coverage/link

< HTTP/1.1 301 Moved Permanently
< location: https://ci.domain.com/jobs/148132
```
