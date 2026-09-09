---
name: tnt-upgrade-dry-gulp
description: Upgrade a T&T dry project's frontend build from a hand-rolled gulp 4 + node-sass setup to gulp 5 via @tallieu_tallieu/dry-gulp-tasks, with yarn 4 and a modern node. Use when the user wants to upgrade gulp, replace node-sass with dart sass, get rid of the local gulp/ task folder, move a dry project from npm to yarn, or when `yarn dev` / `gulp` fails on a modern node version.
---

# Upgrading the gulp toolchain in a dry project

Legacy dry projects carry a `gulp/` folder of hand-written tasks (`css.js`, `javascript.js`, `images.js`, `favicons.js`, `watch.js`) built on gulp 4, browserify, `gulp-sass` 4 and `node-sass`. `node-sass` pins the project to node 14 or older and needs a compiler toolchain to install.

`@tallieu_tallieu/dry-gulp-tasks` replaces that entire folder with one package that bundles gulp 5, dart sass, rollup, imagemin and favicons. Reference implementations: `musicmania-php7` and `dry-base`.

## What changes

| Before | After |
| --- | --- |
| `gulp/` folder of task files | deleted, tasks come from the package |
| `gulpfile.js` CommonJS | `gulpfile.js` ESM, `"type": "module"` |
| browserify + babelify | rollup + babel (inside the package) |
| `gulp-sass` 4 / node-sass | dart `sass` |
| `gulp-imagemin` 6, `gulp-favicons` 2 | imagemin 9, favicons 7 |
| `gulp-rev` + manual `rev-manifest.json` | built-in rev transformer |
| npm, node 14 | yarn 4, node 22.14.0 |

`rev-manifest.json` keeps the same shape, so `\dry\asset_path()` in the templates needs no change.

## Steps

### 1. Inventory what the old tasks actually did

Before deleting `gulp/`, read each task and note the real `src`/`dest` pairs, then check them against the repository. These drift: an `imgTask` pointing at `style/img/**/*` in a project that only has `assets/img/` has been silently producing nothing, and any `url(img/…)` in the sass has been broken. Grep the sass for `url(` and the templates for `build/` to find where the output is expected.

Also list the external JS dependencies that survive (`grep -rhoE "require\(['\"][^.]" js`), everything else in `package.json` is build tooling that goes away.

### 2. `package.json`

```json
{
  "name": "project_name",
  "type": "module",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "dev": "gulp",
    "build": "gulp build --production",
    "styles": "gulp styles --production"
  },
  "dependencies": {
    "imagesloaded": "^4.1.4"
  },
  "devDependencies": {
    "@tallieu_tallieu/dry-gulp-tasks": "^1.2.4"
  },
  "packageManager": "yarn@4.6.0"
}
```

`"type": "module"` is required, the package is ESM-only. Keep runtime libraries that the app's JS imports under `dependencies`; drop every `gulp-*`, `babel*`, `browserify`, `vinyl-*`, `del`, `imagemin-*` entry.

### 3. `.yarnrc.yml` and `.node-version`

```yaml
# .yarnrc.yml
nodeLinker: node-modules
```

```
22.14.0
```

Pick a node version the dry-docker image installed and for which corepack was enabled (16.20.1 and up). Add `.yarn/` and `yarn-error.log` to `.gitignore`; commit `yarn.lock`.

### 4. `gulpfile.js`

