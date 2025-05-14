import hilog from '@ohos.hilog';
import ArrayList from '@ohos.util.ArrayList';

export class JLog {
  private static TAG: string = "JPUSH-Harmony-Flutter"
  private static isDebug: boolean = true;
  private static domain: number = 0x0000;

  static setLogDebug(d: boolean): void {
    hilog.warn(JLog.domain, JLog.getTag("JLog"), 'setLogDebug:%{public}s', d)
    JLog.isDebug = d;
  }

  private static getMsgArrays(msg: string): string[] {
    if (msg && msg.length > 3000) {
      let list = new ArrayList<string>();

      while (msg.length > 3000) {
        list.add(msg.substring(0, 3000))
        msg = msg.substring(3000, msg.length)
      }
      if (msg.length > 0) {
        list.add(msg)
      }
      return list.convertToArray()
    } else {
      return [msg]
    }
  }

  static info(tag: string, msg: string): void {
    let list = JLog.getMsgArrays(msg)
    for (let i = 0; i < list.length; i++) {
      JLog.infoFormat(tag, '%{public}s', list[i])
    }
  }

  static infoFormat(tag: string, format: string, ...args: string[]): void {
    if (!JLog.isDebug) {
      return;
    }
    hilog.info(JLog.domain, JLog.getTag(tag), format, ...args)
  }

  static warn(tag: string, msg: string): void {
    let list = JLog.getMsgArrays(msg)
    for (let i = 0; i < list.length; i++) {
      JLog.warnFormat(tag, '%{public}s', list[i])
    }
  }

  static warnFormat(tag: string, format: string, ...args: string[]): void {
    if (!JLog.isDebug) {
      return;
    }
    hilog.warn(JLog.domain, JLog.getTag(tag), format, ...args)
  }

  static error(tag: string, msg: string, error?: Error): void {

    let list = JLog.getMsgArrays(msg)
    for (let i = 0; i < list.length; i++) {
      if (error) {
        hilog.error(JLog.domain, JLog.getTag(tag), '%{public}s, {error.name:%{public}s, error.message:%{public}s} ,\n json:%{public}s} ', msg, error.name, error.message, JSON.stringify(error))
      } else {
        hilog.error(JLog.domain, JLog.getTag(tag), '%{public}s', msg)
      }
      if (!JLog.isDebug) {
        return;
      }
      if (error) {
        if (error.stack) {
          hilog.error(JLog.domain, JLog.getTag(tag), '%{public}s', error.stack)
        }
      }
    }

  }

  private static getTag(tag: string): string {
    return "[" + JLog.TAG + tag + "]";
  }

  // private static getMsg(msg:string):string[]{
  //   if (condition) {
  //
  //   }
  //   let msgs
  // }
}
