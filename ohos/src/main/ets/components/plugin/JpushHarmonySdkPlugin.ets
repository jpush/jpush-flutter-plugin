import {
  CallBackMsg,
  JAliasMessage,
  JCmdMessage,
  JCustomMessage,
  JMessage,
  JMessageExtra,
  JMessageVoIP,
  JMobileNumberMessage,
  JPushInterface,
  JTagMessage
} from '@jg/push';
import {
  FlutterManager,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { JLog } from './JLog';
import { Ability, common, Want } from '@kit.AbilityKit';
import { ArrayList } from '@kit.ArkTS';
import { pushCommon, RemoteNotificationExtensionAbility } from '@kit.PushKit';
import { pushService } from '@kit.PushKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@ohos.base'
import { FlutterConfig } from './config/FlutterConfig';
import { JPushHelperAlias, JPushHelperConnected, JPushHelperRid, JPushHelperTag } from './JpushHelper';

/** JpushHarmonySdkPlugin **/
export default class JpushHarmonySdkPlugin implements FlutterPlugin, MethodCallHandler {
  private static plugin: JpushHarmonySdkPlugin | null = null;
  private channel: MethodChannel | null = null;
  private applicationContext: common.Context | null = null;
  private static TAG_STATIC: string = "JpushHarmonySdkPlugin"
  private TAG: string = JpushHarmonySdkPlugin.TAG_STATIC

  constructor() {
  }

  getUniqueClassName(): string {
    return "JpushHarmonySdkPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = binding.getApplicationContext()
    JPushInterfaceImp.setApplicationContext(this.applicationContext)
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "jpush");
    this.channel.setMethodCallHandler(this)
    JpushHarmonySdkPlugin.plugin = this;
    this.sendChannelCache()
    this.setCallBackMsg()
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  isCallBackMsg = false;

  setCallBackMsg() {
    if (this.isCallBackMsg) {
      return;
    }
    this.isCallBackMsg = true;
    JLog.info(this.TAG, "setCallBackMsg")
    JPushInterface.setCallBackMsg(new MyCallBackMsg())
  }

  private static sendListCache: ArrayList<SendChannelData> = new ArrayList<SendChannelData>();

  sendChannelCache() {
    // JpushHarmonySdkPlugin.sendListCache.forEach((v) => {
    //   JpushHarmonySdkPlugin.sendChannel(v.name, v.data)
    // })
    // JpushHarmonySdkPlugin.sendListCache.clear();
    while (!JpushHarmonySdkPlugin.sendListCache.isEmpty()) {
      let v = JpushHarmonySdkPlugin.sendListCache.removeByIndex(0);
      JpushHarmonySdkPlugin.sendChannel(v.name, v.data)
    }

  }

  static sendChannel(name: string, data: string | boolean | object) {
    if (null == JpushHarmonySdkPlugin.plugin) {
      let sData: SendChannelData = new SendChannelData(name, data);
      JpushHarmonySdkPlugin.sendListCache.add(sData)
      JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "sendChannel addCache:" + JSON.stringify(sData))
      return
    }
    JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "sendChannel:" + JpushHarmonySdkPlugin.plugin.channel)
    JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "sendChannel name:" + name)
    JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "sendChannel data:" + data)
    JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "sendChannel data string:" + JSON.stringify(data))
    JpushHarmonySdkPlugin.plugin.channel?.invokeMethod(name, data);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    JLog.info(this.TAG, "onMethodCall method:" + call.method)
    JLog.info(this.TAG, "onMethodCall args:" + call.args)
    JPushInterfaceImp.getInstance().onMethodCall(call, result);
  }

  // static wantListCache = new ArrayList<Want>()
  static isSetAppKey = false

  static setClickWant(want: Want, context: common.UIAbilityContext) {
    // FlutterManager.getInstance().getUIAbility().launchWant
    JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "setClickWant want:" + JSON.stringify(want))
    if (!JpushHarmonySdkPlugin.isSetAppKey) {
      JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "setClickWant app key false")
      let appkey = FlutterConfig.getInstance(context).getAppKey()
      if (undefined != appkey && "" != appkey && null != appkey && 0 != appkey.length) {
        JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, "setClickWant set:" + appkey)
        JPushInterface.setAppKey(appkey)
      }
    }
    JPushInterface.setClickWant(want)
  }

  // static sendClockWantCache() {
  //   while (!JpushHarmonySdkPlugin.wantListCache.isEmpty()) {
  //     let want = JpushHarmonySdkPlugin.wantListCache.removeByIndex(0)
  //     JpushHarmonySdkPlugin.setClickWant(want)
  //   }
  // }

  static async customMessageBackgroundData(data: pushCommon.PushPayload) {
    return await JPushInterface.customMessageBackgroundData(data)
  }

  static async extraMessageBackgroundData(data: pushCommon.PushPayload) {
    return await JPushInterface.extraMessageBackgroundData(data)
  }

  static async voIPMessageBackgroundData(data: pushCommon.PushPayload) {
    return await JPushInterface.voIPMessageBackgroundData(data)
  }

  static async receiveExtraDataMessage(rNEAbility: RemoteNotificationExtensionAbility,
    remoteNotificationInfo: pushCommon.RemoteNotificationInfo) {
    return await JPushInterface.receiveExtraDataMessage(rNEAbility, remoteNotificationInfo)
  }

  static receiveMessageAll(ability: Ability) {
    try { // receiveMessage中的参数固定为BACKGROUND-------后台自定义信息接收
      pushService.receiveMessage('BACKGROUND', ability, async (data: pushCommon.PushPayload) => {
        let jg = await JPushInterface.customMessageBackgroundData(data)
        JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, 'BACKGROUND jg:' + jg);
        if (jg) { //如果是true为已经处理
          return
        }
      });
    } catch (e) {
      JLog.error(JpushHarmonySdkPlugin.TAG_STATIC, 'BACKGROUND fail:' + JSON.stringify(e));
    }

    try { // receiveMessage中的参数固定为IM-------拓展通知接收
      pushService.receiveMessage('IM', ability, async (data) => {
        let jg = await JPushInterface.extraMessageBackgroundData(data)
        JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, 'IM jg:' + jg);
        if (jg) { //如果是true为已经处理
          return
        }
      });
    } catch (e) {
      JLog.error(JpushHarmonySdkPlugin.TAG_STATIC, 'IM fail:' + JSON.stringify(e));
    }

    try {
      pushService.receiveMessage('VoIP', ability, async (data) => {
        let jg = await JPushInterface.voIPMessageBackgroundData(data)
        JLog.info(JpushHarmonySdkPlugin.TAG_STATIC, 'VoIP jg:' + jg);
        if (jg) { //如果是true为已经处理
          return
        }
      });
    } catch (e) {
      JLog.error(JpushHarmonySdkPlugin.TAG_STATIC, 'VoIP fail:' + JSON.stringify(e));
    }
  }
}


