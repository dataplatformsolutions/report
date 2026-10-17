# Riff report action

Report a GitHub Actions result as a check on a Riff change. Use `if: always()` so failures still reach Riff.

```yaml
- if: always() && github.event.client_payload.change != 0
  uses: dataplatformsolutions/report@v1
  with:
    server: ${{ vars.RIFF_SERVER }}
    repo: ${{ github.event.client_payload.repo }}
    change: ${{ github.event.client_payload.change }}
    revision: ${{ github.event.client_payload.revision }}
    status: ${{ job.status }}
    name: ci/test
    summary: GitHub Actions ${{ job.status }}
    token: ${{ secrets.RIFF_TOKEN }}
```

The runner must have `riff` on `PATH`, or `riff-binary-url` can point to an executable to download. `cancelled` maps to a failed Riff check. Events without a change number (such as `riff-main`) are skipped. `url` defaults to the current Actions run.

Required inputs: `server`, `repo`, `revision`, and `status`. `change` can be omitted for ref events. `name` defaults to `ci/test`.
