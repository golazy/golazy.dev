+++
title = "Getting Started"
description = "Run the sample application and follow a request from the router to an HTML response."
category = "Start Here"
weight = 10
outcomes = [
  "How to run the current sample application.",
  "How application context, routes, controllers, and views fit together.",
  "Where to make your first application change.",
  "Which parts of the future CLI are not available yet."
]
+++

## Prerequisites

GoLazy currently targets Go 1.26 or later. Confirm your installation:

```sh
go version
```

The `lazy` command is planned but not implemented yet. For now, begin with the
[`sample_app`](https://github.com/golazy/sample_app) repository.

## Run the application

From the sample application directory:

```sh
go run ./cmd/app
```

The server listens on `:8080` by default. Open
<http://localhost:8080> in a browser.

Use `ADDR` to select another port or address:

```sh
ADDR=3000 go run ./cmd/app
ADDR=127.0.0.1:3000 go run ./cmd/app
```

## Follow the startup path

The executable initializes dependencies, creates the framework mux, and draws
application routes:

```go
ctx := appinit.Context(context.Background())
mux := lazyroutes.New(ctx)
appinit.Draw(ctx, mux)
```

This order matters:

1. `Context` initializes the renderer, services, and public-file handler.
2. `lazyroutes.New` creates an `http.ServeMux` with the public fallback.
3. `Draw` registers the application's routes on that mux.
4. `http.Server` serves the completed handler.

## Follow one request

For `GET /posts`, the route binds a controller constructor to an action:

```go
mux.Handle(
    "GET /posts",
    lazycontroller.Bind(
        ctx,
        posts.New,
        (*posts.PostsController).Index,
    ),
)
```

`Bind` creates a new controller for the request. The action loads data into the
controller and renders a view:

```go
func (c *PostsController) Index(
    _ http.ResponseWriter,
    _ *http.Request,
) error {
    c.Set("title", "Posts")
    c.Set("posts", c.posts.List())
    return c.Render("index")
}
```

`Render("index")` resolves:

```text
app/views/posts/index.html.tpl
```

and composes it with:

```text
app/views/layouts/app.html.tpl
```

## Make a first change

Edit `app/views/home/index.html.tpl`, restart `go run ./cmd/app`, and reload the
home page. Templates are embedded at build time, so a running binary does not
read changed files from disk.

The future `lazy` command will provide hot reload. Until it exists, restart the
Go process after changing Go code, templates, embedded content, or public files.

## Verify the application

Run the complete test suite:

```sh
go test ./...
```

Before a release, also run:

```sh
go test -race ./...
go vet ./...
go build -o /tmp/sample-app ./cmd/app
```

Continue with [Application Structure](../application-structure/) for a map of
the repository.
