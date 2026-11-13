"""Check renderer failures without writing generated agent files."""

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
HARNESSES = ("claude", "codex", "pi")


class RendererTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        source = (ROOT / "scripts/build-agents.sh").read_text(encoding="utf-8")
        # Load only the renderer functions, never the file-writing main loop.
        cls.renderers = source[
            source.index("render_body() {") : source.index("\nstatus=0")
        ]

    def render(self, harness: str, failed_source: Path | None = None):
        probe = "\n".join(
            [
                "set -euo pipefail",
                "root=$1; h=$2; failed_source=$3",
                self.renderers,
                """
cat() {
  if [[ "$1" == "$failed_source" ]]; then
    printf 'injected source read failure: %s\n' "$1" >&2
    return 73
  fi
  command cat "$@"
}
rendered="$(render "$h" researcher)" || exit "$?"
printf '%s\n' "$rendered"
""",
            ]
        )
        return subprocess.run(
            [
                "bash",
                "-c",
                probe,
                "renderer-test",
                str(ROOT),
                harness,
                str(failed_source) if failed_source is not None else "",
            ],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,  # Failure is the expected result of fault injection.
        )

    def test_successful_render_matches_generated_agent(self) -> None:
        for harness in HARNESSES:
            with self.subTest(harness=harness):
                if harness == "claude":
                    output = ROOT / "agents/researcher.md"
                elif harness == "codex":
                    output = ROOT / "harness/codex/agents/devproc_researcher.toml"
                else:
                    output = ROOT / "harness/pi/agents/researcher.md"
                result = self.render(harness)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, output.read_text(encoding="utf-8"))

    def test_source_read_failures_abort_render(self) -> None:
        for harness in HARNESSES:
            extension = "toml" if harness == "codex" else "yaml"
            sources = (
                ROOT / "roles/researcher.md",
                ROOT / "roles/_shared.md",
                ROOT / f"harness/{harness}/notes/_all.md",
                ROOT / f"harness/{harness}/notes/researcher.md",
                ROOT / f"harness/{harness}/frontmatter/researcher.{extension}",
            )
            for source in sources:
                with self.subTest(harness=harness, source=source):
                    self.assertTrue(source.is_file(), f"missing test input: {source}")
                    result = self.render(harness, failed_source=source)
                    self.assertIn("injected source read failure", result.stderr)
                    self.assertNotEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
