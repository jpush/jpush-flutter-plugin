import ArrayList from '@ohos.util.ArrayList';
import { HashMap } from '@kit.ArkTS';
import { MethodResult } from '@ohos/flutter_ohos';
import { JAliasMessage, JCmdMessage, JTagMessage } from '@jg/push';
import JpushHarmonySdkPlugin from './JpushHarmonySdkPlugin';


export class JPushHelperConnected {
  static callBackConnected(isConnected: boolean) {
    // JpushHarmonySdkPlugin.sendChannel("onConnected", JPushHelperConnected.getMap(isConnected));
    JpushHarmonySdkPlugin.sendChannel("onConnected", isConnected);
  }

  static getMap(isConnected: boolean): HashMap<string, object> {
    let map = new HashMap<string, Object>();
    map.set('result',isConnected)
    return map;
  }
}

export class JPushHelperRid {
  private static TAG: string = "JPushHelperRid"
  private static ridList: ArrayList<MethodResult> = new ArrayList();

  static addRid(result: MethodResult) {
    JPushHelperRid.ridList.add(result);
  }

  static callBackRid(rid: string) {
    while (!JPushHelperRid.ridList.isEmpty()) {
      let result = JPushHelperRid.ridList.removeByIndex(0);
      if (undefined !== result) {
        result.success(rid)
      }
    }
  }
}

export class JPushHelperPushStatus {
  private static TAG: string = "JPushHelperPushStatus"
  private static pushStatusList: ArrayList<MethodResult> = new ArrayList();

  static addPushStatus(result: MethodResult) {
    JPushHelperPushStatus.pushStatusList.add(result);
  }

  /**
   * getPushStatus 的结果经 onCommandResult 回调（cmd 2006 恢复 / 2007 停止）。
   * 有挂起查询且 cmd 匹配时消费并返回 true，否则返回 false 由调用方继续透传。
   * 回包格式与 Android/iOS 保持一致：{code, isStopped}
   */
  static callBackPushStatus(cmdMessage: JCmdMessage): boolean {
    if (JPushHelperPushStatus.pushStatusList.isEmpty()) {
      return false;
    }
    if (cmdMessage.cmd !== JCmdMessage.CMD_PUSH_STOP && cmdMessage.cmd !== JCmdMessage.CMD_PUSH_RESUME) {
      return false;
    }
    let code = 0;
    if (cmdMessage.errorCode !== undefined && cmdMessage.errorCode !== 0) {
      code = cmdMessage.errorCode;
    }
    let isStopped = cmdMessage.cmd === JCmdMessage.CMD_PUSH_STOP;
    while (!JPushHelperPushStatus.pushStatusList.isEmpty()) {
      let result = JPushHelperPushStatus.pushStatusList.removeByIndex(0);
      if (undefined !== result) {
        let map = new HashMap<string, Object>();
        map.set('code', code);
        map.set('isStopped', isStopped);
        result.success(map);
      }
    }
    return true;
  }
}

export class JPushHelperAlias {
  private static TAG: string = "JPushHelperAlias"
  private static aliasCache: HashMap<number, MethodResult> = new HashMap();

  static setAlias(sequence: number, result: MethodResult): void {
    JPushHelperAlias.aliasCache.set(sequence, result);
  }

  static callBackAlias(jAliasMessage: JAliasMessage) {
    let result = JPushHelperAlias.aliasCache.remove(jAliasMessage.sequence)
    if (undefined !== result) {
      if (jAliasMessage.code === 0) {
        let map = JPushHelperAlias.getAliasMessageMap(jAliasMessage)
        result.success(map)
      } else {
        result.error(jAliasMessage.code + "", "", "")
      }
    }
  }

  static getAliasMessageMap(jAliasMessage: JAliasMessage): HashMap<string, object> {
    let map = new HashMap<string, Object>();
    if (jAliasMessage.sequence !== undefined) {
      map.set('sequence', jAliasMessage.sequence);
    }
    if (jAliasMessage.code !== undefined) {
      map.set('code', jAliasMessage.code);
    }
    if (jAliasMessage.op !== undefined) {
      map.set('op', jAliasMessage.op);
    }
    if (jAliasMessage.alias !== undefined) {
      map.set('alias', jAliasMessage.alias);
    }
    if (jAliasMessage.curr !== undefined) {
      map.set('curr', jAliasMessage.curr);
    }
    if (jAliasMessage.total !== undefined) {
      map.set('total', jAliasMessage.total);
    }
    if (jAliasMessage.msg !== undefined) {
      map.set('msg', jAliasMessage.msg);
    }
    return map;
  }
}

export class JPushHelperTag {
  private static TAG: string = "JPushHelperTag"
  private static tagCache: HashMap<number, MethodResult> = new HashMap();

  static setTags(sequence: number, result: MethodResult): void {
    JPushHelperTag.tagCache.set(sequence, result);
  }

  static callBackTag(jTagMessage: JTagMessage) {
    let result = JPushHelperTag.tagCache.remove(jTagMessage.sequence)
    if (undefined !== result) {
      if (jTagMessage.code === 0) {
        let map = JPushHelperTag.getJTagMessageMap(jTagMessage)
        result.success(map)
      } else {
        result.error(jTagMessage.code + "", "", "")
      }
    }
  }

  static getJTagMessageMap(jTagMessage: JTagMessage): HashMap<string, object> {
    let map = new HashMap<string, Object>();
    if (jTagMessage.sequence !== undefined) {
      map.set('sequence', jTagMessage.sequence);
    }
    if (jTagMessage.code !== undefined) {
      map.set('code', jTagMessage.code);
    }
    if (jTagMessage.op !== undefined) {
      map.set('op', jTagMessage.op);
    }
    if (jTagMessage.tags !== undefined) {
      map.set('tags', jTagMessage.tags);
    }
    if (jTagMessage.curr !== undefined) {
      map.set('curr', jTagMessage.curr);
    }
    if (jTagMessage.total !== undefined) {
      map.set('total', jTagMessage.total);
    }
    if (jTagMessage.msg !== undefined) {
      map.set('msg', jTagMessage.msg);
    }
    if (jTagMessage.validated !== undefined) {
      map.set('validated', jTagMessage.validated);
    }
    return map;
  }
}
