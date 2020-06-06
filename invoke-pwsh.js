import { which } from '@actions/io'
import { spawnSync } from 'child_process'
import { sep } from 'path';

async function run() {
    const pwsh = await which('pwsh', /*check:*/ true)
    // remove trailing 'dist' part of the path
    const folder = __dirname.replace(/[/\\]dist$/, '')
    const scriptPath = folder + sep + 'action.ps1'
    const result = spawnSync(pwsh, ['-f', scriptPath], {
        cwd: process.cwd(),
        stdio: 'inherit',
    })
    if (typeof result.status === 'number') {
        process.exitCode = result.status
    }
}
run()