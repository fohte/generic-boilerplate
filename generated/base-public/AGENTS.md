# AGENTS.md

## Code organization rules

### Split files before they grow past ~500 lines of production code

When a change would push a file's non-test code past ~500 lines, split it along responsibility seams before adding more. Splits must be move-only commits: no logic changes, renames, or reformatting mixed in. Keep external import paths unchanged by keeping the entrypoint file in place and re-exporting the pieces you split out into new files. Tests move together with the code they verify.

Prefer creating a new focused file over appending to the largest existing one.

### テストや story のためだけに export しない

テストや story は、production のコードと同じ公開 API を通して対象を使う。内部の関数・定数・型をテストのためだけに export しない。単体でテストしたいロジックは別モジュールに切り出して production もそこから import し、story で描画する View は container とは別のファイルに置く。

`knip --production` がこの違反を検出する。指摘を `@internal` / `@public` タグや knip の `ignore` 系の設定で隠さない。
