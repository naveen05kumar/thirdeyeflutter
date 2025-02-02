import 'package:get/get.dart';
import '../Services/api_service.dart';
import '../Services/shared_services.dart';
import '../model/stream_urls.dart';

class StreamUrlController extends GetxController {
  RxList<String> streamUrls = <String>[].obs;
  ApiService apiService = ApiService();

  @override
  void onInit() {
    getAllTheUrls();
    super.onInit();
  }

  getAllTheUrls() async {
    final loginDetails = UserSharedServices.loginDetails();
    if (loginDetails != null && loginDetails.streamUrls != null) {
      final allUrls = loginDetails.streamUrls!;
      streamUrls.addAll(allUrls.cast<String>());
      print("streamUrls: $streamUrls");
    } else {
      final staticUrlsResponse = await apiService.getStreamUrl("static");
      final ddnsUrlsResponse = await apiService.getStreamUrl("ddns");
      final staticUrls = (staticUrlsResponse.streamUrls ?? []).cast<String>();
      final ddnsUrls = (ddnsUrlsResponse.streamUrls ?? []).cast<String>();
      streamUrls.addAll(staticUrls);
      streamUrls.addAll(ddnsUrls);
      print("streamUrls: $streamUrls");
    }
  }
}
