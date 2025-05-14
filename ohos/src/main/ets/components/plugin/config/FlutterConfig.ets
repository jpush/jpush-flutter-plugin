import { FlutterBase } from './FlutterBase';

export class FlutterConfig extends FlutterBase {
  private static PREFERENCES_NAME = 'jg_flutter_pc';
  private static instance: FlutterConfig;

  constructor(context: Context) {
    super(FlutterConfig.PREFERENCES_NAME, context)
  }

  public static getInstance(context: Context): FlutterConfig {
    if (!FlutterConfig.instance) {
      FlutterConfig.instance = new FlutterConfig(context);
    }
    return FlutterConfig.instance;
  }


  private static KEY_APP_KEY: string = "k_a_k"

  putAppKey(t: string) {
    super.putUint8Array(FlutterConfig.KEY_APP_KEY, super.changeString(t))
  }

  getAppKey(): string {
    let r = super.getUint8Array(FlutterConfig.KEY_APP_KEY, new Uint8Array());
    if (undefined == r) {
      return "";
    }
    if (r.length <= 0) {
      return "";
    }
    return super.changeUint8Array(r)
  }
}