```js
import gulp from "gulp";

import tasks from "@tallieu_tallieu/dry-gulp-tasks";

export const cssTask = tasks.cssTask({
  src: "style/sass/*.scss",
  dest: "build/css",
});

export const jsTask = tasks.jsTask({
  src: "js/*.js",
  dest: "build/js",
});

export const imgTask = tasks.imageTask({
  src: "assets/img/**/*",
  dest: "build/css/img",
  optimize: true,
});

export const faviconsTask = tasks.faviconsTask({
  src: "assets/favicons/favicon.png",
  dest: "build/favicons",
  options: {
    appName: "Project",
    developer: "Tallieu & Tallieu",
    developerURL: "https://tnt.be",
  },
});

export const watchTask = tasks.watchTask([
  [["style/sass/**/*.scss", "app/templates/styleguide/**/*.scss"], cssTask],
  [["js/**/*.js", "app/templates/styleguide/**/*.js", "!js/dry/**/*.js"], jsTask],
  ["assets/img/**/*", imgTask],
]);

export const build = gulp.series(cssTask, jsTask, faviconsTask, imgTask);
export const styles = gulp.series(cssTask, imgTask);

export default watchTask;
```

Use `style/sass/*.scss` (one level) rather than the package default `style/sass/**/*.scss`, so only the real entry points compile. `faviconsTask` takes a **single source file**, not a glob.

`imgTask`'s `dest` must be the directory that the compiled CSS's relative `url()` calls resolve to: CSS lands in `build/css/`, so `url(img/arrow.svg)` needs `build/css/img`.

### 5. Delete the old toolchain

```sh
rm -rf gulp .babelrc node_modules package-lock.json
```

`.babelrc` must go. `@rollup/plugin-babel` passes its own presets but still picks up a project `.babelrc`, and a stale one referencing `@babel/preset-react` (no longer installed) fails the JS task.

### 6. Switch the Makefile from npm to yarn

Replace the `npm install` / `npm run dev` / `npm run build` targets with `yarn` / `yarn dev` / `yarn build`, and add a `styles` target if you exported one.

## Pitfalls that will bite you

**Sass glob imports must name the extension.** The package's `sassGlobTransformer` expands `@import 'path/**/*'` with a plain `globSync`, which matches **directories** as well as files, producing `@import '/abs/path/to/some-directory';` and:

```
Error: Can't find stylesheet to import.
26 │ @import '/var/www/html/app/templates/styleguide/atoms/wysiwyg';
```

Fix the sass, not the package:

```scss
// before
@import '../../app/templates/styleguide/atoms/**/*';
// after
@import '../../app/templates/styleguide/atoms/**/*.scss';
```

Globs that already end in `*.scss` (`@import 'settings/*.scss'`) are fine. The transformer rewrites out-of-tree matches to absolute paths, which dart sass loads happily.

**JS glob imports keep working.** `import '../app/templates/styleguide/**/*.js'` is handled by the package's `rollupTransformGlobImports`, so `babel-plugin-import-glob` is not needed.

**`slash-div` deprecation warnings flood the build.** `$rule / 1` is deprecated in dart sass and will break in Sass 2.0. These are warnings, not errors, so the upgrade is not blocked. To clear them add a `migrate` script and run it once:

```json
"migrate": "sass-migrator division -d ./style/sass/**"
```

**Dev builds also write revisions.** `useRevisions.addRevision` defaults to true in both modes, so `rev-manifest.json` churns on every `yarn dev` run. That is expected, `asset_path()` reads it either way, and it is gitignored.

**Run it in the container, not on the host.** The node version and yarn come from the container's nodenv/corepack: `docker compose exec <project>-site yarn build`.

## Verify it works

```sh
docker compose exec <project>-site yarn install
docker compose exec <project>-site yarn build
```

Then confirm the output rather than trusting the log:

```sh
cat rev-manifest.json                                  # style.css, app.js, hashed names
grep -o "<a-styleguide-selector>" build/css/style-*.css | wc -l   # globbed partials really compiled
ls build/css/img build/favicons | head
curl -s -o /dev/null -w "%{http_code}\n" "http://<project>.localhost/build/css/$(...)"
```

Compiling without error is not enough: if the sass glob silently matched nothing you get a valid but half-empty stylesheet. Always grep the built CSS for a selector that only exists in a globbed partial.

Finally smoke-test the watcher, which should do one full build and then idle:

```sh
docker compose exec -T <project>-site sh -c 'timeout 45 yarn dev'
```
