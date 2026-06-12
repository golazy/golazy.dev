+++
title = "Embedding and Deployment"
description = "Package templates, public files, and content into one executable and configure it at runtime."
category = "Digging Deeper"
weight = 80
outcomes = [
  "How application resources are embedded.",
  "Why template and asset changes require a rebuild.",
  "How to build and run the application binary.",
  "Which runtime configuration exists today."
]
+++

## Embed application resources

GoLazy applications use `embed.FS`:

```go
//go:embed views public
var Files embed.FS
```

Sub-filesystems keep consumers scoped:

```go
func Views() (fs.FS, error) {
    return fs.Sub(Files, "views")
}

func Public() (fs.FS, error) {
    return fs.Sub(Files, "public")
}
```

Services can use the same pattern for embedded Markdown or other application
content.

## Initialize embedded files

Open and validate embedded resources during application startup:

```go
views, err := app.Views()
if err != nil {
    panic(fmt.Errorf("open embedded views: %w", err))
}

renderer, err := lazycontroller.NewRenderer(views)
if err != nil {
    panic(fmt.Errorf("initialize renderer: %w", err))
}
```

Failing early prevents a server from starting with incomplete templates or
assets.

## Build one binary

Build the executable:

```sh
go build -o /tmp/sample-app ./cmd/app
```

Run it:

```sh
/tmp/sample-app
```

No template or public directory is required beside the binary.

## Configure the address

The sample executable reads `ADDR`:

```sh
ADDR=3000 /tmp/sample-app
ADDR=127.0.0.1:3000 /tmp/sample-app
```

A numeric value is treated as a port. A full value is passed directly to
`http.Server`.

Runtime configuration beyond `ADDR` belongs to the application until the
framework defines a stable configuration API.

## Rebuild on file changes

Embedded files are compiled into the executable. After changing:

- Views.
- Layouts.
- Public files.
- Embedded Markdown.

rebuild or restart `go run`.

The planned `lazy` command will automate this development loop, but it is not
part of the current release.

## Deployment checklist

Before deployment:

1. Run tests, race tests, and `go vet`.
2. Build the exact commit being deployed.
3. Start the binary with the production listen address.
4. Request the home page and at least one public asset.
5. Confirm logs and process supervision are configured by the deployment
   environment.

GoLazy intentionally leaves TLS termination, process supervision, and platform
configuration to the deployment environment and the Go standard library.
