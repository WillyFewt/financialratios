import 'package:catcher/core/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/mode/dialog_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:financialratios/app.dart';
import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:provider/provider.dart';

import 'package:financialratios/app_model.dart';

void main() {
  CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler()]);

  Catcher(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppModel>(builder: (_) => AppModel()),
          ChangeNotifierProvider<DashboardModel>(
              builder: (_) => DashboardModel()),
        ],
        child: App(),
      ),
      debugConfig: debugOptions,
      releaseConfig: debugOptions);
}
