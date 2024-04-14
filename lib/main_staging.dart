import 'package:myrik_intern_task/app/app.dart';
import 'package:myrik_intern_task/bootstrap.dart';

/// This entry point should be used for staging only
void main() {
  ///You can override your environment variable in bootstrap method here for providers
  bootstrap(() => const App());
}
