import { config } from '@fohte/eslint-config'
import storybook from 'eslint-plugin-storybook'

export default config(
  {
    typescript: { typeChecked: true },
    errorHandling: {
      // Glob paths for files that interop with an external SDK/framework or
      // run at process startup (e.g. env validation, DB migrations, main
      // entrypoints) and therefore need throw/try-catch. Everywhere else,
      // model failures as neverthrow Result/ResultAsync values instead.
      interopBoundaryFiles: [],
    },
  },
  ...storybook.configs['flat/recommended'],
  {
    rules: {
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['./*', '../*'],
              message:
                'Please use absolute imports instead of relative imports.',
            },
          ],
        },
      ],
    },
  },
  // .storybook/ and vitest.config.ts are outside src/ where @ alias is unavailable
  {
    files: ['.storybook/**/*.ts', 'vitest.config.ts'],
    rules: {
      'no-restricted-imports': 'off',
    },
  },
)
