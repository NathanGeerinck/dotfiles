---
name: tnt-cloudflare-turnstile
description: Add Cloudflare Turnstile (CAPTCHA) bot protection to a form in a T&T dry/Oak PHP framework project. Use when the user wants to add Turnstile, a CAPTCHA, or bot/spam protection to a form (newsletter subscribe, contact, etc.) in a dry-framework site, or mentions "make cloudflare work" / cf-turnstile.
---

# Cloudflare Turnstile in dry/Oak PHP projects

Integrates [Cloudflare Turnstile](https://developers.cloudflare.com/turnstile/) into a form. Two halves: render the widget client-side, verify the token server-side. This skill targets the `dry` template engine + `Oak` container stack (custom `.tpl` compiler, `Oak\Application` boots Dotenv).

## Prerequisites / how this stack works

- **Env is loaded by `Oak\Application`'s constructor** (`Dotenv::createImmutable(...)->load()`), which runs before `app/configuration/main.inc.php`. So `$_ENV[...]` is populated by the time `main.inc.php` runs. Config values are read via `getenv()` in `config/app.php`.
- **The `.tpl` compiler tokenizes expressions as raw PHP** (`token_get_all('<?php ' . $expr)`), so namespaced constants like `\app\TURNSTILE_SITE_KEY` work directly inside `{% if %}` and `{{ }}`. (Closing tags are `{% /if %}`, not `{% endif %}`.)
- **Compiled templates are cached** in `cache/templates/` and invalidated by mtime, so `.tpl` edits recompile automatically.

## Steps

### 1. Env keys

Add to `.env.example` (and the real `.env`):

```
CLOUDFLARE_TURNSTILE_SITE_KEY=
CLOUDFLARE_TURNSTILE_SECRET_KEY=
```

Site key is public (rendered in HTML); secret key is server-only. Get both from the Cloudflare dashboard → Turnstile.

### 2. Expose the site key as a constant

In `app/configuration/main.inc.php` (namespace `app`), near the other `define()`s:

```php
define('app\\TURNSTILE_SITE_KEY', $_ENV['CLOUDFLARE_TURNSTILE_SITE_KEY'] ?? '');
```

### 3. Load the Turnstile script (base template)

In the base layout's `scripts` block, gated on the key so it's a no-op when unconfigured:

```html
{% if \app\TURNSTILE_SITE_KEY %}
	<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
{% /if %}
```

### 4. Render the widget inside the form partial

Place inside the `<form>`, before the submit button:

```html
{% if \app\TURNSTILE_SITE_KEY %}
	<div class="cf-turnstile" data-sitekey="{{ \app\TURNSTILE_SITE_KEY }}"></div>
{% /if %}
```

The widget auto-injects a hidden `cf-turnstile-response` input into the form on solve.

### 5. Server-side verification helper

Add to the controller handling the form submit:

```php
/**
 * Validates the Cloudflare Turnstile token that accompanies a form submission.
 * Fails open when no secret is configured (e.g. local development) so forms
 * keep working, and fails closed on a missing token or a failed verification.
 */
private static function verify_turnstile(): bool
{
    $secret = $_ENV['CLOUDFLARE_TURNSTILE_SECRET_KEY'] ?? '';

    if ($secret === '') {
        return true; // fail open: unconfigured environments keep working
    }

    $token = $_POST['cf-turnstile-response'] ?? '';

    if ($token === '') {
        return false;
    }

    $ch = curl_init('https://challenges.cloudflare.com/turnstile/v0/siteverify');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_TIMEOUT => 5,
        CURLOPT_POSTFIELDS => http_build_query([
            'secret' => $secret,
            'response' => $token,
            'remoteip' => $_SERVER['REMOTE_ADDR'] ?? '',
        ]),
    ]);
    $response = curl_exec($ch);

    if ($response === false) {
        return false;
    }

    $result = json_decode($response, true);

    return is_array($result) && !empty($result['success']);
}
```

### 6. Gate the form handling on verification

**Critical:** fold the check into the submit guard — do NOT early-`return` from a method with a strict return type.

```php
if ($form->validate() && empty($form->get('honing')) && self::verify_turnstile()) {
    // ... process submission ...
}
```

On failure the submission is skipped and the form re-renders so the user can retry.

## Pitfall that WILL bite you

If the handler is a method typed `: Template` (e.g. `getBaseTemplate(...): Template`) whose callers immediately do `$tpl->render(...)`, an early `return $form;` on Turnstile failure returns a `dry\Form` (which does **not** extend `dry\Template`) → **fatal `TypeError`, 500s the whole page** on every failed verification. Always fold `verify_turnstile()` into the boolean guard instead of early-returning a non-`Template` value.

## Verify it works

- `php -l` the changed PHP files.
- Confirm env→constant resolution at runtime:
  ```php
  require "vendor/autoload.php";
  (Dotenv\Dotenv::createImmutable(getcwd()))->load();
  define('app\TURNSTILE_SITE_KEY', $_ENV['CLOUDFLARE_TURNSTILE_SITE_KEY'] ?? '');
  echo \app\TURNSTILE_SITE_KEY; // should print the site key
  ```
- Load the page: the widget should appear and the `<script>` should be present. Submit without solving → submission rejected; solve → succeeds.
- Remember to add Turnstile to **each** form separately (e.g. newsletter subscribe AND contact) — the widget/verify is per-form.
