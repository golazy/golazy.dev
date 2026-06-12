+++
title = "Routing"
description = "Build routes on Go's ServeMux while preserving method handling and embedded public files."
category = "Core Framework"
weight = 40
outcomes = [
  "How the framework creates the application mux.",
  "How to register controller actions and REST resources.",
  "How path values and unsupported methods are handled.",
  "How public files become the final root fallback."
]
+++

## Create the mux

Initialize the application context before creating routes:

```go
ctx := appinit.Context(context.Background())
mux := lazyroutes.New(ctx)
appinit.Draw(ctx, mux)
```

`lazyroutes.New` creates an `http.ServeMux` and installs the embedded public
handler at `/`.

## Draw Application Routes

All application routes are registered through:

```go
func Draw(ctx context.Context, mux *http.ServeMux)
```

Use `lazyroutes.Bind` when a route maps directly to one action:

```go
mux.Handle(
    "GET /{$}",
    lazyroutes.Bind(
        ctx,
        home.New,
        (*home.HomeController).Index,
    ),
)
```

For REST-style controllers, register a resource:

```go
lazyroutes.Resources(ctx, mux, posts.New)
```

`Resources` derives routes from the controller name. `PostsController` becomes:

```text
GET    /posts             Index
GET    /posts/new         New
POST   /posts             Create
GET    /posts/{post_id}   Show
GET    /posts/{post_id}/edit Edit
PATCH  /posts/{post_id}   Update
PUT    /posts/{post_id}   Update
DELETE /posts/{post_id}   Delete
```

Only implemented actions are registered. An action still has the standard
controller signature:

```go
func (c *PostsController) Show(
    w http.ResponseWriter,
    r *http.Request,
) error
```

## Path Values

Resource member routes derive their path value name from the singular resource
name:

```go
slug := r.PathValue("post_id")
```

Use `GET /{$}` for the root page only. Without `{$}`, `/` is a subtree pattern.
The framework does not replace `http.ServeMux`; standard-library pattern
precedence and conflict behavior still apply.

## Custom Resource Routes

Add collection and member routes inside the resource configuration:

```go
lazyroutes.Resources(ctx, mux, posts.New, func(r *lazyroutes.Resource[posts.PostsController]) {
    r.Get("search", (*posts.PostsController).Search)
    r.MemberGet("preview", (*posts.PostsController).Preview)
})
```

That registers:

```text
GET /posts/search
GET /posts/{post_id}/preview
```

Override derived names when an application needs different paths or parameter
names:

```go
lazyroutes.Resources(ctx, mux, posts.New, func(r *lazyroutes.Resource[posts.PostsController]) {
    r.Path("articles")
    r.Param("slug")
})
```

## Public fallback

The application context installs the public handler:

```go
ctx = lazyroutes.WithPublic(
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
    mux := lazyroutes.New(ctx)
    appinit.Draw(ctx, mux)
    return mux
}
```

Use `httptest.NewRequest` and `httptest.NewRecorder` to verify status, headers,
and response bodies.
