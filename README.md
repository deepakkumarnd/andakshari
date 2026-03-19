# അന്താക്ഷരി · Andakshari

A Malayalam song search engine built with Rails.

Andakshari stores songs with lyrics, movie, and year metadata, and provides a hybrid search experience combining full-text and semantic vector search powered by Ollama embeddings and PostgreSQL's pgvector extension.

Songs are automatically chunked into lines on save, embedded using `nomic-embed-text`, and indexed with HNSW cosine similarity for fast nearest-neighbour retrieval. Search results are ranked by relevance, with songs matching both vector and text search surfaced as top results.

## Stack

- **Rails 8** — backend framework
- **PostgreSQL + pgvector** — relational storage and vector similarity search
- **Ollama** (`nomic-embed-text`) — local embedding model for semantic search
- **Hotwire / Turbo** — live search results without full page reloads
- **Tailwind CSS v4** — styling with custom design tokens

## Setup

```bash
bin/setup
bin/rails db:migrate
bin/rails server
```

Requires a running Ollama instance with `nomic-embed-text` pulled:

```bash
ollama pull nomic-embed-text
```

To regenerate embeddings for all songs:

```bash
bin/rails chunks:recreate
```
