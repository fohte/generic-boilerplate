import { config } from '@fohte/eslint-config'
import tsPlugin from '@typescript-eslint/eslint-plugin'
import storybook from 'eslint-plugin-storybook'

export default config(
  { typescript: { typeChecked: true } },
  {
    files: ['**/*.ts{,x}'],
    languageOptions: {
      parserOptions: {
        projectService: {
          allowDefaultProject: [
            'frontend/.storybook/main.ts',
            'frontend/.storybook/preview.ts',
          ],
        },
      },
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
  // .storybook/ files are matched by allowDefaultProject (no real tsconfig
  // includes them at the workspace root), so the inferred default project
  // — which lacks strict compiler options — would otherwise break the
  // type-aware rules. Disable type-aware rules there.
  {
    ...tsPlugin.configs['flat/disable-type-checked'],
    files: ['**/.storybook/**/*.ts'],
  },
  // .storybook/ is outside src/ where @ alias is unavailable
  {
    files: ['**/.storybook/**/*.ts'],
    rules: {
      'no-restricted-imports': 'off',
    },
  },
)