class JPushInterfaceImp {
  TAG: string = "JPushInterfaceImp"
  private static instance: JPushInterfaceImp;
  private static applicationContext: common.Context;
  private static tagSequence = 1;
  private static aliasSequence = 1;

  public static getInstance(): JPushInterfaceImp {
    if (!JPushInterfaceImp.instance) {
      JPushInterfaceImp.instance = new JPushInterfaceImp();
    }
    return JPushInterfaceImp.instance;
  }

  static setApplicationContext(applicationContext: common.Context) {
    JPushInterfaceImp.applicationContext = applicationContext;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    JLog.info(this.TAG, "onMethodCall method:" + call.method)
    JLog.info(this.TAG, "onMethodCall args:" + call.args)
    if (call.method == "setDebug") {
      this.setDebug(call.args)
    } else if (call.method == "setAppKey") {
      this.setAppKey(call.args)
    } else if (call.method == "setChannel") {
      this.setChannel(call.args)
    } else if (call.method == "init") {
      this.requestEnableNotification()
      this.init(JPushInterfaceImp.applicationContext)
    } else if (call.method == "getRegistrationId") {
      this.getRegistrationId(result)
    } else if (call.method == "setTags") {
      this.setTags(call, result)
    } else if (call.method == "addTags") {
      this.addTags(call, result)
    } else if (call.method == "deleteTags") {
      this.deleteTags(call, result)
    } else if (call.method == "cleanTags") {
      this.cleanTags(call, result)
    } else if (call.method == "getTags") {
      this.getTags(call, result)
    } else if (call.method == "checkTagBindState") {
      this.checkTagBindState(call, result)
    } else if (call.method == "setAlias") {
      this.setAlias(call, result)
    } else if (call.method == "deleteAlias") {
      this.deleteAlias(call, result)
    } else if (call.method == "getAlias") {
      this.getAlias(call, result)
    } else if (call.method == "stopPush") {
      this.stopPush()
    } else if (call.method == "resumePush") {
      this.resumePush()
    } else if (call.method == "isPushStopped") {
      this.isPushStopped(result)
    } else if (call.method == "setBadgeNumber") {
      this.setBadgeNumber(call, result)
    } else if (call.method == "setHeartbeatTime") {
      this.setHeartbeatTime(call, result)
    } else {
      result.notImplemented()
    }
  }

