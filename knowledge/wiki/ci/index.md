[Home](../../index.md) › CI

# CI

Continuous integration setup for the project, pipeline configuration, build and test workflows, and the conventions that govern when they run. Covers signing, artifact handling, and how a failing check gets diagnosed.

## Pipelines

- [Document Workflows](document-workflows.md) - okf-validate, okf-approve and kb-catalog: how specs and knowledge pages are checked and approved, the bot commit they add to main, and what their rules files cover.
- [Pull Request Checks](pull-request-checks.md) - What runs on each pull request and push to main, how long it may take, and what is special about each job, including the iOS retry.
