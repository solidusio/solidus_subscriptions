# Changelog

## [Unreleased](https://github.com/solidusio-contrib/solidus_subscriptions/tree/HEAD)

[Full Changelog](https://github.com/solidusio-contrib/solidus_subscriptions/compare/a8a92654ba21b22bd3f8d07c3ae25e3604e7942a...HEAD)

**Implemented enhancements:**

- Allow admins to add subscription items when editing subscription [\#103](https://github.com/solidusio-contrib/solidus_subscriptions/pull/103) ([aldesantis](https://github.com/aldesantis))

**Fixed bugs:**

- Fix "Store must exist" when creating a subscription via the backend [\#102](https://github.com/solidusio-contrib/solidus_subscriptions/pull/102) ([aldesantis](https://github.com/aldesantis))

**Deprecated:**

- Update admin UI to match new backend guidelines [\#99](https://github.com/solidusio-contrib/solidus_subscriptions/pull/99) ([aldesantis](https://github.com/aldesantis))
- Fix deprecated call to `SolidusSupport.solidus\_gem\_version` [\#97](https://github.com/solidusio-contrib/solidus_subscriptions/pull/97) ([aldesantis](https://github.com/aldesantis))

**Removed:**

- Remove checks on unsupported Solidus versions [\#101](https://github.com/solidusio-contrib/solidus_subscriptions/pull/101) ([aldesantis](https://github.com/aldesantis))
- Remove legacy sidebar and form [\#100](https://github.com/solidusio-contrib/solidus_subscriptions/pull/100) ([aldesantis](https://github.com/aldesantis))

**Merged pull requests:**

- Reorganize and clean up readme [\#104](https://github.com/solidusio-contrib/solidus_subscriptions/pull/104) ([aldesantis](https://github.com/aldesantis))
- Relax solidus\_support dependency [\#95](https://github.com/solidusio-contrib/solidus_subscriptions/pull/95) ([kennyadsl](https://github.com/kennyadsl))
- Fix Dependabot looking for Gemfile-local [\#92](https://github.com/solidusio-contrib/solidus_subscriptions/pull/92) ([aldesantis](https://github.com/aldesantis))
- Update solidus\_dev\_support [\#89](https://github.com/solidusio-contrib/solidus_subscriptions/pull/89) ([blocknotes](https://github.com/blocknotes))
- Adopt solidus\_extension\_dev\_tools [\#81](https://github.com/solidusio-contrib/solidus_subscriptions/pull/81) ([aldesantis](https://github.com/aldesantis))
- Fix CI on Rails 6 [\#71](https://github.com/solidusio-contrib/solidus_subscriptions/pull/71) ([aldesantis](https://github.com/aldesantis))
- Fixes admin sorting on fields without a natural order [\#70](https://github.com/solidusio-contrib/solidus_subscriptions/pull/70) ([mdesantis](https://github.com/mdesantis))
- Perform maintenance tasks [\#69](https://github.com/solidusio-contrib/solidus_subscriptions/pull/69) ([mdesantis](https://github.com/mdesantis))
- Run specs with CircleCI [\#68](https://github.com/solidusio-contrib/solidus_subscriptions/pull/68) ([kennyadsl](https://github.com/kennyadsl))
- Fix broken factories associations [\#67](https://github.com/solidusio-contrib/solidus_subscriptions/pull/67) ([aitbw](https://github.com/aitbw))
- Remove Solidus v2.3 from Travis config \(EOL\) [\#66](https://github.com/solidusio-contrib/solidus_subscriptions/pull/66) ([aitbw](https://github.com/aitbw))
- Add Solidus v2.8 to Travis config [\#65](https://github.com/solidusio-contrib/solidus_subscriptions/pull/65) ([aitbw](https://github.com/aitbw))
- Do not run rubocop on Travis [\#64](https://github.com/solidusio-contrib/solidus_subscriptions/pull/64) ([aitbw](https://github.com/aitbw))
- Update rubocop to fix vulnerability CVE-2017-8418 [\#63](https://github.com/solidusio-contrib/solidus_subscriptions/pull/63) ([aitbw](https://github.com/aitbw))
- Fix deprecations warnings and failing specs [\#61](https://github.com/solidusio-contrib/solidus_subscriptions/pull/61) ([aitbw](https://github.com/aitbw))
- Change api url in documentation [\#58](https://github.com/solidusio-contrib/solidus_subscriptions/pull/58) ([jacobeubanks](https://github.com/jacobeubanks))
- Fix factory girl dependency for Solidus \< 2.5 [\#57](https://github.com/solidusio-contrib/solidus_subscriptions/pull/57) ([jacobherrington](https://github.com/jacobherrington))
- Add Solidus 2.7 to .travis.yml [\#56](https://github.com/solidusio-contrib/solidus_subscriptions/pull/56) ([jacobherrington](https://github.com/jacobherrington))
- Change static factory attrs to dynamic [\#55](https://github.com/solidusio-contrib/solidus_subscriptions/pull/55) ([fastjames](https://github.com/fastjames))
- Update factory\_girl to factory\_bot [\#50](https://github.com/solidusio-contrib/solidus_subscriptions/pull/50) ([fastjames](https://github.com/fastjames))
- Update solidus version for travis [\#46](https://github.com/solidusio-contrib/solidus_subscriptions/pull/46) ([fastjames](https://github.com/fastjames))
- Fix typos in comments [\#39](https://github.com/solidusio-contrib/solidus_subscriptions/pull/39) ([swcraig](https://github.com/swcraig))
- Add ffaker dependency to gemspec [\#35](https://github.com/solidusio-contrib/solidus_subscriptions/pull/35) ([swcraig](https://github.com/swcraig))
- Small UI change to canceling in the admin [\#28](https://github.com/solidusio-contrib/solidus_subscriptions/pull/28) ([seantaylor](https://github.com/seantaylor))
- Authorize subscriptions admin sidebar link [\#23](https://github.com/solidusio-contrib/solidus_subscriptions/pull/23) ([brendandeere](https://github.com/brendandeere))
- Subs track their own interval now [\#21](https://github.com/solidusio-contrib/solidus_subscriptions/pull/21) ([brendandeere](https://github.com/brendandeere))
- Fix/the broken admin [\#20](https://github.com/solidusio-contrib/solidus_subscriptions/pull/20) ([brendandeere](https://github.com/brendandeere))
- Allow destroying nested line items [\#18](https://github.com/solidusio-contrib/solidus_subscriptions/pull/18) ([isaacfreeman](https://github.com/isaacfreeman))
- Update Readme to correct repo [\#17](https://github.com/solidusio-contrib/solidus_subscriptions/pull/17) ([asecondwill](https://github.com/asecondwill))
- Support Rails 5.1  [\#16](https://github.com/solidusio-contrib/solidus_subscriptions/pull/16) ([jhawthorn](https://github.com/jhawthorn))
- Allows for subscription checkout to accommodate a more flexible checko… [\#15](https://github.com/solidusio-contrib/solidus_subscriptions/pull/15) ([joeljackson](https://github.com/joeljackson))
- Only load permitted attributes once [\#11](https://github.com/solidusio-contrib/solidus_subscriptions/pull/11) ([brendandeere](https://github.com/brendandeere))
- Fix duplicated docs [\#10](https://github.com/solidusio-contrib/solidus_subscriptions/pull/10) ([brendandeere](https://github.com/brendandeere))
- Add Subcription inputs to product page [\#9](https://github.com/solidusio-contrib/solidus_subscriptions/pull/9) ([brendandeere](https://github.com/brendandeere))
- Fixes for Solidus 2.2 [\#5](https://github.com/solidusio-contrib/solidus_subscriptions/pull/5) ([jhawthorn](https://github.com/jhawthorn))
- Allow Failed installments to not be reprocessed [\#4](https://github.com/solidusio-contrib/solidus_subscriptions/pull/4) ([brendandeere](https://github.com/brendandeere))
- Lock travis bundler version [\#3](https://github.com/solidusio-contrib/solidus_subscriptions/pull/3) ([brendandeere](https://github.com/brendandeere))
- Group subscriptions by subscription configurations [\#2](https://github.com/solidusio-contrib/solidus_subscriptions/pull/2) ([brendandeere](https://github.com/brendandeere))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
