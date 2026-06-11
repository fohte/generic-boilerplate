# Changelog

## [0.8.2](https://github.com/fohte/generic-boilerplate/compare/v0.8.1...v0.8.2) (2026-06-11)


### Bug Fixes

* **copier:** replace _tasks with _copier_operation exclude for bootstrap.yml ([#408](https://github.com/fohte/generic-boilerplate/issues/408)) ([b281853](https://github.com/fohte/generic-boilerplate/commit/b281853c5180d23f37e3819ed1f5a521c9ca43e1))

## [0.8.1](https://github.com/fohte/generic-boilerplate/compare/v0.8.0...v0.8.1) (2026-06-10)


### Features

* **copier:** add tests flag to opt node subpackage out of test scaffolding ([#398](https://github.com/fohte/generic-boilerplate/issues/398)) ([9327438](https://github.com/fohte/generic-boilerplate/commit/9327438a0fbc9e2f872756bb42e15283abcb8136))
* **copier:** allow subpackages on any root type ([#397](https://github.com/fohte/generic-boilerplate/issues/397)) ([d0ceb53](https://github.com/fohte/generic-boilerplate/commit/d0ceb530c9e38e245ee8a8cc252c62f5475320c4))
* **template:** add bootstrap workflow to generate lockfiles on first push ([#401](https://github.com/fohte/generic-boilerplate/issues/401)) ([8f1e4c6](https://github.com/fohte/generic-boilerplate/commit/8f1e4c69d093b643fb3340e4a80acb0f35334363))


### Bug Fixes

* **scripts:** actually tick Renovate Dashboard checkboxes in trigger-renovate-boilerplate-prs ([#391](https://github.com/fohte/generic-boilerplate/issues/391)) ([312de8e](https://github.com/fohte/generic-boilerplate/commit/312de8e94fd18f5ae3806d33d8ca7da6624e52fa))
* **scripts:** use pnpm install --frozen-lockfile in bootstrap ([#394](https://github.com/fohte/generic-boilerplate/issues/394)) ([cf9b841](https://github.com/fohte/generic-boilerplate/commit/cf9b841e27e2189c910dad03047c5af32382b69d))
* **template:** exempt @fohte/* packages from minimumReleaseAge ([#396](https://github.com/fohte/generic-boilerplate/issues/396)) ([be40033](https://github.com/fohte/generic-boilerplate/commit/be40033d6c760a2b7b99a1b7cba746347b611713))


### Dependencies

* **ci:** Update actions/checkout action to v6.0.3 ([#404](https://github.com/fohte/generic-boilerplate/issues/404)) ([cb8fa4c](https://github.com/fohte/generic-boilerplate/commit/cb8fa4c8c14c1e31cf4d7a36d820e9c5be27dcc0))
* **ci:** Update actions/checkout action to v6.0.3 ([#405](https://github.com/fohte/generic-boilerplate/issues/405)) ([ae10936](https://github.com/fohte/generic-boilerplate/commit/ae1093614ed64372c627f27fd9d8e5ab5b5df7cd))
* **ci:** Update taiki-e/install-action action to v2.81.1 ([#393](https://github.com/fohte/generic-boilerplate/issues/393)) ([bbf1f5c](https://github.com/fohte/generic-boilerplate/commit/bbf1f5c96162961971cbd137b555f87751346cfd))
* **ci:** Update taiki-e/install-action action to v2.81.2 ([#403](https://github.com/fohte/generic-boilerplate/issues/403)) ([7ccc55d](https://github.com/fohte/generic-boilerplate/commit/7ccc55dcb679bc0edc3e800842abf6d6c1743880))
* **ci:** Update taiki-e/install-action action to v2.81.3 ([#406](https://github.com/fohte/generic-boilerplate/issues/406)) ([72a5f0e](https://github.com/fohte/generic-boilerplate/commit/72a5f0ec034414ee2b3d7aed4d962b2242d4794e))
* Update devDependencies (non-major) to v0.3.3 ([#395](https://github.com/fohte/generic-boilerplate/issues/395)) ([7f026bf](https://github.com/fohte/generic-boilerplate/commit/7f026bfa02f1e90ac0eed78e0f15d7c9ab196a0d))
* Update devDependencies (non-major) to v10.0.3 ([#399](https://github.com/fohte/generic-boilerplate/issues/399)) ([7dc691e](https://github.com/fohte/generic-boilerplate/commit/7dc691ecb638ebf1896a361f13beb39bbabf2502))
* Update devDependencies (non-major) to v10.4.2 ([#402](https://github.com/fohte/generic-boilerplate/issues/402)) ([bab9fdb](https://github.com/fohte/generic-boilerplate/commit/bab9fdb88e2ef101eafac17c5d5aabbf7c750518))
* Update pnpm to v11.5.1 ([#400](https://github.com/fohte/generic-boilerplate/issues/400)) ([4a6fb3e](https://github.com/fohte/generic-boilerplate/commit/4a6fb3e0a88c7d46977af83817eda97eb069c313))

## [0.8.0](https://github.com/fohte/generic-boilerplate/compare/v0.7.1...v0.8.0) (2026-06-07)


### ⚠ BREAKING CHANGES

* Update dependency concurrently to v10 ([#375](https://github.com/fohte/generic-boilerplate/issues/375))
* Update dependency pinact to v4 ([#364](https://github.com/fohte/generic-boilerplate/issues/364))

### Features

* guard against pinning fresh SHAs with pinact min_age ([#371](https://github.com/fohte/generic-boilerplate/issues/371)) ([ee3739d](https://github.com/fohte/generic-boilerplate/commit/ee3739d60e45e0a9cb1e1060e6f38927a3aa8202))
* **lefthook:** add betterleaks secret scan to pre-commit ([#388](https://github.com/fohte/generic-boilerplate/issues/388)) ([989f876](https://github.com/fohte/generic-boilerplate/commit/989f8765358eee14e9f28be441c3eec2d5cde014))
* **node:** set a 7-day minimumReleaseAge in generated projects ([#387](https://github.com/fohte/generic-boilerplate/issues/387)) ([6831fd6](https://github.com/fohte/generic-boilerplate/commit/6831fd6f9e7ebfe6fd59f9a4246f524e679eba90))
* **template:** require whole-output equality in test assertion rule ([#363](https://github.com/fohte/generic-boilerplate/issues/363)) ([df1013d](https://github.com/fohte/generic-boilerplate/commit/df1013de337bb6ee2eaa4488d3154fcedf0cb1f7))


### Bug Fixes

* **ci/test-workflow:** authenticate pinact's GitHub API calls ([#384](https://github.com/fohte/generic-boilerplate/issues/384)) ([533285b](https://github.com/fohte/generic-boilerplate/commit/533285bc14518c71d512813522420eaac9cd6fe0))


### Dependencies

* **ci:** Update taiki-e/install-action action to v2.79.10 ([#369](https://github.com/fohte/generic-boilerplate/issues/369)) ([15e3b41](https://github.com/fohte/generic-boilerplate/commit/15e3b4189f29982fcc14b0d4fbc9567f75e910ce))
* **ci:** Update taiki-e/install-action action to v2.79.11 ([#373](https://github.com/fohte/generic-boilerplate/issues/373)) ([d243c14](https://github.com/fohte/generic-boilerplate/commit/d243c14d04cb75171647135256736036875036c6))
* **ci:** Update taiki-e/install-action action to v2.79.12 ([#374](https://github.com/fohte/generic-boilerplate/issues/374)) ([f0f4982](https://github.com/fohte/generic-boilerplate/commit/f0f4982121abb9d82febf20a28c872862a592ba0))
* **ci:** Update taiki-e/install-action action to v2.79.13 ([#376](https://github.com/fohte/generic-boilerplate/issues/376)) ([f4f95ed](https://github.com/fohte/generic-boilerplate/commit/f4f95edb55b52deaea7933d7acc15fc451affe7e))
* **ci:** Update taiki-e/install-action action to v2.79.14 ([#379](https://github.com/fohte/generic-boilerplate/issues/379)) ([0f597f7](https://github.com/fohte/generic-boilerplate/commit/0f597f7007459029e1d7ab7627a3fbefc6c6786d))
* **ci:** Update taiki-e/install-action action to v2.79.15 ([#382](https://github.com/fohte/generic-boilerplate/issues/382)) ([9b2cfb5](https://github.com/fohte/generic-boilerplate/commit/9b2cfb5536f3da78e50653a5602a8377ebe8c11a))
* **ci:** Update taiki-e/install-action action to v2.79.7 ([#361](https://github.com/fohte/generic-boilerplate/issues/361)) ([08b0917](https://github.com/fohte/generic-boilerplate/commit/08b091738bd964744aa2d0edf37414981bb619d3))
* **ci:** Update taiki-e/install-action action to v2.79.8 ([#366](https://github.com/fohte/generic-boilerplate/issues/366)) ([d244fae](https://github.com/fohte/generic-boilerplate/commit/d244fae683334608c3a7a3ac8abf8f0119ddcb56))
* **ci:** Update taiki-e/install-action action to v2.79.9 ([#367](https://github.com/fohte/generic-boilerplate/issues/367)) ([ae4b0fa](https://github.com/fohte/generic-boilerplate/commit/ae4b0faf0b00901166d0a8754da78ce3be0ef274))
* **ci:** Update taiki-e/install-action action to v2.80.0 ([#385](https://github.com/fohte/generic-boilerplate/issues/385)) ([1a9d33b](https://github.com/fohte/generic-boilerplate/commit/1a9d33b99c82d46c1e4f8cc4ba5a5dc794dda90d))
* Update @commitlint/cli to v21.0.2 ([#377](https://github.com/fohte/generic-boilerplate/issues/377)) ([da24dd6](https://github.com/fohte/generic-boilerplate/commit/da24dd663935e4ab396124bc7a0bee2aea9da97e))
* Update dependency concurrently to v10 ([#375](https://github.com/fohte/generic-boilerplate/issues/375)) ([66e5a8c](https://github.com/fohte/generic-boilerplate/commit/66e5a8cd3f21094aabc7d7616166f45a0a0a31ba))
* Update dependency github:ast-grep/ast-grep to v0.43.0 ([#365](https://github.com/fohte/generic-boilerplate/issues/365)) ([a7d2f3d](https://github.com/fohte/generic-boilerplate/commit/a7d2f3db15da91dcb98d174ee97dc1ba1c3b19ca))
* Update dependency lefthook to v2.1.9 ([#378](https://github.com/fohte/generic-boilerplate/issues/378)) ([fbd9843](https://github.com/fohte/generic-boilerplate/commit/fbd9843c244d8e2fc3a1c7f2eb8f9fd547b77081))
* Update dependency pinact to v4 ([#364](https://github.com/fohte/generic-boilerplate/issues/364)) ([eac10de](https://github.com/fohte/generic-boilerplate/commit/eac10de49360bed11fe9fe52c2eb31bbc8668fe5))
* Update devDependencies (non-major) to v10.4.1 ([#381](https://github.com/fohte/generic-boilerplate/issues/381)) ([144346d](https://github.com/fohte/generic-boilerplate/commit/144346d4b6077e31930398740983bd0396278d3a))
* update pnpm to v11.3.0 ([#359](https://github.com/fohte/generic-boilerplate/issues/359)) ([edfeee6](https://github.com/fohte/generic-boilerplate/commit/edfeee6e89c23c80d491099d12c1aeb6585996ea))
* update pnpm to v11.4.0 ([#370](https://github.com/fohte/generic-boilerplate/issues/370)) ([900bd67](https://github.com/fohte/generic-boilerplate/commit/900bd6705491252f5237f47cdb2bafd6732673d9))
* Update pnpm to v11.5.0 ([#380](https://github.com/fohte/generic-boilerplate/issues/380)) ([cc3b546](https://github.com/fohte/generic-boilerplate/commit/cc3b54601c79e0ca80c457ed8f2cba15e7966acd))
* update rust to v1.96.0 ([#372](https://github.com/fohte/generic-boilerplate/issues/372)) ([03d1e0e](https://github.com/fohte/generic-boilerplate/commit/03d1e0e59999013a919d02b6508eccdab656a873))

## [0.7.1](https://github.com/fohte/generic-boilerplate/compare/v0.7.0...v0.7.1) (2026-05-30)


### Features

* **template:** require a workspace scope in the PR title check ([#351](https://github.com/fohte/generic-boilerplate/issues/351)) ([5e3f744](https://github.com/fohte/generic-boilerplate/commit/5e3f744b1c5f9b10110d39274f89b4bbe12e1ad9))
* **template:** use a matrix + aggregation gate for pnpm workspace monorepo CI ([#356](https://github.com/fohte/generic-boilerplate/issues/356)) ([f002f99](https://github.com/fohte/generic-boilerplate/commit/f002f99912e5435a5453e1b906db7b9e3b433c01))


### Bug Fixes

* **template:** install lefthook hooks even in worktrees ([#350](https://github.com/fohte/generic-boilerplate/issues/350)) ([6694824](https://github.com/fohte/generic-boilerplate/commit/66948244a8fa72fbaf60d33174a2d4867a9f3b87))


### Dependencies

* **ci:** Update taiki-e/install-action action to v2.79.3 ([#345](https://github.com/fohte/generic-boilerplate/issues/345)) ([1a9b037](https://github.com/fohte/generic-boilerplate/commit/1a9b03798b19d1bf1c48bb6ee7505c6aeb037e18))
* **ci:** Update taiki-e/install-action action to v2.79.4 ([#349](https://github.com/fohte/generic-boilerplate/issues/349)) ([a53369a](https://github.com/fohte/generic-boilerplate/commit/a53369ae4ab39b7f9a0a98a5ae1ec13d73aea7d4))
* **ci:** Update taiki-e/install-action action to v2.79.5 ([#355](https://github.com/fohte/generic-boilerplate/issues/355)) ([7196b16](https://github.com/fohte/generic-boilerplate/commit/7196b16a19896a3a6fdd2dc6e4fe61d29324f2c4))
* **ci:** Update taiki-e/install-action action to v2.79.6 ([#358](https://github.com/fohte/generic-boilerplate/issues/358)) ([f3f46b1](https://github.com/fohte/generic-boilerplate/commit/f3f46b164f4bd16a2fb9d41dcde64930c73b90bc))
* Update devDependencies (non-major) ([#353](https://github.com/fohte/generic-boilerplate/issues/353)) ([c123f5f](https://github.com/fohte/generic-boilerplate/commit/c123f5fa0e4622c66ac56927f977f00dbf059209))
* Update Node.js to v24.16.0 ([#348](https://github.com/fohte/generic-boilerplate/issues/348)) ([e6d73a5](https://github.com/fohte/generic-boilerplate/commit/e6d73a525d319443df7ff92bf815cd1e2c9f6430))
* update pnpm to v11.2.2 ([#346](https://github.com/fohte/generic-boilerplate/issues/346)) ([e458010](https://github.com/fohte/generic-boilerplate/commit/e458010f955d5eb94fea99fb875d991a057dbc58))

## [0.7.0](https://github.com/fohte/generic-boilerplate/compare/v0.6.5...v0.7.0) (2026-05-26)


### ⚠ BREAKING CHANGES

* Update pnpm to v11 ([#334](https://github.com/fohte/generic-boilerplate/issues/334))
* Update @commitlint/cli to v21 ([#333](https://github.com/fohte/generic-boilerplate/issues/333))
* Update dependency typescript to v6 ([#255](https://github.com/fohte/generic-boilerplate/issues/255))

### Features

* **template:** federate GitHub App tokens through octo-sts ([#341](https://github.com/fohte/generic-boilerplate/issues/341)) ([21713f3](https://github.com/fohte/generic-boilerplate/commit/21713f3c1dbbd52ca0aedf25ae52febb4bc99694))


### Bug Fixes

* **scripts:** preserve scripts entry when a devDependencies key has the same name ([#309](https://github.com/fohte/generic-boilerplate/issues/309)) ([7c143c7](https://github.com/fohte/generic-boilerplate/commit/7c143c714bbe2c709520fb30a463432f4c022f81))


### Dependencies

* **ci:** Update actions/cache action to v5.0.5 ([#316](https://github.com/fohte/generic-boilerplate/issues/316)) ([ada75a6](https://github.com/fohte/generic-boilerplate/commit/ada75a63a4c98bd12650db526ff1aafa2ac507e4))
* **ci:** Update cloudflare/wrangler-action action to v4 ([#335](https://github.com/fohte/generic-boilerplate/issues/335)) ([49a5d88](https://github.com/fohte/generic-boilerplate/commit/49a5d884e62bf0351cac48115734f983f55c33c4))
* **ci:** Update codecov/codecov-action action to v6.0.1 ([#317](https://github.com/fohte/generic-boilerplate/issues/317)) ([dbca4a7](https://github.com/fohte/generic-boilerplate/commit/dbca4a7d1df110190227340d37bf7c8e0dfc2fe4))
* **ci:** Update googleapis/release-please-action action to v4.4.1 ([#318](https://github.com/fohte/generic-boilerplate/issues/318)) ([9214596](https://github.com/fohte/generic-boilerplate/commit/921459625a3fc2048f4dc51036f88b8671b80538))
* **ci:** Update googleapis/release-please-action action to v5 ([#336](https://github.com/fohte/generic-boilerplate/issues/336)) ([07fa1b4](https://github.com/fohte/generic-boilerplate/commit/07fa1b48687d4e7291435a3995ac5cc6f2e894a2))
* **ci:** Update marocchino/sticky-pull-request-comment action to v3.0.4 ([#319](https://github.com/fohte/generic-boilerplate/issues/319)) ([4b8467e](https://github.com/fohte/generic-boilerplate/commit/4b8467e2d4fc8749ac5f815827db40771dd68538))
* **ci:** Update mozilla-actions/sccache-action action to v0.0.10 ([#320](https://github.com/fohte/generic-boilerplate/issues/320)) ([99d1b95](https://github.com/fohte/generic-boilerplate/commit/99d1b95daa14fd243905fc82a82fa30cc3b3ab08))
* **ci:** Update suzuki-shunsuke/commit-action action to v0.1.2 ([#321](https://github.com/fohte/generic-boilerplate/issues/321)) ([335b662](https://github.com/fohte/generic-boilerplate/commit/335b66237c8f55438f7e7641b65bd1d4d956859b))
* **ci:** Update suzuki-shunsuke/commit-action action to v1 ([#337](https://github.com/fohte/generic-boilerplate/issues/337)) ([faaa327](https://github.com/fohte/generic-boilerplate/commit/faaa3274ca66ea29f68c14ef53eeb1e0dd316d6d))
* **ci:** Update taiki-e/install-action action to v2.79.1 ([#332](https://github.com/fohte/generic-boilerplate/issues/332)) ([f4e7373](https://github.com/fohte/generic-boilerplate/commit/f4e737353225d3645d724781ee9320fda1f0d093))
* **ci:** Update taiki-e/install-action action to v2.79.2 ([#339](https://github.com/fohte/generic-boilerplate/issues/339)) ([f0632ad](https://github.com/fohte/generic-boilerplate/commit/f0632ad10de5678c648db09e0b4a0950a623fee0))
* **ci:** Update tj-actions/changed-files action to v47.0.6 ([#322](https://github.com/fohte/generic-boilerplate/issues/322)) ([cec73c3](https://github.com/fohte/generic-boilerplate/commit/cec73c3676d3cfea00ee9616eba865e6027dbc6f))
* Update @commitlint/cli to v20.5.3 ([#311](https://github.com/fohte/generic-boilerplate/issues/311)) ([b761087](https://github.com/fohte/generic-boilerplate/commit/b761087c873daf5874b247cdbef5b5468fb11310))
* Update @commitlint/cli to v21 ([#333](https://github.com/fohte/generic-boilerplate/issues/333)) ([8d94afe](https://github.com/fohte/generic-boilerplate/commit/8d94afe78623292196d3de7ca8496dc4b2720280))
* Update dependency @types/node to v24.12.4 ([#328](https://github.com/fohte/generic-boilerplate/issues/328)) ([6fac23d](https://github.com/fohte/generic-boilerplate/commit/6fac23d8d1d6daffcd41db9bfe9e3cb7ef370f1a))
* Update dependency bats to v1.13.0 ([#323](https://github.com/fohte/generic-boilerplate/issues/323)) ([af3037e](https://github.com/fohte/generic-boilerplate/commit/af3037ed71588dbd8ffb08edbc0f5eee45a9aa38))
* Update dependency eslint to v10.2.1 ([#284](https://github.com/fohte/generic-boilerplate/issues/284)) ([bf18128](https://github.com/fohte/generic-boilerplate/commit/bf181284e37bf32265d8a0fa9477d8494a5e1923))
* Update dependency eslint to v10.4.0 ([#324](https://github.com/fohte/generic-boilerplate/issues/324)) ([25a7f0f](https://github.com/fohte/generic-boilerplate/commit/25a7f0f0ab006e11ffd41b01533fa4eac8f68f69))
* Update dependency github:ast-grep/ast-grep to v0.42.1 ([#287](https://github.com/fohte/generic-boilerplate/issues/287)) ([7b292e8](https://github.com/fohte/generic-boilerplate/commit/7b292e8750c0cb67556dea5d33a17005d20d8b15))
* Update dependency github:ast-grep/ast-grep to v0.42.2 ([#313](https://github.com/fohte/generic-boilerplate/issues/313)) ([f7b90ea](https://github.com/fohte/generic-boilerplate/commit/f7b90eae7c1218c1bbe80aca84f9f9dc2c3b8572))
* Update dependency github:ast-grep/ast-grep to v0.42.3 ([#340](https://github.com/fohte/generic-boilerplate/issues/340)) ([8e6c46d](https://github.com/fohte/generic-boilerplate/commit/8e6c46d2c08bb0509f3d4b3d94ba6135299eb656))
* Update dependency lefthook to v2.1.6 ([#304](https://github.com/fohte/generic-boilerplate/issues/304)) ([54f1b47](https://github.com/fohte/generic-boilerplate/commit/54f1b47a81fa2801779b2c0704a0d857998e9e9c))
* Update dependency lefthook to v2.1.7 ([#329](https://github.com/fohte/generic-boilerplate/issues/329)) ([2208061](https://github.com/fohte/generic-boilerplate/commit/22080616f8975b70905f60b584a59437ac3aafc0))
* Update dependency lefthook to v2.1.8 ([#338](https://github.com/fohte/generic-boilerplate/issues/338)) ([41d586e](https://github.com/fohte/generic-boilerplate/commit/41d586ea3965c1858ff27f49b50946be7e9f52fd))
* Update dependency pinact to v3.10.1 ([#325](https://github.com/fohte/generic-boilerplate/issues/325)) ([ac3b80f](https://github.com/fohte/generic-boilerplate/commit/ac3b80f36d1247e91524d79bd4c56dae59491d1e))
* Update dependency shfmt to v3.13.1 ([#305](https://github.com/fohte/generic-boilerplate/issues/305)) ([43ee71c](https://github.com/fohte/generic-boilerplate/commit/43ee71c21d730cff2100fc5b0fb4960788d0d2e6))
* Update dependency typescript to v6 ([#255](https://github.com/fohte/generic-boilerplate/issues/255)) ([6cc6556](https://github.com/fohte/generic-boilerplate/commit/6cc6556237e7122c9d2378762a6cfe9141bc741d))
* Update dependency typescript to v6.0.3 ([#306](https://github.com/fohte/generic-boilerplate/issues/306)) ([af3a8b6](https://github.com/fohte/generic-boilerplate/commit/af3a8b62c213c71feac153e9acfb4d415d716d8e))
* Update dependency vitest to v4.1.6 ([#308](https://github.com/fohte/generic-boilerplate/issues/308)) ([ef41471](https://github.com/fohte/generic-boilerplate/commit/ef41471ad36c47416d84206abed9679efcff6ea7))
* Update Node.js to v24.15.0 ([#283](https://github.com/fohte/generic-boilerplate/issues/283)) ([993b268](https://github.com/fohte/generic-boilerplate/commit/993b268521d0c91046fdacb4bf88a346b95fa59b))
* update pnpm to v10.33.4 ([#314](https://github.com/fohte/generic-boilerplate/issues/314)) ([14ba0fa](https://github.com/fohte/generic-boilerplate/commit/14ba0fa580095d1b1a86e58d38c99b1069f5d1ad))
* Update pnpm to v11 ([#334](https://github.com/fohte/generic-boilerplate/issues/334)) ([fa86a07](https://github.com/fohte/generic-boilerplate/commit/fa86a073a901f3b5d1826328e5767a92ac0a2e71))
* Update prettier to v3.8.3 ([#315](https://github.com/fohte/generic-boilerplate/issues/315)) ([2d11ee3](https://github.com/fohte/generic-boilerplate/commit/2d11ee35592736ea7211c6c5a88c871a0128a628))
* update rust to v1.95.0 ([#326](https://github.com/fohte/generic-boilerplate/issues/326)) ([cf02610](https://github.com/fohte/generic-boilerplate/commit/cf02610ec3bf99af72b8a313189de9c7268d6971))
* Update storybook monorepo to v10.4.0 ([#282](https://github.com/fohte/generic-boilerplate/issues/282)) ([90f1b59](https://github.com/fohte/generic-boilerplate/commit/90f1b5994afb15012c9c8afb7e060d845a9d0b16))

## [0.6.5](https://github.com/fohte/generic-boilerplate/compare/v0.6.4...v0.6.5) (2026-04-25)


### Features

* **gemini:** add code-comment rules to the code styleguide ([#302](https://github.com/fohte/generic-boilerplate/issues/302)) ([c900c43](https://github.com/fohte/generic-boilerplate/commit/c900c43fe4db008569b966874ace9924194dbfb9))


### Bug Fixes

* **template:** ignore root node_modules for non-workspace monorepos with node subpackages ([#299](https://github.com/fohte/generic-boilerplate/issues/299)) ([0a7f8ba](https://github.com/fohte/generic-boilerplate/commit/0a7f8ba76fa6f9e5478b24a9be9308fbc1ffc15f))

## [0.6.4](https://github.com/fohte/generic-boilerplate/compare/v0.6.3...v0.6.4) (2026-04-19)


### Bug Fixes

* **template:** stop leaking mise template-author comments into rendered output ([#295](https://github.com/fohte/generic-boilerplate/issues/295)) ([81efacc](https://github.com/fohte/generic-boilerplate/commit/81efacc5000e64292f0381c20d965ff6bb3a5468))

## [0.6.3](https://github.com/fohte/generic-boilerplate/compare/v0.6.2...v0.6.3) (2026-04-19)


### Features

* **template:** inline lefthook config and host shared tooling at the root ([#293](https://github.com/fohte/generic-boilerplate/issues/293)) ([42e40a2](https://github.com/fohte/generic-boilerplate/commit/42e40a22ab86d058cd394287e972f42ae7bc10b6))

## [0.6.2](https://github.com/fohte/generic-boilerplate/compare/v0.6.1...v0.6.2) (2026-04-15)


### Features

* **template:** add PR body template ([#291](https://github.com/fohte/generic-boilerplate/issues/291)) ([298c7b4](https://github.com/fohte/generic-boilerplate/commit/298c7b46635e18446f099882ef8ebd8f5f90375b))


### Bug Fixes

* **template:** align `pr-title-check` scope regex with Conventional Commits spec ([#289](https://github.com/fohte/generic-boilerplate/issues/289)) ([4cb43b3](https://github.com/fohte/generic-boilerplate/commit/4cb43b3b029c8c19fc9afdaf9b72b5bf601d4f42))

## [0.6.1](https://github.com/fohte/generic-boilerplate/compare/v0.6.0...v0.6.1) (2026-04-11)


### Bug Fixes

* **template:** pin taiki-e/install-action by version tag with tool input ([#285](https://github.com/fohte/generic-boilerplate/issues/285)) ([b2bd1ab](https://github.com/fohte/generic-boilerplate/commit/b2bd1ab6adb369745026077431ff61a001abbd4f))

## [0.6.0](https://github.com/fohte/generic-boilerplate/compare/v0.5.3...v0.6.0) (2026-04-09)


### ⚠ BREAKING CHANGES

* update dependency fohte/lefthook-config to v0.1.16 ([#272](https://github.com/fohte/generic-boilerplate/issues/272))

### Features

* **template:** add pinact to mise tools ([#268](https://github.com/fohte/generic-boilerplate/issues/268)) ([3df710c](https://github.com/fohte/generic-boilerplate/commit/3df710c360f68a5bbe53390d7cc4519d1ba2f44f))
* **template:** import Storybook types via @storybook/react-vite ([#275](https://github.com/fohte/generic-boilerplate/issues/275)) ([939ae04](https://github.com/fohte/generic-boilerplate/commit/939ae04741dca1eb4ab713b1e3182ed51ee67db2))
* **template:** set up eslint-plugin-storybook when use_storybook is enabled ([#274](https://github.com/fohte/generic-boilerplate/issues/274)) ([0a179d8](https://github.com/fohte/generic-boilerplate/commit/0a179d874a3cd5a941f3f4cd36400be14fcf0a23))


### Bug Fixes

* **template/lefthook:** consolidate workspace monorepo eslint into a single root command ([#270](https://github.com/fohte/generic-boilerplate/issues/270)) ([cd7b491](https://github.com/fohte/generic-boilerplate/commit/cd7b4910402c12b7bef956900be3e8dfafe68b52))
* **template:** drop redundant eslint-disable from commitlint.config.cjs ([#271](https://github.com/fohte/generic-boilerplate/issues/271)) ([23afca4](https://github.com/fohte/generic-boilerplate/commit/23afca413e7486d3270e63b8e4e02b1b6454516e))


### Dependencies

* **ci:** Pin dependencies ([#273](https://github.com/fohte/generic-boilerplate/issues/273)) ([bca4b60](https://github.com/fohte/generic-boilerplate/commit/bca4b60946ca2516510654c68bb281ae524c6db7))
* **ci:** Update actions/cache action to v5.0.4 ([#277](https://github.com/fohte/generic-boilerplate/issues/277)) ([8facdde](https://github.com/fohte/generic-boilerplate/commit/8facdde9e9b69a674b29d74db9d6c28e3ef70967))
* **ci:** Update actions/checkout action to v6.0.2 ([#278](https://github.com/fohte/generic-boilerplate/issues/278)) ([cf0cfcd](https://github.com/fohte/generic-boilerplate/commit/cf0cfcd91d1176485e60f87d56f2c3a62eeda7f3))
* **ci:** Update codecov/codecov-action action to v6 ([#264](https://github.com/fohte/generic-boilerplate/issues/264)) ([7f98aef](https://github.com/fohte/generic-boilerplate/commit/7f98aef601add8e8ab51eccc07bce30b44cce162))
* **ci:** Update marocchino/sticky-pull-request-comment action to v3 ([#281](https://github.com/fohte/generic-boilerplate/issues/281)) ([60a4c26](https://github.com/fohte/generic-boilerplate/commit/60a4c26981a076a1c85d5bb942fc0f47e772fc1d))
* **ci:** Update tj-actions/changed-files action to v47.0.5 ([#280](https://github.com/fohte/generic-boilerplate/issues/280)) ([ccc833d](https://github.com/fohte/generic-boilerplate/commit/ccc833d1e5896aa9531c8236fd010468585e594f))
* Update dependency actionlint to v1.7.12 ([#276](https://github.com/fohte/generic-boilerplate/issues/276)) ([3d498c0](https://github.com/fohte/generic-boilerplate/commit/3d498c0b4419e6e752dce316299dd3122d67ce1e))
* update dependency fohte/lefthook-config to v0.1.16 ([#272](https://github.com/fohte/generic-boilerplate/issues/272)) ([c1200ac](https://github.com/fohte/generic-boilerplate/commit/c1200ac2480969f19925b6ac412c7c7eb98c36c7))
* Update dependency vitest to v4.1.2 ([#254](https://github.com/fohte/generic-boilerplate/issues/254)) ([bb4fc96](https://github.com/fohte/generic-boilerplate/commit/bb4fc961d5098458b0a827393fbde60bac5aa39f))
* Update Node.js to v24.14.1 ([#256](https://github.com/fohte/generic-boilerplate/issues/256)) ([ae45f88](https://github.com/fohte/generic-boilerplate/commit/ae45f88c8ab5aad687b5a4ee9af120f6dced09d2))
* update pnpm to v10.33.0 ([#258](https://github.com/fohte/generic-boilerplate/issues/258)) ([941c17e](https://github.com/fohte/generic-boilerplate/commit/941c17e89b88865748fbe4e48650210707a888f9))

## [0.5.3](https://github.com/fohte/generic-boilerplate/compare/v0.5.2...v0.5.3) (2026-04-02)


### Features

* **template:** add Storybook deploy workflow for Cloudflare Pages ([#262](https://github.com/fohte/generic-boilerplate/issues/262)) ([d241f32](https://github.com/fohte/generic-boilerplate/commit/d241f3206215a2e98ff9566e217a394d2944eaa2))

## [0.5.2](https://github.com/fohte/generic-boilerplate/compare/v0.5.1...v0.5.2) (2026-04-01)


### Bug Fixes

* exclude pr-title-check workflow when release-please is disabled ([#261](https://github.com/fohte/generic-boilerplate/issues/261)) ([6c2a390](https://github.com/fohte/generic-boilerplate/commit/6c2a3906881fb58efb52be3d6e8f7023d03e752b))

## [0.5.1](https://github.com/fohte/generic-boilerplate/compare/v0.5.0...v0.5.1) (2026-04-01)


### Features

* add PR title check workflow for strict Conventional Commits compliance ([#257](https://github.com/fohte/generic-boilerplate/issues/257)) ([e0a86c2](https://github.com/fohte/generic-boilerplate/commit/e0a86c29ff9ce89da20321d2471de253f94da31b))


### Bug Fixes

* exclude `pnpm-lock.yaml` from `.prettierignore` in non-pnpm projects ([#260](https://github.com/fohte/generic-boilerplate/issues/260)) ([d7ac05f](https://github.com/fohte/generic-boilerplate/commit/d7ac05fd4f6e02839356f9743ea48a000e615b02))

## [0.5.0](https://github.com/fohte/generic-boilerplate/compare/v0.4.2...v0.5.0) (2026-03-28)


### ⚠ BREAKING CHANGES

* Update dependency @tsconfig/node-lts to v24.0.0 ([#252](https://github.com/fohte/generic-boilerplate/issues/252))
* Update dependency @types/node to v24 ([#253](https://github.com/fohte/generic-boilerplate/issues/253))

### Features

* **lefthook:** add ESLint pre-commit hook for Node.js projects ([#246](https://github.com/fohte/generic-boilerplate/issues/246)) ([12fe2b2](https://github.com/fohte/generic-boilerplate/commit/12fe2b249ba9d0ce226fdd3d8c4dcd0dd66e6dd0))


### Bug Fixes

* **template:** add `pnpm-lock.yaml` to `.prettierignore` ([#249](https://github.com/fohte/generic-boilerplate/issues/249)) ([2cfc7d2](https://github.com/fohte/generic-boilerplate/commit/2cfc7d2eb632535035ebc1ae7e7b0e3684142891))
* **test-workflow:** base auto-format skip on current commit instead of previous ([#243](https://github.com/fohte/generic-boilerplate/issues/243)) ([4c55e2c](https://github.com/fohte/generic-boilerplate/commit/4c55e2c0943ac37038bb0c0335f43bae48f12e42))


### Dependencies

* **ci:** Update jdx/mise-action action to v4 ([#234](https://github.com/fohte/generic-boilerplate/issues/234)) ([a5c2ce3](https://github.com/fohte/generic-boilerplate/commit/a5c2ce30aabff5d5a99ddb807563dc8f60127429))
* Update @commitlint/cli to v20.5.0 ([#238](https://github.com/fohte/generic-boilerplate/issues/238)) ([9f5cd03](https://github.com/fohte/generic-boilerplate/commit/9f5cd03700484475bb94530af5802e0c39ef5b87))
* Update dependency @tsconfig/node-lts to v24.0.0 ([#252](https://github.com/fohte/generic-boilerplate/issues/252)) ([fcdd62d](https://github.com/fohte/generic-boilerplate/commit/fcdd62d5f87aced9f1e21601773091adf6503a80))
* Update dependency @types/node to v24 ([#253](https://github.com/fohte/generic-boilerplate/issues/253)) ([1360bd7](https://github.com/fohte/generic-boilerplate/commit/1360bd7a59d9b41bd0b41aaaf23b0430c9333836))
* Update dependency eslint to v10.1.0 ([#251](https://github.com/fohte/generic-boilerplate/issues/251)) ([45c14d8](https://github.com/fohte/generic-boilerplate/commit/45c14d8117f4ae00b2a1ba421ad149076a25e1ad))
* Update dependency github:ast-grep/ast-grep to v0.42.0 ([#239](https://github.com/fohte/generic-boilerplate/issues/239)) ([d3c585c](https://github.com/fohte/generic-boilerplate/commit/d3c585c79f23f358c84bf147546fab61b5344818))
* update pnpm to v10.32.1 ([#225](https://github.com/fohte/generic-boilerplate/issues/225)) ([638bb7c](https://github.com/fohte/generic-boilerplate/commit/638bb7ce42a1e6f7e8d1f0a464605d40f99ef881))

## [0.4.2](https://github.com/fohte/generic-boilerplate/compare/v0.4.1...v0.4.2) (2026-03-26)


### Bug Fixes

* **apply-renovate-patch:** handle `package@version` format in `packageManager` field ([#237](https://github.com/fohte/generic-boilerplate/issues/237)) ([1126fa8](https://github.com/fohte/generic-boilerplate/commit/1126fa8ccdb63895b55880f16e5d6088f953b319))


### Dependencies

* **ci:** Update actions/create-github-app-token action to v3 ([#235](https://github.com/fohte/generic-boilerplate/issues/235)) ([143785b](https://github.com/fohte/generic-boilerplate/commit/143785bbf30c8fcf44b5052bcccf5efe9c4d0ab6))
* Update @commitlint/cli to v20.4.4 ([#231](https://github.com/fohte/generic-boilerplate/issues/231)) ([99a73b2](https://github.com/fohte/generic-boilerplate/commit/99a73b2e4f277ede3787c39f1958c7c58cb3eac0))
* Update dependency @fohte/eslint-config to v0.3.1 ([#240](https://github.com/fohte/generic-boilerplate/issues/240)) ([22bdec7](https://github.com/fohte/generic-boilerplate/commit/22bdec781b841b3eb87a8aa622fd3bad05f765d4))
* Update dependency lefthook to v2.1.4 ([#228](https://github.com/fohte/generic-boilerplate/issues/228)) ([bbb123d](https://github.com/fohte/generic-boilerplate/commit/bbb123d62168764ee3c1ca0675ed004a7ebc7bca))
* Update dependency shfmt to v3.13.0 ([#226](https://github.com/fohte/generic-boilerplate/issues/226)) ([1600e93](https://github.com/fohte/generic-boilerplate/commit/1600e939b5ac05d4d66e49225e875889d64b46aa))
* Update dependency vitest to v4.1.0 ([#233](https://github.com/fohte/generic-boilerplate/issues/233)) ([b0bdcd3](https://github.com/fohte/generic-boilerplate/commit/b0bdcd3f0149c28c2f76b89c356cecacec9f6a5e))
* Update Node.js to v24.14.0 ([#223](https://github.com/fohte/generic-boilerplate/issues/223)) ([1962f66](https://github.com/fohte/generic-boilerplate/commit/1962f663ed81bddad213c37608e4f4418f1e495e))

## [0.4.1](https://github.com/fohte/generic-boilerplate/compare/v0.4.0...v0.4.1) (2026-03-20)


### Features

* **template:** migrate pnpm version management to corepack ([#229](https://github.com/fohte/generic-boilerplate/issues/229)) ([be4d268](https://github.com/fohte/generic-boilerplate/commit/be4d268f0eb391b46225b44990dc7fa68843265c))


### Dependencies

* Update dependency github:ast-grep/ast-grep to v0.41.1 ([#227](https://github.com/fohte/generic-boilerplate/issues/227)) ([a65eaba](https://github.com/fohte/generic-boilerplate/commit/a65eaba23559bbff0e2ea28be0a4b2f1d7855bef))

## [0.4.0](https://github.com/fohte/generic-boilerplate/compare/v0.3.18...v0.4.0) (2026-03-14)


### ⚠ BREAKING CHANGES

* **ci:** Update actions/checkout action to v6 ([#224](https://github.com/fohte/generic-boilerplate/issues/224))
* Update dependency eslint to v10 ([#168](https://github.com/fohte/generic-boilerplate/issues/168))
* Update dependency @tsconfig/node-lts to v24.0.0 ([#185](https://github.com/fohte/generic-boilerplate/issues/185))

### Dependencies

* **ci:** Update actions/checkout action to v6 ([#224](https://github.com/fohte/generic-boilerplate/issues/224)) ([872041b](https://github.com/fohte/generic-boilerplate/commit/872041bb779974add15211654c2fe5bf04df31bb))
* **ci:** Update suzuki-shunsuke/commit-action action to v0.1.1 ([#219](https://github.com/fohte/generic-boilerplate/issues/219)) ([4bb72bb](https://github.com/fohte/generic-boilerplate/commit/4bb72bbef1550779a1734e59fdeb57febe737fd5))
* Update @commitlint/cli to v20.4.3 ([#215](https://github.com/fohte/generic-boilerplate/issues/215)) ([d5e8be9](https://github.com/fohte/generic-boilerplate/commit/d5e8be901f09d9cce522f4194876f5598e765a9e))
* Update dependency @tsconfig/node-lts to v24.0.0 ([#185](https://github.com/fohte/generic-boilerplate/issues/185)) ([3a87b65](https://github.com/fohte/generic-boilerplate/commit/3a87b659b0ea521a5cb7485aa0f38c5f55baa123))
* Update dependency actionlint to v1.7.11 ([#217](https://github.com/fohte/generic-boilerplate/issues/217)) ([4f14df8](https://github.com/fohte/generic-boilerplate/commit/4f14df8cf3fc1f0f10fe9fab0bdf3432556156c6))
* Update dependency bun to v1.3.10 ([#194](https://github.com/fohte/generic-boilerplate/issues/194)) ([51ad24c](https://github.com/fohte/generic-boilerplate/commit/51ad24cfd6ccc21b691811db0f8a6bb239c623c9))
* Update dependency eslint to v10 ([#168](https://github.com/fohte/generic-boilerplate/issues/168)) ([348cc28](https://github.com/fohte/generic-boilerplate/commit/348cc2824e0cf3572e47e1be57b438c746d52ef0))
* Update dependency github:ast-grep/ast-grep to v0.41.0 ([#220](https://github.com/fohte/generic-boilerplate/issues/220)) ([7091f1b](https://github.com/fohte/generic-boilerplate/commit/7091f1b77bf33c5d6d53b16fc0f80f82c50ea8e1))
* Update dependency lefthook to v2.1.3 ([#218](https://github.com/fohte/generic-boilerplate/issues/218)) ([7a545d7](https://github.com/fohte/generic-boilerplate/commit/7a545d7d63abb4fbf112cef78ab3113fa3514682))
* Update dependency pnpm to v10.30.3 ([#184](https://github.com/fohte/generic-boilerplate/issues/184)) ([993b25c](https://github.com/fohte/generic-boilerplate/commit/993b25cef0766526d365a1af53d41174c63031a8))

## [0.3.18](https://github.com/fohte/generic-boilerplate/compare/v0.3.17...v0.3.18) (2026-03-14)


### Bug Fixes

* **copier:** remove auto-merge mechanism ([#212](https://github.com/fohte/generic-boilerplate/issues/212)) ([f19f421](https://github.com/fohte/generic-boilerplate/commit/f19f4214eda9d963f5c233cd4548756a48a75b2e))

## [0.3.17](https://github.com/fohte/generic-boilerplate/compare/v0.3.16...v0.3.17) (2026-03-14)


### Bug Fixes

* **copier:** simplify `copier-update` job to only restore executable bit ([#210](https://github.com/fohte/generic-boilerplate/issues/210)) ([f63ea55](https://github.com/fohte/generic-boilerplate/commit/f63ea55d422c5f2aa55822465727b7943229b74a))

## [0.3.16](https://github.com/fohte/generic-boilerplate/compare/v0.3.15...v0.3.16) (2026-03-14)


### Bug Fixes

* **copier:** move `copier update --trust` to CI workflow by removing `_tasks` ([#208](https://github.com/fohte/generic-boilerplate/issues/208)) ([57f2761](https://github.com/fohte/generic-boilerplate/commit/57f27615edd836582c149f14714367cffc1e4601))

## [0.3.15](https://github.com/fohte/generic-boilerplate/compare/v0.3.14...v0.3.15) (2026-03-05)


### Bug Fixes

* **copier:** add workaround to restore executable bit on `scripts/bootstrap` after copier update ([#205](https://github.com/fohte/generic-boilerplate/issues/205)) ([5e4117d](https://github.com/fohte/generic-boilerplate/commit/5e4117df2d56a2e507aab7259906bf72b67044bb))

## [0.3.14](https://github.com/fohte/generic-boilerplate/compare/v0.3.13...v0.3.14) (2026-02-19)


### Features

* **mise:** switch ast-grep and basefmt to `github:` backend ([#203](https://github.com/fohte/generic-boilerplate/issues/203)) ([29c54f6](https://github.com/fohte/generic-boilerplate/commit/29c54f6cc82863a6f7540290bd420fc842baea23))

## [0.3.13](https://github.com/fohte/generic-boilerplate/compare/v0.3.12...v0.3.13) (2026-02-19)


### Features

* **template:** switch lightweight CI jobs to `ubuntu-slim` runner ([#201](https://github.com/fohte/generic-boilerplate/issues/201)) ([eac9810](https://github.com/fohte/generic-boilerplate/commit/eac9810a0802403d3cebb6f2376615a83d2b1b73))

## [0.3.12](https://github.com/fohte/generic-boilerplate/compare/v0.3.11...v0.3.12) (2026-02-18)


### Features

* **rust:** migrate CI build cache to sccache ([#198](https://github.com/fohte/generic-boilerplate/issues/198)) ([49473ac](https://github.com/fohte/generic-boilerplate/commit/49473ac7d09e3621522c9e39d0e9e6cbd7eeb0b9))
* **template:** add `scripts/bootstrap` to automate dev environment setup ([#200](https://github.com/fohte/generic-boilerplate/issues/200)) ([be86016](https://github.com/fohte/generic-boilerplate/commit/be86016b6bf59a34377cbc5ba2a34043d2514780))
* **template:** share `CARGO_TARGET_DIR` across worktrees for Rust projects ([#197](https://github.com/fohte/generic-boilerplate/issues/197)) ([2e50688](https://github.com/fohte/generic-boilerplate/commit/2e50688faa2a752f11209f2d528c92c955a4ce74))

## [0.3.11](https://github.com/fohte/generic-boilerplate/compare/v0.3.10...v0.3.11) (2026-02-16)


### Features

* **template:** support pnpm workspace mode for monorepo ([#195](https://github.com/fohte/generic-boilerplate/issues/195)) ([473678c](https://github.com/fohte/generic-boilerplate/commit/473678c3c11f6e046d2ca693e460d01bbd140753))

## [0.3.10](https://github.com/fohte/generic-boilerplate/compare/v0.3.9...v0.3.10) (2026-02-15)


### Dependencies

* update dependency fohte/lefthook-config to v0.1.15 ([#192](https://github.com/fohte/generic-boilerplate/issues/192)) ([9c13dce](https://github.com/fohte/generic-boilerplate/commit/9c13dce089a2c173d1a1c70156d2d2001d544cf8))
* Update Node.js to v24 ([#186](https://github.com/fohte/generic-boilerplate/issues/186)) ([99a5156](https://github.com/fohte/generic-boilerplate/commit/99a5156834461ceab13d61ecf4eaee5d3b8e0390))

## [0.3.9](https://github.com/fohte/generic-boilerplate/compare/v0.3.8...v0.3.9) (2026-02-15)


### Features

* **template:** auto-merge Renovate copier PRs that only change `.copier-answers.yml` ([#190](https://github.com/fohte/generic-boilerplate/issues/190)) ([b5583cb](https://github.com/fohte/generic-boilerplate/commit/b5583cb488f5174168b97756b7b603571344edd5))

## [0.3.8](https://github.com/fohte/generic-boilerplate/compare/v0.3.7...v0.3.8) (2026-02-15)


### Features

* **template:** run unit tests only for changed subpackages in monorepo CI ([#188](https://github.com/fohte/generic-boilerplate/issues/188)) ([ef3a118](https://github.com/fohte/generic-boilerplate/commit/ef3a1187bae80ddafed0dfebd6b29e958c788f8c))

## [0.3.7](https://github.com/fohte/generic-boilerplate/compare/v0.3.6...v0.3.7) (2026-02-15)


### Features

* **template:** remove lockfiles from template and eliminate sync logic ([#187](https://github.com/fohte/generic-boilerplate/issues/187)) ([49c4d49](https://github.com/fohte/generic-boilerplate/commit/49c4d4978527a79909a6073f93eb1c2fab7f7297))


### Dependencies

* Update dependency @tsconfig/strictest to v2.0.8 ([#180](https://github.com/fohte/generic-boilerplate/issues/180)) ([b36dbee](https://github.com/fohte/generic-boilerplate/commit/b36dbee88989b5d51e17b43acf50ecd97c699baf))
* update dependency pnpm to v10.28.2 ([#181](https://github.com/fohte/generic-boilerplate/issues/181)) ([544e32e](https://github.com/fohte/generic-boilerplate/commit/544e32e1d67ce6dfdf07001bd3bedc5a4cf2fc08))

## [0.3.6](https://github.com/fohte/generic-boilerplate/compare/v0.3.5...v0.3.6) (2026-02-14)


### Features

* **template:** support pnpm as an alternative Node.js package manager ([#166](https://github.com/fohte/generic-boilerplate/issues/166)) ([4c8e2b3](https://github.com/fohte/generic-boilerplate/commit/4c8e2b3c8625e36e03043ae6aaaffca8a52e4659))

## [0.3.5](https://github.com/fohte/generic-boilerplate/compare/v0.3.4...v0.3.5) (2026-02-12)


### Bug Fixes

* **prefer-indoc:** restrict `token_tree` exclusion to `indoc` family macros only ([#163](https://github.com/fohte/generic-boilerplate/issues/163)) ([059935e](https://github.com/fohte/generic-boilerplate/commit/059935e3c68e48b6c921278f65bcaaf36b68e34a))
* **template:** enable `cargo-llvm-cov` coverage for monorepo Rust subpackages ([#164](https://github.com/fohte/generic-boilerplate/issues/164)) ([f350819](https://github.com/fohte/generic-boilerplate/commit/f350819dafd19ff99911269ca3e52fceabe02370))


### Dependencies

* Update @commitlint/cli to v20.4.1 ([#152](https://github.com/fohte/generic-boilerplate/issues/152)) ([004fc84](https://github.com/fohte/generic-boilerplate/commit/004fc84da7d4b8652611056a5ae273ee06943644))
* update dependency cargo:ast-grep to 0.40.5 ([#153](https://github.com/fohte/generic-boilerplate/issues/153)) ([268c5af](https://github.com/fohte/generic-boilerplate/commit/268c5afd33f1d72f446d068a8e0f17c063d2f3b6))
* update dependency lefthook to v2.1.0 ([#156](https://github.com/fohte/generic-boilerplate/issues/156)) ([66a1a13](https://github.com/fohte/generic-boilerplate/commit/66a1a13a4e4c29fd0f982db8a4e7ba2dc65417c4))

## [0.3.4](https://github.com/fohte/generic-boilerplate/compare/v0.3.3...v0.3.4) (2026-02-12)


### Bug Fixes

* **rust/sg:** detect `prefer-indoc` rule violations in pre-commit ([#160](https://github.com/fohte/generic-boilerplate/issues/160)) ([1d569a7](https://github.com/fohte/generic-boilerplate/commit/1d569a7fba6b7977cb9fe07a701b38eaa9c8a059))

## [0.3.3](https://github.com/fohte/generic-boilerplate/compare/v0.3.2...v0.3.3) (2026-02-11)


### Features

* **template:** add Rust test code review rules for AI reviewers ([#157](https://github.com/fohte/generic-boilerplate/issues/157)) ([62a6408](https://github.com/fohte/generic-boilerplate/commit/62a6408d7df6550001fb7c8631e6f859f0c72c50))

## [0.3.2](https://github.com/fohte/generic-boilerplate/compare/v0.3.1...v0.3.2) (2026-02-10)


### Features

* **sg:** add `prefer-indoc` rule for multiline string literals ([#154](https://github.com/fohte/generic-boilerplate/issues/154)) ([35646af](https://github.com/fohte/generic-boilerplate/commit/35646af827556af560ba95bae69019c0de1138cc))
* **template:** support monorepo configuration with Copier yield tag ([#150](https://github.com/fohte/generic-boilerplate/issues/150)) ([a491b7b](https://github.com/fohte/generic-boilerplate/commit/a491b7b1ef836f3a53ce338bfc220f5c20074998))

## [0.3.1](https://github.com/fohte/generic-boilerplate/compare/v0.3.0...v0.3.1) (2026-02-09)


### Features

* **template:** port improvements from armyknife ([#149](https://github.com/fohte/generic-boilerplate/issues/149)) ([5a29064](https://github.com/fohte/generic-boilerplate/commit/5a29064189bea86a1f36b6d9571db3fee56e543c))

## [0.3.0](https://github.com/fohte/generic-boilerplate/compare/v0.2.0...v0.3.0) (2026-02-07)


### ⚠ BREAKING CHANGES

* Update dependency eslint to v9 ([#131](https://github.com/fohte/generic-boilerplate/issues/131))

### Dependencies

* Update @commitlint/cli to v20.4.0 ([#145](https://github.com/fohte/generic-boilerplate/issues/145)) ([4d45aa9](https://github.com/fohte/generic-boilerplate/commit/4d45aa9a2cd679ff6565bb9aa413acbfda12487a))
* Update dependency @fohte/eslint-config to v0.1.2 ([#148](https://github.com/fohte/generic-boilerplate/issues/148)) ([b21ca02](https://github.com/fohte/generic-boilerplate/commit/b21ca0293569f9a76712a373ec198e370bbf2e12))
* Update dependency @types/bun to v1.3.8 ([#144](https://github.com/fohte/generic-boilerplate/issues/144)) ([856acca](https://github.com/fohte/generic-boilerplate/commit/856acca4448001d0e53dd461b4f920a25c65df3d))
* Update dependency eslint to v9 ([#131](https://github.com/fohte/generic-boilerplate/issues/131)) ([cfbe071](https://github.com/fohte/generic-boilerplate/commit/cfbe07116ad6c85cfaad54b85f8aecb68f783aeb))

## [0.2.0](https://github.com/fohte/generic-boilerplate/compare/v0.1.27...v0.2.0) (2026-02-05)


### ⚠ BREAKING CHANGES

* **ci:** Update actions/cache action to v5 ([#142](https://github.com/fohte/generic-boilerplate/issues/142))
* **ci:** Update actions/cache action to v5 ([#137](https://github.com/fohte/generic-boilerplate/issues/137))
* **ci:** Update jdx/mise-action action to v3 ([#138](https://github.com/fohte/generic-boilerplate/issues/138))
* **ci:** Update actions/checkout action to v6 ([#139](https://github.com/fohte/generic-boilerplate/issues/139))
* **ci:** Update actions/checkout action to v6 ([#15](https://github.com/fohte/generic-boilerplate/issues/15))
* **ci:** Update jdx/mise-action action to v3 ([#36](https://github.com/fohte/generic-boilerplate/issues/36))
* Update dependency vitest to v4 ([#135](https://github.com/fohte/generic-boilerplate/issues/135))

### Dependencies

* **ci:** Update actions/cache action to v5 ([#137](https://github.com/fohte/generic-boilerplate/issues/137)) ([a4909f6](https://github.com/fohte/generic-boilerplate/commit/a4909f63291346e51435612c5e08edb131f6b831))
* **ci:** Update actions/cache action to v5 ([#142](https://github.com/fohte/generic-boilerplate/issues/142)) ([1514662](https://github.com/fohte/generic-boilerplate/commit/151466245c0ce29725986efe94931cf89f3dc585))
* **ci:** Update actions/checkout action to v6 ([#139](https://github.com/fohte/generic-boilerplate/issues/139)) ([eec7e08](https://github.com/fohte/generic-boilerplate/commit/eec7e087d8d9224b55b2118b5f9676cb10ce6944))
* **ci:** Update actions/checkout action to v6 ([#15](https://github.com/fohte/generic-boilerplate/issues/15)) ([5cbe1ff](https://github.com/fohte/generic-boilerplate/commit/5cbe1ff060d3186c3d8ad3e4b4e7c67217959970))
* **ci:** Update jdx/mise-action action to v3 ([#138](https://github.com/fohte/generic-boilerplate/issues/138)) ([d29667f](https://github.com/fohte/generic-boilerplate/commit/d29667fd489dc6dde741228b3466788d9b5f0ecb))
* **ci:** Update jdx/mise-action action to v3 ([#36](https://github.com/fohte/generic-boilerplate/issues/36)) ([8d1113d](https://github.com/fohte/generic-boilerplate/commit/8d1113d66fada9eb7f62efb37d7b2c5347e6d04e))
* **ci:** Update suzuki-shunsuke/commit-action action to v0.1.0 ([#123](https://github.com/fohte/generic-boilerplate/issues/123)) ([bc3140e](https://github.com/fohte/generic-boilerplate/commit/bc3140e7d44db016c6e486ee8fe1fc659b5ea735))
* update dependency bun to v1.3.7 ([#132](https://github.com/fohte/generic-boilerplate/issues/132)) ([13edafc](https://github.com/fohte/generic-boilerplate/commit/13edafccbfe1510dbf3bdaac35f93baea679cca8))
* update dependency bun to v1.3.8 ([#136](https://github.com/fohte/generic-boilerplate/issues/136)) ([4e5a2fa](https://github.com/fohte/generic-boilerplate/commit/4e5a2fa9e1d5d0d936d88ab2d1d51ccbd3d2becd))
* update dependency lefthook to v2.0.16 ([#133](https://github.com/fohte/generic-boilerplate/issues/133)) ([a2f1b08](https://github.com/fohte/generic-boilerplate/commit/a2f1b08f4ce8f6511b3963a4b9c5ceda6d7a5828))
* Update dependency vitest to v4 ([#135](https://github.com/fohte/generic-boilerplate/issues/135)) ([999ec84](https://github.com/fohte/generic-boilerplate/commit/999ec84ec021b37de2a33f59d44161c0cfbfb846))
* update prettier to v3.8.1 ([#130](https://github.com/fohte/generic-boilerplate/issues/130)) ([e3f9e7a](https://github.com/fohte/generic-boilerplate/commit/e3f9e7ae1d33211324d31df62e7590f51587ee91))
* update rust crate thiserror to v2.0.18 ([#134](https://github.com/fohte/generic-boilerplate/issues/134)) ([e3ebf58](https://github.com/fohte/generic-boilerplate/commit/e3ebf58cbc776c755786c7bb1d87815686992237))

## [0.1.27](https://github.com/fohte/generic-boilerplate/compare/v0.1.26...v0.1.27) (2026-02-02)


### Dependencies

* update dependency fohte/lefthook-config to v0.1.14 ([#120](https://github.com/fohte/generic-boilerplate/issues/120)) ([17f3248](https://github.com/fohte/generic-boilerplate/commit/17f3248269afca161c6cbe4aade03d71b09c2cc6))

## [0.1.26](https://github.com/fohte/generic-boilerplate/compare/v0.1.25...v0.1.26) (2026-01-27)


### Bug Fixes

* **apply-renovate-patch:** correctly sync semver range specifier changes ([#116](https://github.com/fohte/generic-boilerplate/issues/116)) ([0ec61e5](https://github.com/fohte/generic-boilerplate/commit/0ec61e596aacb824a722209f2e5df065c1755100))
* **apply-renovate-patch:** handle unquoted YAML versions with v prefix ([#114](https://github.com/fohte/generic-boilerplate/issues/114)) ([bdd35f6](https://github.com/fohte/generic-boilerplate/commit/bdd35f672e66f27cd5e7e9229c91f501caede24c))
* **copier:** copy `bun.lock` from `generated/node/` ([#111](https://github.com/fohte/generic-boilerplate/issues/111)) ([da40af5](https://github.com/fohte/generic-boilerplate/commit/da40af5d54518e2203c1eebfe872fc5b8bea05d3))


### Dependencies

* update dependency actionlint to v1.7.10 ([#66](https://github.com/fohte/generic-boilerplate/issues/66)) ([ff2eab5](https://github.com/fohte/generic-boilerplate/commit/ff2eab587b26a7e90a43821fabf98a423dedbb6b))
* update dependency bun to v1.3.6 ([#117](https://github.com/fohte/generic-boilerplate/issues/117)) ([128fd8b](https://github.com/fohte/generic-boilerplate/commit/128fd8b7adc4237accd32dd6c2cced0cd5bae538))
* update dependency fohte/lefthook-config to v0.1.13 ([#97](https://github.com/fohte/generic-boilerplate/issues/97)) ([5b1df41](https://github.com/fohte/generic-boilerplate/commit/5b1df414758c13d5c1e23304ddf7cc4281037d1d))
* update dependency lefthook to v2.0.15 ([#43](https://github.com/fohte/generic-boilerplate/issues/43)) ([e5f27c4](https://github.com/fohte/generic-boilerplate/commit/e5f27c4d4799f19cf1a0e65fcfc2888ff2df8b11))

## [0.1.25](https://github.com/fohte/generic-boilerplate/compare/v0.1.24...v0.1.25) (2026-01-22)


### Features

* **template:** add `type: rust` for Rust project template generation ([#95](https://github.com/fohte/generic-boilerplate/issues/95)) ([9cfd7f9](https://github.com/fohte/generic-boilerplate/commit/9cfd7f9bfe9bd60e194ee3557d6ee8df86996a69))

## [0.1.24](https://github.com/fohte/generic-boilerplate/compare/v0.1.23...v0.1.24) (2026-01-21)


### Bug Fixes

* **copier:** allow Renovate to run `copier update` ([#93](https://github.com/fohte/generic-boilerplate/issues/93)) ([fd86b3e](https://github.com/fohte/generic-boilerplate/commit/fd86b3edebd7d2c1cc8421c34473fa8086788d5a))

## [0.1.23](https://github.com/fohte/generic-boilerplate/compare/v0.1.22...v0.1.23) (2026-01-21)


### Bug Fixes

* **copier:** prevent package.json conflicts during copier update ([#91](https://github.com/fohte/generic-boilerplate/issues/91)) ([50e149f](https://github.com/fohte/generic-boilerplate/commit/50e149f569853dbb8780cb2633958f47c470a0e6))

## [0.1.22](https://github.com/fohte/generic-boilerplate/compare/v0.1.21...v0.1.22) (2026-01-03)


### Dependencies

* update dependency fohte/lefthook-config to v0.1.11 ([#89](https://github.com/fohte/generic-boilerplate/issues/89)) ([79b3add](https://github.com/fohte/generic-boilerplate/commit/79b3addc6707d0f04fc7ad7bc79bcead78463434))

## [0.1.21](https://github.com/fohte/generic-boilerplate/compare/v0.1.20...v0.1.21) (2026-01-03)


### Features

* **template:** add Gemini Code Assist style guide ([#87](https://github.com/fohte/generic-boilerplate/issues/87)) ([7b80a32](https://github.com/fohte/generic-boilerplate/commit/7b80a32a83910a424762b5ce7d543306111c5088))

## [0.1.20](https://github.com/fohte/generic-boilerplate/compare/v0.1.19...v0.1.20) (2026-01-02)


### Bug Fixes

* **copier:** include bun.lock in template to avoid conflicts on update ([#84](https://github.com/fohte/generic-boilerplate/issues/84)) ([7df765a](https://github.com/fohte/generic-boilerplate/commit/7df765a682296570ce5582f5d8cbc237dea80743))

## [0.1.19](https://github.com/fohte/generic-boilerplate/compare/v0.1.18...v0.1.19) (2026-01-01)


### Features

* add Gemini Code Assist style guide ([#78](https://github.com/fohte/generic-boilerplate/issues/78)) ([1f9c231](https://github.com/fohte/generic-boilerplate/commit/1f9c2311e0fa5342067efaad15703baf7992636d))

## [0.1.18](https://github.com/fohte/generic-boilerplate/compare/v0.1.17...v0.1.18) (2025-12-31)


### Bug Fixes

* **template:** fix broken symlinks for commitlint config files ([#74](https://github.com/fohte/generic-boilerplate/issues/74)) ([42d78aa](https://github.com/fohte/generic-boilerplate/commit/42d78aa3aab54fdb0f322116ce412ded2a11278c))

## [0.1.17](https://github.com/fohte/generic-boilerplate/compare/v0.1.16...v0.1.17) (2025-12-31)


### Bug Fixes

* **commitlint:** fix no-external-github-refs rule not working ([#70](https://github.com/fohte/generic-boilerplate/issues/70)) ([0a8c1f1](https://github.com/fohte/generic-boilerplate/commit/0a8c1f1b5a5cea8c9af777f45fb62b0132f2e274))

## [0.1.16](https://github.com/fohte/generic-boilerplate/compare/v0.1.15...v0.1.16) (2025-12-31)


### Features

* **prettier:** change trailingComma to all ([#67](https://github.com/fohte/generic-boilerplate/issues/67)) ([049a2a2](https://github.com/fohte/generic-boilerplate/commit/049a2a2e279c358a9d0bca8d5255d3dd680523cb))

## [0.1.15](https://github.com/fohte/generic-boilerplate/compare/v0.1.14...v0.1.15) (2025-12-30)


### Bug Fixes

* **copier:** change `use_release_please` default to false ([#64](https://github.com/fohte/generic-boilerplate/issues/64)) ([ae5d7fb](https://github.com/fohte/generic-boilerplate/commit/ae5d7fb12aef24071b0ab03075a1431032a054c1))

## [0.1.14](https://github.com/fohte/generic-boilerplate/compare/v0.1.13...v0.1.14) (2025-12-30)


### Features

* **copier:** make release-please config reusable as template ([#62](https://github.com/fohte/generic-boilerplate/issues/62)) ([2779f75](https://github.com/fohte/generic-boilerplate/commit/2779f75bd7a29772dd6574015f80e0e100eaf53f))

## [0.1.13](https://github.com/fohte/generic-boilerplate/compare/v0.1.12...v0.1.13) (2025-12-30)


### Features

* add commitlint ([#53](https://github.com/fohte/generic-boilerplate/issues/53)) ([940b67b](https://github.com/fohte/generic-boilerplate/commit/940b67bda79a532d64cf008a01c1dc74509edb05))
* **commitlint:** add custom plugin to prevent external GitHub references ([#55](https://github.com/fohte/generic-boilerplate/issues/55)) ([d0616b8](https://github.com/fohte/generic-boilerplate/commit/d0616b82ec993c1dcd08a75063e1a9f63739ad71))


### Bug Fixes

* **release-please:** display deps commits in release notes ([#58](https://github.com/fohte/generic-boilerplate/issues/58)) ([a85a0d1](https://github.com/fohte/generic-boilerplate/commit/a85a0d1b172c94594ffd813488fb8e0048814183))
* **template:** clean up README template and add description parameter ([#56](https://github.com/fohte/generic-boilerplate/issues/56)) ([4d4a121](https://github.com/fohte/generic-boilerplate/commit/4d4a121d2b1a5049461029e068962ac10d12e886))


### Dependencies

* update dependency fohte/lefthook-config to v0.1.10 ([#57](https://github.com/fohte/generic-boilerplate/issues/57)) ([6c18582](https://github.com/fohte/generic-boilerplate/commit/6c18582155247b41885621d75b1114dae9c42465))
* update dependency fohte/lefthook-config to v0.1.9 ([#50](https://github.com/fohte/generic-boilerplate/issues/50)) ([2e7929b](https://github.com/fohte/generic-boilerplate/commit/2e7929b8e4a915c70edd9a9a20b9fc09969f7050))

## [0.1.12](https://github.com/fohte/generic-boilerplate/compare/v0.1.11...v0.1.12) (2025-12-28)


### Bug Fixes

* **template:** fix empty README h1 when destination is relative path ([#51](https://github.com/fohte/generic-boilerplate/issues/51)) ([78a18b8](https://github.com/fohte/generic-boilerplate/commit/78a18b811c0cde62e8d92485c3a50d60c35f001c))

## [0.1.11](https://github.com/fohte/generic-boilerplate/compare/v0.1.10...v0.1.11) (2025-12-28)


### Bug Fixes

* **ci:** fix commit-action not detecting staged changes ([#48](https://github.com/fohte/generic-boilerplate/issues/48)) ([3c73768](https://github.com/fohte/generic-boilerplate/commit/3c73768e61e262236a8787a98178846d45858a48))

## [0.1.10](https://github.com/fohte/generic-boilerplate/compare/v0.1.9...v0.1.10) (2025-12-28)


### Bug Fixes

* **editorconfig:** apply shfmt options to extensionless scripts ([#46](https://github.com/fohte/generic-boilerplate/issues/46)) ([0eb46dc](https://github.com/fohte/generic-boilerplate/commit/0eb46dce43ee84b9dd26b34073f7d3ca777830d8))

## [0.1.9](https://github.com/fohte/generic-boilerplate/compare/v0.1.8...v0.1.9) (2025-12-28)


### Features

* **renovate:** add `$schema` for LSP completion ([#44](https://github.com/fohte/generic-boilerplate/issues/44)) ([0c75bb1](https://github.com/fohte/generic-boilerplate/commit/0c75bb185616ec17797abc3d76d0bd2dcae26150))


### Bug Fixes

* **deps:** update dependency fohte/lefthook-config to v0.1.7 ([#42](https://github.com/fohte/generic-boilerplate/issues/42)) ([1e3526b](https://github.com/fohte/generic-boilerplate/commit/1e3526b9851c05693e62fb75a8971aa40482f692))

## [0.1.8](https://github.com/fohte/generic-boilerplate/compare/v0.1.7...v0.1.8) (2025-12-24)


### Features

* **mise:** add shellcheck and shfmt ([#40](https://github.com/fohte/generic-boilerplate/issues/40)) ([18f18b1](https://github.com/fohte/generic-boilerplate/commit/18f18b16083a90eebb60725a1870ca2726035085))

## [0.1.7](https://github.com/fohte/generic-boilerplate/compare/v0.1.6...v0.1.7) (2025-12-23)


### Bug Fixes

* `'pathlib.PurePosixPath object' has no attribute 'resolve'` ([#38](https://github.com/fohte/generic-boilerplate/issues/38)) ([213a98e](https://github.com/fohte/generic-boilerplate/commit/213a98ec04a0a022bc6778451ac31995390869ab))

## [0.1.6](https://github.com/fohte/generic-boilerplate/compare/v0.1.5...v0.1.6) (2025-12-21)


### Features

* migrate from pre-commit to lefthook ([#32](https://github.com/fohte/generic-boilerplate/issues/32)) ([a6913a5](https://github.com/fohte/generic-boilerplate/commit/a6913a5abe395644250fa5fc0752dc79093bdb79))


### Bug Fixes

* **ci:** prevent infinite auto-format commit loop ([#33](https://github.com/fohte/generic-boilerplate/issues/33)) ([580e0cb](https://github.com/fohte/generic-boilerplate/commit/580e0cbb0885db83f73c0fb8b95ce51bf649e897))

## [0.1.5](https://github.com/fohte/generic-boilerplate/compare/v0.1.4...v0.1.5) (2025-12-17)


### Features

* **editorconfig:** add shfmt and Makefile settings ([#30](https://github.com/fohte/generic-boilerplate/issues/30)) ([3a28298](https://github.com/fohte/generic-boilerplate/commit/3a28298eafb097d16ab79c7249e238780d8d9663))

## [0.1.4](https://github.com/fohte/generic-boilerplate/compare/v0.1.3...v0.1.4) (2025-12-17)


### Bug Fixes

* **copier:** use default answers file name ([#28](https://github.com/fohte/generic-boilerplate/issues/28)) ([5853c3c](https://github.com/fohte/generic-boilerplate/commit/5853c3c04724ec1538d6a9584ac2b4975e485555))

## [0.1.3](https://github.com/fohte/generic-boilerplate/compare/v0.1.2...v0.1.3) (2025-12-16)


### Bug Fixes

* **copier:** add .git and copier.yml to exclude list ([#26](https://github.com/fohte/generic-boilerplate/issues/26)) ([bb81a68](https://github.com/fohte/generic-boilerplate/commit/bb81a6873bad9a41b4d8188d57efc37ef4a9b3ae))

## [0.1.2](https://github.com/fohte/generic-boilerplate/compare/v0.1.1...v0.1.2) (2025-12-16)


### Bug Fixes

* **copier:** exclude release-please files from template ([#24](https://github.com/fohte/generic-boilerplate/issues/24)) ([c4a9391](https://github.com/fohte/generic-boilerplate/commit/c4a9391a427744e66f2fb08f3201a449d182cdc0))

## [0.1.1](https://github.com/fohte/generic-boilerplate/compare/v0.1.0...v0.1.1) (2025-12-13)


### Features

* add Copier template support for update propagation ([#17](https://github.com/fohte/generic-boilerplate/issues/17)) ([dc8ea36](https://github.com/fohte/generic-boilerplate/commit/dc8ea36d1e73b5d21cf2b4065c3706b850bc694e))
* add release-please for automated releases ([#22](https://github.com/fohte/generic-boilerplate/issues/22)) ([300504f](https://github.com/fohte/generic-boilerplate/commit/300504f21a2ae2d8ae5ab004bbce891ff99df53f))
