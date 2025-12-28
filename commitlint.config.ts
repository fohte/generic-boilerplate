import type { UserConfig } from '@commitlint/types'
import { RuleConfigSeverity } from '@commitlint/types'

const config: UserConfig = {
  rules: {
    'body-leading-blank': [RuleConfigSeverity.Error, 'always'],
    'footer-leading-blank': [RuleConfigSeverity.Error, 'always'],
    'subject-full-stop': [RuleConfigSeverity.Error, 'never', '.'],
  },
}

export default config
