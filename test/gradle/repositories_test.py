#!/usr/bin/env python3
"""Exercise the actual repository script with fresh Gradle caches, not text mocks."""
import argparse
import http.server
import json
import os
from pathlib import Path
import subprocess
import threading

SOURCE = 'https://maven.jiguang.cn/nexus/content/repositories/releases/'
SCRIPT = Path(__file__).resolve().parents[2] / 'android/repositories.gradle'
HASHES = {
    'jpush-google': 'c340a61ff9a09f66a466545f6b9c0621f63e30197659facdfa1d78c5ae8880a1',
    'jcore-google': 'bd74c6245518b24edf83e2da90bab7391369d7a4da208d0e62422a7ccecd3f4a',
}
REPOSITORIES = """
repositories {
    maven {
        name = 'JiguangReleases'
        url = uri('%s')
        content {
            includeModule('cn.jiguang.sdk', 'jpush-google')
            includeModule('cn.jiguang.sdk', 'jcore-google')
        }
        mavenContent { releasesOnly() }
    }
    google()
    mavenCentral()
}
""" % SOURCE
VERIFY = """
configurations { sdk }
dependencies {
    sdk('cn.jiguang.sdk:jpush-google:6.3.1') { version { strictly '6.3.1' } }
    sdk('cn.jiguang.sdk:jcore-google:5.6.0') { version { strictly '5.6.0' } }
    sdk 'junit:junit:4.13.2'
}
tasks.register('verifySdk') {
    doLast {
        configurations.sdk.resolvedConfiguration.resolvedArtifacts.each { artifact ->
            if (artifact.moduleVersion.id.group == 'cn.jiguang.sdk') {
                def hash = java.security.MessageDigest.getInstance('SHA-256')
                    .digest(artifact.file.bytes).encodeHex().toString()
                println 'VERIFIED_SDK ' + artifact.moduleVersion.id + ' ' + hash
            }
        }
        println 'REPOSITORIES ' + repositories.collect { it.name }.join(',')
        assert rootProject.repositories.isEmpty(): 'Plugin injected repositories into root'
        assert project(':sibling').repositories.isEmpty(): 'Plugin injected repositories into sibling'
    }
}
"""


def run_case(args, name, mode, *, missing=False, override=None, failure=False):
    case = args.work_dir / name
    case.mkdir(parents=True, exist_ok=False)
    (case / 'plugin').mkdir()
    (case / 'sibling').mkdir()
    settings = "rootProject.name = 'jpush-repositories-test'\ninclude ':plugin', ':sibling'\n"
    if mode:
        settings += 'dependencyResolutionManagement {\nrepositoriesMode.set(RepositoriesMode.' + mode + ')\n'
        if not missing:
            settings += REPOSITORIES
        settings += '}\n'
    (case / 'settings.gradle').write_text(settings)
    build = ""
    if not mode or mode == 'PREFER_PROJECT':
        # Verify prioritization even when the host seeded this project with Central.
        build += 'repositories { mavenCentral() }\n'
        if not override:
            build += REPOSITORIES  # Host already followed README; source can coexist.
    build += 'apply from: ' + json.dumps(str(SCRIPT)) + '\n'
    if override:
        build += "def sdkRepo = repositories.find { it.url.toString() == " + json.dumps(SOURCE) + " }\n"
        build += "sdkRepo.url = uri(" + json.dumps(override) + ")\n"
        build += 'sdkRepo.allowInsecureProtocol = true\n'
    if not mode or mode == 'PREFER_PROJECT':
        build += "assert repositories.first().url.toString() == " + json.dumps(override or SOURCE) + "\n"
    else:
        build += "assert repositories.isEmpty(): 'Settings-managed mode declared project repositories'\n"
    build += VERIFY
    (case / 'plugin/build.gradle').write_text(build)
    env = os.environ.copy()
    env['GRADLE_USER_HOME'] = str(case / 'gradle-user-home')
    command = [args.gradle, '--no-daemon', '--console=plain', '--info', ':plugin:verifySdk']
    result = subprocess.run(command, cwd=case, env=env, capture_output=True, text=True, timeout=240)
    output = result.stdout + result.stderr
    (case / 'build.log').write_text(output)
    if failure:
        assert result.returncode != 0, name + ': expected dependency resolution failure'
        assert 'VERIFIED_SDK' not in output
        print(name + ': expected failure verified', flush=True)
        return
    assert result.returncode == 0, name + ': ' + output[-3500:]
    for module, digest in HASHES.items():
        assert digest in output, name + ': unexpected artifact ' + module
    if not override:
        assert SOURCE + 'cn/jiguang/sdk/jpush-google/6.3.1/' in output, name + ': source unproven'
        assert SOURCE + 'cn/jiguang/sdk/jcore-google/5.6.0/' in output, name + ': source unproven'
    assert SOURCE + 'junit/' not in output, name + ': unrelated dependency queried in SDK repository'
    print(name + ': passed (fresh cache, SDK hashes and project isolation)', flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gradle', required=True)
    parser.add_argument('--work-dir', type=Path, required=True)
    args = parser.parse_args()
    args.gradle = str(Path(args.gradle).resolve())
    args.work_dir = args.work_dir.resolve()
    args.work_dir.mkdir(parents=True, exist_ok=True)
    for mode in ['PREFER_PROJECT', 'PREFER_SETTINGS', 'FAIL_ON_PROJECT_REPOS']:
        run_case(args, mode.lower(), mode)
    run_case(args, 'missing-settings-source', 'FAIL_ON_PROJECT_REPOS', missing=True, failure=True)

    requests = []
    class Handler(http.server.BaseHTTPRequestHandler):
        status = 404
        def do_GET(self):
            requests.append(self.path)
            self.send_response(self.status)
            self.end_headers()
        def do_HEAD(self):
            self.do_GET()
        def log_message(self, *unused):
            pass
    server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        url = 'http://127.0.0.1:' + str(server.server_port) + '/'
        run_case(args, 'missing-module-central-candidate', 'PREFER_PROJECT', override=url)
        assert requests and all('/cn/jiguang/sdk/' in path for path in requests), requests
        requests.clear()
        Handler.status = 500
        run_case(args, 'source-server-error', 'PREFER_PROJECT', override=url, failure=True)
        assert requests and all('/cn/jiguang/sdk/' in path for path in requests), requests
    finally:
        server.shutdown()
    print('All repository mode, filtering, missing-module and server-error checks passed')


if __name__ == '__main__':
    main()
