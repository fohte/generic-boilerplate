import type { Plugin, UserConfig } from '@commitlint/types'
import { RuleConfigSeverity } from '@commitlint/types'

let noExternalGitHubRefsPlugin: Plugin | null = null
try {
  // Plugin file exists only in public repos (controlled by copier is_public parameter)
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  noExternalGitHubRefsPlugin =
    require('./commitlint-plugin-no-external-refs').default
} catch {
  // Plugin not available (private repo)
}

const config: UserConfig = {
  rules: {
    'body-leading-blank': [RuleConfigSeverity.Error, 'always'],
    'footer-leading-blank': [RuleConfigSeverity.Error, 'always'],
    'subject-full-stop': [RuleConfigSeverity.Error, 'never', '.'],
    ...(noExternalGitHubRefsPlugin && {
      'no-external-github-refs': [RuleConfigSeverity.Error, 'always'],
    }),
  },
  plugins: noExternalGitHubRefsPlugin ? [noExternalGitHubRefsPlugin] : [],
}

export default config
