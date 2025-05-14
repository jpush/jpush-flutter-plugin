import ArrayList from '@ohos.util.ArrayList';
import { HashMap } from '@kit.ArkTS';
import { MethodResult } from '@ohos/flutter_ohos';
import { JAliasMessage, JTagMessage } from '@jg/push';
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