  setDebug(b: boolean) {
    JLog.setLogDebug(b)
    JPushInterface.setDebug(b);
  }

  setAppKey(appKey: string) {
    JPushInterface.setAppKey(appKey)
    FlutterConfig.getInstance(JPushInterfaceImp.applicationContext).putAppKey(appKey)
    JpushHarmonySdkPlugin.isSetAppKey = true
    // JpushHarmonySdkPlugin.sendClockWantCache()
  }

  setChannel(channel: string) {
    JPushInterface.setChannel(channel)
  }

  requestEnableNotification() {
    try {
      notificationManager.requestEnableNotification(FlutterManager.getInstance().getUIAbility().context).then(() => {
        JLog.info(this.TAG, "requestEnableNotification success");
      }).catch((err: BusinessError) => {
        JLog.info(this.TAG, `requestEnableNotification failed,  ${err.code}, message is ${err.message}`);
      });
    } catch (e) {
      JLog.error(this.TAG, "requestEnableNotification failed", e);
    }
  }

  init(uiContext: common.Context) {
    let uIAbilityContext = FlutterManager.getInstance().getUIAbility()?.context
    if (undefined == uIAbilityContext) {
      uIAbilityContext = uiContext as common.UIAbilityContext
    }
    JPushInterface.init(uIAbilityContext)
  }

  getRegistrationId(result: MethodResult) {
    let rid: String = JPushInterface.getRegistrationId();
    if (undefined === rid || null === rid || rid === "") {
      JPushHelperRid.addRid(result);
      return
    }
    result.success(rid)
  }

  setTags(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.tagSequence++
    let tags: string[] = call.argument("tags")
    JLog.info(this.TAG, "setTags sequence:" + sequence)
    JLog.info(this.TAG, "setTags tags:" + tags)
    JLog.info(this.TAG, "setTags tags1:" + JSON.stringify(tags))
    JPushHelperTag.setTags(sequence, result);
    JPushInterface.setTags(sequence, tags)
  }

  addTags(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.tagSequence++
    let tags: string[] = call.argument("tags")
    JPushHelperTag.setTags(sequence, result);
    JPushInterface.addTags(sequence, tags)
  }

  deleteTags(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.tagSequence++
    let tags: string[] = call.argument("tags")
    JPushHelperTag.setTags(sequence, result);
    JPushInterface.deleteTags(sequence, tags)
  }

  cleanTags(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.tagSequence++
    JPushHelperTag.setTags(sequence, result);
    JPushInterface.cleanTags(sequence)
  }

  getTags(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.tagSequence++
    let curr: number = call.argument("curr")
    JPushHelperTag.setTags(sequence, result);
    JPushInterface.getTags(sequence, curr)
  }

