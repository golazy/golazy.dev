+++
title = "Testing"
description = "Combine focused package tests with full application HTTP integration tests."
category = "Digging Deeper"
weight = 70
outcomes = [
  "Where different kinds of tests belong.",
  "How to test the complete handler without opening a port.",
  "How to verify status, headers, public files, and concurrency.",
  "Which release checks to run."
]
+++

## Test at the ownership boundary

Keep focused tests beside the package they exercise:

- Framework renderer and routing tests live in `golazy`.
- Service tests live beside application services.
- Adapter tests live beside `lib` packages.
- Executable helper tests live in `cmd/app`.

Complete application behavior belongs in `sample_app/test`.

## Construct the real handler

Integration tests should use the same composition path as `main`:

```go
func application() http.Handler {
    ctx := appinit.Context(context.Background())
    mux := routes.New(ctx)
    appinit.Draw(ctx, mux)
    return mux
}
```

This catches broken dependency wiring, route registration, template rendering,
and public-file setup together.

## Exercise requests

Use the standard library:

```go
request := httptest.NewRequest(http.MethodGet, "/posts", nil)
response := httptest.NewRecorder()

application().ServeHTTP(response, request)

if response.Code != http.StatusOK {
    t.Fatalf("status = %d", response.Code)
}
```

Useful assertions include:

- Status code.
- `Content-Type`.
- `Allow` for method errors.
- Escaped or rendered body content.
- `404` behavior for missing records and files.
- Embedded public-file responses.

## Verify request-local controllers

Controller state is mutable, so integration tests should exercise concurrent
requests:

```go
var wait sync.WaitGroup
for range 20 {
    wait.Add(1)
    go func() {
        defer wait.Done()
        response := httptest.NewRecorder()
        handler.ServeHTTP(
            response,
            httptest.NewRequest(http.MethodGet, "/posts", nil),
        )
        if response.Code != http.StatusOK {
            t.Errorf("status = %d", response.Code)
        }
    }()
}
wait.Wait()
```

Run this under the race detector.

## Test rendering boundaries

Framework renderer tests should verify:

- Ordinary values are HTML-escaped.
- View output is composed into the layout.
- Missing views and layouts return contextual errors.
- A renderer cannot be initialized without the default layout.

Application tests should verify only the behavior the application owns.

## Release verification

For the framework:

```sh
go test ./...
go test -race ./...
go vet ./...
```

For the sample application:

```sh
go test ./...
go test -race ./...
go vet ./...
go build -o /tmp/sample-app ./cmd/app
```

Use a temporary `GOCACHE` and `CC=/usr/bin/gcc` when required by the managed
development environment.
