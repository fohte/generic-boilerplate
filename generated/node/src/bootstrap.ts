// Must run before any instrumented module is imported, otherwise
// @opentelemetry/auto-instrumentations-node cannot patch them — hence
// `import './bootstrap'` as the very first statement of `index.ts`.
// This alone is not enough for built-in modules like `http`, though — see
// otel-register.mjs: it must be preloaded via `node --import` before this
// file (or anything else) is imported, or `http.Server` is never patched.
import {
  initObservability,
  isObservabilityConfigured,
} from '@fohte/service-kit/observability'

if (isObservabilityConfigured(process.env)) {
  initObservability(process.env)
}

// `@fohte/service-kit/observability` also exports `captureWithFingerprint`,
// for reporting an error at an interop boundary under a stable fingerprint
// (for Sentry grouping) without changing control flow. Call it once, right
// before re-throwing a wrapped BoundaryError (see src/errors.ts):
//
//   import { captureWithFingerprint } from '@fohte/service-kit/observability'
//
//   catch (caughtErr) {
//     const wrapped = new TaskStorePersistenceError('failed to save', caughtErr)
//     captureWithFingerprint(wrapped, 'task-store.persistence-error')
//     throw wrapped
//   }
