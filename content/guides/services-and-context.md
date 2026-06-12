+++
title = "Services and Context"
description = "Initialize shared dependencies once and expose them through typed context helpers."
category = "Core Framework"
weight = 60
outcomes = [
  "What belongs in the application composition root.",
  "How to define typed context helpers for a service.",
  "How controllers resolve dependencies.",
  "What should and should not be stored in context."
]
+++

## The composition root

`app/init/context.go` initializes shared dependencies once:

```go
func Context(ctx context.Context) context.Context {
    renderer, err := lazycontroller.NewRenderer(views)
    if err != nil {
        panic(err)
    }

    posts, err := postservice.New()
    if err != nil {
        panic(err)
    }

    ctx = lazycontroller.WithRenderer(ctx, renderer)
    ctx = postservice.WithContext(ctx, posts)
    ctx = lazyroutes.WithPublic(ctx, http.FileServerFS(public))
    return ctx
}
```

Embedded resource failures are programming or build errors, so the sample app
fails fast during startup.

## Typed context helpers

Each service owns an unexported key type and exported helpers:

```go
type contextKey struct{}

func WithContext(
    ctx context.Context,
    service *Service,
) context.Context {
    return context.WithValue(ctx, contextKey{}, service)
}

func FromContext(ctx context.Context) (*Service, bool) {
    service, ok := ctx.Value(contextKey{}).(*Service)
    return service, ok
}
```

An unexported key type prevents collisions with other packages.

## Resolve dependencies in constructors

Controller constructors validate their requirements:

```go
posts, ok := postservice.FromContext(ctx)
if !ok {
    return nil, fmt.Errorf(
        "posts service is missing from application context",
    )
}
```

This keeps concrete controller constructors uniform while still making missing
dependencies fail explicitly.

## Shared and request-local state

Application services may be shared when they are safe for concurrent use.
Controller instances must not be shared.

The framework derives a request-specific context containing the
`http.ResponseWriter` before constructing a controller. Render state stays on
that new controller instance.

Run race tests whenever shared service behavior changes:

```sh
go test -race ./...
```

## What belongs in context

In GoLazy, application context is dependency wiring. Store initialized services
and framework infrastructure there.

Do not use it as a general-purpose parameter bag for:

- Optional action arguments.
- View data.
- Values that can be passed directly within a service.
- Mutable request state owned by a controller.

Keep helper APIs typed and package-owned so dependency access remains
searchable and testable.

## Service design

Services should expose application operations rather than HTTP concepts. A
posts service can provide `List` and `Get`; the controller decides how those
results become status codes and HTML.

This separation allows focused unit tests without constructing requests or
templates.
