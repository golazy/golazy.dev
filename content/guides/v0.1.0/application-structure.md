+++
title = "Application Structure"
description = "Learn the conventional directories and ownership boundaries of a GoLazy application."
category = "Start Here"
weight = 20
outcomes = [
  "The responsibility of each application directory.",
  "Which behavior belongs in the framework and which belongs in the app.",
  "Where startup, routing, templates, services, and tests live."
]
+++

## The application tree

A GoLazy application keeps its executable small and places application behavior
under `app`:

```text
app/
  controllers/
  init/
  public/
  services/
  views/
cmd/app/
lib/
test/
```

The structure is conventional, but every directory contains ordinary Go,
standard-library templates, or static files.

## `app/controllers`

Controllers translate HTTP requests into application work. A concrete
controller embeds the application `BaseController`, resolves its services in
`New`, and exposes action methods.

Controller constructors receive only `context.Context`:

```go
func New(ctx context.Context) (*PostsController, error)
```

Controllers are request-local. Never cache a concrete controller or share it
between requests because render data and response state are mutable.

## `app/init`

`app/init/context.go` is the composition root. It initializes shared
dependencies once and places them into a context.

`app/init/routes.go` is the routing table. Its public entry point is:

```go
func Draw(ctx context.Context, mux *http.ServeMux)
```

`Draw` receives the framework-created mux. It does not create or return a mux,
and it does not install the public fallback.

## `app/services`

Services contain application behavior that does not belong to HTTP handling or
template rendering. Each service defines typed `WithContext` and `FromContext`
helpers so its dependency contract stays visible.

Services should be deterministic where practical and independently testable.

## `app/views`

Views use Go's `html/template` syntax:

```text
app/views/layouts/<layout>.html.tpl
app/views/<controller>/<action>.html.tpl
```

The default layout is `layouts/app.html.tpl`. Controller view names are
relative to the controller's view path.

## `app/public`

Public files are embedded and served from the root fallback. For example:

```text
app/public/styles.css
```

is available as:

```text
/styles.css
```

Explicit application routes take precedence over the public fallback.

## `cmd/app`

The executable initializes the application and owns process-level concerns such
as the listen address and `http.Server`.

Keep business logic out of `main`. It should remain possible to construct the
complete handler in tests without starting a network listener.

## `lib`

Application-specific adapters can live in `lib`. The sample app keeps its
Goldmark adapter in `lib/markdown`, leaving the framework independent of that
third-party dependency.

## `test`

Package tests remain next to their code. Full application integration tests live
in `test` and construct the same context, mux, and routes used by the executable.

## Framework boundaries

Generic behavior belongs in the `golazy.dev` module:

- `golazy.dev/controller` owns action binding, rendering, and HTTP errors.
- `golazy.dev/routes` owns mux construction, public fallback, and method
  handling.

Application packages must not be imported by the framework.
