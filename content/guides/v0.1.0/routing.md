+++
title = "Routing"
description = "Build routes on Go's ServeMux while preserving method handling and embedded public files."
category = "Core Framework"
weight = 40
outcomes = [
  "How the framework creates the application mux.",
  "How to register controller actions with standard-library patterns.",
  "How path values and unsupported methods are handled.",
  "How public files become the final root fallback."
]
+++

## Create the mux

Initialize the application context before creating routes:

```go
ctx := appinit.Context(context.Background())
mux := routes.New(ctx)
appinit.Draw(ctx, mux)
```

`routes.New` creates an `http.ServeMux` and installs the embedded public
handler at `/`.

## Draw application routes

All application routes are registered through:

```go
func Draw(ctx context.Context, mux *http.ServeMux)
```

A route combines a Go 1.22+ method pattern with a bound controller action:

```go
mux.Handle(
    "GET /posts",
    controller.Bind(
        ctx,
        posts.New,
        (*posts.PostsController).Index,
    ),
)
```

The framework does not replace `http.ServeMux`. Standard-library pattern
precedence and conflict behavior still apply.

## Path values

Declare path values in braces:

```go
mux.Handle(
    "GET /posts/{param}",
    controller.Bind(
        ctx,
        posts.New,
        (*posts.PostsController).Show,
    ),
)
```

Read the value from the request:

```go
slug := r.PathValue("param")
```

Use `GET /{$}` for the root page only. Without `{$}`, `/` is a subtree pattern.

## Method not allowed

Register an explicit method fallback for application paths:

```go
mux.Handle(
    "/posts",
    routes.MethodNotAllowed(http.MethodGet),
)
```

The handler returns `405 Method Not Allowed` and sets the `Allow` header.

Keep the allowed method list aligned with the method-specific routes for that
path.

## Public fallback

The application context installs the public handler:

```go
ctx = routes.WithPublic(
    ctx,
    http.FileServerFS(public),
)
```

The root fallback accepts `GET` and `HEAD`. Other methods receive `405 Method
Not Allowed`.

Do not install another root public handler in `Draw`; doing so would duplicate
framework responsibility and can cause route conflicts.

## Testing routes

Construct the complete handler without a network listener:

```go
func application() http.Handler {
    ctx := appinit.Context(context.Background())
    mux := routes.New(ctx)
    appinit.Draw(ctx, mux)
    return mux
}
```

Use `httptest.NewRequest` and `httptest.NewRecorder` to verify status, headers,
and response bodies.
