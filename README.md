# golazy.dev

Hugo marketing website and Go vanity-import host for `golazy.dev`.

The site includes a Hugo-powered guide catalog under `/guides/`. Guide content
lives in `content/guides`, navigation metadata in `data/guides.toml`, and guide
templates in `layouts/guides`.

## Development

```bash
hugo server
```

The development server is available at `http://localhost:1313`.

## Production build

```bash
hugo --minify
```

The generated site is written to `public/`. The `CNAME` file and all other
public assets are copied from `static/`.
