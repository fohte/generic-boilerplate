import { config } from '@fohte/eslint-config'
import storybook from 'eslint-plugin-storybook'

export default config(
  { typescript: { typeChecked: true } },
  // Each subpackage's .storybook/ uses its own tsconfig and is linted
  // separately when needed; the root config skips them to avoid pulling
  // them into the inferred default project (which lacks strict options).
  // Story files under each subpackage's src/ are still linted via
  // storybook.configs['flat/recommended'] below.
  { ignores: ['**/.storybook/'] },
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
)
