---
name: laravel
description: Laravel PHP framework conventions and best practices. Use when building Laravel applications, writing controllers, models, migrations, routes, middleware, form requests, policies, jobs, events, or any Laravel-specific code. Triggers include "Laravel", "Eloquent", "Artisan", "php artisan", routing, migrations, or working with Laravel projects.
---

# Laravel 12

Opinionated PHP framework with expressive syntax and well-defined conventions.

## Project Structure

```
app/
├── Http/
│   ├── Controllers/      # Request handlers
│   ├── Middleware/        # HTTP middleware
│   └── Requests/          # Form request validation
├── Models/                # Eloquent models
├── Policies/              # Authorization policies
├── Jobs/                  # Queueable jobs
├── Events/                # Event classes
├── Listeners/             # Event listeners
├── Mail/                  # Mailable classes
└── Providers/             # Service providers
config/                    # Configuration files
database/
├── migrations/            # Database migrations
├── factories/             # Model factories
└── seeders/               # Database seeders
resources/
├── views/                 # Blade templates
└── css/js                 # Frontend assets
routes/
├── web.php                # Web routes
├── api.php                # API routes
└── console.php            # Artisan commands
```

## Artisan Commands

```bash
# Models
php artisan make:model Post -mfsc      # Model + migration, factory, seeder, controller
php artisan make:model Post --all      # All resources

# Controllers
php artisan make:controller PostController --resource    # CRUD controller
php artisan make:controller PostController --api         # API controller
php artisan make:controller ShowPost --invokable         # Single action

# Other
php artisan make:migration create_posts_table
php artisan make:request StorePostRequest
php artisan make:policy PostPolicy --model=Post
php artisan make:job ProcessPodcast
php artisan make:event OrderShipped
php artisan make:listener SendShipmentNotification
```

## Controllers

### Resource Controller
```php
class PostController extends Controller
{
    public function index(): View
    {
        return view('posts.index', ['posts' => Post::latest()->paginate()]);
    }

    public function store(StorePostRequest $request): RedirectResponse
    {
        Post::create($request->validated());
        return redirect()->route('posts.index');
    }

    public function show(Post $post): View  // Route model binding
    {
        return view('posts.show', compact('post'));
    }

    public function update(UpdatePostRequest $request, Post $post): RedirectResponse
    {
        $post->update($request->validated());
        return redirect()->route('posts.show', $post);
    }

    public function destroy(Post $post): RedirectResponse
    {
        $post->delete();
        return redirect()->route('posts.index');
    }
}
```

### Single Action Controller
```php
class ShowDashboard extends Controller
{
    public function __invoke(): View
    {
        return view('dashboard');
    }
}
```

## Routing

```php
// Resource routes
Route::resource('posts', PostController::class);
Route::apiResource('posts', PostController::class);  // API (no create/edit)

// Single routes
Route::get('/dashboard', ShowDashboard::class)->name('dashboard');
Route::get('/users/{user}', [UserController::class, 'show'])->name('users.show');

// Route groups
Route::middleware(['auth'])->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit']);
});

// Livewire pages
Route::livewire('/posts', 'pages::posts.index');
```

## Eloquent Models

```php
class Post extends Model
{
    protected $fillable = ['title', 'content', 'user_id'];

    protected $casts = [
        'published_at' => 'datetime',
        'is_featured' => 'boolean',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class);
    }

    // Scopes
    public function scopePublished(Builder $query): Builder
    {
        return $query->whereNotNull('published_at');
    }
}
```

### Query Patterns
```php
// Eager loading (prevent N+1)
$posts = Post::with(['user', 'comments'])->get();

// Chunking large datasets
Post::chunk(100, function ($posts) {
    foreach ($posts as $post) { /* ... */ }
});

// Upserts
Post::upsert([
    ['id' => 1, 'title' => 'Updated'],
    ['id' => 2, 'title' => 'New'],
], ['id'], ['title']);
```

## Form Requests

```php
class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;  // Or use policies
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'content' => ['required', 'string'],
            'published_at' => ['nullable', 'date'],
        ];
    }
}
```

## Migrations

```php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('content');
            $table->timestamp('published_at')->nullable();
            $table->timestamps();

            $table->index('published_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('posts');
    }
};
```

## Authorization (Policies)

```php
class PostPolicy
{
    public function update(User $user, Post $post): bool
    {
        return $user->id === $post->user_id;
    }

    public function delete(User $user, Post $post): bool
    {
        return $user->id === $post->user_id || $user->is_admin;
    }
}

// Usage in controller
$this->authorize('update', $post);

// Usage in Blade
@can('update', $post) ... @endcan
```

## Best Practices

1. **Use Form Requests** for validation, not controller logic
2. **Eager load relationships** to prevent N+1 queries
3. **Use policies** for authorization, not controller checks
4. **Type-hint dependencies** for automatic injection
5. **Use route model binding** instead of manual lookups
6. **Keep controllers thin** — move business logic to services/actions
7. **Use queued jobs** for slow operations (email, API calls)

## Laravel Boost

For AI-powered development, install Laravel Boost:
```bash
composer require laravel/boost --dev
php artisan boost:install
```

Provides MCP tools for inspecting routes, database, config, and more.

## References

For detailed docs, see `references/`:
- `controllers.md` — Controller patterns
- `eloquent.md` — Model conventions
- `routing.md` — Route definitions
