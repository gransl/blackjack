# Godot Testing + CI Setup Notes

Setting up GdUnit4 and a GitHub Actions pipeline on an existing Godot 4 project.
Environment: Windows, Godot 4.7.1, GDScript.

---

## 1. Picking a framework

Godot has no built-in test framework. Two main options:

- **GUT** (Godot Unit Test) — older, more tutorials and StackOverflow answers.
  `assert_eq(actual, expected)`, close to classic JUnit 4.
- **GdUnit4** — fluent typed assertions `assert_int(x).is_equal(y)`, closer to
  AssertJ. Better failure output, ships its own GitHub Action.

Chose GdUnit4. Deciding factor was the CI story — the maintained action removes
most of the pipeline work.

Note for teaching beginners: fluent assertions are *discoverable via
autocomplete*. Typing `assert_int(x).` shows every valid matcher. With
`assert_eq` you have to already know the assertion vocabulary.

---

## 2. Installing

Asset Library (AssetLib tab in editor) stalled at "version: loading" with the
download button greyed out. Known flaky. Cloned instead:
	
```
	git clone https://github.com/MikeSchulze/gdUnit4.git temp-gdunit
	xcopy /E /I temp-gdunit\addons\gdUnit4 addons\gdUnit4
	rmdir /S /Q temp-gdunit
```

Then: Project > Project Settings > Plugins > enable gdUnit4 > restart editor.
A GdUnit panel appears in the bottom dock.

**Commit the addon.** CI clones the repo and gets only what's tracked. No addon
in the clone means no runner. Godot has no dependency manager for addons, so
vendoring is the normal approach.

---

## 3. Writing tests

Structure: `test/` as a sibling of `src/`, at project root.

- Suites extend `GdUnitTestSuite`
- Test methods must start with `test_`
- Helper methods deliberately don't get the prefix

**A typo'd prefix silently skips the test.** `tets_add_card` doesn't error, it
just never runs. Watch the test count in the run summary.

### Lifecycle hooks (JUnit equivalents)

	func before() -> void:        # @BeforeClass — once per suite
	func before_test() -> void:   # @Before — before each test
	func after_test() -> void:    # @After — after each test
	func after() -> void:         # @AfterClass — once per suite

All optional.

### Example

	extends GdUnitTestSuite

	var test_hand: Hand

	func before_test() -> void:
		test_hand = Hand.new()

	func test_init_hand_empty() -> void:
		assert_array(test_hand.cards).is_empty()

	func test_add_card() -> void:
		var test_card: Card = Card.new(Card.Suit.HEARTS, Card.Rank.TWO)
		test_hand.add_card(test_card)
		assert_array(test_hand.cards).has_size(1)
		assert_array(test_hand.cards).contains(test_card)

### Godot-specific things with no Java analog

- **Object lifecycle.** `Node`-derived objects need `auto_free()` or they leak.
  `RefCounted` classes clean themselves up. The run summary reports `0 orphans`
  when nothing leaked — that's the check.
- **`contains` compares by reference** for `RefCounted`. A fresh but identical
  object won't match. No automatic `equals`/`hashCode` equivalent.
- **Signals.** `await assert_signal(obj).is_emitted("card_dealt")`
- **`await` / frame timing.** Anything spanning frames needs awaiting. Common
  source of intermittent failures.

---

## 4. Verifying the CLI runner locally

This is the prerequisite for CI — the workflow runs this same command.

On Windows, use the **console** build (`Godot_v4.7.1-stable_win64_console.exe`).
The regular exe detaches from the console and you see no output.

	"C:\path\to\Godot_v4.7.1-stable_win64_console.exe" --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd -a test --ignoreHeadlessMode

`--ignoreHeadlessMode` is required. GdUnit4 refuses headless by default (exit
103) because `InputEvent`-based tests silently do nothing without a display
server. Pure logic tests are unaffected. If you later test UI by simulating
button presses, those need a real display server — `xvfb-run` on a Linux runner.

Check the exit code:

	echo %ERRORLEVEL%      REM cmd
	$LASTEXITCODE          # PowerShell

0 on pass. **Also verify non-zero on failure** — break an assertion and rerun. A
runner that reports failures but exits 0 gives you permanently green CI.

---

## 5. The workflow

`.github/workflows/tests.yaml` — path must be exactly `.github/workflows/`,
plural. Wrong path fails silently with nothing in the Actions tab.

```
	name: Tests

	on:
	  push:
		branches: [main]
	  pull_request:
		branches: [main]

	jobs:
	  test:
		runs-on: ubuntu-22.04
		timeout-minutes: 15
		permissions:
		  contents: read
		  checks: write
		  pull-requests: write
		steps:
		  - uses: actions/checkout@v4

		  - uses: MikeSchulze/gdUnit4-action@v1
			with:
			  godot-version: '4.7.1'
			  paths: 'res://test/'
			  timeout: 10
			  report-name: test-results
```

### Permissions

- `contents: read` — enough for tests to run and gate merges
- `checks: write` — results as annotations on the commit instead of buried in
  the log. Without it: `HttpError: Resource not accessible by integration`
- `pull-requests: write` — summary comment on PRs

`contents: write` is **not** needed and is the one that lets a workflow push
commits. The maintainer's example workflow grants it plus `actions: write` and
`statuses: write` — that's being permissive to avoid issue reports, not a
requirement.

Repo-level setting can override: Settings > Actions > General > Workflow
permissions.

### Worth adding

	concurrency:
	  group: ci-${{ github.ref }}
	  cancel-in-progress: true

Cancels superseded runs when you push twice quickly.

Pinning to an exact action version (`@v1.0.2`) instead of `@v1` means it can't
change under you. Worth it on a shared project.

---

## 6. Gitignore additions

    # gdUnit4 test reports
    reports/

    # gdUnit4 runner scratch state
    addons/gdUnit4/GdUnitRunner.cfg

`GdUnitRunner.cfg` is how the editor panel hands selected tests to the runner
process. Rewritten every run. It lives *inside* the committed addon directory,
so "commit addons/" isn't quite the whole rule.

If already tracked:

	git rm --cached addons/gdUnit4/GdUnitRunner.cfg

`--cached` untracks but leaves the file on disk.

---

## 7. Branch protection

Settings > Branches > Add branch ruleset.

- Target: **include default branch** (survives a rename; a literal `main`
  pattern would silently stop applying)
- Enable **Require status checks to pass**
- Select **`test`** — the job itself, not `test-results`

`test-results` is the check run the action creates for reporting. Gating on it
means a hiccup in the reporting step blocks a merge even when tests passed.

The check must have run at least once on the target branch for GitHub to offer
it in the search.

Optionally **Require a pull request before merging** — without it you can push
straight to main and the status check only reports after the fact.

---

## 8. Verify CI actually fails

Break an assertion, push, confirm red, revert:

	git revert HEAD --no-edit

Revert rather than editing back, so the break/fix pair stays in history as
evidence the pipeline was tested. A pipeline you've never seen fail is a
pipeline you don't know works.

---
