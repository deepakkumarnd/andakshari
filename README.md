# അന്താക്ഷരി · Andakshari

A Malayalam song search engine built with Rails 8.

Andakshari stores songs with lyrics, movie, and year metadata, and provides a hybrid search experience combining full-text and semantic vector search powered by Ollama embeddings and PostgreSQL's pgvector extension.

Songs are automatically chunked into lines on save, embedded using `nomic-embed-text`, and indexed with HNSW cosine similarity for fast nearest-neighbour retrieval. Search results are ranked by relevance, with songs matching both vector and text search surfaced as top results.

## Stack

- **Rails 8** — backend framework
- **PostgreSQL + pgvector** — relational storage and vector similarity search
- **Ollama** (`nomic-embed-text`) — local embedding model for semantic search
- **Hotwire / Turbo / Stimulus** — live interactions without full page reloads
- **Tailwind CSS v4** — styling with custom design tokens
- **Solid Queue** — background job processing (recurring tasks, notifications)
- **Devise** — OTP-based passwordless authentication
- **Pundit** — authorization policies

## Prerequisites

- Ruby 3.3.0
- PostgreSQL with the `pgvector` extension
- [Ollama](https://ollama.com) running locally with `nomic-embed-text` pulled

## Setup

**1. Install dependencies**

```bash
bundle install
```

**2. Pull the embedding model**

```bash
ollama pull nomic-embed-text
```

Ollama must be running (`ollama serve`) whenever the app starts, as embeddings are generated on song save.

**3. Create and migrate the database**

```bash
bin/rails db:create db:migrate
```

**4. Load the Solid Queue schema**

Solid Queue uses a separate schema file that must be loaded once:

```bash
bin/rails runner "load Rails.root.join('db/queue_schema.rb')"
```

**5. Start the development server**

```bash
bin/dev
```

This starts three processes together via Foreman:

| Process | Command | Purpose |
|---------|---------|---------|
| `web` | `bin/rails server` | Puma web server |
| `css` | `bin/rails tailwindcss:watch` | Tailwind CSS watcher |
| `jobs` | `bin/jobs` | Solid Queue worker (background jobs + recurring tasks) |

The app will be available at `http://localhost:3000`.

## Background jobs

The Solid Queue worker runs a daily recurring task at 02:00 that prunes notifications older than one month. It starts automatically with `bin/dev`.

To run a job manually:

```bash
bin/rails runner "PruneNotificationsJob.perform_now"
```

## Regenerating embeddings

If you need to rebuild vector embeddings for all existing songs:

```bash
bin/rails chunks:recreate
```
