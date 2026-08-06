import { pushCommon, RemoteNotificationExtensionAbility } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import JpushHarmonySdkPlugin from 'jpush_google_ohos_flutter';

const TAG: string = 'JPUSH-JLog-RemoteNotificationExtAbility'

export default class RemoteNotificationExtAbility extends RemoteNotificationExtensionAbility {
  async onReceiveMessage(remoteNotificationInfo: pushCommon.RemoteNotificationInfo): Promise<pushCommon.RemoteNotificationContent> {
    hilog.info(0x0000, TAG, 'onReceiveMessage, remoteNotificationInfo: %{public}s',
      JSON.stringify(remoteNotificationInfo));

    let jMessageExtra = await JpushHarmonySdkPlugin.receiveExtraDataMessage(this,remoteNotificationInfo);
    hilog.info(0x0000, TAG, 'onReceiveMessage jMessageExtra:' + JSON.stringify(jMessageExtra));
    // Return the replaced message content.
    return {} //如果要修改通知可以反回有数据通知
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'RemoteNotificationExtAbility onDestroy.');
  }
}
