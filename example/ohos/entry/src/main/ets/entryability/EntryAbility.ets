/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import JpushHarmonySdkPlugin from 'jpush_flutter';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'JPUSH-flutter-JLog-EntryAbility'

export default class EntryAbility extends FlutterAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onCreate :' + JSON.stringify(want));
    JpushHarmonySdkPlugin.setClickWant(want, this.context)
    // 如需由开发者自己申请通知权限，可在此处（或 AbilityStage#onCreate）提前调用，需在 init 之前
    // JpushHarmonySdkPlugin.setUserRequestNotificationPermission(this.context, true)
    super.onCreate(want, launchParam)
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'onNewWant :' + JSON.stringify(want));
    JpushHarmonySdkPlugin.setClickWant(want, this.context)
    super.onNewWant(want, launchParams)
  }

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    hilog.info(0x0000, TAG, 'configureFlutterEngine');
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }
}
