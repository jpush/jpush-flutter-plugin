import dataPreferences from '@ohos.data.preferences';
import { JLog } from '../JLog';
import util from '@ohos.util';

export class FlutterBase {
  private TAG_U = 'FlutterBase';
  private pref: dataPreferences.Preferences;

  constructor(p_name: string, context: Context) {
    let options: dataPreferences.Options = { name: p_name }
    this.pref = dataPreferences.getPreferencesSync(context, options);
  }

  protected putString(key: string, value: string) {
    try {
      this.pref.putSync(key, value);
    } catch (err) {
      JLog.error(this.TAG_U, 'put the putString failed, err: key=' + key, err);
    }
    try {
      this.pref.flush();
    } catch (err) {
      JLog.error(this.TAG_U, 'put the flush putString failed, err: key=' + key, err);
    }
  }

  protected getString(key: string, defValue: string): string {
    try {
      return this.pref.getSync(key, defValue) as string
    } catch (e) {
      JLog.error(this.TAG_U, "gs fail", e)
      return defValue
    }
  }

  protected putNumber(key: string, value: number) {
    try {
      this.pref.putSync(key, value);
    } catch (err) {
      JLog.error(this.TAG_U, 'put the putNumber failed, err: key=' + key, err);
    }
    try {
      this.pref.flush();
    } catch (err) {
      JLog.error(this.TAG_U, 'put the flush putNumber failed, err: key=' + key, err);
    }
  }

  protected getNumber(key: string, defValue: number): number {
    try {
      return this.pref.getSync(key, defValue) as number
    } catch (e) {
      JLog.error(this.TAG_U, "gn fail", e)
      return defValue
    }
  }


  protected putBoolean(key: string, value: boolean) {
    try {
      this.pref.putSync(key, value);
    } catch (err) {
      JLog.error(this.TAG_U, 'put the putBoolean failed, err: key=' + key, err);
    }
    try {
      this.pref.flush();
    } catch (err) {
      JLog.error(this.TAG_U, 'put the flush putBoolean failed, err: key=' + key, err);
    }
  }

  protected getBoolean(key: string, defValue: boolean): boolean {
    try {
      return this.pref.getSync(key, defValue) as boolean
    } catch (e) {
      JLog.error(this.TAG_U, "gb fail", e)
      return defValue
    }
  }


  protected putUint8Array(key: string, value: Uint8Array) {
    try {
      this.pref.putSync(key, value);
    } catch (err) {
      JLog.error(this.TAG_U, 'put the putUint8Array failed, err: key=' + key, err);
    }
    try {
      this.pref.flush();
    } catch (err) {
      JLog.error(this.TAG_U, 'put the flush putUint8Array failed, err: key=' + key, err);
    }
  }

  protected getUint8Array(key: string, defValue: Uint8Array): Uint8Array {
    try {
      return this.pref.getSync(key, defValue) as Uint8Array
    } catch (e) {
      JLog.error(this.TAG_U, "gu8 fail", e)
      return defValue
    }
  }

  protected hasSync(key: string): boolean {
    try {
      return this.pref.hasSync(key)
    } catch (e) {
      JLog.error(this.TAG_U, "has fail", e)
      return false
    }
  }

  protected changeString(data: string): Uint8Array {
    return this.change(this.stringToUint8Array(data), 3000)
  }

  protected changeUint8Array(data: Uint8Array): string {
    return this.uint8ArrayToString(this.change(data, 3000))
  }

  protected stringToUint8Array(str: string): Uint8Array {
    let textEncoder: util.TextEncoder = new util.TextEncoder();
    let uint8Array: Uint8Array = textEncoder.encodeInto(str)
    return uint8Array;
  }

  protected uint8ArrayToString(u: Uint8Array): string {
    u = new Uint8Array(u)
    let textDecoder: util.TextDecoder = util.TextDecoder.create();
    let result: string = textDecoder.decodeWithStream(u);
    return result
  }


  protected change(data: Uint8Array, n?: number) {
    if (undefined === n) {
      return data
    }
    if (undefined === data) {
      return data
    }
    for (let index = 0; index < data.length; index++) {
      data[index] = (data[index] ^ n);
    }
    return data
  }
}