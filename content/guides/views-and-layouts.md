+++
title = "Views and Layouts"
description = "Render embedded html/template views through layouts with escaped data and explicit trusted HTML."
category = "Core Framework"
weight = 50
outcomes = [
  "How view and layout files are resolved.",
  "How controller data reaches templates.",
  "How GoLazy composes view content into a layout.",
  "Where the trusted HTML boundary belongs."
]
+++

## Embed views

The application embeds its templates:

```go
//go:embed views public
var Files embed.FS
```

`app.Views` returns the `views` subtree as an `fs.FS`. Startup passes that
filesystem to `lazycontroller.NewRenderer`.

The renderer requires a default layout:

```text
layouts/app.html.tpl
```

Missing embedded resources fail during application initialization rather than
on the first production request.

## Name views by controller and action

Controller view paths follow:

```text
app/views/<controller>/<action>.html.tpl
```

Given:

```go
controllers.NewBaseController(ctx, "posts")
```

this call:

```go
return c.Render("index")
```

loads:

```text
posts/index.html.tpl
```

## Set template data

Add values before rendering:

```go
c.Set("title", "Posts")
c.Set("posts", c.posts.List())
```

Templates access them by name:

```gotemplate
<h1>{{ .title }}</h1>

{{ range .posts }}
  <a href="/posts/{{ .Slug }}">{{ .Title }}</a>
{{ end }}
```

The same data map is available to the layout.

## Compose the layout

GoLazy executes the controller view first. It then passes the generated content
to the selected layout as `.content`:

```gotemplate
<!doctype html>
<html>
  <head>
    <title>{{ .title }}</title>
  </head>
  <body>
    <main>{{ .content }}</main>
  </body>
</html>
```

Use `SetLayout` before `Render` to select a layout other than `app`.

## Escaping and trusted HTML

Go's `html/template` escapes ordinary data according to its HTML context. Keep
user and application data as strings whenever possible.

Only convert HTML that was produced by a trusted renderer:

```go
body, err := markdown.Convert(post.Body)
if err != nil {
    return fmt.Errorf("render post markdown: %w", err)
}

c.Set("body", template.HTML(body))
```

`template.HTML` disables escaping. Never use it merely to make untrusted input
render as markup.

## Rendering errors

`Render` returns contextual errors for:

- Missing view files.
- Invalid view templates.
- View execution failures.
- Missing or invalid layouts.
- Layout execution failures.
- Response write failures.

Return those errors from the action so `lazycontroller.Handle` can produce the
HTTP response.
