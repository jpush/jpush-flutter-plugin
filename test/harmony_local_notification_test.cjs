// 运行真实 ETS 入口与方法；仅 SDK 边界使用替身，不复制序列化实现。
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const ts = require(process.env.TYPESCRIPT_PATH || 'typescript');

const filename = path.join(__dirname,
  '../ohos/src/main/ets/components/plugin/JpushHarmonySdkPlugin.ets');
const source = fs.readFileSync(filename, 'utf8');

function loadBridge(text) {
  const file = ts.createSourceFile(filename, text, ts.ScriptTarget.ES2020, true);
  const owner = file.statements.find(node =>
    ts.isClassDeclaration(node) && node.name?.text === 'JPushInterfaceImp');
  assert.ok(owner, '生产桥接类必须存在');
  const names = ['onMethodCall', 'sendLocalNotification'];
  const methods = names.map(name => {
    const node = owner.members.find(member =>
      ts.isMethodDeclaration(member) && member.name.getText(file) === name);
    assert.ok(node, `生产方法必须存在：${name}`);
    return node.getText(file);
  });
  const result = ts.transpileModule(`class Bridge { ${methods.join('\n')} }`, {
    compilerOptions: { target: ts.ScriptTarget.ES2020 },
    reportDiagnostics: true,
  });
  assert.equal((result.diagnostics || []).filter(d =>
    d.category === ts.DiagnosticCategory.Error).length, 0);
  const submitted = [];
  class LocalNotification {
    extras = 'sdk-default';
    setBroadcastTimeByMs(time) { this.broadcastTime = time; }
  }
  const bridge = new Function('JPushLocalNotification', 'JPushInterface', 'JLog',
    `${result.outputText}; return new Bridge();`)(LocalNotification,
      { addLocalNotification: notification => submitted.push(notification) },
      { info() {} });
  return { bridge, submitted };
}

function verify(text) {
  const { bridge, submitted } = loadBridge(text);
  const cases = [
    ['原始问题', new Map([['fa', '0']]), { fa: '0' }],
    ['多键中文', new Map([['城市', '重庆'], ['emoji', '旅途🚄']]),
      { 城市: '重庆', emoji: '旅途🚄' }],
    ['转义字符', new Map([['"\\\n', '\t\r\n"\\\u0000']]),
      { '"\\\n': '\t\r\n"\\\u0000' }],
    ['特殊键', new Map([['__proto__', 'value'], ['constructor', 'ctor'], ['', '']]),
      JSON.parse('{"__proto__":"value","constructor":"ctor","":""}')],
    ['空 Map', new Map(), {}],
    ['普通对象', { fa: '0', city: '重庆' }, { fa: '0', city: '重庆' }],
    ['空对象', {}, {}],
    ['null', null, null],
    ['undefined', undefined, null],
  ];
  for (const [name, extra, expected] of cases) {
    const args = new Map([
      ['id', 234], ['title', '标题'], ['content', '正文'], ['fireTime', 123456789],
    ]);
    if (extra !== undefined) args.set('extra', extra);
    const successes = [];
    const before = submitted.length;
    bridge.onMethodCall({ method: 'sendLocalNotification', args,
      argument: key => args.get(key) }, { success: value => successes.push(value) });
    assert.equal(submitted.length, before + 1, `${name}: 单次提交`);
    const notification = submitted.at(-1);
    if (expected === null) {
      assert.equal(notification.extras, 'sdk-default', `${name}: 保留 SDK 默认值`);
    } else {
      assert.equal(typeof notification.extras, 'string');
      assert.deepEqual(JSON.parse(notification.extras), expected, name);
    }
    assert.equal(notification.notificationId, 234);
    assert.equal(notification.title, '标题');
    assert.equal(notification.content, '正文');
    assert.equal(notification.broadcastTime, 123456789);
    assert.deepEqual(successes, [true]);
  }
  return cases.length;
}

assert.equal(verify(source), 9);
console.log('PASS: 9 输入场景，实际分发入口 → SDK 入参及成功返回');

// 仅构造内存中的代表错误，不改工作树；证明测试能拒绝旧缺陷和错误接线。
function rejectMutation(label, from, to) {
  assert.ok(source.includes(from), `${label}: 变异目标存在`);
  assert.throws(() => verify(source.replace(from, to)), undefined, label);
  console.log(`PASS: 拒绝代表错误 ${label}`);
}
rejectMutation('旧 Map 空对象缺陷', "ln.extras = '{' + entries.join(',') + '}'",
  'ln.extras = JSON.stringify(extra)');
rejectMutation('取错参数', 'call.argument("extra")', 'call.argument("extras")');
rejectMutation('绕过发送', 'this.sendLocalNotification(call, result)', 'result.success(true)');
rejectMutation('覆盖序列化结果', 'JPushInterface.addLocalNotification(ln)',
  'ln.extras = "{}"; JPushInterface.addLocalNotification(ln)');

const parsed = ts.createSourceFile(filename, source, ts.ScriptTarget.ES2020, true);
const reformatted = ts.createPrinter({ newLine: ts.NewLineKind.CarriageReturnLineFeed })
  .printFile(parsed);
assert.equal(verify(reformatted), 9);
console.log('PASS: TypeScript AST 重排版后语义验证仍通过');
