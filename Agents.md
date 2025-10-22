## C10Y Agents Guide

This document defines agentic best practices for developing, testing, securing, and operating the C10Y (Cryptovalley) EVM project. It is written for human contributors and autonomous agents working via GitHub.

### Scope
- **Smart contracts**: Foundry-based Solidity in `src/`, tests in `test/`, scripts in `script/`.
- **Automation**: GitHub Actions for CI, coverage, security checks, and testnet deployments.
- **Web dApp**: Served via GitHub Pages, wallet-first UX (Rainbow, WalletConnect), reads the latest published deployment addresses.

### Core Principles
- **Security-first**: Prefer simple, audited patterns. Keep contracts minimal and immutable unless a strong need exists for upgradability.
- **Determinism**: Pin toolchain and dependencies. Reproducible builds across CI and local.
- **High test coverage**: Target ≥98% line coverage for contracts in `src/`; enforce thresholds in CI.
- **Separation of concerns**: Contract logic, deploy scripts, and front-end each own their responsibilities with clear interfaces.
- **Automate everything**: Tests, coverage, static analysis, deploys, and verifications should be automated and observable.
- **Least privilege**: Keys and tokens are scoped to the minimum required, stored only in GitHub Secrets.

### Repository Layout
- `src/` – Solidity sources (e.g., `src/C10Y.sol`)
- `test/` – Foundry tests (unit + integration/fork tests)
- `script/` – Forge scripts for deployment/maintenance (e.g., `script/DeployC10Y.s.sol`)
- `lib/` – vendored dependencies (e.g., `forge-std`)
- `out/`, `broadcast/` – build and deployment artifacts (ignored in Git)
- `Agents.md` – this guide

### Tooling Baseline
- **Compiler**: `solc` pinned via `foundry.toml` (`solc_version = "0.8.24"`).
- **Test/Build**: Foundry (`forge build`, `forge test`, `forge coverage`).
- **Static analysis**: Slither (via GitHub Action), optional Mythril/Echidna as needed.
- **Formatting**: `forge fmt` with repo-defined configuration.

### Secrets and Configuration (GitHub)
- Store secrets under GitHub repo or org secrets, never in the codebase:
  - `SEPOLIA_RPC_URL` – HTTPS RPC URL for the Sepolia testnet
  - `DEPLOYER_PRIVATE_KEY` – private key for testnet deployments (funded, testnet-only)
  - `ETHERSCAN_API_KEY` – for contract verification
  - (Optional) Additional RPCs or scanners per network
- Never echo secrets in logs. Use GitHub Actions `secrets.*` and mask outputs.

### CI Expectations
- **Formatting**: `forge fmt --check` must pass.
- **Compile**: `forge build` must pass without errors.
- **Tests**: `forge test -vvv` must pass.
- **Coverage**: `forge coverage --report lcov` must meet thresholds.
  - Coverage thresholds (default):
    - `src/**`: lines ≥98%, branches ≥90%
    - `script/**`, `test/**`, `lib/**`: excluded from thresholds
- **Static analysis**: Slither must execute and report findings; high/critical items block merges.

### Integration Testing
- Prefer fork-based tests for integration with live state:
  - `forge test --fork-url $SEPOLIA_RPC_URL -vvv` for read-only or simulated interactions
- For stateful end-to-end tests, run an ephemeral Anvil instance with fork:
  - `anvil --fork-url $SEPOLIA_RPC_URL` and point tests/scripts at the local RPC

### Deployment (Testnet)
- Deploy via `forge script` using a dedicated testnet deployer key from GitHub Secrets.
- All deploys are performed by GitHub Actions and are reproducible:
  - Broadcast transaction via `--broadcast`
  - Verify on Etherscan when possible
  - Persist outputs (addresses, ABI, metadata) to build artifacts
  - Publish deployment manifest for the web dApp to consume

### Deployment (Mainnet)
- Manual approval required via protected workflow.
- Separate keys and limits; consider a multisig for ownership/administration.
- Produce a signed release with immutable deployment metadata.

### Web dApp (GitHub Pages)
- The front-end should read a published `deployment.json` (per network) produced by CI with:
  - Contract addresses
  - Chain ID and network name
  - ABI source (or reference to artifacts)
- Wallet UX:
  - Prefer RainbowKit/Wagmi/Viem for a robust wallet experience
  - List testnets and mainnet explicitly; default to testnet in non-prod builds

### Suggested GitHub Actions (High-Level)
- `ci.yml`
  - Setup Foundry
  - `forge fmt --check`
  - `forge build`
  - `forge test -vvv`
  - `forge coverage --report lcov`
  - Parse LCOV and enforce thresholds
  - Run Slither static analysis
- `deploy-testnet.yml`
  - Trigger: `workflow_dispatch`, tags, or labeled PR merges
  - Use `DEPLOYER_PRIVATE_KEY` and `SEPOLIA_RPC_URL`
  - `forge script script/DeployC10Y.s.sol:DeployC10Y --rpc-url $SEPOLIA_RPC_URL --broadcast -vvvv`
  - Verify with `--verify` if applicable; publish `deployment.json` as artifact
- `pages.yml`
  - Build the web app (if present) and publish to GitHub Pages
  - Pull deployment info artifact for network config

### Coverage Enforcement Guidance
- Generate LCOV: `forge coverage --report lcov`
- Exclude non-source paths using LCOV filters or a post-step
- Parse LCOV summary and fail the job if below thresholds
- Keep coverage thresholds in one place (e.g., an env var or a `coverage.config.json`) to avoid drift

### Security Checklist (per PR)
- Events emitted for state changes (minting, transfers, config updates)
- Access control reviewed (no privileged calls unless required)
- External calls handled carefully (no reentrancy vulnerabilities)
- No hidden stateful dependencies in scripts/tests
- Gas costs acceptable and predictable; no accidental quadratic behavior
- No secrets or private keys leaked in code or logs

### Decision Records
- Record impactful decisions in short ADRs under `docs/adr/` (date-stamped markdown). Keep them concise with context, decision, and consequences.

### Versioning and Releases
- SemVer for contracts and the dApp
- Tag releases on merges to `main` with passing CI
- Attach artifacts (ABIs, address manifests) to GitHub Releases

### Ground Rules for Agents
- Work in short, verifiable increments; prefer small PRs with isolated scope
- Always run tests locally or via CI before proposing a deploy
- Avoid interactive steps; everything must be scriptable and replayable
- Never store, paste, or log secrets
- Prefer declarative configs and pinned versions over ad-hoc scripts
- Document non-obvious behaviors in code comments and ADRs

### Onboarding Checklist
- Install Foundry and run `forge test`
- Set up `ETHERSCAN_API_KEY` locally (optional) to verify on testnets
- Read `foundry.toml` and `script/DeployC10Y.s.sol`
- Run coverage locally: `forge coverage --report lcov`

### Future Enhancements
- Add Mythril/Echidna-based fuzz/property tests in CI
- Introduce gas snapshots (`forge snapshot`) for regression tracking
- Add ChatOps commands (e.g., comment `/deploy sepolia`) to trigger deploy workflows
- Automate Pages-side configuration refresh after deploys

---

This guide will evolve as the project grows. When in doubt, choose the safer path, add tests, and automate the workflow.