  checkTagBindState(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.tagSequence++
    let tag: string = call.argument("tag")
    JPushHelperTag.setTags(sequence, result);
    JPushInterface.checkTagBindState(sequence, tag)
  }

  setAlias(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.aliasSequence++
    let alias: string = call.argument("alias")
    JPushHelperAlias.setAlias(sequence, result);
    JPushInterface.setAlias(sequence, alias)
  }

  deleteAlias(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.aliasSequence++
    JPushHelperAlias.setAlias(sequence, result);
    JPushInterface.deleteAlias(sequence)
  }

  getAlias(call: MethodCall, result: MethodResult) {
    let sequence: number = JPushInterfaceImp.aliasSequence++
    JPushHelperAlias.setAlias(sequence, result);
    JPushInterface.getAlias(sequence)
  }

  stopPush() {
    JPushInterface.stopPush()
  }

  resumePush() {
    JPushInterface.resumePush()
  }

  isPushStopped(result: MethodResult) {
    result.success(JPushInterface.isPushStopped())
  }

  setBadgeNumber(call: MethodCall, result: MethodResult) {
    let badgeNumber: number = call.args
    JPushInterface.setBadgeNumber(badgeNumber)
    result.success(true)
  }

  setHeartbeatTime(call: MethodCall, result: MethodResult) {
    let heartbeatTime: number = call.args
    JPushInterface.setHeartbeatTime(heartbeatTime)
    result.success(true)
  }
}

class MyCallBackMsg extends CallBackMsg {
  TAG: string = "MyCallBackMsg"

  constructor() {
    super();
  }

  /**
   * 注册成功后回调rid
   * @param registrationId 注册成功后回调rid
   */
  onRegister(registrationId: string): void {
    JLog.info(this.TAG, 'onRegister registrationId:' + registrationId);
    // JpushHarmonySdkPlugin.sendChannel("onRegister", registrationId);
    JPushHelperRid.callBackRid(registrationId)
  }

  /**
   * 长连接登陆 回调
   * @param isConnected true:成功，false：失败
   */
  onConnected(isConnected: boolean): void {
    JLog.info(this.TAG, 'onConnected isConnected:' + isConnected);
    JPushHelperConnected.callBackConnected(isConnected)
  }

  /**
   * 操作 tag 接口回调
   * @param jTagMessage
   * export class JTagMessage {
   * sequence?: number //对应操作id，全局不要重复
   * code?: number //0成功，JTagMessage.CODE_TIME_OUT超时
   * op?: string
   * tags?: string[] //对应数据
   * curr?: number //数据当前页数，页数从1开始
   * total?: number //数据总页数
   * msg?: string
   * }
   */
  onTagOperatorResult(jTagMessage: JTagMessage): void {
    JLog.info(this.TAG, 'onTagOperatorResult JTagMessage:' + JSON.stringify(jTagMessage));
    // JpushHarmonySdkPlugin.sendChannel("onTagOperatorResult", jTagMessage);
    JPushHelperTag.callBackTag(jTagMessage);
  }

  /**
   * 操作 Alias 接口回调
   * @param jAliasMessage
   * export class JAliasMessage {
   * sequence?: number //对应操作id，全局不要重复
   * code?: number //0成功，JAliasMessage.CODE_TIME_OUT超时
   * op?: string
   * alias?: string //对应数据
   * curr?: number
   * total?: number
   * msg?: string
   * }
   */
  onAliasOperatorResult(jAliasMessage: JAliasMessage): void {
    JLog.info(this.TAG, 'onAliasOperatorResult jAliasMessage:' + JSON.stringify(jAliasMessage));
    // JpushHarmonySdkPlugin.sendChannel("onAliasOperatorResult", jAliasMessage);
    JPushHelperAlias.callBackAlias(jAliasMessage);
  }

