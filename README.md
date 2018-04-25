# CiStatus

This is a simple server storage for CI build statuses of different types. Build status consists of:
* link - custom link e.g. to CI server's task that generated this build
* badge - metadata used to generate badge with https://shields.io

Both link and badge can be used in a README's markdown e.g.
```markdown
[![Build](https://ci-status.domain.com/build/packages/http-utils/badge)](https://ci-status.domain.com/build/packages/http-utils/link) 
[![Coverage](https://ci-status.domain.com/coverage/packages/http-utils/badge)](https://ci-status.domain.com/coverage/packages/http-utils/link) 
```

## Installation

```bash
$ mix deps.get
```
