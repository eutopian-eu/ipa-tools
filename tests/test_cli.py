from click.testing import CliRunner

from iPA.scripts.cli import cli


def test_cli_x():
    runner = CliRunner()
    result = runner.invoke(cli, ['3'])
    assert result.exit_code == 0
    assert result.output == "False\nFalse\nFalse\n"
