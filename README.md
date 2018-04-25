# CiStatus

This is a simple server storage for CI build statuses of different types. Build status consists of:
* link - custom link e.g. to CI server's task that generated this build
* badge - metadata used to generate badge with https://shields.io

Both link and badge can be used in a README's markdown e.g.
```markdown
[![Build](https://ci-status.domain.com/build/packages/http-utils/badge)](https://ci-status.domain.com/build/packages/http-utils/link) 
[![Coverage](https://ci-status.domain.com/coverage/packages/http-utils/badge)](https://ci-status.domain.com/coverage/packages/http-utils/link) 
```

## Configuration
Configure prod.exs or dev.exs file
```
use Mix.Config

config :ci_status, CiStatus.Repo,
  adapter: Sqlite.Ecto2,
  database: "ci_statuses.sqlite3"

config :ci_status, port: 80
```

## Installation

Set your required environment to prod or dev
```bash
$ MIX_ENV=prod
```

Download dependencies
```bash
$ mix deps.get
```

Create database
```bash
$ mix ecto.migrate
```

Run application
```bash
$ mix run --no-halt
```