  /**
   * 通知点击事件回调
   * @param jMessage
   *
   * export class JMessage {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: string//自定义数据
   * }
   */
  onClickMessage(jMessage: JMessage) {
    JLog.info(this.TAG, 'onClickMessage jMessage:' + JSON.stringify(jMessage));
    JpushHarmonySdkPlugin.sendChannel("onClickMessage", jMessage);
  }

  /**
   * 自定义信息通知回调
   *  回调一：冷启动调用sdk初始化后回调之前还没有回调的信息
   *  回调二：app存活时会直接回调信息
   * @param jCustomMessage
   *
   * export class JCustomMessage {
   *  msgId?: string //通知id
   *  title?: string //通知标题
   *  content?: string //通知内容
   *  contentType?: string //通知内容类型
   *  extras?: Record<string, Object> //通知自定义键值对
   *  ttl?: number //后台下发的信息过期时间，单位秒
   *  stime?: number //后台下发时间，毫秒
   * }
   */
  onCustomMessage(jCustomMessage: JCustomMessage) {
    JLog.info(this.TAG, 'onCustomMessage jCustomMessage:' + JSON.stringify(jCustomMessage));
    JpushHarmonySdkPlugin.sendChannel("onCustomMessage", jCustomMessage);
  }

  /**
   * 通知扩展消息回调
   * @param jMessageExtra
   *
   * export class JMessageExtra {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: Record<string, Object>//自定义数据
   * extraData?: string//通知扩展消息的自定义数据
   * }
   */
  onJMessageExtra(jme: JMessageExtra) {
    JLog.info(this.TAG, 'onJMessageExtra jme:' + JSON.stringify(jme));
    JpushHarmonySdkPlugin.sendChannel("onJMessageExtra", jme);
  }

  /**
   * VoIP呼叫消息回调
   * export class JMessageVoIP {
   * msgId?: string //通知id
   * extraData?: string //VoIP自定义数据
   }
   * @param jmVoIP
   */
  onJMessageVoIP(jmVoIP: JMessageVoIP) {
    JLog.info(this.TAG, 'JMessageVoIP jmVoIP:' + JSON.stringify(jmVoIP));
    JpushHarmonySdkPlugin.sendChannel("onJMessageVoIP", jmVoIP);
  }

  /**
   * 交互事件回调
   * @param cmdMessage
   * export class JCmdMessage {
   * public static CMD_PUSH_STOP = 2007 //通知停止 设置回调
   * public static CMD_PUSH_RESUME = 2006 //  通知恢复 设置回调
   *
   * cmd?: number  //操作事件，2007通知停止，2006恢复通知
   * errorCode?: number //0表示成功，其他为错误
   * msg?: string //内容信息
   * extra?: Record<string, Object>
   * }
   */
  onCommandResult(cmdMessage: JCmdMessage) {
    JLog.info(this.TAG, 'onCommandResult cmdMessage:' + JSON.stringify(cmdMessage));
    JpushHarmonySdkPlugin.sendChannel("onCommandResult", cmdMessage);
  }

  /**
   * 消息到达回调
   * @param jMessage
   * export class JMessage {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: string//自定义数据
   * }
   */
  onArrivedMessage(jMessage: JMessage) {
    JLog.info(this.TAG, 'onArrivedMessage jMessage:' + JSON.stringify(jMessage));
    JpushHarmonySdkPlugin.sendChannel("onArrivedMessage", jMessage);
  }

  /**
   * 消息未显示回调
   * @param jMessage
   * export class JMessage {
   * msgId?: string //通知id
   * title?: string //通知标题
   * content?: string//通知内容
   * extras?: string//自定义数据
   * }
   */
  onUnShowMessage(jMessage: JMessage) {
    JLog.info(this.TAG, 'onUnShowMessage jMessage:' + JSON.stringify(jMessage));
    JpushHarmonySdkPlugin.sendChannel("onUnShowMessage", jMessage);
  }

}

class SendChannelData {
  name: string
  data: string | boolean | object

  constructor(name: string, data: string | boolean | object) {
    this.name = name;
    this.data = data;
  }
}

