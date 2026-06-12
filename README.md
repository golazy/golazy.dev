# golazy.dev

Hugo marketing website and Go vanity-import host for `golazy.dev`.

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
