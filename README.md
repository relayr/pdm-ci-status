# CiStatus

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

< HTTP/1.1 301 Moved Permanently
< location: https://img.shields.io/badge/coverage-73%25-orange.svg
```

---

##### Get link for CI build

```
> GET https://ci-status.domain.com/packages/http-utils/versions/0.1.3/coverage/link

< HTTP/1.1 301 Moved Permanently
< location: https://ci.domain.com/jobs/148132
```
