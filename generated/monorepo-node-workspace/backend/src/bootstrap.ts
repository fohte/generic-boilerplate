/* eslint-disable @typescript-eslint/no-unsafe-call, @typescript-eslint/strict-boolean-expressions --
 * @fohte/service-kit ships .d.ts files that reference internal `@/...`
 * path aliases unresolvable from consumer projects, so typescript-eslint
 * sees these calls as untyped. tsc passes thanks to skipLibCheck.
 */
// Must run before any instrumented module is imported, otherwise
// @opentelemetry/auto-instrumentations-node cannot patch them. Either
// `import './bootstrap'` as the very first statement of the entrypoint,
// or pre-load with `node --import` (ESM) / `--require` (CJS).
import {
  initObservability,
  isObservabilityConfigured,
} from '@fohte/service-kit/observability'

if (isObservabilityConfigured(process.env)) {
  initObservability(process.env)
}
