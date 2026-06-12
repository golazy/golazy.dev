+++
title = "Controllers"
description = "Use request-local controllers to coordinate services, prepare view data, and return HTTP errors."
category = "Core Framework"
weight = 30
outcomes = [
  "How controller constructors and actions are shaped.",
  "Why every request receives a new controller.",
  "How to set render data and select a layout.",
  "How errors become HTTP responses."
]
+++

## Controller shape

A concrete controller embeds the application's base controller and declares
only the services it needs:

```go
type PostsController struct {
    controllers.BaseController
    posts *postservice.Service
}
```

The constructor receives an application context:

```go
func New(ctx context.Context) (*PostsController, error) {
    base, err := controllers.NewBaseController(ctx, "posts")
    if err != nil {
        return nil, err
    }

    posts, ok := postservice.FromContext(ctx)
    if !ok {
        return nil, fmt.Errorf(
            "posts service is missing from application context",
        )
    }

    return &PostsController{
        BaseController: base,
        posts: posts,
    }, nil
}
```

Do not add renderer, service, request, writer, or view-path parameters to
concrete constructors. Those dependencies are resolved from context or fixed by
the controller.

## Request-local construction

Routes use `lazycontroller.Bind`:

```go
lazycontroller.Bind(
    ctx,
    posts.New,
    (*posts.PostsController).Index,
)
```

For each request, `Bind`:

1. Adds the response writer to the controller context.
2. Calls the controller factory.
3. Runs the selected action.
4. Converts any returned error into an HTTP response.

This lifecycle prevents mutable render data from leaking between requests.

## Actions

Actions use one signature:

```go
func (c *Controller) Action(
    w http.ResponseWriter,
    r *http.Request,
) error
```

An action can use `w` and `r` directly, but ordinary HTML actions normally set
data and render:

```go
func (c *HomeController) Index(
    _ http.ResponseWriter,
    _ *http.Request,
) error {
    c.Set("title", "Home")
    return c.Render("index")
}
```

## View data

`Set` adds a value to the render data:

```go
c.Set("posts", c.posts.List())
```

The value is available to both the controller view and its layout. Template
data is escaped by default.

## Layouts

Controllers use the `app` layout by default. Select another embedded layout
before rendering:

```go
c.SetLayout("admin")
return c.Render("dashboard")
```

This resolves `layouts/admin.html.tpl`.

## HTTP errors

Return `lazycontroller.Error` when an expected failure needs a specific status:

```go
return lazycontroller.Error(
    http.StatusNotFound,
    fmt.Errorf("post %q not found", slug),
)
```

Unexpected errors become `500 Internal Server Error`. The response contains the
standard status text, while the wrapped error remains available to callers and
future logging infrastructure.

## Controller design

Keep actions short:

- Read route values and request input.
- Call services.
- Set view data.
- Render or return an error.

Move reusable application work into services rather than growing controller
methods into business-logic containers.
